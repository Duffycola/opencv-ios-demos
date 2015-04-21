//
//  ViewController.m
//  FindHomography
//
//  Created by Eduard Feicho on 26.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerFindHomography.h"

#import "UIImage+Resize.h"



@implementation ViewControllerFindHomography



#pragma mark - Properties



@synthesize imageView;
@synthesize labelObject;
@synthesize labelScene;

@synthesize labelMin;
@synthesize labelMax;
@synthesize labelSlider;

@synthesize processingSwitch;

@synthesize imagePicker;
@synthesize videoCamera;
@synthesize homographyController;
@synthesize imageViewObject;
@synthesize imageViewScene;

@synthesize actionSheetDetectors;
@synthesize actionSheetDescriptors;

@synthesize slider;


#pragma mark - UIViewController lifecycle

// keep these two arrays in sync
NSString* actionSheetDetectorTitles[] = {@"FAST", @"GDT", @"MSER", @"ORB", @"STAR", @"SIFT", @"SURF"};
enum CVFeatureDetectorType actionSheetDetectorTypes[] = {
	CV_FEATUREDETECTOR_FAST,
	CV_FEATUREDETECTOR_GOODTOTRACK,
	CV_FEATUREDETECTOR_MSER,
	CV_FEATUREDETECTOR_ORB,
	CV_FEATUREDETECTOR_STAR,
	CV_FEATUREDETECTOR_SIFT,
	CV_FEATUREDETECTOR_SURF,
};

// keep these two arrays in sync, don't forget the final nil
NSString* actionSheetDescriptorTitles[] = {@"ORB", @"SIFT", @"SURF"};
enum CVFeatureDescriptorType actionSheetDescriptorTypes[] = {
	CV_FEATUREDESCRIPTOR_ORB,
	CV_FEATUREDESCRIPTOR_SIFT,
	CV_FEATUREDESCRIPTOR_SURF,
};

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
	
	self.title = @"FindHomography";
	
	self.homographyController = [CvHomographyController sharedInstance];
	
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	self.videoCamera.defaultFPS = 15;
	self.videoCamera.grayscaleMode = YES;
	
	self.actionSheetDetectors = [[UIActionSheet alloc] initWithTitle:@"Detector" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
	for (int i=0; i<7; i++) {
		[self.actionSheetDetectors addButtonWithTitle:actionSheetDetectorTitles[i]];
	}
	
	self.actionSheetDescriptors = [[UIActionSheet alloc] initWithTitle:@"Descriptor" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
	for (int i=0; i<3; i++) {
		[self.actionSheetDescriptors addButtonWithTitle:actionSheetDescriptorTitles[i]];
	}
	
	enableProcessing = NO;
	
	[self.imageViewObject.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[self.imageViewObject.layer setBorderWidth:1.5];
	
	[self.imageViewScene.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[self.imageViewScene.layer setBorderWidth:1.5];
	
	/*
	float rotationAngle = 0.0;
	CGRect bounds = self.imageView.bounds;
	CALayer* layer = self.imageView.layer;
	
	rotationAngle = 3*M_PI/2.;
	bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
	
	//layer.position = CGPointMake(bounds.size.width/2., bounds.size.height/2.);
	layer.affineTransform = CGAffineTransformMakeRotation(rotationAngle);
	layer.bounds = bounds;
	*/
	
	objectLoaded = NO;
	
	[self updateView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	} else {
	    return YES;
	}
}


- (void)updateView;
{
	self.imageView.hidden = !enableProcessing;
	self.labelObject.hidden = !enableProcessing || self.imageViewObject.image != nil;
	self.labelScene.hidden = !enableProcessing || self.imageViewScene.image != nil;
/*
	self.slider.hidden = !enableProcessing;
	self.labelSlider.hidden = !enableProcessing;
	self.labelMin.hidden = !enableProcessing;
	self.labelMax.hidden = !enableProcessing;
*/
	
	self.labelSlider.text = [NSString stringWithFormat:@"%@: %2.2f", [self.homographyController getDetectorThresholdName], [self.homographyController getDetectorThreshold]];
	self.labelMin.text = [NSString stringWithFormat:@"%3.1f", self.homographyController.thresh_min];
	self.labelMax.text = [NSString stringWithFormat:@"%3.1f", self.homographyController.thresh_max];
	self.slider.minimumValue = self.homographyController.thresh_min;
	self.slider.maximumValue = self.homographyController.thresh_max;
	self.slider.value = [self.homographyController getDetectorThreshold];
	
	self.processingSwitch.enabled = self.homographyController.object_loaded == YES;
	
	if (self.homographyController.object_loaded) {
		self.imageViewObject.image = [self.homographyController getObjectImage];
	}
	
	NSLog(@"Slider value: %f", [self.homographyController getDetectorThreshold]);
}



#pragma mark - UI Interface



- (IBAction)changeSlider:(id)sender;
{
	/*
	[self.homographyController setDetectorThreshold:self.slider.value];
	[self updateView];
	*/
	
	/*
	BOOL started = self.videoCamera.running;
	
	UISlider* slider = (UISlider*)sender;
	if (started) {
		[self.videoCamera stop];
	}
	[self.videoCamera start];
	 */
}



- (IBAction)switchProcessingOnOff:(id)sender;
{
	enableProcessing = !enableProcessing;
	if (enableProcessing) {
		[self.videoCamera start];
		self.imageView.hidden = NO;
	} else {
		[self.videoCamera stop];
		self.imageView.hidden = YES;
	}
}



- (IBAction)switchCamera:(id)sender;
{
	UIBarButtonItem* button = (UIBarButtonItem*)sender;
	[self.videoCamera switchCameras];
	if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
		button.title = @"Back";
	} else {
		button.title = @"Front";
	}
}



- (IBAction)showCameraImage:(id)sender;
{
	self.imagePicker = [[ImagePickerController alloc] initAsCamera];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}



- (IBAction)showPhotoLibrary:(id)sender;
{
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


- (IBAction)showDetectors:(id)sender;
{
	[self.actionSheetDetectors showInView:self.view];
}


- (IBAction)showDescriptors:(id)sender;
{
	[self.actionSheetDescriptors showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	NSLog(@"button index: %d", buttonIndex);
	
	if (actionSheet.cancelButtonIndex == buttonIndex) {
		return;
	}
	BOOL wasRunning = self.videoCamera.running;
	[self.videoCamera stop];
	
	if (actionSheet == self.actionSheetDetectors) {
		detector = actionSheetDetectorTypes[buttonIndex-1];
		[self.homographyController setDetector:detector];
	} else if (actionSheet == self.actionSheetDescriptors) {
		descriptor = actionSheetDescriptorTypes[buttonIndex-1];
		[self.homographyController setDescriptor:descriptor];
	}
	
	if (wasRunning) {
		[self.videoCamera start];
	}
	
	[self updateView];
}

#pragma mark - Protocol VideoCameraControllerDelegate


#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
	if (enableProcessing) {
		
		NSLog(@"Processing (matching)...");
		[self.homographyController setSceneImage:&image];
		[self.homographyController detect];
		[self.homographyController descript];
		[self.homographyController match];
		[self.homographyController drawScene];
		NSLog(@"done.");
        
	}
}
#endif



#pragma mark - Protocol UIImagePickerControllerDelegate



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	CGSize desiredSize;
	if (image.size.width > image.size.height) {
		desiredSize = CGSizeMake(352, 288);
	} else {
		desiredSize = CGSizeMake(288, 352);
	}
	image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:desiredSize];
	
	NSLog(@"imagePickerController didFinish: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	
	[self.homographyController reset];
	[self.homographyController setObjectImage:image];
	[self.imageViewObject setImage:[self.homographyController getObjectImage]];
	
	//[self.homographyController match];
	//[self.homographyController drawMatches];
	//[self.imageView setImage:[UIImageCVMatConverter UIImageFromCVMat:[self.homographyController getMatchImage] ]];
	
	objectLoaded = YES;
	
	[self.imagePicker hidePicker:picker];
	
	[self updateView];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePicker hidePicker:picker];
}



@end
