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

- (NSArray *)formatComment:(NSString *)comment
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *sections = [self sectionsFromLines:[comment arrayOfLines]];
    for (NSArray *lines in sections) {
        NSString *sectionString = [NSString stringByCombiningLines:lines delimitWith:@"\n"];
        
        GBCommentFormatter *formatter = [GBCommentFormatter new];
        formatter.commentString = sectionString;
        
        [self separateString:sectionString formatterInfo:^(NSString *name, NSString *desc, NSString *value) {
            formatter.name = [self convertFormatterKey:name];   //  规范key格式
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
    if ([name length] > 0 && [self hasValue:name]) {
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
- (BOOL)hasValue:(NSString *)name
{
    return [[self convertFormatterKey:name] isEqualToString:K_GBCOMMENT_FORMATTER_PARAM] ? YES : NO;
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

- (NSString *)convertFormatterKey:(NSString *)key
{
    if (matchedFormatterKey(@[@"param"], key)) {
        return K_GBCOMMENT_FORMATTER_PARAM;
    } else if (matchedFormatterKey(@[@"result", @"return"], key)) {
        return K_GBCOMMENT_FORMATTER_RESULT;
    } else if (matchedFormatterKey(@[@"sample"], key)) {
        return K_GBCOMMENT_FORMATTER_SAMPLE;
    } else if (matchedFormatterKey(@[@"abstract"], key)) {
        return K_GBCOMMENT_FORMATTER_ABSTRACT;
    } else if (matchedFormatterKey(@[@"discussion"], key)) {
        return K_GBCOMMENT_FORMATTER_DISCUSSION;
    } else if (matchedFormatterKey(@[@"header"], key)) {
        return K_GBCOMMENT_FORMATTER_HEADER;
    } else if (matchedFormatterKey(@[@"author"], key)) {
        return K_GBCOMMENT_FORMATTER_AUTHOR;
    } else if (matchedFormatterKey(@[@"version"], key)) {
        return K_GBCOMMENT_FORMATTER_VERSION;
    }
    return [key lowercaseString];
}
NS_INLINE BOOL matchedFormatterKey(NSArray *keys, NSString *key)
{
    return (key && [keys containsObject:[key lowercaseString]]) ? YES : NO;
}

@end

#import <objc/runtime.h>

#define runtimeAddRProperty(P, type, p, con) \
- (void)P:(type)p {\
    objc_setAssociatedObject(self, con, p, OBJC_ASSOCIATION_RETAIN);\
}\
- (type)p {\
    return objc_getAssociatedObject(self, con);\
}\

@implementation GBComment (CommentFormatter)

- (void)dispatchFormatters
{
    self.formattedParams = [self formattedItems:K_GBCOMMENT_FORMATTER_PARAM];
    self.formattedResults = [self formattedItems:K_GBCOMMENT_FORMATTER_RESULT];
    self.formattedResult = [self.formattedResults firstObject];
    self.formattedSample = [[self formattedItems:K_GBCOMMENT_FORMATTER_SAMPLE] firstObject];
    self.formattedAbstract = [[self formattedItems:K_GBCOMMENT_FORMATTER_ABSTRACT] firstObject];
    self.formattedDiscussion = [[self formattedItems:K_GBCOMMENT_FORMATTER_DISCUSSION] firstObject];
    self.formattedHeader = [[self formattedItems:K_GBCOMMENT_FORMATTER_HEADER] firstObject];
    self.formattedAuthor = [[self formattedItems:K_GBCOMMENT_FORMATTER_AUTHOR] firstObject];
    self.formattedVersion = [[self formattedItems:K_GBCOMMENT_FORMATTER_VERSION] firstObject];
}
- (NSArray *)formattedItems:(NSString *)name
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
    for (GBCommentFormatter *formatter in self.formatters) {
        if (formatter.name && [[name lowercaseString] isEqualToString:[formatter.name lowercaseString]]) {
            [results addObject:formatter];
        }
    }
    return results;
}

runtimeAddRProperty(setFormattedParams, NSArray *, formattedParams, "GB_COM_FORMAT_formattedParams")
runtimeAddRProperty(setFormattedResults, NSArray *, formattedResults, "GB_COM_FORMAT_formattedResults")
runtimeAddRProperty(setFormattedResult, GBCommentFormatter *, formattedResult, "GB_COM_FORMAT_formattedResult")
runtimeAddRProperty(setFormattedSample, GBCommentFormatter *, formattedSample, "GB_COM_FORMAT_formattedSample")
runtimeAddRProperty(setFormattedAbstract, GBCommentFormatter *, formattedAbstract, "GB_COM_FORMAT_formattedAbstract")
runtimeAddRProperty(setFormattedDiscussion, GBCommentFormatter *, formattedDiscussion, "GB_COM_FORMAT_formattedDiscussion")
runtimeAddRProperty(setFormattedHeader, GBCommentFormatter *, formattedHeader, "GB_COM_FORMAT_formattedHeader")
runtimeAddRProperty(setFormattedAuthor, GBCommentFormatter *, formattedAuthor, "GB_COM_FORMAT_formattedAuthor")
runtimeAddRProperty(setFormattedVersion, GBCommentFormatter *, formattedVersion, "GB_COM_FORMAT_formattedVersion")

@end
