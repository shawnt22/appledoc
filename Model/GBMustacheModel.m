//
//  GBMustacheModel.m
//  appledoc
//
//  Created by 佳佑 on 17/5/18.
//  Copyright © 2017年 Gentle Bytes. All rights reserved.
//

#import "GBMustacheModel.h"

@implementation GBModelBase (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"comment"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBClassData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"nameOfClass",
                                                           @"nameOfSuperclass",
                                                           @"superclass",
                                                           @"adoptedProtocols",
                                                           @"methods",
                                                           a_isna(@"hasProtocols"),
                                                           @"formattedProtocols"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSString *)formattedProtocols
{
    if ([self.adoptedProtocols.protocols count] > 0) {
        NSMutableString *result = [NSMutableString stringWithString:@"<"];
        NSArray *protocols = self.adoptedProtocols.protocolsSortedByName;
        [protocols enumerateObjectsUsingBlock:^(GBProtocolData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [result appendFormat:@"%@%@", obj.nameOfProtocol, (idx==[protocols count]-1 ? @">" : @", ")];
        }];
        return result;
    }
    return nil;
}
- (NSValue *)hasProtocols_VALUE
{
    return @([self.adoptedProtocols.protocols count] > 0 ? YES : NO);
}

@end

@implementation GBCategoryData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[a_isna(@"isExtension"),
                                                           @"nameOfCategory",
                                                           @"nameOfClass",
                                                           @"idOfCategory",
                                                           @"adoptedProtocols",
                                                           @"methods"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSValue *)isExtension_VALUE
{
    return @(self.isExtension);
}

@end

@implementation GBProtocolData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"nameOfProtocol",
                                                           @"adoptedProtocols",
                                                           @"methods"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBAdoptedProtocolsProvider (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"protocols"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBMethodsProvider (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"methods",
                                                           @"classMethods",
                                                           @"instanceMethods",
                                                           @"properties",
                                                           a_isna(@"hasClassMethods"),
                                                           a_isna(@"hasInstanceMethods"),
                                                           a_isna(@"hasProperties")] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSValue *)hasClassMethods_VALUE
{
    return @(self.hasClassMethods);
}
- (NSValue *)hasInstanceMethods_VALUE
{
    return @(self.hasInstanceMethods);
}
- (NSValue *)hasProperties_VALUE
{
    return @(self.hasProperties);
}

@end

@implementation GBMethodData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"methodAttributes",
                                                           @"methodResultTypes",
                                                           @"methodArguments",
                                                           @"methodSelector",
                                                           @"methodReturnType",
                                                           @"methodTypeString",
                                                           @"formatedArguments",
                                                           @"formatedResults",
                                                           @"formatedTypePrefix",
                                                           a_isna(@"hasArguments"),
                                                           a_isna(@"hasResults")] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSString *)formatedTypePrefix
{
    NSString *prefix = nil;
    switch (self.methodType) {
        case GBMethodTypeClass:
            prefix = @"+";
            break;
        case GBMethodTypeInstance:
            prefix = @"-";
            break;
        default:
            break;
    }
    return prefix;
}
- (NSArray *)formatedArguments
{
    NSMutableArray *list = nil;
    if ([self hasArguments_VALUE]) {
        list = [NSMutableArray arrayWithCapacity:[self.methodArguments count]];
        for (NSInteger index = 0; index < [self.methodArguments count]; index++) {
            GBMethodArgument *methodArgument = self.methodArguments[index];
            GBCommentFormatter *formatter = index < [self.comment.com_params count] ? self.comment.com_params[index] : nil;
            
            NSString *arguVar = methodArgument.argumentVar;
            NSString *arguType = [methodArgument argumentTypeDesc];
            NSString *arguDesc = formatter.desc;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setObjectSafely:arguVar forKey:@"arguVar"];
            [dict setObjectSafely:arguType forKey:@"arguType"];
            [dict setObjectSafely:arguDesc forKey:@"arguDesc"];
            
            [list addObjectSafely:dict];
        }
    }
    return [NSArray arrayWithArray:list];
}
- (NSArray *)formatedResults
{
    NSMutableArray *list = nil;
    if ([self hasResults_VALUE]) {
        list = [NSMutableArray arrayWithCapacity:[self.methodResultTypes count]];
        
        GBCommentFormatter *formatter = [self.comment.com_results firstObject];
        NSString *arguDesc = formatter.desc;
        
        NSMutableString *arguType = [NSMutableString stringWithString:@""];
        [self.methodResultTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            [arguType appendString:([self.methodResultTypes count]-1 == idx ? type : [NSString stringWithFormat:@"%@ ", type])];
        }];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setObjectSafely:arguDesc forKey:@"arguDesc"];
        [dict setObjectSafely:arguType forKey:@"arguType"];
        
        [list addObjectSafely:dict];
    }
    return [NSArray arrayWithArray:list];
}
- (NSValue *)hasArguments_VALUE
{
    return @([self.methodArguments count] > 0 ? YES : NO);
}
- (NSValue *)hasResults_VALUE
{
    return @(self.comment.hasMethodResult);
}


@end

@implementation GBMethodArgument (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"argumentName",
                                                           @"argumentTypes",
                                                           @"argumentVar",
                                                           @"argumentTypeDesc"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSString *)argumentTypeDesc
{
    return [GBMustacheModelHelper argumentTypeDesc:self.argumentTypes];
}

@end

@implementation GBTypedefEnumData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"nameOfEnum",
                                                           @"enumPrimitive",
                                                           @"enumStyle",
                                                           @"methodSelector",
                                                           @"methodReturnType",
                                                           @"methodTypeString"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBEnumConstantData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"name",
                                                           @"assignedValue",
                                                           a_isna(@"hasAssignedValue")] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSValue *)hasAssignedValue_VALUE
{
    return @(self.hasAssignedValue);
}

@end

@implementation GBEnumConstantProvider (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"constants"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSArray *)mustacheHashList
{
    return nil;
}

@end

@implementation GBTypedefBlockData (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"nameOfBlock",
                                                           @"returnType",
                                                           @"parameters"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBTypedefBlockArgument (GRMustacheHash)

- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[super mustacheHashDict]];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"name",
                                                           @"className",
                                                           @"href"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBSourceInfo (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"filename"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBComment (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"com_params",
                                                           @"com_results",
                                                           @"com_abstract",
                                                           @"com_discussion",
                                                           @"ali_sample",
                                                           @"atom_categary",
                                                           @"atom_title",
                                                           a_isna(@"hascom_params"),
                                                           a_isna(@"hascom_results"),
                                                           a_isna(@"hascom_abstract"),
                                                           a_isna(@"hascom_discussion"),
                                                           a_isna(@"hasali_sample"),
                                                           a_isna(@"hasatom_categary"),
                                                           a_isna(@"hasatom_title"),
                                                           @"formatters",
                                                           @"sourceInfo"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSValue *)hascom_params_VALUE
{
    return @([self.com_params count] > 0 ? YES : NO);
}
- (NSValue *)hascom_results_VALUE
{
    return @([self.com_results count] > 0 ? YES : NO);
}
- (NSValue *)hascom_abstract_VALUE
{
    return @(self.com_abstract ? YES : NO);
}
- (NSValue *)hascom_discussion_VALUE
{
    return @(self.com_discussion ? YES : NO);
}
- (NSValue *)hasali_sample_VALUE
{
    return @(self.ali_sample ? YES : NO);
}
- (NSValue *)hasatom_categary_VALUE
{
    return @(self.atom_categary ? YES : NO);
}
- (NSValue *)hasatom_title_VALUE
{
    return @(self.atom_title ? YES : NO);
}

@end

@implementation GBCommentComponent (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"stringValue",
                                                           @"markdownValue",
                                                           @"htmlValue",
                                                           @"textValue"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBCommentComponentsList (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"components"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBCommentArgument (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"argumentName",
                                                           @"argumentDescription"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation GBCommentFormatter (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"name",
                                                           @"desc",
                                                           @"value"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

#pragma mark -

@implementation NSDictionary (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    return nil;
}
- (NSDictionary *)mustacheHashDict
{
    NSMutableDictionary *hashDict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    [self.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id<GBMustacheModel> value = self[key];
        if ([value conformsToProtocol:@protocol(GBMustacheModel)]) {
            [hashDict setObjectSafely:[value mustacheHash] forKey:key];
        }
    }];
    return [NSDictionary dictionaryWithDictionary:hashDict];
}

@end

@implementation NSArray (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    NSMutableArray *hashlist = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(GBMustacheModel)]) {
            id<GBMustacheModel> model = obj;
            [hashlist addObjectSafely:[model mustacheHash]];
        }
    }];
    return [NSArray arrayWithArray:hashlist];
}
- (NSDictionary *)mustacheHashDict
{
    return nil;
}

@end

@implementation NSSet (GRMustacheHash)

- (id)mustacheHash
{
    return [GBMustacheModelHelper mustacheHash:self];
}
- (NSArray *)mustacheHashList
{
    NSMutableArray *hashlist = [NSMutableArray arrayWithCapacity:[self count]];
    [[self allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(GBMustacheModel)]) {
            id<GBMustacheModel> model = obj;
            [hashlist addObjectSafely:[model mustacheHash]];
        }
    }];
    return [NSArray arrayWithArray:hashlist];
}
- (NSDictionary *)mustacheHashDict
{
    return nil;
}

@end

@implementation NSValue (GRMustacheHash)

- (id)mustacheHash
{
    return self;
}
- (NSDictionary *)mustacheHashDict
{
    return nil;
}
- (NSArray *)mustacheHashList
{
    return nil;
}

@end

@implementation NSString (GRMustacheHash)

- (id)mustacheHash
{
    return self;
}
- (NSDictionary *)mustacheHashDict
{
    return nil;
}
- (NSArray *)mustacheHashList
{
    return nil;
}

@end

#pragma mark -

@implementation GBMustacheModelHelper

+ (id)mustacheHash:(id<GBMustacheModel>)model
{
    id result = nil;
    if ([model conformsToProtocol:@protocol(GBMustacheModel)]) {
        if ([model respondsToSelector:@selector(mustacheHashDict)]) {
            NSDictionary *dict = [model mustacheHashDict];
            if ([dict count] > 0) {
                result = dict;
            }
        }
        if (!result) {
            if ([model respondsToSelector:@selector(mustacheHashList)]) {
                NSArray *list = [model mustacheHashList];
                if ([list count] > 0) {
                    result = list;
                }
            }
        }
    }
    return result;
}
+ (void)addMustacheHash:(id<GBMustacheModel>)model selNames:(NSArray *)selNames toDict:(NSMutableDictionary *)dict
{
    if ([model conformsToProtocol:@protocol(GBMustacheModel)]) {
        [selNames enumerateObjectsUsingBlock:^(NSString * _Nonnull aname, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isna = isna(aname) ? YES : NO;
            aname = r_isna(aname);
            SEL selector = NSSelectorFromString(isna ? [NSString stringWithFormat:@"%@_VALUE", aname] : aname);
            if ([model respondsToSelector:selector]) {
                id<GBMustacheModel> value = [model performSelector:selector];
                if ([value conformsToProtocol:@protocol(GBMustacheModel)]) {
                    [dict setObjectSafely:[value mustacheHash] forKey:aname];
                }
            }
        }];
    }
}
+ (BOOL)hasIsnaPrefix:(NSString *)str
{
    return [str hasPrefix:@"+"] ? YES : NO;
}
+ (NSString *)addIsnaPrefix:(NSString *)str
{
    if (![GBMustacheModelHelper hasIsnaPrefix:str]) {
        return [NSString stringWithFormat:@"+%@",str];
    }
    return str;
}
+ (NSString *)removeIsnaPrefix:(NSString *)str
{
    if ([GBMustacheModelHelper hasIsnaPrefix:str]) {
        //return [str length] > 1 ? [str substringWithRange:NSMakeRange(1, [str length])] : @"";
        return [str substringWithRange:NSMakeRange(1, [str length]-1)];
    }
    return str;
}

+ (NSString *)argumentTypeDesc:(id)type
{
    NSMutableString *desc = [NSMutableString stringWithString:@""];
    if ([type isKindOfClass:[NSString class]]) {
        [desc appendString:type];
    } else if ([type isKindOfClass:[NSArray class]]) {
        [type enumerateObjectsUsingBlock:^(NSString *  _Nonnull atype, NSUInteger idx, BOOL * _Nonnull stop) {
            [desc appendString:([type count]-1 == idx ? atype : [NSString stringWithFormat:@"%@ ", atype])];
        }];
    }
    return desc;
}

@end

@implementation NSMutableArray (GBHelpers)

- (void)addObjectSafely:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

@end

@implementation NSMutableDictionary (GBHelpers)

- (void)setObjectSafely:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
