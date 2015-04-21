//
//  ImageCaptureViewController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#include <Accelerate/Accelerate.h>




@class VideoCameraController;

@protocol VideoCameraControllerDelegate <NSObject>

// whether or not to use a AVCaptureVideoPreviewLayer to show the camera video
- (BOOL)allowPreviewLayer;

// if allowPreviewLayer is set, provide a parent view for the camera's AVCaptureVideoPreviewLayer
- (UIView*)getPreviewView;

// delegate method for processing images
// note, the vImage_Buffer encapsulates a pointer to grayscale pixel data and height, width and bytesPerRow
// note, a CGContextRef is passed that can be used for rendering purposes
- (void)processImage:(const vImage_Buffer)image withRenderContext:(CGContextRef)contextOverlay;

// delegate completion method, used to deliver a (processed) image on the main thread
- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)image;

// currently unused
- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController;

@end



@interface VideoCameraController : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
	
	AVCaptureSession* captureSession;
	AVCaptureStillImageOutput *stillImageOutput;
	
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureVideoDataOutput *videoDataOutput;
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
	CALayer *customPreviewLayer;
	AVCaptureConnection* videoCaptureConnection;
	UIDeviceOrientation currentDeviceOrientation;
	
	BOOL running;
	BOOL canTakePicture;
	BOOL captureSessionLoaded;
	
	BOOL photoCameraMode;
	
	
	AVCaptureDevicePosition defaultAVCaptureDevicePosition;
	AVCaptureVideoOrientation defaultAVCaptureVideoOrientation;
	NSString *const defaultAVCaptureSessionPreset;
	
	
	int defaultFPS;
}


@property (nonatomic, assign) id<VideoCameraControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) BOOL canTakePicture;
@property (nonatomic, readonly) BOOL captureSessionLoaded;

@property (nonatomic, assign) int defaultFPS;
@property (nonatomic, assign) AVCaptureDevicePosition defaultAVCaptureDevicePosition;
@property (nonatomic, assign) AVCaptureVideoOrientation defaultAVCaptureVideoOrientation;
@property (nonatomic, strong) NSString *const defaultAVCaptureSessionPreset;
@property (nonatomic, assign) BOOL photoCameraMode;


- (void)start;
- (void)stop;
- (void)switchCameras;


- (void)takePicture;
- (void)enableCameraControls:(BOOL)enabled;


@end
