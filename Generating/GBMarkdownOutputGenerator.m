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
#import <GRMustache/GRMustache.h>
#import "GBMustacheModel.h"

@implementation GBMarkdownOutputGenerator

- (BOOL)generateOutputWithStore:(id)store error:(NSError **)error {
    if (![super generateOutputWithStore:store error:error]) return NO;
    NSLog(@"md debug -- start\n\n\n");
    
    
    
    for (GBClassData *class in self.store.classes) {
        
        NSLog(@"%@\n", [class mustacheHash]);
    }
    
    
    
    
    
    NSError *aerr = nil;
    NSString *rendering = [GRMustacheTemplate renderObject:@{@"obj1":@{@"obj2":@{@"obj3":@{@"obj4":@[@"aaa\n",@"bbb\n",@"ccc\n"]},
                                                                                 @"0bj5":@"hahaha"
                                                                                 }
                                                                       }
                                                             }
                                                fromString:@"Hello {{obj1.obj2.obj3.obj4}} -- {{obj1.obj2.obj5}}"
                                                     error:&aerr];
    NSLog(@"%@", rendering);
    
    /*
    for (GBClassData *classData in self.store.classes) {
        NSLog(@"%@", [classData debugDescription]);
    }
    */
    
    NSLog(@"\n\n\nmd debug -- end");
    return YES;
}
- (NSString *)outputSubpath {
    return @"markdown";
}

@end
