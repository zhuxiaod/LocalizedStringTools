//
//  CommonTools.h
//  PlistTool
//
//  Created by mac on 2021/1/21.
//  Copyright © 2021 dayan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MorePathBlock)(NSString *path);

@interface CommonTools : NSObject

@property(nonatomic,copy) MorePathBlock morePathBlock;

+ (instancetype)sharedInstance;

#pragma mark - 获取文件中的字符串
-(NSString *)getContentWithFilePath:(NSString *)filePath;

#pragma mark - 文件写入
-(void)writeStringToFilePath:(NSString *)filePath contentString:(NSString *)contentString;

#pragma mark - 数组去重
-(NSMutableArray *)duplicateRemoveArray:(NSArray *)originalArr;
    
#pragma mark - 去除多余字符 @"a" --> a
-(NSString *)removeDuplicateString:(NSString *)string;

#pragma mark - 查看是否有index
-(BOOL)isHaveIndex:(NSString *)contentString;

#pragma mark - 获取Index
-(NSInteger)getTesIndex:(NSString *)contentString;

#pragma mark - 获取Index字符串
-(NSString *)getTesIndexString:(NSString *)contentString;

#pragma mark - 文件遍历
- (void)showAllFileWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
