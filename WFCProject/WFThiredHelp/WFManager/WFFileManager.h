//
//  WFFileManager.h
//  WFCProject
//
//  Created by PRD_01 on 2018/4/24.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFFileManager : NSObject


/**
 获取本地文件URL

 @param fileName 文件名
 @param type 文件类型
 @return 本地文件URL 文件未发现返回nil
 */
+(NSURL *)getFilePathWithName:(NSString *)fileName type:(NSString *)type;

@end
