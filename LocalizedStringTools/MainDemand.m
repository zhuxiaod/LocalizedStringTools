//
//  CommonTools.m
//  PlistTool
//
//  Created by dayan on 2020/4/28.
//  Copyright © 2020 dayan. All rights reserved.
//

#import "MainDemand.h"
#import "CommonTools.h"

@implementation MainDemand

+ (instancetype)sharedInstance {
    static MainDemand *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        sharedInstance = [[MainDemand alloc] init];
    });
    return sharedInstance;
}

-(NSString *)getFileString{
    printf("请输入文件地址：");
    char *filetring = malloc(sizeof(char) * 100);
    scanf("%s",filetring);
    printf("输入文字是：%s\n",filetring);
    //转化成字符串
    NSString *fileStr = [NSString stringWithFormat:@"%s",filetring];
    return fileStr;
}


-(void)scanfCodeType:(void(^)(NSInteger type))block{
    //判断是解密还是什么
    NSInteger codeType = -1;
    do {
        printf("功能列表:");
        printf("\n");
        printf("1.单文件国际化\n2.多文件国际化\n3.strings文件提取中文\n");
        printf("请选择功能:");
        scanf("%ld",&codeType);
    } while (codeType < -1 || codeType > 10);
    
    if(codeType == 1){
        printf("已选择功能1\n");
    }else if (codeType == 2){
        printf("已选择功能2\n");
    }else if (codeType == 3){
        printf("已选择提取中文功能\n");
    }else{
        printf("已经退出程序\n");
//        exit(0);
    }
    
    block(codeType);
}

#pragma mark - 获取正则检索结果 需要去重复
-(NSMutableArray *)getReplaceStringArrayWithExpression:(NSString *)expressionString contentString:(NSString *)contentString{
    // 1.创建正则表达式
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:expressionString options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:contentString options:0 range:NSMakeRange(0, contentString.length)];
    //获取需要替换的字符串
    NSMutableArray *replaceStringArray = [NSMutableArray array];
    //获取找到的坐标
    for (NSTextCheckingResult *result in results) {
        NSString *oldString = [contentString substringWithRange:result.range];//str2 = "is"
//        NSLog(@"oldString:%@",oldString);
        
        //是否已经国际化
        BOOL isHaveParentheses = [self isLocalizedString:contentString range:NSMakeRange(result.range.location, 1)];
        
        if(isHaveParentheses == YES){
            continue;
        }
        [replaceStringArray addObject:oldString];
    }
    //去重
    return [[CommonTools sharedInstance] duplicateRemoveArray:replaceStringArray];
}

#pragma mark - 获取正则检索结果 不判断是否国际化
-(NSMutableArray *)getReplaceArrayWithExpression:(NSString *)expressionString contentString:(NSString *)contentString{
    // 1.创建正则表达式
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:expressionString options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:contentString options:0 range:NSMakeRange(0, contentString.length)];
    //获取需要替换的字符串
    NSMutableArray *replaceStringArray = [NSMutableArray array];
    //获取找到的坐标
    for (NSTextCheckingResult *result in results) {
        NSString *oldString = [contentString substringWithRange:result.range];
        
        [replaceStringArray addObject:oldString];
    }
    //去重
    return [[CommonTools sharedInstance] duplicateRemoveArray:replaceStringArray];
}

//判断是否已经国际化
-(BOOL)isLocalizedString:(NSString *)contentString range:(NSRange)range{
    BOOL isHaveParentheses = NO;
    //@的坐标
    NSRange range1 = NSMakeRange(range.location, 1);
    //向前遍历
    for (NSInteger i = 0; i < 100; i++) {
        NSString *string = [contentString substringWithRange:NSMakeRange(range1.location - 1, 1)];
//            NSLog(@"string:%@\n",string);
        //如果是; 、）号代表已经找完此行代码
        if ([string isEqualToString:@";"] || [string isEqualToString:@")"] || [string isEqualToString:@"["])  break;

        if ([string isEqualToString:@"("]) {
            NSString *indexString = [contentString substringWithRange:NSMakeRange(range1.location - 18, 18)];
//                NSLog(@"test:%@",test);
            if([indexString containsString:@"NSLocalizedString"] == YES){
                isHaveParentheses = YES;
            }
            break;
        }
        range1 = NSMakeRange(range1.location - 1, 1);
    }
    return isHaveParentheses;
}

#pragma mark - 获取编辑后的文件内容
/// 获取编辑后的文件内容
/// @param replaceStringArray 替换文本的数组
/// @param contentString 文件内容
/// @param fileString 文件名字
-(NSString *)getChengedFileContent:(NSMutableArray *)replaceStringArray contentString:(NSString *)contentString fileString:(NSString *)fileString{
    //文件名
    NSString *fileName = fileString.lastPathComponent;
    //取出 . 以后的内容
    fileName = [fileName substringToIndex:fileName.length - 2];
    
    NSInteger index = 0;
    
    //Strings 文件地址
    NSString *stringsContent = [[CommonTools sharedInstance] getContentWithFilePath:@"/Users/mac/Desktop/autoStings/Localizable.strings"];
    
    //是否拥有index
    BOOL isHaveIndex = [[CommonTools sharedInstance] isHaveIndex:contentString];
    
    //如果有INDEX
    if(isHaveIndex){
        index = [[CommonTools sharedInstance] getTesIndex:contentString];
    }
    
    //需要本地化的字符串
    for (NSString *replaceString in replaceStringArray) {
        //替换 文字
        NSString *newString = [NSString stringWithFormat:@"NSLocalizedString(@\"%@_%ld\", %@)",fileName,index,replaceString];
        
        contentString = [contentString stringByReplacingOccurrencesOfString:replaceString withString:newString];
        
        //拼接Strings内容
        stringsContent = [self addStringsContent:replaceString stringsContent:stringsContent fileName:fileName index:index];
        
        index++;
    }
    //写入inx
    if(isHaveIndex){//替换
        
        NSString *tesIndexString = [[CommonTools sharedInstance] getTesIndexString:contentString];
        
        contentString = [contentString stringByReplacingOccurrencesOfString:tesIndexString withString:[NSString stringWithFormat:@"TES_index(%ld)",index]];
        
    }else{//添加
        
        NSString *tesIndexString = [NSString stringWithFormat:@"//  TES_index(%ld)",index];
        NSMutableString *multStringsContent = [[NSMutableString alloc]initWithString:contentString];
        [multStringsContent insertString:tesIndexString atIndex:0];
        contentString = [multStringsContent copy];
        
    }
    //保存Strings文件
    [[CommonTools sharedInstance] writeStringToFilePath:@"/Users/mac/Desktop/autoStings/Localizable.strings" contentString:stringsContent];
    
    return contentString;
}

#pragma mark - 将需要写入的内容 导入至Strings文件
-(void)saveArrayToStringsFile:(NSMutableArray *)array{
    NSString *content = [[CommonTools sharedInstance] getContentWithFilePath:@"/Users/mac/Desktop/autoStings/Localizable.strings"];
    for(NSString *string in array){
        NSString *word = [[CommonTools sharedInstance] removeDuplicateString:string];
        //注释 需要去掉一些内容
        NSString *annotationString = [NSString stringWithFormat:@"/* %@ */\n",word];
        //正文
        NSString *keyValueString = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n\n",word,word];
        
        content = [content stringByAppendingString:annotationString];
        content = [content stringByAppendingString:keyValueString];
    }
    //保存到一个文件
    [[CommonTools sharedInstance] writeStringToFilePath:@"/Users/mac/Desktop/autoStings/Localizable.strings" contentString:content];
    NSLog(@"contetnt:%@\n",content);
}

#pragma mark - 拼接Strings内容
-(NSString *)addStringsContent:(NSString *)string stringsContent:(NSString *)stringsContent fileName:(NSString *)fileName index:(NSInteger)index{
    //内容
    NSString *word = [[CommonTools sharedInstance] removeDuplicateString:string];
    
    //添加 注释
    NSString *annotationString = [NSString stringWithFormat:@"/* %@ */\n",word];
    
    //正文
    NSString *keyValueString = [NSString stringWithFormat:@"\"%@_%ld\" = \"%@\";\n\n",fileName,index,word];
    
    stringsContent = [stringsContent stringByAppendingString:annotationString];
    
    stringsContent = [stringsContent stringByAppendingString:keyValueString];
    
    return stringsContent;
}







#pragma mark - 单文件国际化
-(void)singleFileLocalizedString:(NSString *)fileString{
    //读取文件，获取文件内容
    NSString *fileContent = [[CommonTools sharedInstance] getContentWithFilePath:fileString];

    //遍历出文件中的字符串内容
    NSMutableArray *replaceStringArray = [[MainDemand sharedInstance] getReplaceStringArrayWithExpression:@"(@\"[^\"]*[\\u4E00-\\u9FA5]+[^\"\n]*?\")" contentString:fileContent];
    
    //修改后的内容
    NSString *changedFileContent = [[MainDemand sharedInstance] getChengedFileContent:replaceStringArray contentString:fileContent fileString:fileString];
    
    //文件写入
    [[CommonTools sharedInstance] writeStringToFilePath:fileString contentString:changedFileContent];
}

#pragma mark - 多文件国际化
-(void)moreFileLocalizedString:(NSString *)fileString{
    
    [[CommonTools sharedInstance] showAllFileWithPath:fileString];
    CommonTools *tools = [CommonTools sharedInstance];
    tools.morePathBlock = ^(NSString * _Nonnull path) {
        [[MainDemand sharedInstance] singleFileLocalizedString:path];
    };
}

#pragma mark - 提取Strings中文文件
-(void)extractionChineseWithStrings:(NSString *)stringsPath{
    //读取文件，获取文件内容
    NSString *fileContent = [[CommonTools sharedInstance] getContentWithFilePath:stringsPath];
    //遍历出文件中的字符串内容
    NSMutableArray *replaceStringArray = [[MainDemand sharedInstance] getReplaceArrayWithExpression:@"\"[^\"]*[\\u4E00-\\u9FA5]*?\" = \"[^\"]*[\\u4E00-\\u9FA5]*?\";" contentString:fileContent];
    [self exportArrayToStringsFile:replaceStringArray];
    
    NSLog(@"\n%@",replaceStringArray);
}

#pragma mark - 导出操作
-(void)exportArrayToStringsFile:(NSMutableArray *)array{
    //字符串去重
    NSMutableArray *newArray = [NSMutableArray array];
    for(NSString *string in array){
        NSString *word = [[CommonTools sharedInstance] removeDuplicateString:string];
        //只要等号后面的
        NSRange range = [word rangeOfString:@"= "];
        NSString *otherString = [word substringFromIndex:(range.location + range.length)];
        otherString = [otherString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        otherString = [otherString stringByReplacingOccurrencesOfString:@";" withString:@""];
        [newArray addObject:otherString];
    }
    
    //去重后
    NSMutableArray *mutableArray = [self stringDuplicateRemove:newArray];
    
    NSString *contentString = [[NSString alloc] init];
    for(NSString *string in mutableArray){
        contentString = [contentString stringByAppendingString:[NSString stringWithFormat:@"%@\n",string]];
    }

    //保存到一个文件
    [[CommonTools sharedInstance] writeStringToFilePath:@"/Users/mac/Desktop/autoStings/chinese.txt" contentString:contentString];
}

-(NSMutableArray *)stringDuplicateRemove:(NSMutableArray *)array{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString * str in array) {
        [dict setObject:str forKey:str];
    }
    return [[dict allKeys] mutableCopy];
}

@end
