#import <Foundation/Foundation.h>
#import "GPUImageOpenGLESContext1.h"

struct GPUByteColorVector1 {
    GLubyte red;
    GLubyte green;
    GLubyte blue;
    GLubyte alpha;
};
typedef struct GPUByteColorVector1 GPUByteColorVector1;

@protocol GPUImageRawDataProcessor;

@interface GPUImageRawData1 : NSObject <GPUImageInput1>

@property(readwrite, unsafe_unretained, nonatomic) id<GPUImageRawDataProcessor> delegate;
@property(readonly) GLubyte *rawBytesForImage;

// Initialization and teardown
- (id)initWithImageSize:(CGSize)newImageSize;

// Data access
- (GPUByteColorVector1)colorAtLocation:(CGPoint)locationInImage;

@end

@protocol GPUImageRawDataProcessor
- (void)newImageFrameAvailableFromDataSource:(GPUImageRawData1 *)rawDataSource;
@end