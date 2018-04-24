//
//  WFFileManager.h
//  WFCProject
//
//  Created by PRD_01 on 2018/4/24.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,WFFileType){
    WFFileType_xlsx,
    WFFileType_pdf
};

@interface WFFileManager : NSObject

+(NSURL *)getFilePathWithName:(NSString *)fileName type:(WFFileType)type;

@end
