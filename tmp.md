
hystrix

每次执行命令都只能执行一次，不能重复执行，也就是说每次都需要new新的命令对象来执行



spring cache:

https://blog.csdn.net/f641385712/article/details/94603480
https://blog.csdn.net/f641385712/article/details/94570960

https://blog.csdn.net/elim168/article/details/78445863 // AOP


// 为合适的对象创建代理对象

(InfrastuctureAdvisorAutoProxyCreator.java) 

AbstractAutoProxyCreator.postProcessAfterInitialization 

then

AbstractAutoProxyCreator.getAdvicesAndAdvisorsForBean

then 

AdvisedSupport.getInterceptorsAndDynamicInterceptionAdvice // 获取interceptor


cache

通过 cacheManager 的getCache 获取 Cache实例。 可以对这两个对象进行扩展
自定义cache实例，可以实现缓存失效时间或主动加载等策略


- [ ] golang sort heap的理解

heap sort.Less() 方法返回true才进行交换
因此如果定义：
```go
func Less(i, j int) bool {
    if i > j {
        return true
    }
}

// 即 i< j 时进行交换，那么最终堆是个大顶堆，升序排列

// 大顶堆的含义，最大的元素在顶，每次出队时，先将其交换到队尾，将队尾放置到顶部，然后进行堆平衡交换
// 这样最大的值到了队列的尾部。
// 自定义出队方法时，POP获取队尾元素即可
```

- [ ] leetcode 迷宫 地下城与勇士
- [ ] CompleteFuture 总结
- [ ] Flow Api 学习理解




