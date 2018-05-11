//
//  LogFileDelete.m
//  CheckOil
//


#import "LogFileDelete.h"
#import "TimeChecker.h"
#import "Defines.h"
@implementation LogFileDelete

+ (void)removeFileAtPath:(NSString*)removeFile
{
    [[NSFileManager defaultManager] removeItemAtPath:removeFile error:nil];
}

//1달 이전의 이벤트 로그 데이터 삭제
+ (void) deleteEventLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, SAVE_LOG_FILE_DIR];
    NSArray *files = [self findAllFileFromDir:dirPath];
    if(files == nil || files.count == 0)
        return;
    
    for (NSString *item in files)
    {
        NSString *fileName = [NSString stringWithFormat:@"%@/%@", dirPath, item];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil];
        NSString *creatTime = [item substringToIndex:10];
        NSDate *fileDate = [TimeChecker getDateFromString:creatTime format:@"yyyy-MM-dd"];
        BOOL  isOberdue = [self checkDataDayOverdue:fileDate day:7];
        if(isOberdue){
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        NSLog(@"%@", fileAttributes);
    }
}


////한달 지났으면 true 아니면 false 반환
+ (BOOL)checkDataDayOverdue:(NSDate*)date day:(int)day
{
    BOOL isOverdue = false;
    NSDate *currentDate  = [NSDate date];
    NSInteger diffDay = [self GetRemainingDay:date EndDate:currentDate];
    
    //입력한 날짜 보다 크면 True
    if(day < diffDay)
    {
        isOverdue = true;
    }
    
    return  isOverdue;
}

+ (NSInteger)GetRemainingDay:(NSDate*)_start EndDate:(NSDate*)_end
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitDay;
    NSDateComponents* com = [gregorian components:unitFlags fromDate:_start toDate:_end options:0];
    
    return [com day];
}

+(NSArray *)findFiles:(NSString *)extension
{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}
+(NSArray *)findAllFileFromDir:(NSString *)dirPath
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
}

@end









