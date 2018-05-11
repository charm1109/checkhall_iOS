//
//  ConfigNetworkData.h
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

/** @file ConfigNetworkData.h
 *   @name               : 통신 데이터 구성  
 *   @brief              : 리퀘스트에 필요한 정보 구성 
 *   @author             : 조준호 
 *   @warning            : 
 *   @version            : 1.0.0
 */

#import <Foundation/Foundation.h>

@interface ConfigNetworkData : NSObject
{
    NSString * connectURL;      //통신 주소 ex)www.naver.com
    NSString * HTTPMethod;      //GET, HEAD, PUT, POST, DELETE, TRACE, CONNECT
    NSString * requestID;       //통신에대한 고유 ID
    NSString * filePath;        //파일 전송시 필요
    NSDictionary * requestData;  //전송 데이터 
}

@property (nonatomic, retain) NSString * connectURL;
@property (nonatomic, retain) NSString * HTTPMethod;
@property (nonatomic, retain) NSString * requestID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSDictionary * requestData;

@end
