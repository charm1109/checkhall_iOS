
#import <UIKit/UIKit.h>
#import "JHUtile.h"
#import "KeychainItemWrapper.h"
#import <quartzcore/quartzcore.h>

//디바이스 모델명
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation JHUtile
+ (UIImage *)image1x1WithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)writeToTextFile:(NSString*)filename content:(NSString*)content
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory,filename];
    
    NSMutableString *fileStr;
    //make a file name to write the data to using the documents directory:
    
    //if([[NSFileManager defaultManager] fileExistsAtPath:fileName] == NO)
    fileStr =  [[NSMutableString alloc] initWithString:@""];
    [fileStr appendString:[NSString stringWithFormat:@"%@", content]];
    
    //save content to the documents directory
    [fileStr writeToFile:fileName
              atomically:NO
                encoding:NSUTF8StringEncoding
                   error:nil];
}

+ (NSString*)readToTextFile:(NSString*)filename
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          documentsDirectory,filename];
    
    NSMutableString *fileStr;
    //make a file name to write the data to using the documents directory:
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName] == NO)
        fileStr =  [[NSMutableString alloc] initWithString:@""];
    else
        fileStr =  [[NSMutableString alloc] initWithString:[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil]];
    
    return fileStr;
}

+(BOOL)NetworkErrCheck:(id)ParsingData
{
    BOOL isErr = FALSE;
    if([ParsingData isKindOfClass:[NSError class]])
    {  //보안접속 상태가 아닐 경우 발생
        NSError * err = (NSError *)ParsingData;
        NSString *errMessage = [err description];
        NSRange errRangestart = [errMessage rangeOfString:@"\""];
        NSRange errRangeend;
        
        NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        if(YES == [currentLanguage hasPrefix:@"ja"]) {                //일본어
            errRangeend = [errMessage rangeOfString:@"。"];
        }
        else
        {
            errRangeend = [errMessage rangeOfString:@"."];
        }
        
        NSRange cutRange;
        cutRange.location = errRangestart.location+1;
        cutRange.length = errRangeend.location - errRangestart.location;
        
        NSString *Message = [errMessage substringWithRange:cutRange];
        NSDictionary* dict = [NSDictionary dictionaryWithObject:Message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkErrMessage" object:self userInfo:dict];
        isErr = TRUE;
    }
    return isErr;
}


+ (BOOL)isOverSubStringToByte:(NSString *)text lanth:(NSInteger)lanth{
    NSUInteger countText = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];//-2147481280
    NSUInteger subByte = lanth;
    BOOL isOver = false;
    if (countText > subByte) {
        isOver = true;
    }
    return isOver;
}

+ (NSString *)subStringToByte:(NSString *)text lanth:(NSInteger)lanth{
    NSUInteger countText = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];//-2147481280
    NSUInteger subByte = lanth;
    NSString * returnString = @"";
    if (countText > subByte) {
        NSUInteger range = [JHUtile getBytes:text subByte:subByte];
        NSRange twoToSixRange = NSMakeRange(0, range);
        NSString *tempString = [text substringWithRange:twoToSixRange];
        NSLog(@"%@", tempString);
        returnString = tempString;
    }else{
        NSLog(@"%@", text);
        returnString = text;
    }
    return returnString;
}

+ (NSUInteger)getBytes:(NSString *)string subByte:(NSUInteger)subByte{
    unichar unicharAtIndex;
    NSUInteger bytes = 0;
    NSUInteger loopValue;
    for(loopValue = 0; loopValue < [string length]; loopValue++){
        unicharAtIndex = [string characterAtIndex:loopValue];
        if((NSUInteger)unicharAtIndex > 255){
            bytes += 2;
            if (bytes > subByte) {
                return loopValue;
            }
        }else{
            bytes++;
            if (bytes > subByte) {
                return loopValue;
            }
        }
    }
    return loopValue;
}

+ (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        NSLog(@"searchRange = %@", NSStringFromRange(searchRange));
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}

+ (NSString*)changeFileSizeFromBite:(NSString*)fileSize
{
    NSString *attSize = @"";
    CGFloat sizeFloat = [fileSize floatValue];
    
    if(sizeFloat >= 1024)
    {//KB
        sizeFloat = sizeFloat/1024;
        attSize = [NSString stringWithFormat:@"%.1fKB", sizeFloat];
    }
    else
    {
        if(sizeFloat < 99)
        {
            attSize = [NSString stringWithFormat:@"0.0KB"];
        }
        else
        {
            sizeFloat = sizeFloat/1024;
            attSize = [NSString stringWithFormat:@"%.1fKB", sizeFloat];
        }
    }
    if(sizeFloat >= 1024)
    {//MB
        sizeFloat = sizeFloat/1024;
        attSize = [NSString stringWithFormat:@"%.1fMB", sizeFloat];
    }
    if(sizeFloat >= 1024)
    {//GB
        sizeFloat = sizeFloat/1024;
        attSize = [NSString stringWithFormat:@"%.1fGB", sizeFloat];
    }
    return attSize;
}


//size 에대한 수정
+ (CGSize)getSizeViewOS7:(CGSize)ViewSize
{
    CGSize size;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        size = ViewSize;
        size.height -= 20;
    }
    else
    {
        size = ViewSize;
    }
    return size;
}

//크기에 대한 수정
+ (CGRect)getRectViewOS7:(CGRect)ViewRect
{
    CGRect rect = CGRectZero;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        rect = ViewRect;
        rect.size.height -= 20;
    }
    else
    {
        rect = ViewRect;
    }
    return rect;
}

//위치에 대한 수정
+ (CGRect)getRectViewOS7Pos:(CGRect)ViewRect
{
    CGRect rect = CGRectZero;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        rect = ViewRect;
        rect.origin.y -= 20;
    }
    else
    {
        rect = ViewRect;
    }
    return rect;
}

//위치값 과크기에대한 수정
+ (CGRect)getChangeRectViewOS7:(CGRect)ViewRect
{
    CGRect rect = CGRectZero;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        rect = ViewRect;
        rect.origin.y += 20;
        rect.size.height -= 20;
    }
    else
    {
        rect = ViewRect;
    }
    return rect;
}

//위치값 Y + 20
+ (CGRect)getChangeRectViewOS7PlusY:(CGRect)ViewRect
{
    CGRect rect = CGRectZero;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        rect = ViewRect;
        rect.origin.y += 20;
    }
    else
    {
        rect = ViewRect;
    }
    return rect;
}

+ (BOOL)isWidthSize320 {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 320.0);
}

+ (BOOL)isiPhone6Pluse {
    BOOL isiPhone6Pluse = false;
    NSString *hardware = [JHUtile hardwareString];
    if ([hardware isEqualToString:@"iPhone7,1"]){
        isiPhone6Pluse = true;
    }
    return isiPhone6Pluse;
    
}

+ (BOOL)isiPhone4sDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 480.0);
}

+ (BOOL)isiPhoneXDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 812.0);
}

//현재 OS 가 7 이상 일때 TRUE
+ (BOOL)isIOS7over
{
    BOOL isOS7Over = NO;
    float systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;
    if(systemVersion >= 7.0)
    {
        isOS7Over = YES;
    }
    return isOS7Over;
}


//UUID 값을 생성한다.
+ (NSString *)getUUID
{
    //키체인 정보
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    //UUID
    NSString *savedUUID = [NSString stringWithFormat:@"%@", [keychainItem objectForKey:(__bridge id)kSecValueData]];
    if(savedUUID.length == 0)
    {
        @try {
            //UUID 생성 및 저장
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            CFStringRef generatedUUIDString = CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            NSString* hashKey = (__bridge NSString*)generatedUUIDString;
            [keychainItem setObject:hashKey forKey:(__bridge id)kSecValueData];
            savedUUID = [NSString stringWithFormat:@"%@", [keychainItem objectForKey:(__bridge id)kSecValueData]];
        }
        @catch (NSException *exception) {
#ifdef DEBUG
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"알림" message:@"키체인 설정을 확인하세요!!" delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alertView show];

#endif
        }
    }
//    NSArray *uuidArr = [savedUUID componentsSeparatedByString:@"-"];
//    savedUUID = [NSString stringWithFormat:@"%@", [uuidArr firstObject]];
    return savedUUID;
}


+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    char bmp[2] = {'B', 'M'};
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    }
    
    return nil;
}

+ (NSString *)contentTypeForImageDataForm:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    char bmp[2] = {'B', 'M'};
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    }
    
    return nil;
}

//가로 세로 뷰일경우 뷰 전체 크기 가져오기
+ (CGRect)getRectForView {

    CGRect mainBounds = CGRectZero;
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
//    if(orientation == UIDeviceOrientationLandscapeRight ||  orientation == UIDeviceOrientationLandscapeLeft)
//    {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
//            mainBounds = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width);
//        } else {
//            mainBounds = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.height, (([UIScreen mainScreen].bounds.size.width )));
//        }
//        NSLog(@"The height is %f", mainBounds.size.height );
//        return mainBounds;
//    }
//
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
//        mainBounds = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height);
//        if([self isiPhoneXDisplay]){
//            mainBounds = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width, [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height-35);
//        }
//    } else {
//        mainBounds = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, (([UIScreen mainScreen].bounds.size.height )));
//    }
    mainBounds = CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, (([UIScreen mainScreen].bounds.size.height )));
    
    //NSLog(@"The height is %f", mainBounds.size.height );
    return mainBounds;
}


+ (CGRect)getRectForViewFromOrientation:(UIDeviceOrientation)orientation
{
    if(orientation == UIDeviceOrientationLandscapeRight ||  orientation == UIDeviceOrientationLandscapeLeft)
    {
        return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.height, (([UIScreen mainScreen].bounds.size.width )));
    }
    //    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
    //
    //        return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.height, (([UIScreen mainScreen].bounds.size.width )));
    //
    //    }
    
    NSLog(@"The height is %f", [UIScreen mainScreen].bounds.size.height );
    return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, (([UIScreen mainScreen].bounds.size.height )));
}

+ (BOOL)isIOS8over{
    BOOL isIOS8over = false;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        isIOS8over = true;
    }
    return isIOS8over;
}


+ (BOOL)isiPad {
    BOOL isiPad = false;
    NSString *kindofDevice = [[UIDevice currentDevice] model]; // e.g. @"iPhone", @"iPod touch"
    if([kindofDevice isEqualToString:@"iPad"] || [kindofDevice isEqualToString:@"iPad Simulator"])
    {
        isiPad = true;
    }
    return isiPad;
}


// 이미지 크기 축소
+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution orientation:(UIImageOrientation)orientation
{
    NSLog(@"PickerDelegate: scaleAndRotate");
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if(maxResolution > 2048)
        maxResolution = maxResolution * 0.25;
    else if(maxResolution > 1024)
        maxResolution = maxResolution * 0.5;
    else {
        maxResolution = maxResolution * 1.0;
    }
    
    if (width > maxResolution || height > maxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = maxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    switch (orientation) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight || orientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

// 이미지 크기 축소
+ (UIImage *)scaleAndRotate:(UIImage *)image maxResolution:(int)maxResolution
{
    NSLog(@"PickerDelegate: scaleAndRotate");
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    float sizeRate = 1.0;
    if(maxResolution > 2048)
        sizeRate = 0.25;
    else if(maxResolution > 1024)
        sizeRate = 0.5;
    else {
        sizeRate = 1.0;
    }
    CGRect bounds = CGRectMake(0, 0, width*sizeRate, height*sizeRate);
    UIImage *imageCopy = [JHUtile imageWithImage:image scaledToSize:bounds.size];
    UIImage *imageFix  = [JHUtile fixrotation:imageCopy];
    return imageFix;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+ (CGSize)getStringSize:(CGSize)size font:(UIFont*)font message:(NSString*)message
{
    CGSize sizevelue = CGSizeZero;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;//NSLineBreakByCharWrapping,NSLineBreakByWordWrapping
    NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName: paragraph};
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //속성값
        CGRect rectsize = CGRectZero;
        rectsize = [message boundingRectWithSize:size options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes context:nil];
        sizevelue = rectsize.size;
    }
    sizevelue.width += 10;
    sizevelue.height += 2;
    return sizevelue;
}

+ (CGSize)getUITextViewSizeFromUITextView:(CGSize)size font:(UIFont*)font message:(NSString*)message textView:(UITextView*)textView fileType:(NSInteger)fileType
{
    NSValue *sizeVale = [NSValue valueWithCGSize:size];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          sizeVale,          @"size",
                          font,              @"font",
                          message, @"message",
                          textView, @"textView",
                          nil];
    
    [JHUtile performSelectorOnMainThread:@selector(getSizeUITextview:) withObject:dict waitUntilDone:YES];
    
    
    NSValue *returnSizeVale = [dict objectForKey:@"returnSize"];
    CGSize sizeValue = [returnSizeVale CGSizeValue];
    if(sizeValue.height > 100){
        sizeValue.height -= 7;
    }else{
        sizeValue.height -= 10;
    }
    
    if(fileType == 2){
        sizeValue.width = size.width;
    }
    return sizeValue;
}

+ (void)getSizeUITextview:(NSMutableDictionary*)dict{

    NSValue *sizeVale = [dict objectForKey:@"size"];
    CGSize size = [sizeVale CGSizeValue];
    UIFont *font = [dict objectForKey:@"font"];
    NSString *message = [dict objectForKey:@"message"];
    UITextView *textView = [dict objectForKey:@"textView"];

    if(textView == nil){
        //init시 시간 소요
        textView = [[UITextView alloc] init];
        [textView setFont:font];
        [textView setEditable:NO];
        [textView setScrollEnabled:NO];
        [textView setDataDetectorTypes:UIDataDetectorTypeLink|UIDataDetectorTypePhoneNumber|UIDataDetectorTypeAddress];
    }
    
    [textView setFont:font];
    [textView setText:message];
    CGSize sizeValue = [textView sizeThatFits:size];
    NSValue *returnSize = [NSValue valueWithCGSize:sizeValue];
    [dict setObject:returnSize forKeyedSubscript:@"returnSize"];
    
}

+ (NSString*)encodeURL:(NSString *)string
{
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)string,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    return escapedString;
}


//파리미터만 인코딩
+(NSString*)changeQueryStringParameter:(NSString *)urlString
{
    NSArray *hostParser = [urlString componentsSeparatedByString:@"?"];
    NSMutableString *encodingURL = [[NSMutableString alloc] initWithString:[hostParser firstObject]];
    if(hostParser.count == 2){
        [encodingURL appendString:@"?"];
        NSString *lastStr = [hostParser lastObject];
        NSArray *parmParser = [lastStr componentsSeparatedByString:@"&"];
        for (int i=0; i<parmParser.count; i++) {
            if(i != 0){
                [encodingURL appendString:@"&"];
            }
            NSString *item = [parmParser objectAtIndex:i];
            NSRange pos = [item rangeOfString:@"="];
            if(pos.location == NSNotFound){
                urlString = [NSString stringWithFormat:@"%@", [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; //인코딩 (URL 케치시 디코딩한것을 다시 인코딩함)
                return urlString;
            }
            NSString *key = [item substringToIndex:pos.location];
            NSString *value = [self encodeURL:[item substringFromIndex:pos.location+1]];
            [encodingURL appendString:key];
            [encodingURL appendString:@"="];
            [encodingURL appendString:value];
        }
    }else{
        urlString = [NSString stringWithFormat:@"%@", [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; //인코딩 (URL 케치시 디코딩한것을 다시 인코딩함)
        return urlString;
    }
    return encodingURL;
}



//애니메이션
+ (CABasicAnimation*)moveAnimation:(UIView*)view form:(CGPoint)formPoint to:(CGPoint)toPoint duration:(CFTimeInterval)duration
{
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setDuration:duration];
    [move setFromValue:[NSValue valueWithCGPoint:formPoint]];
    [move setToValue:[NSValue valueWithCGPoint:toPoint]];
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [view.layer addAnimation:move forKey:@"position"];
    return move;
}

+ (CABasicAnimation *)boundsAnimation:(UIView*)view form:(CGRect)formValue to:(CGRect)toValue duration:(CFTimeInterval)duration
{
    CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [bounds setDuration:duration];
    [bounds setFromValue:[NSValue valueWithCGRect:formValue]];
    [bounds setToValue:[NSValue valueWithCGRect:toValue]];
    bounds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:bounds forKey:@"bounds"];
    return bounds;
}

+ (CABasicAnimation *)appearAnimation:(UIView*)view duration:(CFTimeInterval)duration
{
    CABasicAnimation *appear = [CABasicAnimation animationWithKeyPath:@"hidden"];
    [appear setDuration:duration];
    [appear setFromValue:[NSNumber numberWithDouble:1]];
    [appear setToValue:[NSNumber numberWithDouble:0]];
    appear.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:appear forKey:@"hidden"];
    return appear;
}

+ (NSString*)getCurrentDeviceModel{
    
    //https://github.com/InderKumarRathore/DeviceUtil/blob/master/DeviceUtil.m
    NSString *hardware = [JHUtile hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev. A)";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([hardware isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad (WiFi)";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi Rev. A)";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air (WiFi+GSM)";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (Wi-Fi + Cellular CN)";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Wi-Fi + Cellular)";
    
    if ([hardware isEqualToString:@"i386"])         return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";
    if ([hardware hasPrefix:@"iPhone"])             return @"iPhone";
    if ([hardware hasPrefix:@"iPod"])               return @"iPod";
    if ([hardware hasPrefix:@"iPad"])               return @"iPad";

    return nil;

}

+ (NSString*)hardwareString {
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}


//영어 ~번째 표시
+ (NSString *)formatOrdinalNumber:(NSInteger)number{
    //0 remains just 0
    if (number == 0) return @"0";
    //test for number between 3 and 21 as they follow a
    //slightly different rule and all end with th
    if (number > 3 && number < 21)
    {
        return [NSString stringWithFormat:@"%ldth", (long)number];
    }
    //return the last digit of the number e.g. 102 is 2
    int lastdigit = number % 10;
    //append the correct ordinal val
    switch (lastdigit)
    {
        case 1: return [NSString stringWithFormat:@"%ldst", (long)number];
        case 2: return [NSString stringWithFormat:@"%ldnd", (long)number];
        case 3: return [NSString stringWithFormat:@"%ldrd", (long)number];
        default: return [NSString stringWithFormat:@"%ldth", (long)number];
    }
    
}


//URL 정규식
//stringURL : 텍스트 메시지
//리턴 : URL 이 없을경우  @""  리턴, 있을 경우 해당 URL 리턴
+ (NSString*)validateUrl:(NSString *)stringURL{
    
    __block NSString *value = @"";
    NSString *string = stringURL;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSURL *url = [match URL];
        if ([[url scheme] isEqual:@"tel"]) {
            NSLog(@"found telephone url: %@", url);
        } else if ([[url scheme] isEqual:@"mailto"]) {
            NSLog(@"found e-mail url: %@", url);
        } else {
            value = [url absoluteString];
            NSLog(@"found regular url: %@", url);
            break;
        }
    }
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(concurrentQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isCanOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:value]];
            if(isCanOpen == false){
                value = @"";
            }
        });
    });
    return value;
}

//랜덤값 
+ (NSInteger)getRandomNumber:(NSInteger)number{
    //arc4random() is the standard Objective-C random number generator function
    return arc4random() % number;
}


//파일 네임 인코딩
+ (NSString*)getFilenameFromContentDisposition:(NSString*)contentDisposition {
    return  [NSString stringWithCString:[contentDisposition cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
}

+ (BOOL)checkDisableCamera{
    
    BOOL isdisableCamera = false;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status != AVAuthorizationStatusAuthorized && status != AVAuthorizationStatusNotDetermined){
        isdisableCamera =true;
    }
    return isdisableCamera;
}

+ (BOOL)checkMoveFile:(NSString*)fileName{
    
    BOOL isMoveFile = false;
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"."];
    
    NSString *fileExtension = [[fileNameArray lastObject] lowercaseString];
    if([fileExtension isEqualToString:@"mov"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"avi"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"mp4"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"mpeg"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"mpg"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"m4v"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"wmv"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"mkv"]){
        isMoveFile = true;
    }else if([fileExtension isEqualToString:@"3gp"]){
        isMoveFile = true;
    }
    return isMoveFile;
}

+ (void)deleteCookies{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

+ (void)setCookis:(NSArray*)cookies{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in cookies) {
        [storage setCookie:cookie];
    }
}

+ (BOOL)isEmptyString:(NSString*)string{
    if(string == nil || string.length == 0 || [string isEqualToString:@"(null)"]){
        return YES;
    }
    return NO;
}

+ (NSInteger)getUnSingedInt:(NSInteger)integer{
    if(integer < 0){
        return 0;
    }
    return integer;
}

+ (NSString*)getCurrentLangage{
    NSString *kindofLanguage = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    if(YES == [currentLanguage hasPrefix:@"ja"]) {    //일본어
        kindofLanguage = @"ja";
    } else if(YES == [currentLanguage hasPrefix:@"zh-Hans"]) {    //중국어 //(간체)
        kindofLanguage = @"zh_CN";
    } else if(YES == [currentLanguage hasPrefix:@"zh-Hant"]) {    //중국어 //(번체)
        kindofLanguage = @"zh_TW";
    } else if(YES == [currentLanguage hasPrefix:@"ko"]) {     //한국어
        kindofLanguage = @"ko";
    } else if(YES == [currentLanguage hasPrefix:@"vi"]) {     //베트남
        kindofLanguage = @"vi";
    } else {
        kindofLanguage = @"en";
    }
    return kindofLanguage;
}
@end
















