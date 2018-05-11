//
//  GlobalData.m
//  TeamOffice
//
//  Created by Junho Jo on 11. 11. 24..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import "GlobalData.h"


@implementation GlobalData
@synthesize fcmToken;
@synthesize notiUrl;
static GlobalData *_globalData = nil;
- (id) init{
    self = [super init];
    //if (self) {
    if ((self = [super init]) != nil) {
    }
    return self;
}


#pragma mark -
#pragma mark 싱글톤 메소드 
#pragma mark 
+ (GlobalData *)sharedData
{
    static GlobalData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GlobalData alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone 
{
	@synchronized([GlobalData class])
	{
		NSAssert(_globalData == nil, @"Attempted to allocate a second instance of a singleton.");
		_globalData = [super allocWithZone:zone];
		return _globalData;
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


@end
