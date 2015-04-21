//
//  ViewControllerFaceDetectVideo.m
//  FaceDetectVideo
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerFaceDetectVideo.h"
#import "UIImage+Resize.h"
#import "UIImageCVMatConverter.h"

@interface ViewControllerFaceDetectVideo ()

@end


@implementation ViewControllerFaceDetectVideo


@synthesize cvFaceDetector;
@synthesize imagePicker;
@synthesize videoCamera;
@synthesize imageView;
@synthesize labelFPS;


#pragma mark - UIViewController lifecycle

- (void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
	if (enableProcessing) {
		[self.videoCamera start];
	} else {
		[self.videoCamera stop];
	}
}

- (void)viewWillDisappear:(BOOL)animated;
{
	[super viewWillDisappear:animated];
	
	[self.videoCamera stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"FaceDetectVideo";
	
	self.cvFaceDetector = [[CvFaceDetector alloc] init];
	
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	self.videoCamera.defaultFPS = 15;
	self.videoCamera.grayscaleMode = YES;
	
	enableProcessing = NO;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	} else {
	    return NO;
	}
}


#pragma mark - UI Interface




- (IBAction)changeFPS:(id)sender;
{
	NSLog(@"IBAction changeFPS");
	
	BOOL started = self.videoCamera.running;
	
	UISlider* slider = (UISlider*)sender;
	if (started) {
		[self.videoCamera stop];
	}
	self.videoCamera.defaultFPS = (int)slider.value;
	if (started) {
		[self.videoCamera start];
	}
	self.labelFPS.text = [NSString stringWithFormat:@"%d", self.videoCamera.defaultFPS];
}


- (IBAction)switchProcessingOnOff:(id)sender;
{
	enableProcessing = !enableProcessing;
	if (enableProcessing) {
		[self.videoCamera start];
	} else {
		[self.videoCamera stop];
	}
}



- (IBAction)switchCamera:(id)sender;
{
	[self.videoCamera switchCameras];
}


- (IBAction)showCameraImage:(id)sender;
{
	NSLog(@"show camera image");
	
	self.imagePicker = [[ImagePickerController alloc] initAsCamera];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}

- (IBAction)showPhotoLibrary:(id)sender;
{
	NSLog(@"show photo library");
	
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}


- (IBAction)showVideoCamera:(id)sender;
{
	NSLog(@"show video camera");
	
	UIBarButtonItem* button = (UIBarButtonItem*)sender;
	
	if (self.videoCamera.running) {
		[self.videoCamera stop];
		[button setTitle:@"Start Cam"];
	} else {
		[self.videoCamera start];
		[button setTitle:@"Stop Cam"];
	}
}



#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
	if (enableProcessing) {
		NSLog(@"Detecting faces...");
		[cvFaceDetector detectFacesInMat:&image];
		NSLog(@"done.");
	}
}
#endif


#pragma mark - Protocol UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	Mat m_image = [UIImageCVMatConverter cvMatGrayFromUIImage:image];
    [self processImage:m_image];
    image = [UIImageCVMatConverter UIImageFromCVMat:m_image];
    self.imageView.image = image;
    
    [self.imagePicker hidePicker:self];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self.imagePicker hidePicker:self];
}





@end
