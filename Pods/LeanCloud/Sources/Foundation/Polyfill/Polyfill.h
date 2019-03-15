//
//  Polyfill.h
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/10/15.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LeanCloud)

- (nullable id)lc_associatedObjectForKey:(NSString *)key;

- (void)lc_associateObject:(nullable id)object forKey:(NSString *)key policy:(objc_AssociationPolicy)policy;

@end

NS_ASSUME_NONNULL_END
