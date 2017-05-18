//
//  GBMustacheModel.h
//  appledoc
//
//  Created by 佳佑 on 17/5/18.
//  Copyright © 2017年 Gentle Bytes. All rights reserved.
//

/*
 NOTE:
 
 *. 实现策略上对主要的GB类Model都做一个Mustache的扩展，用来提供模板渲染时使用的hash信息
 *. 针对Model类的基本类型（bool、int、float、struct...），需要额外的实现一个 方法名 + "_VALUE" 格式的方法，转成NSValue后再录入mustache的hash信息内
 *. 提供了一个用于在mustache模板内换行的宏，方便markdown类模板内换行 { GB_MUSTACHE_RN_K : GB_MUSTACHE_RN_V }
 *. - mustacheHash 方法执行时有优先级 : HashDict > HashList 一般一个Model在实现GBMustacheModel扩展协议时只需实现一个方法即可，要么是HashDic，要么是HashList
 *. GBMustacheModelHelper工具接口里提供的 + addMustacheHash 方法主要思路是直接指定model内可hash的方法名，通过runtime动态填充到hash信息内
 *. + addMustacheHash 方法指定基本类型的方法名时，需要通过 isna(str) 宏添加特殊的前缀来特殊处理
 
 */

#import <Foundation/Foundation.h>
#import <GRMustache/GRMustache.h>
#import "GBDataObjects.h"

#define GB_MUSTACHE_RN_K @"rn"  //  模板内换行符 - KEY
#define GB_MUSTACHE_RN_V @"\n"  //  模板内换行符 - VALUE

@protocol GBMustacheModel <NSObject>

@required
- (id)mustacheHash;

@optional
- (NSArray *)mustacheHashList;
- (NSDictionary *)mustacheHashDict;

@end

#pragma mark - MUSTACHE

@interface GBModelBase (GRMustacheHash) <GBMustacheModel>

@end

@interface GBClassData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBCategoryData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBProtocolData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBAdoptedProtocolsProvider (GRMustacheHash) <GBMustacheModel>

@end

@interface GBMethodsProvider (GRMustacheHash) <GBMustacheModel>

@end

@interface GBMethodData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBMethodArgument (GRMustacheHash) <GBMustacheModel>

@end

@interface GBTypedefEnumData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBEnumConstantData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBEnumConstantProvider (GRMustacheHash) <GBMustacheModel>

@end

@interface GBTypedefBlockData (GRMustacheHash) <GBMustacheModel>

@end

@interface GBTypedefBlockArgument (GRMustacheHash) <GBMustacheModel>

@end

@interface GBComment (GRMustacheHash) <GBMustacheModel>

@end

@interface GBCommentComponent (GRMustacheHash) <GBMustacheModel>

@end

@interface GBCommentComponentsList (GRMustacheHash) <GBMustacheModel>

@end

@interface GBCommentArgument (GRMustacheHash) <GBMustacheModel>

@end

@interface NSArray (GRMustacheHash) <GBMustacheModel>

@end

@interface NSSet (GRMustacheHash) <GBMustacheModel>

@end

@interface NSValue (GRMustacheHash) <GBMustacheModel>

@end

@interface NSString (GRMustacheHash) <GBMustacheModel>

@end

#pragma mark - HELP

#define isna(str)   [GBMustacheModelHelper hasIsnaPrefix:str]
#define a_isna(str) [GBMustacheModelHelper addIsnaPrefix:str]
#define r_isna(str) [GBMustacheModelHelper removeIsnaPrefix:str]

@interface GBMustacheModelHelper : NSObject
+ (id)mustacheHash:(id<GBMustacheModel>)model;
+ (void)addMustacheHash:(id<GBMustacheModel>)model selNames:(NSArray *)selNames toDict:(NSMutableDictionary *)dict;

+ (BOOL)hasIsnaPrefix:(NSString *)str;
+ (NSString *)addIsnaPrefix:(NSString *)str;
+ (NSString *)removeIsnaPrefix:(NSString *)str;
@end

@interface NSMutableArray (GBHelpers)
- (void)addObjectSafely:(id)anObject;
@end

@interface NSMutableDictionary (GBHelpers)
- (void)setObjectSafely:(id)anObject forKey:(id<NSCopying>)aKey;
@end
