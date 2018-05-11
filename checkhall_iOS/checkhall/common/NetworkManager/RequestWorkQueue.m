//
//  RequestWorkQueue.m
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 23..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "RequestWorkQueue.h"

@implementation RequestWorkQueue

- (id)init
{
    self = [super init];
    if (self) {
        //Queue에 대한 설정 
        [self setMaxConcurrentOperationCount:5]; //최대 동작 쓰레드 설정 

    }
    
    return self;
}

@end
