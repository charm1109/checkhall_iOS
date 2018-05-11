//
//  LogFileDelete.h
//  CheckOil
//

#import <Foundation/Foundation.h>

@interface LogFileDelete : NSObject
+ (void)removeFileAtPath:(NSString*)removeFile;
+ (void) deleteEventLogFile;
+ (BOOL)checkDataDayOverdue:(NSDate*)date day:(int)day;
+ (NSInteger)GetRemainingDay:(NSDate*)_start EndDate:(NSDate*)_end;
+ (NSArray *)findFiles:(NSString *)extension;
+ (NSArray *)findAllFileFromDir:(NSString *)dirPath;
@end
