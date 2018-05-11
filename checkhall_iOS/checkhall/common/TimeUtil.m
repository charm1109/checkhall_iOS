

#import "TimeUtil.h"
#import "Defines.h"


@implementation TimeUtil
// Date Format String
#define DATE_FORMAT_WITHIN_A_DAY    @"HH"
#define DATE_FORMAT_WITHIN_A_WEEK   @"E HH:mm"
#define DATE_FORMAT_AFTER_A_WEEK    @"yyyy.MM.dd"
#define DATE_FORMAT_AFTER_A_DAY     @"yyyy.MM.dd(E) HH:mm "

//#define LocalizedString(string) \
//[NSString stringWithFormat:NSLocalizedString(string,@""),[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] localeIdentifier]]]


+ (NSString *)converterTimeZone:(NSString *)timeStr{

    NSString *localDate = @"";
    NSInteger count = timeStr.length;
    if(count >= 28){
        //타입 정보 셋팅
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *dateFromString = [dateFormatter dateFromString:timeStr];
        
        //타임정보 로컬시간으로 변경
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        localDate = [dateFormatter stringFromDate: dateFromString];
    }else{
        //타입 정보 셋팅
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *dateFromString = [dateFormatter dateFromString:timeStr];
        
        //타임정보 로컬시간으로 변경
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        localDate = [dateFormatter stringFromDate: dateFromString];
    }
    return localDate;
}

+ (NSString *)converterSettingTime:(NSString *)timeStr inFormat:(NSString*)inFormat outFormat:(NSString*)outFormat{

    //타입 정보 셋팅
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:inFormat];
    NSDate *dateFromString = [dateFormatter dateFromString:timeStr];
    
    //타임정보 로컬시간으로 변경
    [dateFormatter setDateFormat:outFormat];
    NSString *localDate = [dateFormatter stringFromDate: dateFromString];
    return localDate;
}


/**
 @return
 - (NSString *) 변환된 시간
 @param
 - (NSString *)timeStr 변환할 시간
 @brief
 - "yyyy.MM.dd(E) HH:mm " 형식으로 시간 변환
 @warning
 
 */
+ (NSString *)converterFullTime:(NSString *)timeStr
{
    NSString *convertedDateStr = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSzzz"];
    NSDate *dateFromString = [dateFormatter dateFromString:timeStr];
    
    [dateFormatter setDateFormat:DATE_FORMAT_AFTER_A_DAY];
    convertedDateStr = [dateFormatter stringFromDate:dateFromString];
    
    return convertedDateStr;
}



/**
 @return 
 - (NSString *) 변환된 시간
 @param
 - 
 @brief
 - 현재 시간을 yyyyMMddHHmmss 형식으로 반환
 @warning
 
 */
+ (NSString *)getCurrentDateStr 
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateForm stringFromDate:date];
    return currentDateStr;
}

/**
 @return
 - (NSString *) 변환된 시간
 @param
 -
 @brief

 @warning
 
 */

+ (NSString *)getCurrentDateStrFormat:(NSString*)dataFormat Locale:(NSLocale *)locale
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    
    if(locale != nil){
        [dateForm setLocale:locale];
    }
    
    [dateForm setDateFormat:dataFormat];
    NSString *currentDateStr = [dateForm stringFromDate:date];
    
    return currentDateStr;
}

/**
 @return 
 - (NSString *) 변환된 시간
 @param
 - (NSString *)dateStr 변환할 시간
 @brief
 - HH:mm 형식으로 시간 반환
 @warning
 
 */
+ (NSString *)getReceivedTimeForMessangerTalk:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    //TimeZone 추가 변경
    //if(dateStr.length > )
    NSLog(@"%d", (int)dateStr.length);
    if(dateStr.length > 28){
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];  
    }
    
    NSDate *dateFromString = [dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:@"HH:mm"];        
    NSString *convertedTime = [dateFormatter stringFromDate:dateFromString];
    
    return convertedTime;
}

+ (NSDate *)getDateFromString:(NSString *)pstrDate
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"yyyy-MM-dd"];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}

+ (NSDate *)getDateFromString:(NSString *)pstrDate format:(NSString*)format
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:format];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}

//두 날짜간의 일수 차이구하기
+ (NSInteger)GetRemainingDay:(NSDate*)_start EndDate:(NSDate*)_end
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitDay;
    NSDateComponents* com = [gregorian components:unitFlags fromDate:_start toDate:_end options:0];
    
    return [com day];
}

+ (NSString *)getDataFromFormat:(NSDate*)data format:(NSString *)format
{
    NSDate *currentTime = data;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *strData = [NSString stringWithFormat:@"%@", [formatter stringFromDate:currentTime]];
    return strData;
}

+ (NSString *)getCurrentDateAddDay:(NSInteger)day{
    
    NSDate *currentDate = [NSDate date];
    NSDate *datePlus = [currentDate dateByAddingTimeInterval:60*60*24*day];
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    [dateForm setDateFormat:@"yyyyMMddHHmmss"];
    NSString *addDate = [dateForm stringFromDate:datePlus];
    return addDate;
}

+ (BOOL)getExpiredDay:(NSString*)expiredDay{
    BOOL isExpired = false;
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *dtPostDate = [df1 dateFromString:expiredDay];
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [dtPostDate compare:currentDate];
    if(result == NSOrderedAscending){
        isExpired = true;
    }
    return isExpired;
}

@end
