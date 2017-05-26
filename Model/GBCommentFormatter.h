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
- (NSArray *)formatComment:(GBComment *)comment;

@end
