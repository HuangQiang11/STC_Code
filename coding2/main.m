//
//  main.m
//  coding2
//
//  Created by qiang on 2019/10/23.
//  Copyright © 2019 pan. All rights reserved.
//

#import <Foundation/Foundation.h>

//文件路径
NSString * kFilePath = @"";
//混编跨度
const NSInteger kCodingOffset = 6;
//方法前缀
NSString * kPreMethod = @"ls_";
//随机数
const NSInteger kRandom = 2;
//给方法名加前缀且随机筛选n个字符加offset
NSString * codingMethodNameText(NSString *text,NSString * pre,NSInteger n,NSInteger offset);
//字符串随机n个加offset
NSString * changeRandomASCIIVaule(NSString *testStr, NSInteger n,NSInteger offset);
//字符串s码加offset
NSString * addASCIIValue(NSString * testStr, NSInteger offset);
//一个字符s码加offset
char addASCIIChar(char tem, NSInteger offset);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
                NSLog(@"开始混编");//方法名称混编
                NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:kFilePath encoding:NSUTF8StringEncoding error:nil];
                NSMutableArray * arr = [fileContent componentsSeparatedByString:@"\n"].mutableCopy;
                NSString * preStr = nil;
                NSString * preCodeStr = nil;
                BOOL isMethod = NO;
                for (NSInteger i=0 ; i<arr.count; i++) {
                    NSString * lineStr = arr[i];
                    if ([lineStr hasSuffix:@"方法名修改（此行为标识不可以删除）"]) {
                        isMethod = YES;
                        continue;
                    }else if([lineStr hasSuffix:@"属性名修改（此行为标识不可以删除）"]){
                        isMethod = NO;
                        continue;
                    }
                    
                    if ([lineStr rangeOfString:@"#define"].location != NSNotFound) {
                        if (isMethod) {//方法名混编
                            NSUInteger n = [lineStr rangeOfString:@"#define"].location;
                            if (n != 0) {
                                lineStr = [lineStr substringFromIndex:n];
                            }
                            NSMutableArray * lineArr = [lineStr componentsSeparatedByString:@" "].mutableCopy;
                            if (lineArr.count == 3) {
                                lineArr[2] = codingMethodNameText(lineArr[1], kPreMethod, kRandom, kCodingOffset);
                            }
                            arr[i] = [lineArr componentsJoinedByString:@" "];
                        }else{//属性名混编
                            NSUInteger n = [lineStr rangeOfString:@"#define"].location;
                            if (n != 0) {
                                lineStr = [lineStr substringFromIndex:n];
                            }
                            NSMutableArray * lineArr = [lineStr componentsSeparatedByString:@" "].mutableCopy;
                            if (lineArr.count == 3) {
                                if (preStr) {
                                    if ([[NSString stringWithFormat:@"_%@",preStr] isEqualToString:lineArr[1]]) {//_systemLoadingV 对比
                                        lineArr[2] = [NSString stringWithFormat:@"_%@",preCodeStr];
                                    }else if ([[NSString stringWithFormat:@"set%@%@",[[preStr capitalizedString] substringWithRange:NSMakeRange(0, 1)],[preStr substringFromIndex:1]] isEqualToString:lineArr[1]]){//setSystemLoadingV对比
                                        lineArr[2] = [NSString stringWithFormat:@"set%@%@",[[preCodeStr capitalizedString] substringWithRange:NSMakeRange(0, 1)],[preCodeStr substringFromIndex:1]];;
                                    }else{
                                        lineArr[2] = changeRandomASCIIVaule(lineArr[1],kRandom,kCodingOffset);
                                        preStr = lineArr[1];
                                        preCodeStr = lineArr[2];
                                    }
                                }else{
                                    lineArr[2] = changeRandomASCIIVaule(lineArr[1],kRandom,kCodingOffset);
                                    preStr = lineArr[1];
                                    preCodeStr = lineArr[2];
                                }
                                
                            }
                            arr[i] = [lineArr componentsJoinedByString:@" "];
                        }
                    }
                }
                NSString * newFileContent = [arr componentsJoinedByString:@"\n"];
        
                [newFileContent writeToFile:kFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"混编完毕");

        
        
        
//        NSLog(@"开始混编");//方法名称混编
//        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:kFilePath encoding:NSUTF8StringEncoding error:nil];
//        NSMutableArray * arr = [fileContent componentsSeparatedByString:@"\n"].mutableCopy;
//        for (NSInteger i=0 ; i<arr.count; i++) {
//            NSString * lineStr = arr[i];
//            if ([lineStr rangeOfString:@"#define"].location != NSNotFound) {
//                NSUInteger n = [lineStr rangeOfString:@"#define"].location;
//                if (n != 0) {
//                    lineStr = [lineStr substringFromIndex:n];
//                }
//                NSMutableArray * lineArr = [lineStr componentsSeparatedByString:@" "].mutableCopy;
//                if (lineArr.count == 3) {
//                    lineArr[2] = codingMethodNameText(lineArr[1], kPreMethod, kRandom, kCodingOffset);
//                }
//                arr[i] = [lineArr componentsJoinedByString:@" "];
//            }
//        }
//        NSString * newFileContent = [arr componentsJoinedByString:@"\n"];
//
//        [newFileContent writeToFile:kFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        NSLog(@"混编完毕");
    }
    return 0;
}






NSString * codingMethodNameText(NSString *text,NSString * pre,NSInteger n,NSInteger offset){
    
//    setTwoListLayout  属性set方法需要特殊处理
//    if ([text hasPrefix:@"set"]) {
//        pre = @"set";
//    }
    
    
    NSString * testStr = text;
    BOOL hasPre = NO;
    if ([text hasPrefix:pre]) {
        testStr = [text substringFromIndex:pre.length];
        hasPre = YES;
    }else{
        testStr = text;
        hasPre = YES;
    }

    testStr = changeRandomASCIIVaule(testStr, n, offset);
    if (hasPre) {
        return [NSString stringWithFormat:@"%@%@",pre,testStr];
    }else{
        return text;
    }
}

NSString * changeRandomASCIIVaule(NSString *testStr, NSInteger n,NSInteger offset){
    NSMutableString * newStr = testStr.mutableCopy;
    const char * s = [testStr cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long len = strlen(s);
    if (len > 0) {
        for (NSInteger i = 0; i < n; i++) {
            NSInteger random = arc4random()%len;
            char tem = s[random];
            tem = addASCIIChar(tem, offset);
            [newStr replaceCharactersInRange:NSMakeRange(random, 1) withString:[NSString stringWithFormat:@"%c",tem]];
        }
    }
    return newStr;
}


//字符串s码加offset
NSString * addASCIIValue(NSString * testStr, NSInteger offset){
    const char * s = [testStr cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long len = strlen(s);
    NSMutableString * newStr = [NSMutableString string];
    for (int i = 0; i<len; i++) {
        char tem = s[i];
        
        tem = addASCIIChar(tem, kCodingOffset);
        
        [newStr appendFormat:@"%c",tem];
    }
    return newStr;
}

char addASCIIChar(char tem, NSInteger offset){
    if (tem >= 65 && tem <= 90) {
        tem = tem + offset;
        if (tem > 90) {
            tem = tem - 90 + 65 -1;
        }
    }else if (tem >= 97 && tem <= 122) {
        tem = tem + offset;
        if (tem > 122) {
            tem = tem - 122 + 97 -1;
        }
    }
    return tem;
}



