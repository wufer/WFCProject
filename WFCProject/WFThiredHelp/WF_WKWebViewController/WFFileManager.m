//
//  WFFileManager.m
//  WFCProject
//
//  Created by PRD_01 on 2018/4/24.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFFileManager.h"



@implementation WFFileManager

+(instancetype)shared{
    static WFFileManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WFFileManager alloc]init];
    });
    return manager;
}

+(NSURL *)getFilePathWithName:(NSString *)fileName type:(WFFileType)type{
    NSString *typeStr = nil;
    switch (type) {
        case WFFileType_xlsx:
            typeStr = @"xlsx";
            break;
        case WFFileType_pdf:
            typeStr = @"pdf";
            break;
        default:
            break;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:typeStr];
     NSURL *baseURL = [NSURL fileURLWithPath:path];
    if (path.length) {
        return baseURL;
    }else{
        return nil;
    }
//    NSString *path = nil;
//    NSFileManager *manager = [NSFileManager defaultManager];
//    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documents = [array lastObject];
//    //拼接绝对路径
////    NSString *documentPath = [documents stringByAppendingPathComponent:fileName];
//    path = [NSString stringWithFormat:@"%@/%@",documents,path];
//    return path;
}



@end
