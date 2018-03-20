//
//  WFBackgroundTaskManager.h
//  WFCProject
//
//  Created by wufer on 2018/3/19.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@interface WFBackgroundTaskManager : NSObject

/**
 创建后台管理类

 @return 后台管理类单例
 */
+(instancetype)sharedBackgroundTaskManager;

/**
 开启新后台任务

 @return 后台任务对象ID
 */
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;

/**
 结束全部后台任务
 */
-(void)endAllBackgroundTasks;

@end
