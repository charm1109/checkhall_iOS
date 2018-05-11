//
//  TimeChecker.h
//  CheckOil
//
//  Created by WooKyun Jeon on 2014. 2. 27..
//  Copyright (c) 2014년 WooKyun Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeChecker : NSObject {
    
    NSDate *startTime;
    NSDate *stopTime;
    double beforeStopTotalTime;
}

+ (TimeChecker *)sharedInstance;

- (void)startTimeCheck;
- (void)stopTimeCheck;
- (void)resetTimeCheck;
- (double)getTime;
- (double)getStartFromCurrentTime;
- (NSString *)getCurrentTime;
- (NSString *)getTimeDescription;
- (NSString *)getCurrentTimeDescription;
+ (NSString *)getDataFromFormat:(NSDate*)data format:(NSString *)format;
- (NSString *)getCovertTimeDescription:(int)time;
+ (NSString *)getCurrentTime:(NSString *)format;
+ (NSDate *)getDateFromString:(NSString *)pstrDate format:(NSString*)format;
- (void)setBeforeStopTotalTime:(double)beforeTotalTime;

@end
