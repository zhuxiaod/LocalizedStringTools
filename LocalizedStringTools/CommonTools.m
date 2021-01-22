//
//  CommonTools.m
//  PlistTool
//
//  Created by mac on 2021/1/21.
//  Copyright © 2021 dayan. All rights reserved.
//

#import "CommonTools.h"

@implementation CommonTools

+ (instancetype)sharedInstance {
    static CommonTools *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        sharedInstance = [[CommonTools alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 获取文件中的字符串
-(NSString *)getContentWithFilePath:(NSString *)filePath{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *fileData = [fm contentsAtPath:filePath];
    return [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
}

#pragma mark - 文件写入
-(void)writeStringToFilePath:(NSString *)filePath contentString:(NSString *)contentString{
    BOOL isWriteString = [contentString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (isWriteString) { NSLog(@"string 文件写入成功"); };
}

#pragma mark - 数组去重
-(NSMutableArray *)duplicateRemoveArray:(NSArray *)originalArr{
    
    NSMutableArray *resultArrM = [NSMutableArray array];
    
    for (NSString *item in originalArr) {
        if (![resultArrM containsObject:item]) {
            [resultArrM addObject:item];
        }
    }
    return resultArrM;
}

#pragma mark - 去除多余字符 @"a" --> a
-(NSString *)removeDuplicateString:(NSString *)string{
    NSString *newString = [string substringFromIndex:2];
    newString = [newString substringToIndex:newString.length - 1];
    NSLog(@"%@",newString);
    return newString;
}

#pragma mark - 查看是否有index
-(BOOL)isHaveIndex:(NSString *)contentString{
    BOOL isHaveIndex = NO;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(TES_index(.{0,20}))" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:contentString options:0 range:NSMakeRange(0, [contentString length])];
    if (result) {
        isHaveIndex = YES;
    }
    return isHaveIndex;
}

#pragma mark - 获取Index
-(NSInteger)getTesIndex:(NSString *)contentString{
    NSInteger index = 0;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(TES_index(.{0,20}))" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:contentString options:0 range:NSMakeRange(0, [contentString length])];
    if (result) {
        NSString *tesIndexString = [contentString substringWithRange:result.range];
        tesIndexString = [tesIndexString stringByReplacingOccurrencesOfString:@"TES_index(" withString:@""];
        tesIndexString = [tesIndexString stringByReplacingOccurrencesOfString:@")" withString:@""];
        index = [tesIndexString integerValue];
    }
    return index;
}

#pragma mark - 获取Index字符串
-(NSString *)getTesIndexString:(NSString *)contentString{
    NSString *string = @"";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(TES_index(.{0,20}))" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:contentString options:0 range:NSMakeRange(0, [contentString length])];
    if (result) {
        string = [contentString substringWithRange:result.range];
    }
    return string;
}

#pragma mark - 文件遍历
- (void)showAllFileWithPath:(NSString *)path{
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    //是否存在的
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            // 只是获取指定路劲下的一级目录
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                if([str isEqualToString:@"Pods"])break;//规避风险
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
            
        }else{
            
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".m"] && ![fileName isEqualToString:@"TESConstant"]) {
                //do anything you want
//                [fileArray addObject:path];
                if(self.morePathBlock){
                    self.morePathBlock(path);
                }
                //单文件路径
                NSLog(@"path:%@",path);
            }
        }
    }else{
        NSLog(@"this path is not exist!");
    }
}

@end
