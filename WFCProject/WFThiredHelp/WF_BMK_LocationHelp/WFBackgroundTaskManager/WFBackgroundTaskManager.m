//
//  WFBackgroundTaskManager.m
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFBackgroundTaskManager.h"

@interface WFBackgroundTaskManager()

@property (nonatomic,strong) NSMutableArray *BGTaskIDList;
@property (nonatomic,assign)UIBackgroundTaskIdentifier masterTaskID;

@end

@implementation WFBackgroundTaskManager

+(instancetype)sharedBackgroundTaskManager{
    static WFBackgroundTaskManager *BGTaskManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BGTaskManager = [[WFBackgroundTaskManager alloc]init];
    });
    return BGTaskManager;
}

-(instancetype)init{
    if (self = [super init]) {
        _BGTaskIDList = [[NSMutableArray alloc]init];
        _masterTaskID = UIBackgroundTaskInvalid;
    }
    return self;
}

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier BGTaskID = UIBackgroundTaskInvalid;
    if ([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        BGTaskID = [application beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"后台任务    %lu     过期",(unsigned long)BGTaskID);
            [self.BGTaskIDList removeObject:@(BGTaskID)];
            [application endBackgroundTask:BGTaskID];
            BGTaskID = UIBackgroundTaskInvalid;
        }];
    }
    if (self.masterTaskID == UIBackgroundTaskInvalid) {
        self.masterTaskID = BGTaskID;
        NSLog(@"开始主任务   %lu",(unsigned long)BGTaskID);
    }else{
        NSLog(@"启动后台任务 %lu",(unsigned long)BGTaskID);
        [self.BGTaskIDList addObject:@(BGTaskID)];
        [self endAllBackgroundTasks];
    }
    
    return BGTaskID;
}

-(void)endAllBackgroundTasks{
    [self drainBGTaskList:NO];
}
-(void)endBackgroundTasks{
    [self drainBGTaskList:YES];
}
-(void)drainBGTaskList:(BOOL)isAll{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(endBackgroundTask:)]) {
        NSUInteger count = self.BGTaskIDList.count;
        for (NSUInteger i = (isAll?0:1); i<count; i++) {
            UIBackgroundTaskIdentifier BGTaskID = [[self.BGTaskIDList objectAtIndex:0] integerValue];
            [application endBackgroundTask:BGTaskID];
            [self.BGTaskIDList removeObjectAtIndex:0];
            NSLog(@"正在结束后台任务    ID  %lu",(unsigned long)BGTaskID);
        }
        if (self.BGTaskIDList.count>0) {
            NSLog(@"持续后台任务      ID  %@",[self.BGTaskIDList objectAtIndex:0]);
        }
        if (isAll) {
            NSLog(@"没有更多后台任务");
            [application endBackgroundTask:self.masterTaskID];
            self.masterTaskID = UIBackgroundTaskInvalid;
        }else{
            NSLog(@"保持主后台任务     ID  %lu",(unsigned long)self.masterTaskID);
        }
    }
}


@end
