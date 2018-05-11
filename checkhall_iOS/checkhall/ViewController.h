//
//  ViewController.h
//  checkhall
//
//  Created by pc on 2017. 12. 3..
//  Copyright © 2017년 pc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ConnectManager.h"

typedef enum {
    NonError,
    FileSizeOverflow,
    HTTPException
} FileUploadErrorType;


//Color
#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface ViewController : UIViewController<UIScrollViewDelegate,UIWebViewDelegate,MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UIWebView           *_webView;
    UIActivityIndicatorView     *loadingView;
    ConnectManager      *ivoryManager;
    
    
    //파일 업로드
    NSString *callback;
    NSString *action_url;
    
}
@end

