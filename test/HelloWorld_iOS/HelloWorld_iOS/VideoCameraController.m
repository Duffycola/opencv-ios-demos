//
//  ImageCaptureViewController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 1/06/12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

#import "VideoCameraController.h"
#include <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>



#pragma mark - Private Interface

@interface VideoCameraController ()

@property (nonatomic, retain) CALayer *customPreviewLayer;
@property (nonatomic, retain) AVCaptureSession* captureSession;
@property (nonatomic, retain) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, retain) AVCaptureVideoDataOutput* videoDataOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* captureVideoPreviewLayer;
@property (nonatomic, retain) AVCaptureConnection* videoCaptureConnection;

- (void)enableCameraControls:(BOOL)enabled;
- (void)deviceOrientationDidChange:(NSNotification*)notification;
- (void)startCaptureSession;
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)setDesiredCameraPosition:(AVCaptureDevicePosition)desiredPosition;



@end



#pragma mark - Implementation



@implementation VideoCameraController



#pragma mark - Properties

#pragma mark Public

@synthesize running;
@synthesize canTakePicture;
@synthesize captureSessionLoaded;

@synthesize defaultFPS;
@synthesize defaultAVCaptureDevicePosition;
@synthesize defaultAVCaptureVideoOrientation;
@synthesize defaultAVCaptureSessionPreset;
@synthesize photoCameraMode;


#pragma mark Private

@synthesize captureSession;
@synthesize stillImageOutput;
@synthesize videoDataOutput;
@synthesize captureVideoPreviewLayer;
@synthesize videoCaptureConnection;
@synthesize delegate;
@synthesize customPreviewLayer;


#pragma mark - Constructors



- (id)init;
{
	self = [super init];
	if (self) {
		// react to device orientation notifications
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationDidChange:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		currentDeviceOrientation = [[UIDevice currentDevice] orientation];
		
		
		// check if camera available
		canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
		NSLog(@"camera available: %@", (canTakePicture == YES ? @"YES" : @"NO") );
		
		
		running = NO;
		
		
		// set camera default configuration
		self.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
		self.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		self.defaultFPS = 15;
		self.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
		
		self.photoCameraMode = NO;
		
	}
	return self;
}



- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


#pragma mark - Public interface


- (void)start;
{
	if (running == YES) {
		return;
	}
	running = YES;
	
	if (canTakePicture) {
		[self performSelectorOnMainThread:@selector(startCaptureSession) withObject:nil waitUntilDone:NO];
	}
}


- (void)stop;
{
	running = NO;
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self.captureSession stopRunning];
	self.captureSession = nil;
	self.stillImageOutput = nil;
	self.captureVideoPreviewLayer = nil;
	self.videoCaptureConnection = nil;
	captureSessionLoaded = NO;
	
	self.videoDataOutput = nil;
	if (videoDataOutputQueue)
		dispatch_release(videoDataOutputQueue);
	
	self.customPreviewLayer = nil;
	
	if (self.delegate) {
		[self.delegate videoCameraViewControllerDone:self ];
	}
}



// use front/back camera
- (void)switchCameras;
{
	BOOL was_running = self.running;
	if (was_running) {
		[self stop];
	}
	if (self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
		self.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	} else {
		self.defaultAVCaptureDevicePosition  = AVCaptureDevicePositionFront;
	}
	if (was_running) {
		[self start];
	}
}




- (void)enableCameraControls:(BOOL)enabled
{
	canTakePicture = enabled;
}



- (void)takePicture
{
	if (canTakePicture == NO || !self.photoCameraMode) {
		return;
	}
	
	[self enableCameraControls:NO];
	
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.videoCaptureConnection
													   completionHandler:
	 ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
	 {
		 if (error == nil && imageSampleBuffer != NULL)
		 {
			 // TODO check
			 //			 NSNumber* imageOrientation = [UIImage cgImageOrientationForUIDeviceOrientation:currentDeviceOrientation];
			 //			 CMSetAttachment(imageSampleBuffer, kCGImagePropertyOrientation, imageOrientation, 1);
			 
			 NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
			 
			 dispatch_async(dispatch_get_main_queue(), ^{
				 [self.captureSession stopRunning];
				 
				 // Make sure we create objects on the main thread in the main context
				 UIImage* newImage = [UIImage imageWithData:jpegData];
				 
				 //UIImageOrientation orientation = [newImage imageOrientation];
				 
				 // TODO: only apply rotation, don't scale, since we can set this directly in the camera
				 /*
				 switch (orientation) {
					 case UIImageOrientationUp:
					 case UIImageOrientationDown:
						 newImage = [newImage imageWithAppliedRotationAndMaxSize:CGSizeMake(640.0, 480.0)];
						 break;
					 case UIImageOrientationLeft:
					 case UIImageOrientationRight:
						 newImage = [newImage imageWithMaxSize:CGSizeMake(640.0, 480.0)];
					 default:
						 break;
				 }
				 */
				 
				 // We have captured the image, we can allow the user to take another picture
				 [self enableCameraControls:YES];
				 
				 NSLog(@"capture");
				 if (self.delegate) {
					 [self.delegate videoCameraViewController:self capturedImage:newImage];
				 }
				 
				 [self.captureSession startRunning];
			 });
		 }
	 }];
}


#pragma mark - Device Orientation Changes


- (void)deviceOrientationDidChange:(NSNotification*)notification
{
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;

	switch (orientation)
	{
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			currentDeviceOrientation = orientation;
			break;
		
			// unsupported?
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
			break;
	}
}

#pragma mark - Private Interface

- (void)createCaptureSession;
{
	// set a av capture session preset
	self.captureSession = [[AVCaptureSession alloc] init];
	if ([self.captureSession canSetSessionPreset:self.defaultAVCaptureSessionPreset]) {
		[self.captureSession setSessionPreset:self.defaultAVCaptureSessionPreset];
	} else if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
		[self.captureSession setSessionPreset:AVCaptureSessionPresetLow];
	} else {
		NSLog(@"[Camera] Error: could not set session preset");
	}
}

- (void)createCaptureDevice;
{
	// setup the device
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[self setDesiredCameraPosition:self.defaultAVCaptureDevicePosition];
	NSLog(@"[Camera] device connected? %@", device.connected ? @"YES" : @"NO");
	NSLog(@"[Camera] device position %@", (device.position == AVCaptureDevicePositionBack) ? @"back" : @"front");
}

- (void)createStillImageOutput;
{
	// setup still image output with jpeg codec
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[self.stillImageOutput setOutputSettings:outputSettings];
	[self.captureSession addOutput:self.stillImageOutput];
	
	for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([port.mediaType isEqual:AVMediaTypeVideo]) {
				self.videoCaptureConnection = connection;
				break;
			}
		}
		if (self.videoCaptureConnection) {
			break;
		}
	}
	NSLog(@"[Camera] still image output created");
}

- (void)createVideoDataOutput;
{
	// Make a video data output
	self.videoDataOutput = [AVCaptureVideoDataOutput new];
	
	// we want YUV (YpCbCr 4:2:0) so we can directly access the graylevel intensity values (Y component)
	self.videoDataOutput.videoSettings =
	  [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
								  forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
	[self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
	
	if ( [self.captureSession canAddOutput:self.videoDataOutput] ) {
		[self.captureSession addOutput:self.videoDataOutput];
	}
	[[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
	
	
	// set default FPS
	if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMinFrameDuration) {
		[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMinFrameDuration = CMTimeMake(1, self.defaultFPS);
	}
	if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMaxFrameDuration) {
		[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMaxFrameDuration = CMTimeMake(1, self.defaultFPS);
	}
	
	// set video mirroring for front camera (more intuitive)
	if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMirroring) {
		if (self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
			[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = YES;
		} else {
			[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = NO;
		}
	}
	
	// set default video orientation
	if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoOrientation) {
		[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = self.defaultAVCaptureVideoOrientation;
	}
	
	
	// create a custom preview layer
	self.customPreviewLayer = [CALayer layer];
	if (self.delegate) {
		UIView* parentView = [self.delegate getPreviewView];
		
		
		float rotationAngle = 0.0;
		CGRect bounds = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
		
		if (self.defaultAVCaptureVideoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
			rotationAngle = M_PI/2.;
			bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
		} else if (self.defaultAVCaptureVideoOrientation == AVCaptureVideoOrientationLandscapeRight) {
			rotationAngle = 3.*M_PI/2.;
			bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
		} else if (self.defaultAVCaptureVideoOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
			rotationAngle = M_PI;
		}
		
		self.customPreviewLayer.bounds = bounds;
		self.customPreviewLayer.position = CGPointMake(parentView.frame.size.width/2., parentView.frame.size.height/2.);
		self.customPreviewLayer.affineTransform = CGAffineTransformMakeRotation(rotationAngle);
		
		[parentView.layer addSublayer:self.customPreviewLayer];
	} else {
		self.customPreviewLayer.bounds = CGRectMake(0, 0, 0, 0);
		self.customPreviewLayer.position = CGPointMake(0, 0);
	}
	
	
	// create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
	// a serial dispatch queue must be used to guarantee that video frames will be delivered in order
	// see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[self.videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
	
	NSLog(@"[Camera] created AVCaptureVideoDataOutput at %d FPS", self.defaultFPS);
}


- (void)createVideoPreviewLayer;
{
	self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	UIView* previewView = [self.delegate getPreviewView];
	if (previewView != nil) {
		self.captureVideoPreviewLayer.frame = previewView.bounds;
		self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		[previewView.layer addSublayer:self.captureVideoPreviewLayer];
	}
	NSLog(@"[Camera] created AVCaptureVideoPreviewLayer");
}




- (void)setDesiredCameraPosition:(AVCaptureDevicePosition)desiredPosition;
{
	for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([device position] == desiredPosition) {
			[self.captureSession beginConfiguration];
			
			NSError* error;
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
			if (!input) {
				NSLog(@"error creating input %@", [error localizedDescription]);
			}
			
			// support for autofocus
			if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
				NSError *error = nil;
				if ([device lockForConfiguration:&error]) {
					device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
					[device unlockForConfiguration];
				} else {
					NSLog(@"unable to lock device for autofocos configuration %@", [error localizedDescription]);
				}
			}
			[self.captureSession addInput:input];
			
			for (AVCaptureInput *oldInput in self.captureSession.inputs) {
				[self.captureSession removeInput:oldInput];
			}
			[self.captureSession addInput:input];
			[self.captureSession commitConfiguration];
			break;
		}
	}
}



- (void)startCaptureSession
{
	if (!canTakePicture) {
		return;
	}
		
	if (captureSessionLoaded == NO) {
		[self createCaptureSession];
		[self createCaptureDevice];
		
		if (photoCameraMode) {
			[self createStillImageOutput];
		} else {
			// setup video output
			[self createVideoDataOutput];
		}
		
		// setup preview layer
		if (!delegate || [delegate allowPreviewLayer]) {
			[self createVideoPreviewLayer];
		}
		
		captureSessionLoaded = YES;
	}
	
	[self.captureSession startRunning];
}


#pragma mark - Protocol AVCaptureVideoDataOutputSampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	if (self.delegate) {
		// convert from Core Media to Core Video
		CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
		
		CVPixelBufferLockBaseAddress(imageBuffer, 0);
		size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
		size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
		size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
		
		// extract intensity channel directly
		Pixel_8 *lumaBuffer = (Pixel_8*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
		
		// render the luma buffer on the layer with CoreGraphics
		// (create color space, create graphics context, render buffer)
		CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
		CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
		
		// delegate image processing to the delegate
		const vImage_Buffer image = {lumaBuffer, height, width, bytesPerRow};
		[self.delegate processImage:image withRenderContext:context];
		
		CGImageRef dstImage = CGBitmapContextCreateImage(context);
		
		// render buffer
		dispatch_sync(dispatch_get_main_queue(), ^{
			self.customPreviewLayer.contents = (__bridge id)dstImage;
		});
		
		
		// cleanup
		CGImageRelease(dstImage);
		CGContextRelease(context);
		CGColorSpaceRelease(grayColorSpace);
		
		CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
		
		
		
		CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	}
}


// Create a UIImage from sample buffer data
// TODO fix orientation
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
	
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
												 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
	
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
	
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
	
    // Release the Quartz image
    CGImageRelease(quartzImage);
	
    return (image);
}



// TODO not working
- (UIImage*)imageFromSampleBuffer2:(CMSampleBufferRef) sampleBuffer;
{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
	 The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
	 by the TIFF and EXIF specifications -- see enumeration of integer constants. 
	 The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
	 
	 used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
	 If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
	
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	};
	
	switch (currentDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
	
	return [UIImage imageWithCIImage:ciImage];
}



@end
