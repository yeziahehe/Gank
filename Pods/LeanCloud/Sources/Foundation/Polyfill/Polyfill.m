//
//  Polyfill.m
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/10/15.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

#import "Polyfill.h"

@implementation NSObject (LeanCloud)

- (id)lc_associatedObjectForKey:(NSString *)key {
    SEL selector = sel_registerName(key.UTF8String);
    id object = objc_getAssociatedObject(self, selector);
    return object;
}

- (void)lc_associateObject:(id)object forKey:(NSString *)key policy:(objc_AssociationPolicy)policy {
    SEL selector = sel_registerName(key.UTF8String);
    objc_setAssociatedObject(self, selector, object, policy);
}

@end
