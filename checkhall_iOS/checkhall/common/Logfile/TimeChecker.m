//
//  TimeChecker.m
//  CheckOil
//
//  Created by WooKyun Jeon on 2014. 2. 27..
//  Copyright (c) 2014년 WooKyun Jeon. All rights reserved.
//

#import "TimeChecker.h"

#define A_MINUTE_TO_SECOND          60
#define A_HOUR_TO_MINUTE            60

static TimeChecker *instance = nil;

@implementation TimeChecker

+ (TimeChecker *)sharedInstance
{
    if (instance == nil) {
        
        instance = [[TimeChecker alloc] init];
    }
    
    return instance;
}

+ (void)releaseSharedInstance
{
    if (instance != nil) {
        
        instance = nil;
    }
}

- (void)startTimeCheck
{
    startTime = [NSDate date];
}

- (void)stopTimeCheck
{
    stopTime = [NSDate date];
}

- (double)getTime
{
    double time = [stopTime timeIntervalSinceDate:startTime];
    
    return time;
}

- (double)getStartFromCurrentTime
{
    double time = [[NSDate date] timeIntervalSinceDate:startTime];
    
    return time;
}


- (NSString *)getTimeDescription
{
    int time = [[NSNumber numberWithDouble:[self getTime]] intValue];
    
    NSString *description = @"";
    description = [self getCovertTimeDescription:time];
    
    return description;
}

- (NSString *)getCurrentTimeDescription
{
    int time = [[NSNumber numberWithDouble:[self getStartFromCurrentTime]] intValue];
    
    NSString *description = @"";
    description = [self getCovertTimeDescription:time];
    
    return description;
}


- (NSString *)getCovertTimeDescription:(int)time
{
    /* 20141022.CCH 시간 표시 에러로 인한 주석 처리
    // time : 30
    int hour = time / (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND);
    int minute = (time % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) / A_MINUTE_TO_SECOND;
    int second = (time % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) % A_MINUTE_TO_SECOND;

    // hour : 0, minute : 00, second : 30, beforeStopTotalTime : 100
    
    NSLog(@"getTime : %d, hour : %d, minute : %02d, second : %02d / beforeStopTotalTime : %lf", time, hour, minute, second, beforeStopTotalTime);
    
    //이전 Total시간 계산
    int beforeHour = 0;
    int beforeMinute = 0;
    int beforeSecond = 0;
    
    if (beforeStopTotalTime != 0) {
        int beforeTime = [[NSNumber numberWithDouble:beforeStopTotalTime] intValue];
        
        beforeHour = beforeTime / (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND);
        beforeMinute = (beforeTime % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) / A_MINUTE_TO_SECOND;
        beforeSecond = (beforeTime % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) % A_MINUTE_TO_SECOND;
    }
    
    hour = hour + beforeHour;
    minute = minute + beforeMinute;
    second = second + beforeSecond;
    */
    
    if (beforeStopTotalTime != 0) {
        int beforeTime = [[NSNumber numberWithDouble:beforeStopTotalTime] intValue];
        time += beforeTime;
    }
    
    int hour = time / (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND);
    int minute = (time % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) / A_MINUTE_TO_SECOND;
    int second = (time % (A_HOUR_TO_MINUTE * A_MINUTE_TO_SECOND)) % A_MINUTE_TO_SECOND;
    
    NSString *description = @"";
    if (hour != 0) {
        description = [NSString stringWithFormat:@"%d시간 ", hour];
    }
    if (minute != 0) {
        description = [NSString stringWithFormat:@"%@%02d분 ", description, minute];
    }
    
    description = [NSString stringWithFormat:@"%@%02d초", description, second];
    
//    NSLog(@"Time description : %@", description);
    
    return description;
}

- (NSString *)getCurrentTime {

    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormat stringFromDate:todayDate];
}

+ (NSString *)getCurrentTime:(NSString *)format
{
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:currentTime];
}

+ (NSString *)getDataFromFormat:(NSDate*)data format:(NSString *)format
{
    NSDate *currentTime = data;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:currentTime];
}

+ (NSDate *)getDateFromString:(NSString *)pstrDate format:(NSString*)format
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:format];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}

- (void)resetTimeCheck
{
    startTime = nil;
    stopTime = nil;
    beforeStopTotalTime = 0;
}

- (void)setBeforeStopTotalTime:(double)beforeTotalTime
{
    beforeStopTotalTime = beforeTotalTime;
}
@end
