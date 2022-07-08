---
title: ConcurrentLinkedQueue 源码解析
date: 2020-06-15 10:55:02
tags: ["java","concurrent","LinkedQueue"]
toc: true
---

我们常用的线程安全的队列主要有BlockingLinkedQueue 、 ConcurrentLinkedQueue, 它俩的主要区别是一个使用了锁 ，一个基于CAS + volatile 实现的无锁队列，本篇我们主要分析ConcurrentLinedQueue的实现原理。


## Node 节点

队列的节点数据结构，原子性的修改主要使用UNSAFE 来通过内存偏移地址操作元素，详细请搜索 ``UNSAFE`` 的使用
```java
private static class Node<E> {
        volatile E item;   
        volatile Node<E> next;   
  
        Node(E item) {
          UNSAFE.putObject(this, itemOffset, item);
        }
        
        boolean casItem(E cmp, E val) {

        //通过内存偏移地址修改变量值
        return UNSAFE.compareAndSwapObject(this, itemOffset, cmp, val);
        }
        boolean casNext(Node<E> cmp, Node<E> val) {
            return UNSAFE.compareAndSwapObject(this, nextOffset, cmp, val);
        }

        private static final sun.misc.Unsafe UNSAFE;
        private static final long itemOffset;
        private static final long nextOffset;

        static {
            try {
                UNSAFE = sun.misc.Unsafe.getUnsafe();
                Class<?> k = Node.class;
                itemOffset = UNSAFE.objectFieldOffset
                    (k.getDeclaredField("item"));
                nextOffset = UNSAFE.objectFieldOffset
                    (k.getDeclaredField("next"));
            } catch (Exception e) {
                throw new Error(e);
            }
        }
    }

```

## 2. head tail 的说明

``` java

/**
 * 不变性:
 *  - 队列中所有未删除的节点都可以通过head节点的succ方法查找到
 *  - head节点一定不可能等于null
 *  - (tmp = head).next != tmp,即head的next不能指向自己。
 * 
 * 可变性:
 * - head的item可能为null,也可能不为null
 * - tail节点可能会滞后于head节点，因此从head节点未必一定可以找到tail节点
 * 
 */
private transient volatile Node<E> head;

/**
 * 不变性:
 *  - 节点中的最后一个元素总是可以通过tail的succ方法来获取
 *  - tail节点不等于null
 * 
 * 可变性:
 *  - head的item可能为null,也可能不为null
 *  - tail 节点的next可能指向自己，也可能不指向自己
 *  - tail节点可能会滞后于head节点，因此从head节点未必一定可以找到tail节点
 */
private transient volatile Node<E> tail;

```

### 2.1 tail 落后于head的情况

先offer 后 poll， offer之后 head的next节点会指向下一个节点，如果此时poll ，那么 head.item == null，所以此时head会移动到head.next,成为新的节点 ，在下一次的遍历中head中的item出队 ，而此时tail仍指向最原始的头节点，从而出现了tail滞后于head的情况

![tail滞后head](/images/tail-after-head.png)

## 3. Offer 方法

```java
public boolean offer(E e) {
        checkNotNull(e);
        final Node<E> newNode = new Node<E>(e);

        for (Node<E> t = tail, p = t;;) {
            Node<E> q = p.next;
            if (q == null) {
                // p is last node
                if (p.casNext(null, newNode)) {
                    // Successful CAS is the linearization point
                    // for e to become an element of this queue,
                    // and for newNode to become "live".
                    // 因为tail的滞后性 ，并不会随时随地的修改tail，只有当tail指针与真实的尾节点
                    // 距离相差超过1时 才会进行更新。 该操作如果失败，说明有其他线程执行成功，所以不需重试
                    if (p != t) // hop two nodes at a time
                        casTail(t, newNode);  // Failure is OK.
                    return true;
                }
                // Lost CAS race to another thread; re-read next
            }
            // 当执行 poll 或 remove操作时，会有这种情况产生
            else if (p == q)
                // p == q 说明p变成来哨兵节点（即被poll删除了） 因此需要判断t的执行是否与当前的tail节点一致
                // 如果一致，说明tail被删除了，那么需要从头开始遍历 ，如果不一致，那么直接从当前尾节点继续遍历
                p = (t != (t = tail)) ? t : head;
            else
                // 只有offer操作 会执行到这里  
                // 1. 当有两个线程（A B) 竞争时, 如果A 添加了尾节点 ，那么B会在第二次循环时走到这里（因为p.next 已经不为null），此时 p == t  所以 p 指向 q 然后在下一轮更新 赋值

                // 2. 如果又有C线程竞争 ，因为执行完1后，线程B 在添加尾节点时有竞争失败，那么继续走到这里，此时 p 已经执行 q,即 p != t, 而如果 tail被其他线程改变了，那么p = t(这时的t已经指向了新的tail) 然后开始新一轮的循环
                p = (p != t && t != (t = tail)) ? t : q;
        }
    }

```

## 4. Poll 方法

获取当前队列的第一个节点，并出队 

```java
    public E poll() {
        restartFromHead:
        for (;;) {
            for (Node<E> h = head, p = h, q;;) {
                E item = p.item;

                // 元素不为null，出队
                if (item != null && p.casItem(item, null)) {
                    // Successful CAS is the linearization point
                    // for item to be removed from this queue.
                    // head的更新也是滞后的，也就是head的item可以为null，但是head一定不为null
                    if (p != h) // hop two nodes at a time
                        updateHead(h, ((q = p.next) != null) ? q : p);
                    return item;
                }
                // 如果 p.next == null ，那么说明队列已经空了，直接返回null
                else if ((q = p.next) == null) {
                    updateHead(h, p);
                    return null;
                }
                // 说明 p节点被其他的线程出队了，重新从head节点查询
                else if (p == q)
                    continue restartFromHead;
                else
                    // 说明p.next 不为空，那么直接将p节点向后移动一位
                    p = q;
            }
        }
    }
```

## 5. 其他

基本上了解了以上两个方法，就基本可以了解 concurrentLinkedQueue的运行原理 ，其他的一些辅助方法如下：

``` java
// 寻找下一个节点，如果 当前节点被删除，那么重新跳回到头节点
final Node<E> succ(Node<E> p) {
        Node<E> next = p.next;
        return (p == next) ? head : next;
}

// 找寻第一个节点，主要用于遍历，和poll的主要不同点在于
// 1. first 方法不删除节点   2. first方法返回的是 Node，而不是 item
Node<E> first() {
        restartFromHead:
        for (;;) {
            for (Node<E> h = head, p = h, q;;) {
                boolean hasItem = (p.item != null);
                if (hasItem || (q = p.next) == null) {
                    updateHead(h, p);
                    return hasItem ? p : null;
                }
                else if (p == q)
                    continue restartFromHead;
                else
                    p = q;
            }
        }
}
```

## 6. 参考

1. [Java并发编程之ConcurrentLinkedQueue详解](https://blog.csdn.net/qq_38293564/article/details/80798310)
2. [ConcurrentLinkedQueue](https://www.jianshu.com/p/32d6526494fd)
3. [深入理解分析ConcurrentLinkedQueue源码设计](https://www.jianshu.com/p/53582b21bb73)
