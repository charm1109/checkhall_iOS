
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

@interface JHUtile : NSObject
+ (UIImage *)image1x1WithColor:(UIColor *)color;

+ (void)writeToTextFile:(NSString*)filename content:(NSString*)content;
+ (NSString*)readToTextFile:(NSString*)filename;

//errcheck
+ (BOOL)NetworkErrCheck:(id)ParsingData;

//글자 길이 자르기
+ (BOOL)isOverSubStringToByte:(NSString *)text lanth:(NSInteger)lanth;
+ (NSString *)subStringToByte:(NSString *)text lanth:(NSInteger)lanth;
+ (NSUInteger)getBytes:(NSString *)string subByte:(NSUInteger)subByte;
//특정 문자열의 위치값 리턴
+ (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str;

//바이트를 키로바이트 또는 메가 바이트 로 변환
+ (NSString*)changeFileSizeFromBite:(NSString*)fileSize;


//뷰 사이즈 iOS7 이상일 경우 상태바 영역삭제 크기 리턴
+ (CGSize)getSizeViewOS7:(CGSize)ViewSize;
+ (CGRect)getRectViewOS7:(CGRect)ViewRect;
+ (CGRect)getRectViewOS7Pos:(CGRect)ViewRect;
+ (CGRect)getChangeRectViewOS7:(CGRect)ViewRect;
+ (CGRect)getChangeRectViewOS7PlusY:(CGRect)ViewRect;
+ (BOOL)isWidthSize320;
+ (BOOL)isiPhone6Pluse;
+ (BOOL)isiPhone4sDisplay;
+ (BOOL)isiPhoneXDisplay;
+ (BOOL)isIOS7over;
+ (BOOL)isIOS8over;
+ (BOOL)isiPad;


// 이미지 크기 축소
+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution orientation:(UIImageOrientation)orientation;
+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)fixrotation:(UIImage *)image;

//UUID
+ (NSString *)getUUID;

//NSData 이미지 타입 리턴
+ (NSString *)contentTypeForImageData:(NSData *)data;
+ (NSString *)contentTypeForImageDataForm:(NSData *)data;

//뷰 사이즈 가져오기
+ (CGRect)getRectForView;
+ (CGRect)getRectForViewFromOrientation:(UIDeviceOrientation)orientation;

//스트링 사이즈 가져오기
+ (CGSize)getStringSize:(CGSize)size font:(UIFont*)font message:(NSString*)message;
+ (CGSize)getUITextViewSizeFromUITextView:(CGSize)size font:(UIFont*)font message:(NSString*)message textView:(UITextView*)textView fileType:(NSInteger)fileType;

//URL ENCODING
+ (NSString*)encodeURL:(NSString *)string;
+ (NSString*)changeQueryStringParameter:(NSString *)urlString;


//애니메이션
+ (CABasicAnimation *)moveAnimation:(UIView*)view form:(CGPoint)formPoint to:(CGPoint)toPoint duration:(CFTimeInterval)duration;
+ (CABasicAnimation *)boundsAnimation:(UIView*)view form:(CGRect)formValue to:(CGRect)toValue duration:(CFTimeInterval)duration;
+ (CABasicAnimation *)appearAnimation:(UIView*)view duration:(CFTimeInterval)duration;

//모델명
+ (NSString*)getCurrentDeviceModel;
+ (NSString*)hardwareString;

//영어 ~번째 표시
+ (NSString *)formatOrdinalNumber:(NSInteger)number;

//URL 정규식
+ (NSString*)validateUrl:(NSString *)stringURL;

//랜덤값
+ (NSInteger)getRandomNumber:(NSInteger)number;

//파일 네임 인코딩
+ (NSString*)getFilenameFromContentDisposition:(NSString*)contentDisposition;

//카메라 설정 확인
+ (BOOL)checkDisableCamera;

//동영상 파일 확인
+ (BOOL)checkMoveFile:(NSString*)fileName;

//쿠키설정
+ (void)deleteCookies;
+ (void)setCookis:(NSArray*)cookies;


//문자열
+ (BOOL)isEmptyString:(NSString*)string;

//숫자
+ (NSInteger)getUnSingedInt:(NSInteger)integer;

//현재 언어 가져오기
+ (NSString*)getCurrentLangage;
@end
