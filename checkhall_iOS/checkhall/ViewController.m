//
//  ViewController.m
//  checkhall
//
//  Created by pc on 2017. 12. 3..
//  Copyright © 2017년 pc. All rights reserved.
//

#import "ViewController.h"
#import <KakaoLink/KakaoLink.h>
#import "UIView+Loading.h"
#import "UIViewController+Alert.h"
#import "Defines.h"
#import "JHUtile.h"
#import "CheckhallUtile.h"
#import "GlobalData.h"


#define HEAD                @"checkhall://"


@interface ViewController ()

@end

@implementation ViewController
- (id) init {
    self = [super init];
    if (self != nil) {
        NSLog(@" MemberSyncAppDelegate => init");
        ivoryManager = [[ConnectManager alloc] init];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTI_LINK" object:nil];
    [ivoryManager.Work cancelAllOperations];
    NSArray *operations  = [ivoryManager.Work operations];
    for (IvoryRequest *item in operations) {
        NSLog(@" IvoryRequest nil => %@", item);
        item.target = nil;
        item.selector = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect mainRect = [JHUtile getRectForView];
    CGFloat webHeight = mainRect.size.height+20;
    
    if([JHUtile isiPhoneXDisplay]){
        webHeight +=35;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiLink) name:@"NOTI_LINK" object:nil];
    
    CGRect webrect = [JHUtile getRectViewOS7:CGRectMake(0, 0, self.view.frame.size.width, webHeight)];
    _webView = [[UIWebView alloc] initWithFrame:webrect];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.multipleTouchEnabled = YES;
    _webView.scrollView.bounces =false;
    _webView.backgroundColor = [UIColor whiteColor];
     [self.view addSubview:_webView];
    
    NSInteger statusHeight = 23;
    if([JHUtile isiPhoneXDisplay]){
        statusHeight = 48;
    }
    UIImageView *statusBgView = [[UIImageView alloc] initWithImage:[JHUtile image1x1WithColor:RGBA(255, 255, 255, 1)]];
    [statusBgView setFrame:CGRectMake(0, 0, mainRect.size.width, statusHeight)];
    [statusBgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [statusBgView setUserInteractionEnabled:YES];
    [self.view addSubview:statusBgView];
    
    NSString *notiUrl = [[GlobalData sharedData] notiUrl];
    if([JHUtile isEmptyString:notiUrl]){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString: @"http://www.checkhall.com"]];
        [_webView loadRequest:request];
    }else{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString: notiUrl]];
        [_webView loadRequest:request];
    }

    [[GlobalData sharedData] setIsNotiAppRun:NO];
    // Indigator 적용
    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 30);
    [self.view addSubview:loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strUrl = [[request URL] absoluteString];
    NSString * strTemp = [NSString stringWithFormat:@"%@", [strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"webView ==> %@" , strTemp);
    
    //strTemp = @"checkhall://sendKakao?type=feed&&&title=유석 플래너의 추천 웨딩홀 리스트입니다.&&&imageUrl=http://checkhall.com/images_upload/c/e3299cf3eef2509feb68daf7b635f754.jpg&&&link=http://checkhall.com/plan/wanted/proposal.jsp?enc_idx=a338a9c642a49bbe4c4782f749caa2c1&push_yn=Y";

    //strTemp = @"checkhall://sendSms?mobile_no=&&&body=유석 플래너의 추천 웨딩홀 리스트입니다. http://checkhall.com/plan/wanted/proposal.jsp?enc_idx=a338a9c642a49bbe4c4782f749caa2c1&push_yn=Y";
    
    //strTemp = @"checkhall://sendEmail?email=&&&subject=유석 플래너의 추천 웨딩홀 리스트입니다. &&&body=유석 플래너의 추천 웨딩홀 리스트입니다. http://checkhall.com/plan/wanted/proposal.jsp?enc_idx=a338a9c642a49bbe4c4782f749caa2c1&push_yn=Y";
    
    //strTemp = @"checkhall://uploadFile?auction_url=http://checkhall.com/member/setPhotoApp.jsp?idx=c7aa9d923757006fbd32a511fcdf0470&enctype=multipart/form-data&&&callback=fnReset()";
    //strTemp = @"checkhall://uploadFile?callback=fnReset()&&&auction_url=http://checkhall.com/member/setPhotoApp.jsp?idx=c7aa9d923757006fbd32a511fcdf0470&enctype=multipart/form-data";
    //strTemp = @"checkhall://resetBadge?badge_count="+badge_count";
    //strTemp = @"checkhall://resetBadge?badge_count=13";
    
    BOOL isLink = [self checkCheckHallSchema:strTemp];
    if(isLink){
        NSArray *splitedURL = [strTemp componentsSeparatedByString:HEAD];
        NSString *prefix = [splitedURL objectAtIndex:1];
        NSArray *arr = [prefix componentsSeparatedByString:@"?"];
        NSString *type = [arr objectAtIndex:0];
        
        NSRange spiteRange = [prefix rangeOfString:@"?"];
        if(spiteRange.location == NSNotFound){
            return NO;
        }
        //NSString *value = [arr objectAtIndex:1];
        NSString *value = [prefix substringFromIndex:spiteRange.location+ spiteRange.length];
        if([type hasPrefix:@"sendSms"]){
            [self sendSms:value];
        }else if([type hasPrefix:@"sendKakao"]){
            [self sendKakaoData:value];
        }else if([type hasPrefix:@"sendEmail"]){
            [self sendEmail:value];
        }else if([type hasPrefix:@"uploadFile"]){
            [self uploadFile:value];
        }else if([type hasPrefix:@"externalURL"]){
            [self externalURL:value];
        }else if([type hasPrefix:@"resetBadge"]){
            [self resetBadge:value];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
    [loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    NSLog(@"%@", yourHTMLSourceCodeString);
    
    NSString * idx = [CheckhallUtile getIdxString:yourHTMLSourceCodeString];
    if(idx.length > 0){
        NSLog(@"%@", idx);
        [self requsetPushToken:idx];
    }
    [loadingView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError %@", error);
    [loadingView stopAnimating];
}


- (void)requsetPushToken:(NSString*)idx{
    NSLog(@"requsetPushToken");
    
    NSString *deviceId = [JHUtile getUUID];
    NSString *fcmToken = [[GlobalData sharedData] fcmToken];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          idx,          @"idx",    //
                          deviceId,    @"device_id",   //Device의 unique id값을 생성또는 catch해서 전달한
                          @"fcm",    @"push_type",
                          fcmToken,       @"push_token", //Firebase의 tokenid를 전달한다.
                          nil];
    NSString *makeURL = [[NSString alloc] initWithFormat:@"http://m.checkhall.com/member/setPushToken.jsp"];
    NSLog(@"호출 : %@", makeURL);
    IvoryRequest *request = [[IvoryRequest alloc] init];
    [request.IvRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setDelegate:self selector:@selector(recivePushToken:)];
    [request setIsReturnValue:YES];
    [request setReturnValue:request.IvRequest];
    [request requestPOSTURL:makeURL requestData:dict];
    //[ivoryManager addRequest:request];
}

- (void)recivePushToken:(id)ParsingData{
    NSString *strRtn = [[NSString alloc] initWithData:ParsingData encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [strRtn objectFromJSONString];
    
}


#pragma mark - check
- (BOOL)checkCheckHallSchema:(NSString*)url{
    BOOL isLink = false;
    if([url hasPrefix:HEAD]){
        isLink = true;
    }
    return isLink;
}

#pragma mark - 카카오
- (void)sendKakaoData:(NSString*)value{
    NSArray *values = [value componentsSeparatedByString:@"&&&"];
    
    NSString *type = @"";
    NSString *title = @"";
    NSString *imageUrl = @"";
    NSString *link = @"";
    
    for (NSString *item in values) {
        NSArray * params =[item componentsSeparatedByString:@"="];
        NSString *key = [params objectAtIndex:0];
        NSRange spiteRange = [item rangeOfString:@"="];
        if(spiteRange.location == NSNotFound){
            continue;
        }
        NSString *data = [item substringFromIndex:spiteRange.location+ spiteRange.length];
        
        if([@"type" hasPrefix:key]){
            type = data;
        }else if([@"title" hasPrefix:key]){
            title = data;
        }else if([@"imageUrl" hasPrefix:key]){
            imageUrl = data;
        }else if([@"link" hasPrefix:key]){
            link = data;
        }
    }
    
    //카카오메시지
    [self sendKakao:title imageURL:imageUrl link:link];
}


//- (void)sendKakao:(NSString *)title imageURL:(NSString *)imageURL link:(NSString*)link{
//    // Feed 타입 템플릿 오브젝트 생성
//    KLKTemplate *template = [KLKFeedTemplate feedTemplateWithBuilderBlock:^(KLKFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
//
//        // 컨텐츠
//        feedTemplateBuilder.content = [KLKContentObject contentObjectWithBuilderBlock:^(KLKContentBuilder * _Nonnull contentBuilder) {
//            contentBuilder.title = title;
//            contentBuilder.desc = @"";
//            contentBuilder.imageURL = [NSURL URLWithString:imageURL];
//            contentBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
////                linkBuilder.androidExecutionParams = link;
////                linkBuilder.iosExecutionParams = link;
////                linkBuilder.mobileWebURL = [NSURL URLWithString:link];
//                linkBuilder.webURL = [NSURL URLWithString:link];
//            }];
//        }];
//
//        // 버튼
//        [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {
//            buttonBuilder.title = @"연결";
//            //buttonBuilder.title = title;
//            buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
//                linkBuilder.webURL = [NSURL URLWithString:link];
//            }];
//        }]];
//
//
////        [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {
////            buttonBuilder.title = @"앱으로 보기";
////            buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
////                linkBuilder.iosExecutionParams = @"param1=value1&param2=value2";
////                linkBuilder.androidExecutionParams = @"param1=value1&param2=value2";
////            }];
////        }]];
//    }];
//
//    // 카카오링크 실행
//    //[self.view startLoading];
//    [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
//
//        // 성공
//        //[self.view stopLoading];
//        NSLog(@"warning message: %@", warningMsg);
//        NSLog(@"argument message: %@", argumentMsg);
//    } failure:^(NSError * _Nonnull error) {
//
//        // 실패
//        //[self.view stopLoading];
//        //[self alertWithMessage:error.description];
//        NSLog(@"error: %@", error);
//    }];
//}


- (void)sendKakao:(NSString *)title imageURL:(NSString *)imageURL link:(NSString*)link{
    // Feed 타입 템플릿 오브젝트 생성
    KLKTemplate *template = [KLKFeedTemplate feedTemplateWithBuilderBlock:^(KLKFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
        
        // 컨텐츠
        feedTemplateBuilder.content = [KLKContentObject contentObjectWithBuilderBlock:^(KLKContentBuilder * _Nonnull contentBuilder) {
            contentBuilder.title = title;
            contentBuilder.desc = @"";
            contentBuilder.imageURL = [NSURL URLWithString:imageURL];
            contentBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                linkBuilder.mobileWebURL = [NSURL URLWithString:link];
                linkBuilder.webURL = [NSURL URLWithString:link];
            }];
        }];
        
        // 버튼
        [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {
            buttonBuilder.title = @"연결";
            buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                linkBuilder.mobileWebURL = [NSURL URLWithString:link];
                linkBuilder.webURL = [NSURL URLWithString:link];
            }];
        }]];
    }];
    
    // 카카오링크 실행
    [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        
        // 성공
        NSLog(@"warning message: %@", warningMsg);
        NSLog(@"argument message: %@", argumentMsg);
    } failure:^(NSError * _Nonnull error) {
        
        // 실패
        NSLog(@"error: %@", error);
    }];
}
#pragma mark - 문자발송
- (void)sendSms:(NSString*)value{
    NSArray *values = [value componentsSeparatedByString:@"&&&"];
    
    NSString *mobile_no = @"";
    NSString *body = @"";
    
    for (NSString *item in values) {
        
        NSArray * params =[item componentsSeparatedByString:@"="];
        NSString *key = [params objectAtIndex:0];
        NSRange spiteRange = [item rangeOfString:@"="];
        if(spiteRange.location == NSNotFound){
            continue;
        }
        NSString *data = [item substringFromIndex:spiteRange.location+ spiteRange.length];
        
        if([@"mobile_no" hasPrefix:key]){
            mobile_no = data;
        }else if([@"body" hasPrefix:key]){
            body = data;
        }
    }
    
    //문자메시지 발송
    NSString *MemberCall = mobile_no;
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]){
        NSArray * toRecipients = [NSArray arrayWithObjects:MemberCall, nil];
        controller.recipients = toRecipients;
        controller.title = @"";
        [controller setBody:body];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"ProfileViewCtrl: SMS send cancel");
            break;
        case MessageComposeResultFailed:
            NSLog(@"ProfileViewCtrl: SMS was sent ResultFailed");
            break;
        case MessageComposeResultSent:
            NSLog(@"ProfileViewCtrl: SMS was sent successfully");
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 이메일

- (void)sendEmail:(NSString*)value{
    NSArray *values = [value componentsSeparatedByString:@"&&&"];
    NSString *email = @"";
    NSString *subject = @"";
    NSString *body = @"";
    for (NSString *item in values) {
        NSArray * params =[item componentsSeparatedByString:@"="];
        NSString *key = [params objectAtIndex:0];
        NSRange spiteRange = [item rangeOfString:@"="];
        if(spiteRange.location == NSNotFound){
            continue;
        }
        NSString *data = [item substringFromIndex:spiteRange.location+ spiteRange.length];
        
        if([@"email" hasPrefix:key]){
            email = data;
        }else if([@"subject" hasPrefix:key]){
            subject = data;
        }else if([@"body" hasPrefix:key]){
            body = data;
        }
    }
    
    //이메일 발송
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:subject];
        [mailCont setToRecipients:[NSArray arrayWithObject:email]];
        [mailCont setMessageBody:body isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                            message:@"메일을 발송할수 없습니다. 메일 설정을 확인해주세요."
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"확인", nil) otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 프로필 업로드
- (void)uploadFile:(NSString*)value{

//    action_url = @"";
//    callback = @"";
//    
//    NSRange callbackRange = [value rangeOfString:@"callback"];
//    NSRange auction_urlRange = [value rangeOfString:@"auction_url"];
//    
//    if(callbackRange.location > auction_urlRange.location){
//        callback = [value substringFromIndex:callbackRange.location+callbackRange.length+1];
//        
//        NSUInteger firstpos = auction_urlRange.location+auction_urlRange.length+1;
//        action_url = [value substringWithRange:NSMakeRange(firstpos, callbackRange.location - firstpos -1)];
//    }else{
//        action_url = [value substringFromIndex:auction_urlRange.location+auction_urlRange.length+1];
//        
//        NSUInteger firstpos = callbackRange.location+callbackRange.length+1;
//        callback = [value substringWithRange:NSMakeRange(firstpos, auction_urlRange.location - firstpos -1)];
//    }
    
    NSArray *values = [value componentsSeparatedByString:@"&&&"];
    action_url = @"";
    callback = @"";
    for (NSString *item in values) {
        NSArray * params =[item componentsSeparatedByString:@"="];
        NSString *key = [params objectAtIndex:0];
        NSRange spiteRange = [item rangeOfString:@"="];
        if(spiteRange.location == NSNotFound){
            continue;
        }
        NSString *data = [item substringFromIndex:spiteRange.location+ spiteRange.length];
        
        if([@"auction_url" hasPrefix:key]){
            action_url = data;
        }else if([@"callback" hasPrefix:key]){
            callback = data;
        }
    }
    if(action_url.length > 0  && callback.length > 0){
        //사진 선택 실행
        [self showPickerController];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"호출파라미터가 잘못되었습니다."
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"확인", nil) otherButtonTitles:nil];
        [alert show];
    }
    
}

//사진선택
- (void)showPickerController{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

//선택 완료
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *imgData = UIImageJPEGRepresentation(chosenImage, 1.0);
    
    NSDate *randomkeyTime = [NSDate date];
    NSDateFormatter *randomkeyFormatter = [[NSDateFormatter alloc] init];
    [randomkeyFormatter setDateFormat:@"ssddSSSMMHHmm"];
    NSString *randomkeyDate = [randomkeyFormatter stringFromDate:randomkeyTime];
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@.jpg" ,randomkeyDate];
    [self fileUpload:imgData fileName:fileName];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//사진 전송
- (FileUploadErrorType)fileUpload:(NSData*)data fileName:(NSString*)fileName{

    NSLog(@"fileUpload fileneme = [%@]", fileName);
    FileUploadErrorType ret =NonError;
    @try {
        NSString *url = action_url;
        IvoryRequest * requst = [[IvoryRequest alloc] init];
        [requst setDelegate:self selector:@selector(ReciveData:)];
        
        ///////////////헤더////////////////
        NSString *boundary = @"----WebKitFormBoundarykCJByabD491BlTiw";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        NSString *ConnectionType = [NSString stringWithFormat:@"Keep-Alive"];
        NSDictionary *HeadParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    ConnectionType,                 @"Connection",
                                    contentType,                    @"content-Type",
                                    @"application/json",                 @"Accept",
                                    @"file://",                     @"Origin",
                                    @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.54.16 (KHTML, like Gecko) Version/5.1.4 Safari/534.54.16", @"User-Agent",nil];
        
        ///////////////바디////////////////
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:data]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [requst requestSendFileURL:url filePath:@"" requestParams:nil Head:HeadParams Body:body];
        [ivoryManager addRequest:requst];
        
        ret = NonError;
    }
    @catch (NSException *exception) {
        ret = HTTPException;
    }
    return ret;
}

-(void)ReciveData:(id)sender
{
    if(sender == nil) {
        //에러
        NSLog(@"ReciveData ERR");
        return;
    }
    NSString * result = [[NSString alloc] initWithData:sender encoding:NSUTF8StringEncoding];
    NSLog(@"ReciveData :: %@" , result);
    [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:callback waitUntilDone:NO];
    return;
}

#pragma mark - 외부 URL (비제휴사)
- (void)externalURL:(NSString*)value{
    NSString *externalURL = @"";
    NSRange urlRange = [value rangeOfString:@"action_url"];
    externalURL = [value substringFromIndex:urlRange.location+urlRange.length+1];

    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:externalURL];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened url");
        }
    }];
}


#pragma mark - 벳지카운트 갱신
- (void)resetBadge:(NSString*)value{
    NSString *badge_count = @"";
    NSRange urlRange = [value rangeOfString:@"badge_count"];
    badge_count = [value substringFromIndex:urlRange.location+urlRange.length+1];
    
    NSInteger count = [badge_count integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    NSLog(@"resetBadge badge_count = %@, count = %d", badge_count, count);
}



#pragma mark - noti link
- (void)notiLink{
    NSString * url = [[GlobalData sharedData] notiUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:url]];
    [_webView loadRequest:request];
}

@end
