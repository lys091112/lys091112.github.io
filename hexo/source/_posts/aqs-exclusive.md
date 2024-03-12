---
title: java同步器AQS的独享模式分析
date: 2018-04-17 07:29:25
tags: 
  - java并发
  - concurrent
toc: true
---

## 前言

在java.util.concurrent包中有很多控制同步和并发的类，其中向ReentrantLock，CountDownLatch 内部实现都依赖与AbstractQueuedSynchronizer（用于控制同步的框架AQS），下面我们来分析独占模式下的原理


## 原理

队列同步器AQS是用来构建锁和其他同步组件的基础框架，内部使用int来表示成员的同步状态，通过内置的FIFO队列来完成资源获取线程的排序工作，其中成员变量包括 内部状态state 、等待队列的对头head(对头是一个空节点,也可以认为是当前持有锁的线程)、等待队列的队尾tail，都是通过volatile修饰，保证在并发过程中对其他线程可见

<!-- more -->
基本结构：
```java
public abstract class AbstractQueuedSynchronizer
    extends AbstractOwnableSynchronizer
    implements java.io.Serializable {
    private transient volatile Node head;

    private transient volatile Node tail;

    /**
     * 同步状态
     */
    private volatile int state;

}
```

AQS内部队列的实现原理
```java
static final class Node {
        /** Marker to indicate a node is waiting in shared mode */
        static final Node SHARED = new Node();
        /** Marker to indicate a node is waiting in exclusive mode */
        static final Node EXCLUSIVE = null;

        /** waitStatus value to indicate thread has cancelled */
        static final int CANCELLED =  1;
        /** waitStatus value to indicate successor's thread needs unparking */
        static final int SIGNAL    = -1;
        /** waitStatus value to indicate thread is waiting on condition */
        static final int CONDITION = -2;
        /**
         * waitStatus value to indicate the next acquireShared should
         * unconditionally propagate
         */
        static final int PROPAGATE = -3;

        volatile int waitStatus;
        volatile Node prev;
        volatile Node next;
        volatile Thread thread;
        Node nextWaiter;

```

- 每当有线程竞争锁失败，那么会将其加入到队列的队尾，tail始终指向最后一个元素

- 节点存储的信息包括 节点的模式，前驱和后继节点，当前线程引用，以及当前状态waitStatus,
多线程并发时，会存在多个线程节点，waitStatus表示当前节点的状态，有的线程可能在等待过程中放弃，有的节点可能在等待条件满足后在触发。状态分为以下四种：

    - CANCELLED 取消状态
    - SIGNAL 等待触发状态
    - CONDITION 等待条件状态
    - PROPAGATE 状态需要向后传播

- 等待队列是FIFO先进先出，只有前一个节点的状态为SIGNAL时，当前节点的线程才能被挂起。

## 源码解析：

1. acquire(int)

```java

   public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
    /** 需要有子类进行实现 **/
    protected boolean tryAcquire(int arg) {
        throw new UnsupportedOperationException();
    }
```
    1. tryAcquire 尝试获取锁资源，如果获取成功，直接返回
    2. 首先通过addWaiter 以独占模式将当前线程添加到队尾，而后accquireQueued 在队列中获取资源，直到获取到资源,如果在获取过程中被中断，则返回true，否则返回false
    3. 线程在等待过程中被中断过，它是不响应的。只是获取资源后才再进行自我中断selfInterrupt()，将中断补上

2. addWaiter(Node)

```java
    
    private Node addWaiter(Node mode) {
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        enq(node);
        return node;
    }
    private Node enq(final Node node) {
        for (;;) {
            Node t = tail;
            if (t == null) { // Must initialize
                if (compareAndSetHead(new Node()))
                    tail = head;
            } else {
                node.prev = t;
                if (compareAndSetTail(t, node)) {
                    t.next = node;
                    return t;
                }
            }
        }
    }

```
    1. 首先尝试将节点直接加入队列，如果在加入过程中队尾不为空，其没有变化，那么直接加入并返回
    2. 如果队尾为空，或者在加入过程中队尾指针变化，那么需要重新检测并入队。通过一个自循环，不停的检测，直到加入成功。首先获取队列队尾，检查队尾是否为空，如果为空则代表没有其他等待节点，那么首先初始化队列，将对象头置为不包含任何数据的节点，并同步队尾指针然后再次循环检查
    3. 如果队尾节点不为空，那么尝试将节点添加到队尾

3. acquireQueued(node, int)

```java

    final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }

```
    进入等待状态休息，直到其他线程彻底释放资源后唤醒自己，自己再拿到资源，然后就可以去干自己想干的事了。
    1. 检查当前节点的前驱节点，如果前驱节点是头节点，那么更新头节点，并返回是否在获取过程中被中断(在addWaiter中如果队列为空那么会先初始化一个头节点，然后将节点添加进去，在这一步又使用节点替换头节点)
    2. 如果前驱非头节点，那么检查是否需要检查等待状态然后等待被唤醒并检查是否在等待过程中被中断

4. shouldParkAfterFailedAcquire(node,node)

```java
    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
        int ws = pred.waitStatus;
        if (ws == Node.SIGNAL)
            /*
             * This node has already set status asking a release
             * to signal it, so it can safely park.
             */
            return true;
        if (ws > 0) {
            /*
             * Predecessor was cancelled. Skip over predecessors and
             * indicate retry.
             */
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
            /*
             * waitStatus must be 0 or PROPAGATE.  Indicate that we
             * need a signal, but don't park yet.  Caller will need to
             * retry to make sure it cannot acquire before parking.
             */
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }

    private final boolean parkAndCheckInterrupt() {
        LockSupport.park(this);
        return Thread.interrupted();
    }

    static void selfInterrupt() {
        Thread.currentThread().interrupt();
    }
```
    1. 检查上一个节点的状态是否是可唤醒状态，如果是则返回true，并执行parkAndCheckInterrupt进行park
    2. 如果不是，那么针对于状态大于0的都是取消状态，需要忽略，那么从队尾指针往前找直到某个状态小于等于0，那节点的前驱节点设置为找寻到的节点，然后进行新一轮的自旋迭代

    3. 如果不是可唤醒状态，而且状态不大于0，那么需要修改节点状态，再一次自旋

结合aquireQueued，流程如下：
    1. 结点进入队尾后，检查状态，找到安全休息点；
    2. 调用park()进入waiting状态，等待unpark()或interrupt()唤醒自己；
    3. 被唤醒后，看自己是不是有资格能拿到号。如果拿到，head指向当前结点，并返回从入队到拿到号的整个过程中是否被中断过；如果没拿到，继续流程1。

5. release(int)

```java
public final boolean release(int arg) {
    if (tryRelease(arg)) {
        Node h = head;
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}

/** 由子类实现 **/
protected boolean tryRelease(int arg) {
    throw new UnsupportedOperationException();
}

private void unparkSuccessor(Node node) {
    int ws = node.waitStatus;
    if (ws < 0)
        compareAndSetWaitStatus(node, ws, 0);

    Node s = node.next;
    if (s == null || s.waitStatus > 0) {
        s = null;
        for (Node t = tail; t != null && t != node; t = t.prev)
            if (t.waitStatus <= 0)
                s = t;
    }
    if (s != null)
        LockSupport.unpark(s.thread);//唤醒
}

```
    1. 根据tryRelease 查看是否释放成功
    2. 如果释放成功，那么对线程进行unpark唤起 head节点一般是当前线程所在节点，首先查看head节点的状态，如果状态小于0，那么将其置为0，然后遍历查找下一个需要唤醒的节点，如果节点的状态大于0，表明该节点已经取消，那么需要从队尾遍历往前找到最头不为且状态不大于0的节点进行唤醒

总结：

以上就是AQS对于独占模式下线程竞争的数据处理过程,下节分析共享模式下的处理流程



