//
//  HKDeferredDeeplinking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeferredDeeplinking.h"

#import "HKUtils.h"
#import "HKLogger.h"
#import "HKDevice.h"
#import "HKNetworking.h"
#import "HKNetworkOperation.h"

NSString *const HKDeferredDeeplinkingNotFirstRun = @"isNotFirstRun";
NSString *const HKDeferredDeeplinkingPath = @"deferred/lookup";

@interface HKDeferredDeeplinking ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HKDeferredDeeplinking

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (void)requestDeferredDeeplink:(void (^)(NSString *))handler
{
    BOOL isFirstRun = ![[HKUtils objectForKey:HKDeferredDeeplinkingNotFirstRun] boolValue];
    if (isFirstRun) {
        [HKUtils saveObject:@YES key:HKDeferredDeeplinkingNotFirstRun];
        [HKNetworking postToPath:[HKNetworkOperation urlFromPath:HKDeferredDeeplinkingPath] parameters:self.json token:self.token successBlock:^(id json) {
            NSString *deeplink = json[@"deeplink"];
            if (deeplink && [deeplink isKindOfClass:[NSString class]] && handler) {
                handler(deeplink);
            }
        } failedBlock:^(NSError *error) {
            HKErrorLog(error);
        }];
    }
}

- (id)json
{
    return @{@"os_version": [HKDevice device].systemVersion,
             @"device_type": [HKDevice device].platform,
             @"language": [HKDevice device].systemLanguage.lowercaseString,
             @"screen_size": [HKDevice device].screenSize,
             @"timezone_offset": [HKDevice device].timezoneOffset};
}

@end
