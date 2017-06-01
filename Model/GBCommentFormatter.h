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

#pragma mark -

//  基本的
#define K_GBCOMMENT_FORMATTER_PARAM         @"com_param"        //  参数
#define K_GBCOMMENT_FORMATTER_RESULT        @"com_result"       //  结果
#define K_GBCOMMENT_FORMATTER_ABSTRACT      @"com_abstract"     //  简略描述
#define K_GBCOMMENT_FORMATTER_DISCUSSION    @"com_discussion"   //  详细描述
#define K_GBCOMMENT_FORMATTER_HEADER        @"com_header"
#define K_GBCOMMENT_FORMATTER_AUTHOR        @"com_author"
#define K_GBCOMMENT_FORMATTER_VERSION       @"com_version"
//  支付宝扩展的
#define K_GBCOMMENT_FORMATTER_ALI_SAMPLE    @"ali_sample"   //  示例
#define K_GBCOMMENT_FORMATTER_ALI_IGNOR     @"ali_ignor"    //  忽略
//  ATOM网站扩展的
#define K_GBCOMMENT_FORMATTER_ATOM_CATEGARY @"atom_categary"    //  功能类目名称
#define K_GBCOMMENT_FORMATTER_ATOM_TITLE    @"atom_title"       //  功能名称

@interface GBComment (CommentFormatter)
@property (nonatomic, strong) NSArray *com_params;
@property (nonatomic, strong) NSArray *com_results;
@property (nonatomic, strong) GBCommentFormatter *com_abstract;
@property (nonatomic, strong) GBCommentFormatter *com_discussion;
@property (nonatomic, strong) GBCommentFormatter *com_header;
@property (nonatomic, strong) GBCommentFormatter *com_author;
@property (nonatomic, strong) GBCommentFormatter *com_version;
@property (nonatomic, strong) GBCommentFormatter *ali_sample;
@property (nonatomic, strong) GBCommentFormatter *ali_ignor;
@property (nonatomic, strong) GBCommentFormatter *atom_categary;
@property (nonatomic, strong) GBCommentFormatter *atom_title;

- (void)dispatchFormatters;

@end
