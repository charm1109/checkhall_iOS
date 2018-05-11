#import <Foundation/Foundation.h>

@interface GlobalData : NSObject{
    
}
@property (nonatomic, strong) NSString *fcmToken;
@property (nonatomic, strong) NSString *notiUrl;
@property (nonatomic, assign) BOOL isNotiAppRun;
//#pragma mark 싱글톤 메소드
+ (GlobalData *)sharedData;
+ (id) allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
//- (id)retain;
//- (unsigned)retainCount;
//- (id)autorelease;

@end
