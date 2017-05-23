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
                                                           @"methods"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
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
                                                           @"formatedTypePrefix"] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSArray *)formatedArguments
{
    NSMutableArray *list = nil;
    if (self.comment.hasMethodParameters) {
        list = [NSMutableArray arrayWithCapacity:[self.methodArguments count]];
        for (NSInteger index = 0; index < [self.methodArguments count]; index++) {
            GBCommentArgument *commentArgument = index < [self.comment.methodParameters count] ? self.comment.methodParameters[index] : nil;
            GBMethodArgument *methodArgument = self.methodArguments[index];
            
            NSString *arguVar = methodArgument.argumentVar;
            NSString *arguType = [methodArgument argumentTypeDesc];
            GBCommentComponent *component = [commentArgument.argumentDescription.components firstObject];
            NSString *arguDesc = component.stringValue;
            
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
    if (self.comment.hasMethodResult) {
        list = [NSMutableArray arrayWithCapacity:[self.methodResultTypes count]];
        
        for (NSInteger index = 0; index < [self.methodResultTypes count]; index++) {
            GBCommentComponent *component = index < [self.comment.methodResult.components count] ? self.comment.methodResult.components[index] : nil;
            NSString *type = self.methodResultTypes[index];
            
            NSString *arguType = [GBMustacheModelHelper argumentTypeDesc:type];
            NSString *arguDesc = component.stringValue;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setObjectSafely:arguDesc forKey:@"arguDesc"];
            [dict setObjectSafely:arguType forKey:@"arguType"];
            
            [list addObjectSafely:dict];
        }
    }
    return [NSArray arrayWithArray:list];
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
    [GBMustacheModelHelper addMustacheHash:self selNames:@[@"shortDescription",
                                                           @"longDescription",
                                                           @"relatedItems",
                                                           @"methodParameters",
                                                           @"methodExceptions",
                                                           @"methodResult",
                                                           @"availability",
                                                           a_isna(@"hasShortDescription"),
                                                           a_isna(@"hasLongDescription"),
                                                           a_isna(@"hasMethodParameters"),
                                                           a_isna(@"hasMethodExceptions"),
                                                           a_isna(@"hasMethodResult"),
                                                           a_isna(@"hasAvailability")] toDict:dict];
    return [NSDictionary dictionaryWithDictionary:dict];
}
- (NSValue *)hasShortDescription_VALUE
{
    return @(self.hasShortDescription);
}
- (NSValue *)hasLongDescription_VALUE
{
    return @(self.hasLongDescription);
}
- (NSValue *)hasMethodParameters_VALUE
{
    return @(self.hasMethodParameters);
}
- (NSValue *)hasMethodExceptions_VALUE
{
    return @(self.hasMethodExceptions);
}
- (NSValue *)hasMethodResult_VALUE
{
    return @(self.hasMethodResult);
}
- (NSValue *)hasAvailability_VALUE
{
    return @(self.hasAvailability);
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
        [type enumerateObjectsUsingBlock:^(NSString *  _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            [desc appendString:([type isEqualToString:@"*"] ? [NSString stringWithFormat:@" %@", type] : type)];
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