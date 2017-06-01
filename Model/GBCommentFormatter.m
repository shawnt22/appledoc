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
    if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_PARAM, @"param"], key)) {
        return K_GBCOMMENT_FORMATTER_PARAM;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_RESULT, @"result", @"return"], key)) {
        return K_GBCOMMENT_FORMATTER_RESULT;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_ABSTRACT, @"abstract"], key)) {
        return K_GBCOMMENT_FORMATTER_ABSTRACT;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_DISCUSSION, @"discussion"], key)) {
        return K_GBCOMMENT_FORMATTER_DISCUSSION;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_HEADER, @"header"], key)) {
        return K_GBCOMMENT_FORMATTER_HEADER;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_AUTHOR, @"author"], key)) {
        return K_GBCOMMENT_FORMATTER_AUTHOR;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_VERSION, @"version"], key)) {
        return K_GBCOMMENT_FORMATTER_VERSION;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_ALI_SAMPLE, @"sample"], key)) {
        return K_GBCOMMENT_FORMATTER_ALI_SAMPLE;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_ALI_IGNOR, @"ignor"], key)) {
        return K_GBCOMMENT_FORMATTER_ALI_IGNOR;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_ATOM_CATEGARY, @"categary"], key)) {
        return K_GBCOMMENT_FORMATTER_ATOM_CATEGARY;
        
    } else if (matchedFormatterKey(@[K_GBCOMMENT_FORMATTER_ATOM_TITLE, @"title"], key)) {
        return K_GBCOMMENT_FORMATTER_ATOM_TITLE;
        
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
    //  multi-item
    self.com_params = [self formattedItems:K_GBCOMMENT_FORMATTER_PARAM];
    self.com_results = [self formattedItems:K_GBCOMMENT_FORMATTER_RESULT];
    
    //  single-item
    self.com_abstract = [[self formattedItems:K_GBCOMMENT_FORMATTER_ABSTRACT] firstObject];
    self.com_discussion = [[self formattedItems:K_GBCOMMENT_FORMATTER_DISCUSSION] firstObject];
    self.com_header = [[self formattedItems:K_GBCOMMENT_FORMATTER_HEADER] firstObject];
    self.com_author = [[self formattedItems:K_GBCOMMENT_FORMATTER_AUTHOR] firstObject];
    self.com_version = [[self formattedItems:K_GBCOMMENT_FORMATTER_VERSION] firstObject];
    self.ali_sample = [[self formattedItems:K_GBCOMMENT_FORMATTER_ALI_SAMPLE] firstObject];
    self.ali_ignor = [[self formattedItems:K_GBCOMMENT_FORMATTER_ALI_IGNOR] firstObject];
    self.atom_categary = [[self formattedItems:K_GBCOMMENT_FORMATTER_ATOM_CATEGARY] firstObject];
    self.atom_title = [[self formattedItems:K_GBCOMMENT_FORMATTER_ATOM_TITLE] firstObject];
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

runtimeAddRProperty(setCom_params, NSArray *, com_params, "GB_COM_FORMAT_com_params")
runtimeAddRProperty(setCom_results, NSArray *, com_results, "GB_COM_FORMAT_com_results")
runtimeAddRProperty(setCom_abstract, GBCommentFormatter *, com_abstract, "GB_COM_FORMAT_com_abstract")
runtimeAddRProperty(setCom_discussion, GBCommentFormatter *, com_discussion, "GB_COM_FORMAT_com_discussion")
runtimeAddRProperty(setCom_header, GBCommentFormatter *, com_header, "GB_COM_FORMAT_com_header")
runtimeAddRProperty(setCom_author, GBCommentFormatter *, com_author, "GB_COM_FORMAT_com_author")
runtimeAddRProperty(setCom_version, GBCommentFormatter *, com_version, "GB_COM_FORMAT_com_version")

runtimeAddRProperty(setAli_sample, GBCommentFormatter *, ali_sample, "GB_COM_FORMAT_ali_sample")
runtimeAddRProperty(setAli_ignor, GBCommentFormatter *, ali_ignor, "GB_COM_FORMAT_ali_ignor")
runtimeAddRProperty(setAtom_categary, GBCommentFormatter *, atom_categary, "GB_COM_FORMAT_atom_categary")
runtimeAddRProperty(setAtom_title, GBCommentFormatter *, atom_title, "GB_COM_FORMAT_atom_title")

@end
