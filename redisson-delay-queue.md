
1. 通过offer 入队列


2. 通过定时任务，不停轮训有序队列，从队列中获取头元素来确定下一次任务执行时间，将满足条件的任务放到准备就绪队列中


3. 在offer方法中，通过一下lua脚本来判断新增的元素是否放置到了队首，如果放置到了队首，则publish到某个执行队列

``` lua
// if new object added to queue head when publish its startTime 
              // to all scheduler workers 
              + "local v = redis.call('zrange', KEYS[2], 0, 0); "
              + "if v[1] == value then "
                 + "redis.call('publish', KEYS[4], ARGV[1]); 


```

4. 接收指定队列的publish消息，表明当前的有序队列队首改变，需要更新下一次任务的执行时间，将原有老得队列cacel掉，然后重新调度新的队列
