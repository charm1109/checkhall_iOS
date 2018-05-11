//
//  AppDelegate.h
//  checkhall
//
//  Created by pc on 2017. 12. 3..
//  Copyright © 2017년 pc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogFile.h"
@import Firebase;
@import FirebaseMessaging;
@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

