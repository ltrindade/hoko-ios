//
//  HKApp.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <UIKit/UIImage.h>

@interface HKApp : NSObject

+ (instancetype)app;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *bundle;
@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSString *build;
@property (nonatomic, strong, readonly) NSArray *urlSchemes;
@property (nonatomic, readonly) BOOL hasURLSchemes;
@property (nonatomic, readonly) BOOL isDebugBuild;
@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) id json;

- (void)postIconWithToken:(NSString *)token;

@end
