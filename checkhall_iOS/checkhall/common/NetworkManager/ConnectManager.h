//
//  ConnectManager.h
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

/** @file ConnectManager.h
 *   @name               : 네트워크 메니져 (네트워크에대한 큐관리 => 싱글톤)
 *   @brief              : 리퀘스트를 받아 큐에 데이터 전달 
 *   @author             : 조준호 
 *   @warning            : 
 *   @version            : 1.0.0
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IvoryRequest.h"
#import "RequestWorkQueue.h"
@class IvoryRequest;
@interface ConnectManager : NSObject
{
    RequestWorkQueue    * Work; //네트워크 Queue 처리
}

@property (nonatomic,retain) RequestWorkQueue    *Work;

+ (ConnectManager *)sharedObject;
+ (void)releaseSharedObject;
- (void)setRequest:(IvoryRequest *)RequestItem;
- (void)addRequest:(IvoryRequest *)RequestItem;
@end
