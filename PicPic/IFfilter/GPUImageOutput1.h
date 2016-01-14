#import "GPUImageOpenGLESContext1.h"
#import "GLProgram1.h"

@interface GPUImageOutput1 : NSObject
{
    NSMutableArray *targets, *targetTextureIndices;
    
    GLuint outputTexture;
    CGSize inputTextureSize, cachedMaximumOutputSize;
}

@property(readwrite, nonatomic) BOOL shouldSmoothlyScaleOutput;

// Managing targets
- (void)addTarget:(id<GPUImageInput1>)newTarget;
- (void)removeTarget:(id<GPUImageInput1>)targetToRemove;
- (void)removeAllTargets;

// Manage the output texture
- (void)initializeOutputTexture;
- (void)deleteOutputTexture;

@end
