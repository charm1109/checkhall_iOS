//
//  IvoryRequest.h
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

/** @file IvoryRequest.h
 *   @name               : 리퀘스트 
 *   @brief              : 리퀘스트 셋팅 
 *   @author             : 조준호 
 *   @warning            : 
 *   @version            : 1.0.0
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ConfigNetworkData.h"
#import "ConnectManager.h"
#import "ParserObject.h"
#import "Reachability.h"
#import "JSONKit.h"
enum
{
	REQUEST_TYPE_GET,
    REQUEST_TYPE_POST,
    REQUEST_TYPE_FILE,
    REQUEST_TYPE_SAMPLE_FILE,
    REQUEST_TYPE_DELETE,
    REQUEST_TYPE_ETC
};


#define TIME_OUT_INTERVAL           30.0

@class ConnectManager;

@interface IvoryRequest : NSOperation<NSURLConnectionDataDelegate>
{
    ConfigNetworkData   * ConfigData;       //네트워크 데이터 
    ParserObject        * Parser;           //파서 클래스 (템플릿)
    NSURLConnection     *saveCancelConnection;
    NSMutableURLRequest * IvRequest;        //네트워크 설정 구성 
    NSMutableData       * receivedData;     //통신 결과 데이터(비동기식 일때만 사용)    
    NSInteger           requestType;        //통신 형태 설정 
	id target;                              //통신 결과 반환 클래스
	SEL selector;                           //통신 결과 반환 함수
    
    //FILE 전송을위한 변수 
    NSDictionary        *HeadData;          //파일 전송 헤더 값 
    NSMutableData       *BodyData;          //파일 전송 바디 값
    
    ConnectManager      *manager;
    
    
    CGFloat fileSize;
    CGFloat fileProgress;
    CGFloat fileProgressSave;
}

@property (nonatomic, retain) ConfigNetworkData     * ConfigData;
@property (nonatomic, retain) ParserObject          * Parser;
@property (nonatomic, retain) NSMutableURLRequest   * IvRequest;
@property (nonatomic, retain) NSMutableData         * receivedData;
@property ( assign) id target;
@property ( assign) SEL selector;

@property (nonatomic, retain) NSDictionary          * HeadData;
@property (nonatomic, retain) NSMutableData         * BodyData;
@property (nonatomic, assign) BOOL                  isReturnValue;
@property (nonatomic, assign) BOOL                  isReturnResponse;
@property (nonatomic, assign) id                    returnValue;
@property (nonatomic, assign) BOOL                  isUseNSURLConnectionDataDelegate;

- (void)requestURL;
- (void)requestGETURL;
- (void)requestPOSTURL;
- (void)requestSendFileURL;
- (void)requestSendSampleFileURL;
- (void)requestGETURL:(NSString *)URL ;
- (void)requestPOSTURL:(NSString *)URL requestData:(NSDictionary *)requestParams ;
- (void)requestDELETEURL:(NSString *)URL requestData:(NSDictionary *)requestParams;
- (void)requestSendFileURL:(NSString *)URL filePath:(NSString *)Path 
             requestParams:(NSDictionary *)requestParams 
                      Head:(NSDictionary *)Headdata 
                      Body:(NSMutableData*)Bodydata;
- (void)requestURL:(NSString *)URL method:(NSString*)Method requestData:(NSDictionary *)requestParams;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector;
- (void)setSendFileHTTPHeaderFields:(NSDictionary*)headField BodyFields:(NSData*)bodyField;
- (void)setHeadAndBodyData;
- (void)setIvoryRequestAllHTTPHeaderFields:(NSDictionary *)headerFields;
- (void)setIvoryRequestValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)setIvoryRequestAddValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)excuteGetRequest;
- (void)excutePostRequest;
- (void)excuteDeleteRequest;
- (void)excuteRequestEx;
- (void)excuteFileRequest;
- (void)excuteSampleFileRequest;
- (void)NetworkConnect;
- (void)reqestDownloadCancel;
+ (NSString*)getMACAddress;
+ (NSInteger)getNetworkStatus;
+ (NSInteger)getHostNetworkCheck:(NSString *)hostName;
+ (NSString *)getIPAddress;
+ (NSString *)getAPAddress;
+ (NSString *)getWifiName;
+ (NSString *)getWifiMacAddress;
+ (NSString *)getRouterAddress;
+ (NSString *)getSubnetMask;
@end
