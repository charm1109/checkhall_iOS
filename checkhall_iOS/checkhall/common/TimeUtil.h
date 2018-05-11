

#import <Foundation/Foundation.h>


@interface TimeUtil : NSObject
+ (NSString *)converterTimeZone:(NSString *)timeStr;
+ (NSString *)converterSettingTime:(NSString *)timeStr inFormat:(NSString*)inFromat outFormat:(NSString*)outFromat;
+ (NSString *)converterFullTime:(NSString *)timeStr;
+ (NSString *)getCurrentDateStr;
+ (NSString *)getCurrentDateStrFormat:(NSString*)dataFormat Locale:(NSLocale *)locale;
+ (NSString *)getReceivedTimeForMessangerTalk:(NSString *)dateStr;
+ (NSDate *)getDateFromString:(NSString *)pstrDate;
+ (NSDate *)getDateFromString:(NSString *)pstrDate format:(NSString*)format;
//두 날짜간의 일수 차이구하기
+ (NSInteger)GetRemainingDay:(NSDate*)_start EndDate:(NSDate*)_end;
+ (NSString *)getDataFromFormat:(NSDate*)data format:(NSString *)format;
+ (NSString *)getCurrentDateAddDay:(NSInteger)day;
+ (BOOL)getExpiredDay:(NSString*)expiredDay;
@end
