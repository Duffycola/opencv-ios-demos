//
//  ViewController.m
//  VideoFilter
//
//  Created by Eduard Feicho on 17.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerVideoFilter.h"

#import "imageFilter.h"
#import "UIImageCVMatConverter.h"


#ifdef __cplusplus
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
using namespace cv;

#endif


@interface ViewControllerVideoFilter ()

@end

@implementation ViewControllerVideoFilter

@synthesize imagePicker;

@synthesize imageFilterController;

@synthesize videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    enablePixelize = NO;
    enableInvert = NO;
    enableRetro = NO;
    enableSoftFocus = NO;
    enableCartoon = NO;
    enablePinhole = NO;
    
    enableProcessing = NO;
    
    hasVideo = NO;
    
    self.title = @"VideoFilter";
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    
	self.videoCamera.delegate = self;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
	self.videoCamera.defaultFPS = 30;
	self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera.recordVideo = YES;
    
    startOrientation = self.interfaceOrientation;
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
		default:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
    }
    
    self.imageFilterController = [[imageFilter alloc] init];
    
    
    
    [self updateView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.imageFilterController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == startOrientation);
    } else {
        return YES;
    }
}



#pragma mark - GUI actions


- (IBAction)actionPixelize:(id)sender;
{
    enablePixelize = !enablePixelize;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enablePixelize) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionInvert:(id)sender;
{
    enableInvert = !enableInvert;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableInvert) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionRetro:(id)sender;
{
    enableRetro = !enableRetro;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableRetro) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionSoftFocus:(id)sender;
{
    enableSoftFocus = !enableSoftFocus;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableSoftFocus) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionCartoon:(id)sender;
{
    enableCartoon = !enableCartoon;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableCartoon) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionPinhole:(id)sender;
{
    enablePinhole = !enablePinhole;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enablePinhole) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}



- (IBAction)actionBlurMedian:(id)sender;
{
    enableBlurMedian = !enableBlurMedian;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableBlurMedian) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}


- (IBAction)actionSobel:(id)sender;
{
    enableSobel = !enableSobel;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableSobel) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}

- (IBAction)actionCanny:(id)sender;
{
    enableCanny = !enableCanny;
    UIBarButtonItem* button = (UIBarButtonItem*)sender;
    button.style = (enableCanny) ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
}





- (IBAction)actionEnableProcessing:(id)sender;
{
    enableProcessing = !enableProcessing;
    if (enableProcessing) {
		[self.videoCamera start];
        hasVideo = YES;
        videoSaved = NO;
	} else {
		[self.videoCamera stop];
	}
    [self updateView];
}


- (IBAction)saveVideo:(id)sender;
{
    if (videoSaved == NO) {
        [self.videoCamera stop];
        enableProcessing = NO;
    }
    videoSaved = YES;
    
    [self.videoCamera saveVideo];
    
    [self presentMoviePlayerViewControllerAnimated:[[MPMoviePlayerViewController alloc] initWithContentURL:[self.videoCamera videoFileURL]]];
}


#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus


// delegate method for processing image frames


- (void)processImage:(cv::Mat&)image;
{
    const int& width = (int)image.cols;
	const int& height = (int)image.rows;
	const int& bytesPerRow = (int)image.step;

    cv::Mat result;
    if (enableCartoon) {
        result = [self.imageFilterController cartoonMatConversion:image];
//        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enableInvert) {
        result = [self.imageFilterController inverseMatConversion:image];
        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enablePinhole) {
        result = [self.imageFilterController pinholeCameraConversion:image];
//        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enablePixelize) {
        result = [self.imageFilterController pixalizeMatConversion:image pixelValue:5];
        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enableRetro) {
        result = [self.imageFilterController retroEffectConversion:image];
//        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enableSoftFocus) {
        result = [self.imageFilterController softFocusConversion:image];
        memcpy(image.data, result.data, max(width,bytesPerRow)*height);
    }
    if (enableBlurMedian || enableSobel || enableCanny) {
        vector<Mat> planes;
        split(image, planes);
    
        if (enableBlurMedian) {
            [CvConvolutionController filterBlurMedian:planes.at(0) withKernelSize:11];
        }
        if (enableSobel) {
            [CvConvolutionController filterSobel:planes.at(0) withKernelSize:3];
        }
        if (enableCanny) {
            [CvConvolutionController filterCanny:planes.at(0) withKernelSize:3 andLowThreshold:15];
        }
        
        merge(planes, image);
    }
}



- (IBAction)showPhotoLibrary:(id)sender;
{
	NSLog(@"show photo library");
	
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}



#endif

- (void)updateView;
{
    saveLabel.hidden = !hasVideo;
    saveButton.hidden = !hasVideo;
}



#pragma mark - Protocol UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	Mat m_image = [UIImageCVMatConverter cvMatFromUIImage:image];
    [self processImage:m_image];
    image = [UIImageCVMatConverter UIImageFromCVMat:m_image];
    imageView.image = image;
    
    UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
    
    [self.imagePicker hidePicker:self];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self.imagePicker hidePicker:self];
}



@end
