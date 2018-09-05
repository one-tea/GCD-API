# GCD-API
 
 ## 目录 ##
 
 **知识点**
 
 GCD中有2个核心概念：任务和队列
 
 任务：执行什么操作，任务有两种执行方式： 同步函数 和 异步函数，他们之间的区别是
 
 同步：只能在当前线程中执行任务，不具备开启新线程的能力，任务立刻马上执行，会阻塞当前线程并等待 Block中的任务执行完毕，然后当前线程才会继续往下运行
 异步：可以在新的线程中执行任务，具备开启新线程的能力，但不一定会开新线程，当前线程会直接往下执行，不会阻塞当前线程
 
 队列：用来存放任务，分为串行队列 和 并行队列
 
 串行队列（Serial Dispatch Queue）
 让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）
 并发队列（Concurrent Dispatch Queue）
 可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）
 并发功能只有在异步（dispatch_async）函数下才有效
 (并发和并行的区别：并发是同一时间内执行多个任务，并行是同一时刻执行多个任务！)
 
 任务执行顺序：
 1.异步函数+并发队列：会开启新的线程,并发执行
 2.异步函数+串行队列：会开启一条线程,任务串行执行
 3.同步函数+并发队列：不会开线程,任务串行执行
 4.同步函数+串行队列：不会开线程,任务串行执行
 5.异步函数+主队列:  不会开线程,任务串行执行（主队列是GCD自带的一种特殊的串行队列，放在主队列中的任务，都会放到主线程中执行）
 6.同步函数+主队列:  死锁

 
 #### 应用场景1：等待现在执行中处理结束，多任务则按顺序进行-> serialQueue (cmd+click)
 
 #### 应用场景2：不等待现在执行中处理结束，多任务则并发进行，适用于耗时操作，没有前后逻辑顺序或依赖，可用返回顺序按本身耗时时间决定 -> concurrentQueue
 
 #### 应用场景3：不论任何函数生成的队列，如果想指定 A队列 与 B队列 拥有相同优先级 -> dispatch_set_target_queue
   (知识点：优先级 -> 并不是线程按等级顺序来执行完结束，而是系统处理器优先分配处理，并不代表该线程最先处理完
 
  #### 应用场景4：在追加多个处理全部结束后想执行结束处理 -> dispatch_group
 
 #### 应用场景5：访问数据库或文件时，为避免数据竞争 -> dispatch_barrier_async

 #### 应用场景6：将Block指定次数的添加到Dispatch queue中 -> dispatch_apply
 
 #### 应用场景7：在大量处理追加到queue中，对已添加过未执行的处理进行管理（挂起/唤醒） -> dispatch_suspend__dispatch_resume

 #### 应用场景8：在并行处理更新数据，会产生数据不一的情况，虽然串行和栅栏函数(dispatch_barrier_async)也可以解决，更细量化处理到任务中一个方法调用 -> dispatchSemaphore


 ## 参考资料：
 
 grand-central-dispatch-in-depth-part：  
 https://github.com/nixzhu/dev-blog/blob/master/2014-04-19-grand-central-dispatch-in-depth-part-1.md   
 http://www.raywenderlich.com/63338/grand-central-dispatch-in-depth-part-2   
 iOS - 多线程你看全不全：https://juejin.im/entry/57dcc1cc0bd1d00057e97dc7  
 IOS多线程之GCD的执行原理：http://www.jianshu.com/p/5840523fb3ea  
 
 作者：_方丈    
 链接：https://www.jianshu.com/p/4e75bc34ef07
