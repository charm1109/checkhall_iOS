//
//  ParserObject.m
//  IvoryProject
//
//  Created by Junho Jo on 12. 3. 27..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "ParserObject.h"

@implementation ParserObject
/**
 @return 
 (id) : 파싱된 데이터 
 @param
 (NSData *)withData : 파싱할 데이터 
 @brief
 - resultParsing 함수를 오버라이드 하여 직접 파싱 함수를 구현한다. 
 @note
 @warning
 */
- (id)resultParsing:(NSData *)withData;
{
    //재정의 사용
    NSLog(@"//재정의 사용");
    return withData;
}

@end
