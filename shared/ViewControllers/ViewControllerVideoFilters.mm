//
//  ViewController.m
//  VideoFilters
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerVideoFilters.h"
#import "UIImageCVMatConverter.h"

// keep these two arrays in sync
NSString* actionSheetBlurTitles[] = {@"Homogeneous", @"Gaussian", @"Median", @"Bilateral"};
enum OpenCV_Filter_Mode actionSheetBlurModes[] = {
	FILTERMODE_BLUR_HOMOGENEOUS,
	FILTERMODE_BLUR_GAUSSIAN,
	FILTERMODE_BLUR_MEDIAN,
	FILTERMODE_BLUR_BILATERAL,
};

// keep these two arrays in sync, don't forget the final nil
NSString* actionSheetEdgeTitles[] = {@"Laplacian", @"Sobel", @"Canny"};
enum OpenCV_Filter_Mode actionSheetEdgeModes[] = {
	FILTERMODE_LAPLACIAN,
	FILTERMODE_SOBEL,
	FILTERMODE_CANNY,
};



@interface ViewControllerVideoFilters ()

@end

@implementation ViewControllerVideoFilters


#pragma mark - Properties

@synthesize imagePicker;
@synthesize videoCamera;
@synthesize imageView;
@synthesize sliderValueItem;
@synthesize sliderTitleItem;
@synthesize slider;
@synthesize actionSheetBlurFilters;
@synthesize actionSheetEdgeFilters;


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

- (void)viewDidLoad;
{
    [super viewDidLoad];
	
	self.title = @"VideoFilters";
	
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultFPS = 30;
	self.videoCamera.grayscaleMode = YES;
	
	self.actionSheetBlurFilters = [[UIActionSheet alloc] initWithTitle:@"Blur Filters" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
	for (int i=0; i<4; i++) {
		[self.actionSheetBlurFilters addButtonWithTitle:actionSheetBlurTitles[i]];
	}
	
	self.actionSheetEdgeFilters = [[UIActionSheet alloc] initWithTitle:@"Edge Filters" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
	for (int i=0; i<3; i++) {
		[self.actionSheetEdgeFilters addButtonWithTitle:actionSheetEdgeTitles[i]];
	}
	
	enableProcessing = NO;
	
	mode = FILTERMODE_BLUR_HOMOGENEOUS;
	kernel_size = 3;
	threshold = 1;
	
	[self updateView];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}



#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    switch (mode) {
        case FILTERMODE_BLUR_HOMOGENEOUS:
            [CvFilterController filterBlurHomogeneousAccelerated:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_BLUR_GAUSSIAN:
            [CvFilterController filterBlurGaussian:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_BLUR_MEDIAN:
            [CvFilterController filterBlurMedian:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_BLUR_BILATERAL:
            [CvFilterController filterBlurBilateral:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_LAPLACIAN:
            [CvFilterController filterLaplace:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_SOBEL:
            [CvFilterController filterSobel:image withKernelSize:kernel_size];
            break;
            
        case FILTERMODE_CANNY:
            [CvFilterController filterCanny:image withKernelSize:3 andLowThreshold:threshold];
            break;
            
        default:
            break;
    }
}
#endif


#pragma mark - UI Interface



- (IBAction)showPhotoLibrary:(id)sender;
{
	NSLog(@"show photo library");
	
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}


- (IBAction)sliderValueChanged:(id)sender;
{
	int new_value;
	switch (mode) {
		case FILTERMODE_BLUR_BILATERAL:
		case FILTERMODE_BLUR_HOMOGENEOUS:
		case FILTERMODE_BLUR_GAUSSIAN:
		case FILTERMODE_BLUR_MEDIAN:
		case FILTERMODE_LAPLACIAN:
		case FILTERMODE_SOBEL:
			new_value = ((int)((slider.value + 1.0) / 2.0) * 2.0);
			if (new_value % 2 == 0) {
				new_value--;
			}
			[slider setValue:new_value animated:NO];
			kernel_size = (int)slider.value;
			
			break;
		case FILTERMODE_CANNY:
			new_value = slider.value;
			threshold = new_value;
			
			break;
		default:
			break;
	}
	
	[self updateView];
}


- (IBAction)switchProcessingOnOff:(id)sender;
{
	enableProcessing = !enableProcessing;
	
	if (enableProcessing) {
		[videoCamera start];
	} else {
		[videoCamera stop];
	}
}



- (IBAction)switchCamera:(id)sender;
{
	[self.videoCamera switchCameras];
}


- (IBAction)showBlurFilters:(id)sender;
{
	[self.actionSheetBlurFilters showInView:self.view];
}


- (IBAction)showEdgeFilters:(id)sender;
{
	[self.actionSheetEdgeFilters showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (actionSheet.cancelButtonIndex == buttonIndex) {
		return;
	}
	if (actionSheet == self.actionSheetBlurFilters) {
		mode = actionSheetBlurModes[buttonIndex-1];
	} else if (actionSheet == self.actionSheetEdgeFilters) {
		mode = actionSheetEdgeModes[buttonIndex-1];
	}
	[self updateView];
}


- (void)updateView;
{
	if (mode == FILTERMODE_CANNY) {
		self.slider.minimumValue = 0;
		self.slider.maximumValue = 100;
		self.slider.value = threshold;
		self.sliderTitleItem.title = @"Thresh";
		self.sliderValueItem.title = [NSString stringWithFormat:@"%d", threshold];
	} else {
		self.slider.minimumValue = 1;
		self.slider.maximumValue = 31;
		self.slider.value = kernel_size;
		self.sliderTitleItem.title = @"Kernel";
		self.sliderValueItem.title = [NSString stringWithFormat:@"%d", kernel_size];
	}
}


#pragma mark - Protocol UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	Mat m_image = [UIImageCVMatConverter cvMatGrayFromUIImage:image];
    [self processImage:m_image];
    image = [UIImageCVMatConverter UIImageFromCVMat:m_image];
    self.imageView.image = image;
    
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
    
    [self.imagePicker hidePicker:self];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self.imagePicker hidePicker:self];
}


@end
