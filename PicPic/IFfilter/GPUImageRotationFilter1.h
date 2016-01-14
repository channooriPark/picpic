#import "GPUImageFilter1.h"

typedef enum { kGPUImageRotateLeft1, kGPUImageRotateRight1, kGPUImageFlipVertical1, kGPUImageFlipHorizonal1} GPUImageRotationMode1;

@interface GPUImageRotationFilter1 : GPUImageFilter1
{
    GPUImageRotationMode1 rotationMode;
}

// Initialization and teardown
- (id)initWithRotation:(GPUImageRotationMode1)newRotationMode;

@end
