//
//  GBMarkdownOutputGenerator.m
//  appledoc
//
//  Created by 佳佑 on 17/5/15.
//  Copyright © 2017年 Gentle Bytes. All rights reserved.
//

#import "GBMarkdownOutputGenerator.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBTemplateHandler.h"
#import <GRMustache/GRMustache.h>
#import "GBMustacheModel.h"
#import "GBApplicationSettingsProvider.h"

@implementation GBMarkdownOutputGenerator

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
    if (![super generateOutputWithStore:store error:error]) return NO;
    
    if (![self validateTemplates:error]) return NO;
    if (![self processClasses:error]) return NO;
    if (![self processCategories:error]) return NO;
    if (![self processProtocols:error]) return NO;
    
    return YES;
}
- (BOOL)processClasses:(NSError **)error {
    for (GBClassData *class in self.store.classes) {
        if (!class.includeInOutput) continue;
        GBLogInfo(@"Generating output for class %@...", class);
        
        for (GBMethodData *method in class.methods.methods) {
            NSMutableDictionary *hash = [NSMutableDictionary dictionary];
            
            NSMutableDictionary *methodData = [NSMutableDictionary dictionaryWithDictionary:[method mustacheHash]];
            [self appendRNToMethodData:methodData key:@"formatedArguments"];
            [self appendRNToMethodData:methodData key:@"formatedResults"];
            [hash setObjectSafely:methodData forKey:@"methodData"];
            
            [hash setObjectSafely:[class mustacheHash] forKey:@"classData"];
            
            NSString *output = [[self documentTemplate] renderObject:hash];
            
            NSString *filename = [NSString stringWithFormat:@"%@_%@.md", class.nameOfClass, method.methodSelector];
            NSString *path = [[self.settings.outputPath stringByAppendingPathComponent:filename] stringByStandardizingPath];
            
            NSLog(@"markdown output path : %@", path);
            
            if (![self writeString:output toFile:path error:error]) {
                NSLog(@"Failed writing Markdown for class %@ to '%@'!", class, path);
                GBLogWarn(@"Failed writing Markdown for class %@ to '%@'!", class, path);
                return NO;
            }
            NSLog(@"markdown output success!");
        }
        GBLogDebug(@"Finished generating output for class %@.", class);
    }
    return YES;
}

- (BOOL)processCategories:(NSError **)error {
    return YES;
}

- (BOOL)processProtocols:(NSError **)error {
    return YES;
}
- (BOOL)validateTemplates:(NSError **)error
{
    if (!self.documentTemplate) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Object template file 'document-template.md' is missing at '%@'!", self.templateUserPath];
            *error = [NSError errorWithCode:GBErrorHTMLObjectTemplateMissing description:desc reason:nil];
        }
        return NO;
    }
    return YES;
}
- (GBTemplateHandler *)documentTemplate
{
    return self.templateFiles[@"document-template.md"];
}
- (NSString *)outputSubpath {
    return @"markdown";
}
- (void)appendRNToMethodData:(NSMutableDictionary *)methodData key:(NSString *)key
{
    if ([key length] == 0) {
        return;
    }
    NSMutableArray *formatedArguments = [NSMutableArray array];
    for (NSDictionary *dic in methodData[key]) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *arguDict = [NSMutableDictionary dictionaryWithDictionary:dic];
            [arguDict setObjectSafely:GB_MUSTACHE_RN_V forKey:GB_MUSTACHE_RN_K];
            [formatedArguments addObjectSafely:arguDict];
        } else {
            [formatedArguments addObjectSafely:dic];
        }
    }
    [methodData setObjectSafely:formatedArguments forKey:key];
}

@end
