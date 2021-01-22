//
//  CommonTools.h
//  PlistTool
//
//  Created by dayan on 2020/4/28.
//  Copyright © 2020 dayan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainDemand : NSObject

-(NSString *)getFileString;

+ (instancetype)sharedInstance;

//选择方式
-(void)scanfCodeType:(void(^)(NSInteger type))block;

//#pragma mark - 获取文件中的字符串
//-(NSString *)getContentWithFilePath:(NSString *)filePath;

#pragma mark - 获取需要更换的字符串
-(NSMutableArray *)getReplaceStringArrayWithExpression:(NSString *)expressionString contentString:(NSString *)contentString;

#pragma mark - 获取正则检索结果 不判断是否国际化
-(NSMutableArray *)getReplaceArrayWithExpression:(NSString *)expressionString contentString:(NSString *)contentString;
    
#pragma mark - 获取编辑后的文件内容
/// 获取编辑后的文件内容
/// @param replaceStringArray 替换文本的数组
/// @param contentString 文件内容
/// @param fileString 文件名字
-(NSString *)getChengedFileContent:(NSArray *)replaceStringArray contentString:(NSString *)contentString fileString:(NSString *)fileString;

#pragma mark - 将需要写入的内容 导入至Strings文件
-(void)saveArrayToStringsFile:(NSMutableArray *)array;


#pragma mark - 单文件国际化
-(void)singleFileLocalizedString:(NSString *)fileString;

#pragma mark - 多文件国际化
-(void)moreFileLocalizedString:(NSString *)fileString;

#pragma mark - 提取Strings中文文件
-(void)extractionChineseWithStrings:(NSString *)stringsPath;

#pragma mark - 导出操作
-(void)exportArrayToStringsFile:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
