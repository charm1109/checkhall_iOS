
#import "LogFile.h"
#import "JSONKit.h"
#import "Defines.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <objc/runtime.h>
#import "Defines.h"
@implementation LogFile


+ (void)writeLogFile:(NSString*)content
{
    @try {
        
        //디렉토리 확인 및 생성
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dir = [NSString stringWithFormat:@"%@/%@",documentsDirectory, SAVE_LOG_FILE_DIR];
        [self creatDirectory:dir];
        
        //시간추가
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *time = [formatter stringFromDate:currentTime];
        content = [NSString stringWithFormat:@"[%@] %@",time, content];
        //줄바꿈 추가
        content = [content stringByAppendingString:@"\n"];
        
        NSArray *formatterArr = [time componentsSeparatedByString:@" "];
        NSString *savefileName = [NSString stringWithFormat:@"%@.log",[formatterArr firstObject]];
        //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [dir stringByAppendingPathComponent:savefileName];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        //append text to file (you'll probably want to add a newline every write)
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        
        NSLog(@"%@",content);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
}

+ (void)writeLogFileReqest:(NSString*)content result:(NSData*)result{
    //에러 결과만 result 값을 남김
    NSString *strRtn = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [strRtn objectFromJSONString];
    NSString *code = [NSString stringWithFormat:@"%@", [dic objectForKey:@"code"]];
    if([code isEqualToString:@"200"]){
        [LogFile writeLogFile:content];
    }else{
        NSString * resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSString * logStr = [NSString stringWithFormat:@"%@\nresult : %@", content, resultStr];
        [LogFile writeLogFile:logStr];
    }
    
}

+ (BOOL) checkFreeMemory
{
    #define MIN_FREE_MEMORY				2000000            // 2MB
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    natural_t mem_free = vm_stat.free_count * pagesize;
    NSLog(@"Available Memory Size = %u", mem_free - MIN_FREE_MEMORY);

    [LogFile writeLogFile:[NSString stringWithFormat:@"Available Memory Size = %u", mem_free - MIN_FREE_MEMORY]];
    if (mem_free > MIN_FREE_MEMORY)
    {
        return YES;
    }
    
    return NO;
}

+ (void)creatDirectory:(NSString*)dirName
{
    [[NSFileManager defaultManager] createDirectoryAtPath:dirName withIntermediateDirectories:NO attributes:nil error:nil];
}

@end
