//
//  NSDictionary-MutableDeepCopy.m
//  TableView_Customizing_3
//
//  Created by WooKyun Jeon on 11. 3. 11..
//  Copyright 2011 DAOU Tech. All rights reserved.
//

#import "NSDictionary-MutableDeepCopy.h"


@implementation NSDictionary (MutableDeepCopy)
- (NSMutableDictionary *)mutableDeepCopy {
    // 20111108 MEMORY 관련 수정 autorelease 추가
	NSMutableDictionary *ret = [[NSMutableDictionary alloc]initWithCapacity:[self count]];
	NSArray *keys = [self allKeys];
	for(id key in keys) {
		id oneValue = [self valueForKey:key];
		id oneCopy = nil;
		
		if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
			oneCopy = [oneValue mutableDeepCopy];
		} else if ([oneValue respondsToSelector:@selector(mutableCopy)]) {
			oneCopy = [oneValue mutableCopy];
		}
		
		if (oneCopy == nil) {
			oneCopy = [oneValue copy];
		}
		
		[ret setValue:oneCopy forKey:key];
	}
	return ret;
}
@end
