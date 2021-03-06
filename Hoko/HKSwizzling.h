//
//  HKSwizzling.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  HKSwizzling is a helper class to swizzle some particular functions out of the AppDelegate.
 *  Making it easier to integrate the Hoko Framework.
 */
@interface HKSwizzling : NSObject

+ (void)swizzleHKDeeplinking;

@end
