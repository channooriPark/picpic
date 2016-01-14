//
//  IFVideoCamera.h
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "GPUImage1.h"

@class IFVideoCamera;

@protocol IFVideoCameraDelegate <NSObject>

- (void)IFVideoCameraWillStartCaptureStillImage:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishCaptureStillImage:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidSaveStillImage:(IFVideoCamera *)videoCamera;
- (BOOL)canIFVideoCameraStartRecordingMovie:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraWillStartProcessingMovie:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishProcessingMovie:(IFVideoCamera *)videoCamera;
@end

@interface IFVideoCamera : GPUImageVideoCamera1

@property (strong, readonly) GPUImageView1 *gpuImageView;
@property (strong, readonly) GPUImageView1 *gpuImageView_HD;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, unsafe_unretained, readonly) BOOL isRecordingMovie;

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highVideoQuality:(BOOL)isHighQuality;
- (void)switchFilter:(IFFilterType)type;
- (void)cancelAlbumPhotoAndGoBackToNormal;
- (void)takePhoto;
- (void)startRecordingMovie;
- (void)stopRecordingMovie;
- (void)saveCurrentStillImage;

@end
