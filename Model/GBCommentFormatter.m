//
//  GBCommentFormatter.m
//  appledoc
//
//  Created by 佳佑 on 17/5/26.
//  Copyright © 2017年 Gentle Bytes. All rights reserved.
//

#import "GBCommentFormatter.h"
#import "GBCommentComponentsProvider.h"
#import <RegexKitLite/RegexKitLite.h>

@implementation GBCommentFormatter
- (NSString *)description
{
    return [self debugDescription];
}
- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"name: %@ value: %@ desc: %@", self.name, self.value, self.desc];
}
@end

@implementation GBCommentFormatterProvider

- (NSArray *)formatComment:(GBComment *)comment
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *sections = [self sectionsFromLines:[comment.stringValue arrayOfLines]];
    for (NSArray *lines in sections) {
        NSString *commentString = @"";
        for (NSUInteger index = 0; index < [lines count]; index++) {
            //  组装回原字符串
            commentString = [NSString stringWithFormat:@"%@%@%@", commentString, (index==[lines count]-1 ? @"" : @"\n"), lines[index]];
        }
        GBCommentFormatter *formatter = [GBCommentFormatter new];
        formatter.commentString = commentString;
        
        [self separateString:commentString formatterInfo:^(NSString *name, NSString *desc, NSString *value) {
            formatter.name = name;
            formatter.desc = desc;
            formatter.value = value;
        }];
        if ([formatter.name length] > 0 || [formatter.value length] > 0 || [formatter.desc length] > 0) {
            [result addObject:formatter];
        }
    }
    return result;
}

/**
 逐个字符分析，分拣出格式化需要的基本信息，分拣规则 : @name value desc
 */
- (void)separateString:(NSString *)string formatterInfo:(void(^)(NSString *name, NSString *desc, NSString *value))formatterInfo
{
    NSString *name = @"";
    NSString *desc = @"";
    NSString *value = @"";
    
    NSUInteger loc = 0;
    NSUInteger len = 1;
    //  优先填充 name
    BOOL hasName = NO;
    while (loc < [string length]) {
        NSString *character = [string substringWithRange:NSMakeRange(loc, len)];
        if ([character isEqualToString:@" "] || [character isEqualToString:@"\n"]) {
            if (hasName) {
                //  name分拣完毕
                loc++;
                break;
            } else {
                //  忽略空格、换行
            }
        } else if ([character isEqualToString:@"@"]) {
            hasName = YES;
        } else {
            if (hasName) {
                name = [NSString stringWithFormat:@"%@%@", name, character];
            } else {
                //  未包含合法的 @name 结构，不再填充name
                loc = 0;    //  重置游标
                break;
            }
        }
        loc++;
    }
    
    //  其次填充 value
    if ([name length] > 0 && [self hasValue:string]) {
        BOOL hasValue = NO;
        NSUInteger oriLoc = loc;    //  缓存原游标
        while (loc < [string length]) {
            NSString *character = [string substringWithRange:NSMakeRange(loc, len)];
            if ([character isEqualToString:@" "] || [character isEqualToString:@"\n"]) {
                if (hasValue) {
                    loc++;
                    break;
                } else {
                    //  忽略空格、换行
                }
            } else {
                hasValue = YES;
                value = [NSString stringWithFormat:@"%@%@", value, character];
            }
            loc++;
        }
        if (![self checkValue:value]) {
            //  无效的结果，重置状态
            loc = oriLoc;
            value = @"";
        }
    }
    
    //  最后填充 desc
    while (loc < [string length]) {
        NSString *character = [string substringWithRange:NSMakeRange(loc, len)];
        if ([character isEqualToString:@" "] || [character isEqualToString:@"\n"]) {
            //  过滤空过、换行
            loc++;
        } else {
            break;
        }
    }
    desc = loc < [string length] ? [string substringFromIndex:loc] : @"";
    
    if (formatterInfo) formatterInfo(name, desc, value);
}
- (BOOL)hasValue:(NSString *)string
{
    NSArray *components = [string captureComponentsMatchedByRegex:[[GBCommentComponentsProvider provider] parameterDescriptionRegex]];
    return [components count] > 0 ? YES : NO;
}
- (BOOL)checkValue:(NSString *)value
{
    return YES;
}

/**
 按单行前缀 @ 分组
 */
- (NSArray *)sectionsFromLines:(NSArray<NSString *> *)lines
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    __block NSMutableArray *section = [NSMutableArray arrayWithCapacity:1];
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[line stringByReplacingOccurrencesOfString:@" " withString:@""] hasPrefix:@"@"]) {
            if ([section count] > 0) [results addObject:section];    //  追加前一组
            section = [NSMutableArray arrayWithCapacity:1];
        }
        [section addObject:line];
    }];
    if ([section count] > 0)  [results addObject:section];    //  追加最后一组
    return results;
}

@end
