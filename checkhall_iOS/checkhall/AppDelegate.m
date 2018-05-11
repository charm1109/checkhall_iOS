//
//  AppDelegate.m
//  checkhall
//
//  Created by pc on 2017. 12. 3..
//  Copyright © 2017년 pc. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalData.h"
#import "JHUtile.h"

@import Firebase;
@import FirebaseMessaging;
@import UserNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"243043320845";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;

    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    [application registerForRemoteNotifications];
    
    
    //APNS  수신 시 처리 설정
    NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if(userInfo != nil){
        [[GlobalData sharedData] setIsNotiAppRun:YES];
        [self application:application didReceiveRemoteNotification:userInfo];
    }else{
        [[GlobalData sharedData] setNotiUrl:@""];
        [[GlobalData sharedData] setIsNotiAppRun:NO];
    }
    
    if([launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"]){
        NSString *url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
        
        [NSThread detachNewThreadSelector:@selector(linkKakao:) toTarget:self withObject:url];
        //[self linkKakao:url];
    }
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%@", url);
    [self linkKakao:[NSString stringWithFormat:@"%@", url]];
    return YES;
}

- (void)linkKakao:(NSString*)url{
    NSString *urlStr = [NSString stringWithFormat:@"%@", url];
    NSArray *splitedURL = [urlStr componentsSeparatedByString:@"kakao188a01da8291ae8cd43b7e3e9c177f2d://kakaolink?"];
    if(splitedURL.count == 2){
        NSString *linkURL = [splitedURL objectAtIndex:1];
        
//        //외부앱실행
//        UIApplication *application = [UIApplication sharedApplication];
//        NSURL *URL = [NSURL URLWithString:linkURL];
//        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
//            if (success) {
//                NSLog(@"Opened url");
//            }
//        }];
        
        //내부앱실행
        if(![JHUtile isEmptyString:linkURL]) {
            [[GlobalData sharedData] setNotiUrl:linkURL];
            [self performSelector:@selector(NewNotoficationThread) withObject:nil afterDelay:0.5];
        }
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification => %@", userInfo);
    [LogFile writeLogFile:[NSString stringWithFormat:@"didReceiveRemoteNotification => %@",userInfo]];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    NSString *action_url = [userInfo objectForKey:@"action_url"];
    if(![JHUtile isEmptyString:action_url]) {
        [[GlobalData sharedData] setNotiUrl:action_url];
        if([[GlobalData sharedData] isNotiAppRun]==NO){
            [self performSelector:@selector(NewNotoficationThread) withObject:nil afterDelay:0.5];
            
        }
    }
}

- (void)NewNotoficationThread
{
    //APNS 실행
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_LINK" object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    NSLog(@"didReceiveRemoteNotification => %@", userInfo);
    [LogFile writeLogFile:[NSString stringWithFormat:@"didReceiveRemoteNotification => %@",userInfo]];
    
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    //[[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSString *action_url = [userInfo objectForKey:@"action_url"];
    if(![JHUtile isEmptyString:action_url]) {
        [[GlobalData sharedData] setNotiUrl:action_url];
        if([[GlobalData sharedData] isNotiAppRun]==NO){
            [self performSelector:@selector(NewNotoficationThread) withObject:nil afterDelay:0.5];
            
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSString *action_url = [userInfo objectForKey:@"action_url"];
    if(![JHUtile isEmptyString:action_url]) {
        [[GlobalData sharedData] setNotiUrl:action_url];
        if([[GlobalData sharedData] isNotiAppRun]==NO){
            [self performSelector:@selector(NewNotoficationThread) withObject:nil afterDelay:0.5];
            
        }
    }
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    NSString *action_url = [userInfo objectForKey:@"action_url"];
    if(![JHUtile isEmptyString:action_url]) {
        [[GlobalData sharedData] setNotiUrl:action_url];
        if([[GlobalData sharedData] isNotiAppRun]==NO){
            [self performSelector:@selector(NewNotoficationThread) withObject:nil afterDelay:0.5];
            
        }
    }
    
    completionHandler();
}

    
// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    [[GlobalData sharedData] setFcmToken:fcmToken];
    
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
}


    
@end
