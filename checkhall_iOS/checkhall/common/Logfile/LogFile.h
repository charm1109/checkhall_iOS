
#import <Foundation/Foundation.h>


@interface LogFile : NSObject

+ (void)writeLogFile:(NSString*)content;
+ (void)writeLogFileReqest:(NSString*)content result:(NSData*)result;
+ (BOOL) checkFreeMemory;
@end
