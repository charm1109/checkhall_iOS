
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIImage (UIImageSizeExtention)

- (UIImage *)fixImageSize;
- (UIImage *)fitToSize:(CGSize)newSize;
- (UIImage *)scaleToSize:(CGSize)newSize;
- (UIImage *)scaleProportionlyToWidth:(CGFloat)width;
- (UIImage *)scaleProportionlyToHeight:(CGFloat)height;
- (UIImage *)cropToRect:(CGRect)newRect;

@end
