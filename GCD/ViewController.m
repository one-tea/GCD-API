//
//  ViewController.m
//  GCD
//
//  Created by keanuzhang on 30/06/2017.
//  Copyright © 2017 keanuzhang. All rights reserved.
//
/***********************************************************************************************************************************
 
 ##目录##
 
 知识点：
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

 
 ## 应用场景1：等待现在执行中处理结束，多任务则按顺序进行-> serialQueue (cmd+click)
 
 ## 应用场景2：不等待现在执行中处理结束，多任务则并发进行，适用于耗时操作，没有前后逻辑顺序或依赖，可用返回顺序按本身耗时时间决定 -> concurrentQueue
 
 ## 应用场景3：不论任何函数生成的队列，如果想指定 A队列 与 B队列 拥有相同优先级 -> dispatch_set_target_queue
    (知识点：优先级 -> 并不是线程按等级顺序来执行完结束，而是系统处理器空闲时优先分配处理，并不代表该线程最先处理完（只是会哭的孩子有奶吃长得快！）
 
 ## 应用场景4：在追加多个处理全部结束后想执行结束处理 -> dispatch_group
 
 ## 应用场景5：访问数据库或文件时，为避免数据竞争 -> dispatch_barrier_async

 ## 应用场景6：将Block指定次数的添加到Dispatch queue中 -> dispatch_apply
 
 ## 应用场景7：在大量处理追加到queue中，对已添加过未执行的处理 进行管理开关（挂起/唤醒） -> dispatch_suspend__dispatch_resume

 ## 应用场景8：在并行处理更新数据，会产生数据不一的情况，虽然串行和栅栏函数(dispatch_barrier_async)也可以解决，更细量化处理到任务中每一个方法调用 -> dispatchSemaphore


 ##
 参考资料：
 grand-central-dispatch-in-depth-part：
 https://github.com/nixzhu/dev-blog/blob/master/2014-04-19-grand-central-dispatch-in-depth-part-1.md
 http://www.raywenderlich.com/63338/grand-central-dispatch-in-depth-part-2
 iOS - 多线程你看全不全：https://juejin.im/entry/57dcc1cc0bd1d00057e97dc7
 iOS多线程之GCD的执行原理：http://www.jianshu.com/p/5840523fb3ea

 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self gcdApi];
    
}


-(void)gcdApi{

    [self dispatch_queue];
    
    [self dispatch_set_target_queue];
    
    [self dispatch_group];
    
    [self dispatch_barrier_async];
    
    [self dispatch_apply];

    [self dispatch_suspend__dispatch_resume];
    
    [self dispatchSemaphore];

}



/** 队列
 
 - 1.串行(Serial dispatch、Main dispatch)
 - 2.并行(Concurrent dispatch)
 
 */

#pragma mark - Queue

-(void)dispatch_queue{


    [self serialQueue];
    
    [self concurrentQueue];
    
}

-(void)serialQueue{
    
    /**
     dispatch_queue_create 生成串行队列
     
     - Parameters:
     - value1: 自定义
     - value2: NULL: 默认先进先出(FIFO) 即串行
     */
    dispatch_queue_t mySerial = dispatch_queue_create("com.example.gcd.MySerialQueue", NULL);
    
    /***
     * 异步线程加入串行队列 -> 会开辟新线程 执行顺序onebyone
     */
    dispatch_async(mySerial, ^{
        NSLog(@"serialQueue_task1");
    });
    dispatch_async(mySerial, ^{
        NSLog(@"serialQueue_task2");
    });
    
//    dispatch_release(mySerial);
}

-(void)concurrentQueue{
    
    /**
     全局队列，并行
     
     @ Parameters:
         * value1: 优先级 (注意：由于通过XNU内核用于GCD并不能保证时效性，因此执行高优先级只是大致判断并不精准，在处理的执行可有可无下按优先级)
             #define DISPATCH_QUEUE_PRIORITY_HIGH 2
             #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
             #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
             #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
        * value2: 待留参数，传递除0以外的任何值都可能导致一个空返回值
     */
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /***
     * 异步线程加入全局队列 -> 并发
     */
    dispatch_async(global, ^{
        NSLog(@"concurrentQueue_task1");
    });
    dispatch_async(global, ^{
        NSLog(@"concurrentQueue_task2");
    });
}


#pragma mark - dispatch_set_target_queue

-(void)dispatch_set_target_queue{
    
    dispatch_queue_t createSerial = dispatch_queue_create("com.exmple.gcd.targetSerialQueue", NULL);
    
    dispatch_queue_t globelBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    /***
     * createSerial 拥有 globelBackground 相同的优先级
     */
    dispatch_set_target_queue(createSerial, globelBackground);
    
}


#pragma mark - dispatch_Group

-(void)dispatch_group{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk0");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk2");
    });
    
    /**
     * 追加三个Block到globel_queue中，等Block中全部执行完毕，就会执行 dispatch_get_main_queue中的Block
     */
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Done!");
    });

    //也可以使用wait, DISPATCH_TIME_FOREVER表示一直等待，也可以是一段时间内
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    NSLog(@"Done!");
    
    //blk0
    //blk1
    //blk2
    //Done!
    
}


#pragma mark - dispatch_barrier_async

-(void)dispatch_barrier_async{
    
    //用dispatch_queue_create函数生成一个Concurrent Dispatch Queue
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.example.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"blk0_reading");
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"blk1_reading");
    });
    
    /**
     * 在blk1结束后，blk2开始前写入，将Block追加到queue中，可以是异步/同步，同步须考虑死锁
     */
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"blk_writing");
    });
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"blk2_reading");
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"blk3_reading");
    });
    
}


#pragma mark - dispatch_apply

-(void)dispatch_apply{
    
    /**
     * 将Block指定次数的添加到Dispatch queue中,并开辟多个线程
     */
    dispatch_queue_t globel = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, globel, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    NSLog(@"done");
    
    //2
    //3
    //6
    //...
    //9
    //done
    
}


#pragma mark - dispatch_suspend__dispatch_resume

-(void)dispatch_suspend__dispatch_resume{
    /**
     * 在大量处理追加到queue中，对已添加过未执行的处理暂停 进行管理开关（挂起/唤醒）
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_suspend(queue);
    //dispatch_resume恢复指定的queue
    dispatch_resume(queue);
}


#pragma mark - dispatchSemaphore

-(void)dispatchSemaphore{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);//创建信号量初始值为1
    
    NSMutableArray *arry = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<1000; i++) {
        dispatch_async(queue, ^{
       
            //等待semaphore,计数为0时等待
            //一直等待，直到Dispatch_semaphore的计数值>=1减一并执行
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//-1，
            /**
             * 由于semphore经wait减一，此时计数值为0，可向下进行
             */
            //访问arry类对象的线程，只有一个，可以安全访问
            [arry addObject:@1];
            
            //onebyone
            dispatch_semaphore_signal(semaphore);//+1
            
    });
}
}


@end
