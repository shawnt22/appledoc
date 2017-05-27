//
//  GBCommentFormatter.h
//  appledoc
//
//  Created by 佳佑 on 17/5/26.
//  Copyright © 2017年 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBComment.h"

/**
 format rule : @name value desc
 */
@interface GBCommentFormatter : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *commentString;
@end

@interface GBCommentFormatterProvider : NSObject

/**
 格式化注释

 @param comment parse后的注释对象，主要使用其内的stringValue字段
 @return 格式化后的注释数组，元素为 GBCommentFormatter
 */
- (NSArray *)formatComment:(NSString *)comment;

@end

#define K_GBCOMMENT_FORMATTER_PARAM         @"param"        //  参数
#define K_GBCOMMENT_FORMATTER_RESULT        @"result"       //  结果
#define K_GBCOMMENT_FORMATTER_SAMPLE        @"sample"       //  示例
#define K_GBCOMMENT_FORMATTER_ABSTRACT      @"abstract"     //  简略描述
#define K_GBCOMMENT_FORMATTER_DISCUSSION    @"discussion"   //  详细描述
#define K_GBCOMMENT_FORMATTER_HEADER        @"header"
#define K_GBCOMMENT_FORMATTER_AUTHOR        @"author"
#define K_GBCOMMENT_FORMATTER_VERSION       @"version"

@interface GBComment (CommentFormatter)
@property (nonatomic, strong) NSArray *formattedParams;
@property (nonatomic, strong) NSArray *formattedResults;
@property (nonatomic, strong) GBCommentFormatter *formattedResult;
@property (nonatomic, strong) GBCommentFormatter *formattedSample;
@property (nonatomic, strong) GBCommentFormatter *formattedAbstract;
@property (nonatomic, strong) GBCommentFormatter *formattedDiscussion;
@property (nonatomic, strong) GBCommentFormatter *formattedHeader;
@property (nonatomic, strong) GBCommentFormatter *formattedAuthor;
@property (nonatomic, strong) GBCommentFormatter *formattedVersion;

- (void)dispatchFormatters;

@end
