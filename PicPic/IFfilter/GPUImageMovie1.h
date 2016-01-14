#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "GPUImageOpenGLESContext1.h"
#import "GPUImageOutput1.h"

@interface GPUImageMovie1 : GPUImageOutput1 {
  CVPixelBufferRef _currentBuffer;
}

@property (readwrite, retain) NSURL *url;

-(id)initWithURL:(NSURL *)url;
-(void)startProcessing;
-(void)endProcessing;

@end
