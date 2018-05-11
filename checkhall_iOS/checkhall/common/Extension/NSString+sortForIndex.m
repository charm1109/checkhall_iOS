
#import <UIKit/UIKit.h>
#import "NSString+sortForIndex.h"

@implementation NSString (sortForIndex)

- (NSComparisonResult)sortForIndex:(NSString *)comp
{
    NSString *left = [NSString stringWithFormat:@"%@%@", 
                            [self localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                            !([self localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                            @"1", self];
    NSString *right = [NSString stringWithFormat:@"%@%@", 
                            [comp localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                            !([comp localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                            @"1", comp];
    
    return [left localizedCaseInsensitiveCompare:right];
}

@end
