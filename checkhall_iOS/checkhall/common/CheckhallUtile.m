
#import <UIKit/UIKit.h>
#import "JHUtile.h"
#import "CheckhallUtile.h"


@implementation CheckhallUtile
+ (NSString*)getIdxString:(NSString*)html{
    NSString *idx = @"";
    
    NSRange range = [html rangeOfString:@"{\"idx\":"];
    if(range.location != NSNotFound){
        NSRange findRange = NSMakeRange(range.length+range.location+1, 32);
        idx = [html substringWithRange:findRange];
    }
    return idx;
}

@end
















