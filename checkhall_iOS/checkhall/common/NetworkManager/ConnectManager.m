//
//  ConnectManager.m
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 22..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "ConnectManager.h"

@implementation ConnectManager

@synthesize Work;

static ConnectManager *__sharedObject = nil;

- (id)init
{
    self = [super init];
    if (self) {
        
        RequestWorkQueue *tempwork = [[RequestWorkQueue alloc] init];
        self.Work = tempwork;
        [tempwork release];

    }
    
    return self;
}

- (void) dealloc {
    NSLog(@"ConnectManager - dealloc!!!");
    [Work release];
    Work = nil;
    
    [super dealloc];
}

+ (ConnectManager *)sharedObject
{
    @synchronized([ConnectManager class])
	{
		if(__sharedObject == nil)
		{
			__sharedObject = [[ConnectManager alloc] init];
		}
	}
    
    return __sharedObject;
}

+ (void)releaseSharedObject {
    [__sharedObject release];
    __sharedObject = nil;
}

/**
 @return 
 @param
 (IvoryRequest *)RequestItem 작업 오퍼레이션 (리퀘스트에대한 정보가 모두 저장되어 있음)
 @brief
 작업 큐에다가 리퀘스트 정보 전송 
 @note
 @warning
 */
- (void)setRequest:(IvoryRequest *)RequestItem
{
//    return;//클래스에서 큐 생성후 사용하는 방법으로 변경
    if(RequestItem != nil)
        [Work addOperation:RequestItem];
}

- (void)addRequest:(IvoryRequest *)RequestItem{
    if(RequestItem != nil)
        [Work addOperation:RequestItem];
}

@end
