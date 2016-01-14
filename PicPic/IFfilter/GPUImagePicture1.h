#import <UIKit/UIKit.h>
#import "GPUImageOutput1.h"


@interface GPUImagePicture1 : GPUImageOutput1
{
    UIImage *imageSource;
}

// Initialization and teardown
- (id)initWithImage:(UIImage *)newImageSource;
- (id)initWithImage:(UIImage *)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput;

// Image rendering
- (void)processImage;

@end
