//
//  HokoPushNotifications.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HokoPushNotifications.h"

#import "Hoko.h"
#import "HKApp.h"
#import "HKDevice.h"
#import "HKObserver.h"
#import "Hoko+Private.h"
#import "HokoAnalytics+Private.h"
#import "HokoDeeplinking+Private.h"
#import "HokoIOS8PushNotifications.h"
#import "HokoLegacyPushNotifications.h"

NSString *const HKPushNotificationAPSKey = @"aps";
NSString *const HKPushNotificationAlertKey = @"alert";
NSString *const HKPushNotificationDeeplinkKey = @"hoko_deeplink";

@interface HokoPushNotifications ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HokoPushNotifications

#pragma mark - Initializer
+ (instancetype)pushNotificationsWithToken:(NSString *)token
{
  HokoPushNotifications *instance;
  if (HKSystemVersionGreaterThanOrEqualTo(@"8.0")) {
    instance = [[HokoIOS8PushNotifications alloc] initWithToken:token];
  } else {
    instance = [[HokoLegacyPushNotifications alloc] initWithToken:token];
  }
  
  [instance observeApplicationDidFinishLaunching];
  
  return instance;
}

#pragma mark - Push Notifications
- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
    [self applicationDidReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
  }
}

- (void)registerForRemoteNotificationTypes:(HKRemoteNotificationType)types
{
  NSAssert(NO, @"[HOKO] This is an abstract method and should be overridden");
}

- (BOOL)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
  HKLog(@"Received PN %@",userInfo);
  
  NSString *deeplink = userInfo[HKPushNotificationDeeplinkKey];
  NSURL *deeplinkURL = [NSURL URLWithString:deeplink];
  // application was in background, open route
  if (self.application.applicationState != UIApplicationStateActive) {
    if (deeplink)
      return [[Hoko deeplinking] handleOpenURL:deeplinkURL];
  } else {
    if (deeplink && [[Hoko deeplinking] canOpenURL:deeplinkURL])
      [[Hoko deeplinking] handleOpenURLFromForeground:deeplinkURL];

  }
  
  return NO;
}

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token{
  
  // Convert byte data to string token
  const unsigned *tokenBytes = [token bytes];
  NSString *apnsToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3]),
                         ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
  NSString *previousAPNSToken = [HKDevice device].apnsToken;
  
  // Only update if different token
  if (!previousAPNSToken || ![apnsToken isEqualToString:previousAPNSToken]) {
    [HKDevice device].apnsToken = apnsToken;
    [[Hoko analytics] postCurrentUser];
  }
}

#pragma mark - Observer
- (void)observeApplicationDidFinishLaunching
{
  __block HokoPushNotifications *wself = self;
  [[HKObserver observer] registerForNotification:UIApplicationDidFinishLaunchingNotification triggered:^(NSNotification *notification) {
    [wself applicationDidFinishLaunchingWithOptions:notification.userInfo];
  }];
}

#pragma mark - Helpers
- (UIApplication *)application
{
  return [UIApplication sharedApplication];
}

@end
