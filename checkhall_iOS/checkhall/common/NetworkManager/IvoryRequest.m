//
//  IvoryRequest.m
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

//링크 라이브러리
//libresolv.dylib

#import "IvoryRequest.h"
#import "NSObject+performSelectorOnMainThreadMultipleArgs.h"
#import "ConnectManager.h"
#import "AppDelegate.h"
#import "Defines.h"
#import "LogFile.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import "getgateway.h"
#include <resolv.h>
#include <dns.h>



@implementation IvoryRequest
//#define TIME_OUT_INTERVAL   10.0f

@synthesize ConfigData;
@synthesize Parser;
@synthesize IvRequest;
@synthesize receivedData;
@synthesize target;
@synthesize selector;
@synthesize isReturnValue;
@synthesize isReturnResponse;
@synthesize returnValue;
@synthesize HeadData;
@synthesize BodyData;
@synthesize isUseNSURLConnectionDataDelegate;

- (void)dealloc
{
    NSLog(@"deallocated %@", self);
    if(ConfigData != nil)
    {
        [ConfigData release];
        ConfigData = nil;
    }
    if(Parser != nil)
    {
        [Parser release];
        Parser = nil;
    }
    if(receivedData != nil)
    {
        [receivedData release];
        receivedData = nil;
    }
    if(HeadData != nil)
    {
        [HeadData release];
        HeadData = nil;
    }
    if(BodyData != nil)
    {
        [BodyData release];
        BodyData = nil;
    }
    if(IvRequest != nil)
    {
        [IvRequest release];
        IvRequest = nil;
    }


    [super dealloc];
}


- (id)init
{
    self = [super init];
    if (self) {
        ConfigNetworkData     * Data = [[ConfigNetworkData alloc] init];
        self.ConfigData = Data;
        [Data release];
        
        manager = [ConnectManager sharedObject];
        
        isReturnValue = FALSE;
        isReturnResponse = FALSE;
        isUseNSURLConnectionDataDelegate = FALSE;

        NSMutableURLRequest *_IvRequest = [[NSMutableURLRequest alloc] init];
        self.IvRequest = _IvRequest;
        [_IvRequest release];
        
    }
    
    return self;
}

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(requestType == REQUEST_TYPE_GET)
        [self excuteGetRequest];
    else if(requestType == REQUEST_TYPE_POST)
        [self excutePostRequest];
    else if(requestType == REQUEST_TYPE_FILE)
        [self excuteFileRequest];
    else if(requestType == REQUEST_TYPE_SAMPLE_FILE)
        [self excuteSampleFileRequest];
    else if(requestType == REQUEST_TYPE_DELETE)
        [self excuteDeleteRequest];
    else if(requestType == REQUEST_TYPE_ETC)
        [self excuteRequestEx];
    [pool release];
}

#pragma mark - 네트워크 지원 함수 설정 -
/**
 @return 
 (NSString*) 맥어드래스 값 리턴 
 @param
 @brief
 맥어드래스 값 리턴 
 @note
 @warning
 */
+ (NSString*)getMACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;              
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        NSLog(@"Mac Address: %@", macAddressString);
        
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    // Error...
    NSLog(@"Error: %@", errorFlag);
    
    return errorFlag;
}

/**
 @return 
 - (BOOL)					네트웍 사용가능여부
 @param
 - (id)viewCtl				Alert의 델리게이트 
 @brief
 - 네트웍 사용가능여부를 파악한다.
 @warning
 
 */
+ (NSInteger)getNetworkStatus 
{
	int nRtn = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	switch (nRtn)
	{
		case NotReachable:      //접속불가
            NSLog(@"Access Not Available : %ld", (long)NotReachable);
            break;
		case ReachableViaWiFi:  //WiFi
            NSLog(@"ReachableViaWiFi : %ld", (long)ReachableViaWiFi);
            break;                     
            
		case ReachableViaWWAN:  //3G
            NSLog(@"ReachableViaWWAN : %ld", (long)ReachableViaWWAN);
            break;
	}
    
	return nRtn;
}

/**
 @return 
 - (int) 접속 여부 값
 @param
 - (NSString *)hostName 체크할 호스트 주소
 @brief
 - 특정 호스트주소의 접속 가능 여부 반환
 @warring
 
 */
+ (NSInteger)getHostNetworkCheck:(NSString *)hostName
{
    
    NSInteger resVal = 0;
    
    Reachability *hostReach = [[Reachability reachabilityWithHostName:hostName] retain];
    
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    BOOL connectionRequired= [hostReach connectionRequired];
    NSString* statusString= @"";
    
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            NSLog(@"%@", statusString);
            connectionRequired= NO;
            resVal = NotReachable;
            break;
        }
            
        case ReachableViaWiFi:
        {
            statusString = @"Reachable WiFi";
            NSLog(@"%@", statusString);
            resVal = ReachableViaWiFi;
            break;
        }            
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            NSLog(@"%@", statusString);
            resVal = ReachableViaWWAN;
            break;
        }
    } 
    
    if(connectionRequired)
    {
        NSLog(@"%@, Connection Required", statusString);
    }
    
    [hostReach release];
    
    return resVal;
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
} 

+ (NSString *)getAPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_LINK) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"ap1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


//SSID
+ (NSString *)getWifiName{
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    if(myDict == nil)
        return @"";
    NSString *networkName = CFDictionaryGetValue(myDict, kCNNetworkInfoKeySSID);
    return networkName;
}

//MAC 주소
+ (NSString *)getWifiMacAddress{
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    if(myDict == nil)
        return @"";
    NSString *networkBSSID = CFDictionaryGetValue(myDict, kCNNetworkInfoKeyBSSID);
    return networkBSSID;
}

//라우터 주소
+ (NSString *)getRouterAddress{
//#import "getgateway.h"
    
    NSString * ipString = @"";
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r>=0){
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
        NSLog(@"default gateway : %@", ipString );
    }
    else
    {
        NSLog(@"getdefaultgateway() failed");
    }
    return ipString;
}

+ (NSString *)getSubnetMask
{
    NSString *netmask = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);

    return netmask;
}
#pragma mark - 네트워크 설정(ConfigNetworkData 설정) -
/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 큐에 저장 (기본 설정)
 @note
 @warning
 */
- (void)requestURL
{
    requestType = REQUEST_TYPE_GET;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 
    [manager setRequest:self];
}

/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 큐에 저장 (GET 설정)
 @note
 @warning
 */
- (void)requestGETURL
{
    requestType = REQUEST_TYPE_GET;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 

    [manager setRequest:self];
}

/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 큐에 저장 (POST 설정)
 @note
 @warning
 */
- (void)requestPOSTURL
{
    requestType = REQUEST_TYPE_POST;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 

    [manager setRequest:self];
}

/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 큐에 저장 (파일 전송)
 @note
 @warning
 */
- (void)requestSendFileURL
{
    requestType = REQUEST_TYPE_FILE;

    [manager setRequest:self];
}

/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 큐에 저장 (파일 전송 샘플)
 @note
 @warning
 */
- (void)requestSendSampleFileURL
{
    requestType = REQUEST_TYPE_SAMPLE_FILE;

    [manager setRequest:self];
}


#pragma mark - 네트워크 설정(함수로 설정) -
/**
 @return 
 @param
 (NSString *)URL Get형식으로 전송할 URL
 @brief
 Get 형식의 리퀘스트 전송 
 @note
 @warning
 */
- (void)requestGETURL:(NSString *)URL 
{
    self.ConfigData.HTTPMethod = @"GET";
    self.ConfigData.connectURL = URL;
 
    requestType = REQUEST_TYPE_GET;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 
    
    //** 클래스에서 큐등록하도록 수정
    //[manager setRequest:self];
}

/**
 @return 
 @param
 (NSString *)URL Post 전송할 통신 URL 
 (NSDictionary *)requestParams  Post 전송할 데이터 정보  
 @brief
 Post 형식의 리퀘스트 전송
 @note
 @warning
 */
- (void)requestPOSTURL:(NSString *)URL requestData:(NSDictionary *)requestParams 
{
    self.ConfigData.HTTPMethod = @"POST";
    self.ConfigData.connectURL = URL;
    self.ConfigData.requestData = requestParams;
    
    requestType = REQUEST_TYPE_POST;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 

    [manager setRequest:self];
}

/**
 @return
 @param
 (NSString *)URL DELETE 전송할 통신 URL
 (NSDictionary *)requestParams  DELETE 전송할 데이터 정보
 @brief
 DELETE 형식의 리퀘스트 전송
 @note
 @warning
 */
- (void)requestDELETEURL:(NSString *)URL requestData:(NSDictionary *)requestParams
{
    self.ConfigData.HTTPMethod = @"DELETE";
    self.ConfigData.connectURL = URL;
    self.ConfigData.requestData = requestParams;
    
    requestType = REQUEST_TYPE_DELETE;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌
    
    [manager setRequest:self];
}

- (void)requestSendFileURL:(NSString *)URL filePath:(NSString *)Path 
             requestParams:(NSDictionary *)requestParams 
                      Head:(NSDictionary *)Headdata 
                      Body:(NSMutableData*)Bodydata
                
{
    self.ConfigData.requestData = requestParams;
    self.ConfigData.filePath = Path;
    self.ConfigData.HTTPMethod = @"POST";
    self.ConfigData.connectURL = URL;
    
    self.HeadData = Headdata;
    self.BodyData = Bodydata;
    
    
    requestType = REQUEST_TYPE_FILE;
    [manager setRequest:self];
}
/**
 @return 
 @param
 (NSString *)URL 전송할 통신 URL 
 (NSString*)Method 전송 방식  ex) GET, HEAD, PUT, POST, DELETE, TRACE, CONNECT
 (NSDictionary *)requestParams 전송할 데이터  (전송할 데이터가 없으면 nil)
 @brief
 사용자 정의 통신 
 @note
 @warning
 */
- (void)requestURL:(NSString *)URL method:(NSString*)Method requestData:(NSDictionary *)requestParams 
{
    self.ConfigData.HTTPMethod = Method;
    self.ConfigData.connectURL = URL;
    self.ConfigData.requestData = requestParams;
    
    requestType = REQUEST_TYPE_ETC;
    //네트워크 메니저에게 정보를 구성해서 넘겨줌 

    [manager setRequest:self];
}

#pragma mark - 반환 값 설정 -
/**
 @return 
 @param
 (id)aTarget selector : 반환값 전달 클래스
 (SEL)aSelector : 반환값 전달 함수 
 @brief
 - 반환값을 전달할 정보 저장 
 @note
 @warning
 */
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector
{
	self.target = aTarget;
	self.selector = aSelector;
}

#pragma mark - ExcuteRequest -
/**
 @return 
 @param
 @brief
 쓰레드로 실행 되어지는 Get 네트워크 작업 (데이터 구성, 전송 파싱) 
 @note
 @warning
 */
- (void)excuteGetRequest
{
	// URL Request 객체 생성
//	IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ConfigData.connectURL]
//                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                    timeoutInterval:5.0f];
    [IvRequest setURL:[NSURL URLWithString:ConfigData.connectURL]];
    [IvRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [IvRequest setTimeoutInterval:TIME_OUT_INTERVAL];
    // 통신방식 정의 (POST, GET)
	[IvRequest setHTTPMethod:ConfigData.HTTPMethod];
	
    if(ConfigData.requestData)
    {
        NSMutableString *part = [[NSMutableString alloc] init];
        id key;
        id value;
        
        [part appendString:@"?"];
        
        for(key in ConfigData.requestData)
        {
            value = [ConfigData.requestData objectForKey:key];
            
            [part appendString:[NSString stringWithFormat:@"%@=%@&", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        
        NSString * reSetURL = [NSString stringWithFormat:@"%@%@", ConfigData.connectURL,part];
        self.IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reSetURL]
                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:TIME_OUT_INTERVAL];
        [part release];
    }
    

    
    [self NetworkConnect];
}

/**
 @return 
 @param
 @brief
 쓰레드로 실행 되어지는 Post 네트워크 작업 (데이터 구성, 전송 파싱) 
 @note
 @warning
 */
- (void)excutePostRequest
{
	// URL Request 객체 생성
//	IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ConfigData.connectURL]
//                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                    timeoutInterval:5.0f];
    [IvRequest setURL:[NSURL URLWithString:ConfigData.connectURL]];
    [IvRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [IvRequest setTimeoutInterval:TIME_OUT_INTERVAL];
    // 통신방식 정의 (POST, GET)
	[IvRequest setHTTPMethod:ConfigData.HTTPMethod];
    //[IvRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(ConfigData.requestData)
    {
        NSMutableArray *parts = [NSMutableArray array];
        NSString *part;
        id key;
        id value;
        
        for(key in ConfigData.requestData)
        {
            value = [ConfigData.requestData objectForKey:key];
            part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                    [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [parts addObject:part];
        }
        
        // 값들을 &로 연결하여 Body에 사용
        [IvRequest setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self NetworkConnect];
}

/**
 @return
 @param
 @brief
 쓰레드로 실행 되어지는 Delete 네트워크 작업 (데이터 구성, 전송 파싱)
 @note
 @warning
 */
- (void)excuteDeleteRequest
{
	// URL Request 객체 생성
    //	IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ConfigData.connectURL]
    //                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                    timeoutInterval:5.0f];
    [IvRequest setURL:[NSURL URLWithString:ConfigData.connectURL]];
    [IvRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [IvRequest setTimeoutInterval:TIME_OUT_INTERVAL];
    // 통신방식 정의 (POST, GET)
	[IvRequest setHTTPMethod:ConfigData.HTTPMethod];
    //[IvRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(ConfigData.requestData)
    {
        NSMutableArray *parts = [NSMutableArray array];
        NSString *part;
        id key;
        id value;
        
        for(key in ConfigData.requestData)
        {
            value = [ConfigData.requestData objectForKey:key];
            part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                    [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [parts addObject:part];
        }
        
        // 값들을 &로 연결하여 Body에 사용
        [IvRequest setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self NetworkConnect];
}

/**
 @return 
 @param
 @brief
 사용자 구성 통신 요청일때 처리 
 @note
 @warning
 */
- (void)excuteRequestEx 
{
    [IvRequest setURL:[NSURL URLWithString:ConfigData.connectURL]];
    [IvRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [IvRequest setTimeoutInterval:TIME_OUT_INTERVAL];
    // 통신방식 정의 (POST, GET)
	[IvRequest setHTTPMethod:ConfigData.HTTPMethod];
    //[IvRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(ConfigData.requestData)
    {
        NSMutableArray *parts = [NSMutableArray array];
        NSString *part;
        id key;
        id value;
        
        for(key in ConfigData.requestData)
        {
            value = [ConfigData.requestData objectForKey:key];
            part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                    [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [parts addObject:part];
        }
        
        // 값들을 &로 연결하여 Body에 사용
        [IvRequest setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self NetworkConnect];
}

/**
 @return 
 @param
 @brief
 샘플코드에서 구성된 정보를가지고 쓰레드로 실행 되어지는 네트워크 작업 (데이터 구성, 전송 파싱) 파일 처리 
 @note
 @warning
 */
- (void)excuteFileRequest
{
    
    // URL Request 객체 생성
	self.IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ConfigData.connectURL]
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:TIME_OUT_INTERVAL];
    // 통신방식 정의 (POST, GET)
	[IvRequest setHTTPMethod:ConfigData.HTTPMethod];
    [self setSendFileHTTPHeaderFields:self.HeadData BodyFields:self.BodyData];
    
    [self NetworkConnect];
}

/**
 @return 
 @param
 @brief
 쓰레드로 실행 되어지는 네트워크 작업 (데이터 구성, 전송 파싱) 파일 처리 헤더와 바디부분 구성 포함  
 @note
 @warning
 */
- (void)excuteSampleFileRequest
{
    //파일정보 가져오기 
    NSString *uniquePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"thumb.png"];
    ConfigData.filePath = uniquePath;
    NSData *fileContent = [NSData dataWithContentsOfFile:uniquePath options:NSDataWritingAtomic error:nil];
    
    //파일이름 가져오기 
    NSArray *split = [ConfigData.filePath componentsSeparatedByString:@"/"];
    NSString *fileName = (NSString*)[split lastObject];

    //기본 네트워크 설정 
    IvRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ConfigData.connectURL]
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:TIME_OUT_INTERVAL];
    [IvRequest setHTTPMethod:ConfigData.HTTPMethod];
    
    //헤더 부분 셋팅
    NSString *boundary = @"----WebKitFormBoundarykCJByabD491BlTiw";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSString *ConnectionType = [NSString stringWithFormat:@"Keep-Alive"];
    NSDictionary *HeadParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                ConnectionType,                 @"Connection",
                                contentType,                    @"content-Type", 
                                @"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",                 @"Accept", 
                                @"file://", @"Origin",
                                @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.54.16 (KHTML, like Gecko) Version/5.1.4 Safari/534.54.16",@"User-Agent",
                                nil];
    [self setIvoryRequestAllHTTPHeaderFields:HeadParams];
    [HeadParams release];

    //바디 셋팅
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"profile_img\"; filename=\"%@\"\r\n",fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:fileContent]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"api_key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"84ac8dbff1a3838d07422cd66342c865" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [IvRequest setHTTPBody:body];
    
    [self NetworkConnect];
}

/**
 @return 
 @param
 @brief
 네트워크 동기화 연결 과 파싱 처리 
 @note
 @warning
 */
- (void)NetworkConnect{
    //head body 데이트 있을경우 설정 
    [self setHeadAndBodyData];
    if(isUseNSURLConnectionDataDelegate == true){
        NSLog(@"isUseNSURLConnectionDataDelegate");
        [self NetworkConnectAsynchronous];
        return;
    }

    NSDictionary * head = [IvRequest allHTTPHeaderFields];
    NSLog(@"%@",head);
    
    //네트워크 통신
    NSError *error = nil;
    NSHTTPURLResponse * response = nil;
    NSData * recievedSyncData = [NSURLConnection sendSynchronousRequest:IvRequest returningResponse:&response error:&error];
    [self requestResult:recievedSyncData returningResponse:response error:error];

}


- (void)requestResult:(NSData*)recievedData returningResponse:(NSHTTPURLResponse *)response error:(NSError *)error{
#ifdef DEBUG
    NSString * result = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
    NSString *mime = [response MIMEType];
    NSString *filename = [response suggestedFilename];
    NSLog(@"requset:[%@], mime:[%@], filename:[%@] \nresult : %@ \n err : %@",self.IvRequest.URL, mime, filename, result, [error description]);
    [result release];
#endif
    
    [LogFile writeLogFileReqest:[NSString stringWithFormat:@"url = %@\nself = [%@]",self.IvRequest.URL, self] result:recievedData];
    
    
    //결과 값 파싱
    id deliveryValue = nil;
    if(Parser != nil)
        deliveryValue = [Parser resultParsing:recievedData];
    else
        deliveryValue = recievedData;
    
    if(target)
    {//델리 게이트 실행
        @try {
            //NSString *className = [NSString stringWithFormat:@"class = [%@] funtion = [%@]", [[target class] description], selector];
            if(recievedData.length == 0)
            {
                if(target != nil && selector != nil){
                    if(isReturnValue == TRUE){
                        [target performSelector:selector withObject:error withObject:returnValue];
                        
                    }else if(isReturnResponse == TRUE){
                        [target performSelector:selector withObject:error withObject:response];
                    }else{
                        [target performSelector:selector withObject:error];
                    }
                }
            }
            else
            {
                if(target != nil && selector != nil){
                    
                    if(isReturnValue == TRUE){
                        [target performSelector:selector withObject:deliveryValue withObject:returnValue];
                        
                    }else if(isReturnResponse == TRUE){
                        [target performSelector:selector withObject:deliveryValue withObject:response];
                    }else{
                        [target performSelector:selector withObject:deliveryValue];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"target is dealloc exception" );
            
            NSString *className = [NSString stringWithFormat:@"IvoryRequest Err class = [%@] funtion = [%@]", [[target class] description], NSStringFromSelector(selector)];
            NSLog(@"className = [%@] exception = [%@]",  className, exception.description);
        }
    }
}


#pragma mark - Asynchronous
- (void)NetworkConnectAsynchronous{

    //NSURLConnection 의 델리게이트는 아이보리를 만든곳에서 생성하여 결과값을 받는다.(NSURLConnectionDataDelegate)
    //헤더파일에 델리게이트 지정해줘야함
    dispatch_async(dispatch_get_main_queue(), ^{
        saveCancelConnection =  [[NSURLConnection alloc] initWithRequest:IvRequest delegate:target];
        [saveCancelConnection start];
    });
}

-(void)reqestDownloadCancel{
    
    if([NSURLConnection canHandleRequest:IvRequest]){
        NSLog(@"reqestDownloadCancel 전송 취소");
        [saveCancelConnection cancel];
    }
    
}

#pragma mark - NSMutableURLRequest header setting  내부 함수 -
/**
 @return 
 @param
 @brief
 - 리퀘스트 정보를 설정할때 구성한 헤더와 바디 값을 셋팅한다 
 @note
 @warning
 - 리퀘스트객체가 생성이되기 전에 설정 설정하면 오류가 날수 있음
 */
- (void)setSendFileHTTPHeaderFields:(NSDictionary*)headField BodyFields:(NSData*)bodyField
{    //FILE 전송을위한 변수 
    NSAssert(self.IvRequest, @"setSendFileHTTPHeaderFields IvRequest is NULL");
    [self.IvRequest setAllHTTPHeaderFields:headField];
    [self.IvRequest setHTTPBody:bodyField];
    
#ifdef DEBUG	
    NSDictionary * headdata = [self.IvRequest allHTTPHeaderFields];
    NSLog(@"%@", headdata);
#endif
}

/**
 @return 
 @param
 @brief
 - head와 bady 데이터가 셋팅되어 있으면 설정한다. nil경우 무시 
 @note
 @warning
 */
- (void)setHeadAndBodyData 
{    //FILE 전송을위한 변수 
    NSAssert(self.IvRequest, @"setSendFileHTTPHeaderFields IvRequest is NULL");

    if(self.HeadData != nil)
        [self.IvRequest setAllHTTPHeaderFields:self.HeadData];
    
    if(self.BodyData != nil)
        [self.IvRequest setHTTPBody:self.BodyData];
    
    
#ifdef DEBUG	
//    NSDictionary * headdata = [self.IvRequest allHTTPHeaderFields];
//    NSLog(@"%@", headdata);
#endif
}


/**
 @return 
 @param
 (NSDictionary *)headerFields : 저장할 헤더값 
 @brief
 모든 헤더값을 저장한다. 
 @note
 @warning
 */
- (void)setIvoryRequestAllHTTPHeaderFields:(NSDictionary *)headerFields
{
    [self.IvRequest setAllHTTPHeaderFields:headerFields];
}

/**
 @return 
 @param
 (NSString *)value : 헤더에 설정할 값 
 (NSString *)field : 헤더에 설정할 키값 
 @brief
 해당 키에 헤더 설정 
 @note
 @warning
 */
- (void)setIvoryRequestValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [self.IvRequest setValue:value forHTTPHeaderField:field];    
}

/**
 @return 
 @param
 (NSString *)value : 헤더에 설정할 값 
 (NSString *)field : 헤더에 설정할 키값 
 @brief
 해당 키에 헤더 설정 추가  
 @note
 @warning
 */
- (void)setIvoryRequestAddValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [self.IvRequest addValue:value forHTTPHeaderField:field];
}



@end















