//
//  ViewController.h
//  VideoFilters
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>
#import "CvFilterController.h"
#import "ImagePickerController.h"


enum OpenCV_Filter_Mode {
	FILTERMODE_BLUR_HOMOGENEOUS,
	FILTERMODE_BLUR_GAUSSIAN,
	FILTERMODE_BLUR_MEDIAN,
	FILTERMODE_BLUR_BILATERAL,
	FILTERMODE_LAPLACIAN,
	FILTERMODE_SOBEL,
	FILTERMODE_CANNY,
	FILTERMODE_HARRIS
};



@interface ViewControllerVideoFilters : UIViewController<CvVideoCameraDelegate, UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	ImagePickerController* imagePicker;
	
	
	UIImageView* imageView;
	UISlider* slider;
	UIBarButtonItem* sliderTitleItem;
	UIBarButtonItem* sliderValueItem;
	
	UIActionSheet* actionSheetBlurFilters;
	UIActionSheet* actionSheetEdgeFilters;
	
	BOOL enableProcessing;
	
	CvVideoCamera* videoCamera;
	
	enum OpenCV_Filter_Mode mode;
	int kernel_size;
	int threshold;
}


@property (nonatomic, retain) IBOutlet UIImageView* imageView;

@property (nonatomic, retain) IBOutlet UISlider* slider;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* sliderTitleItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* sliderValueItem;

@property (nonatomic, retain) IBOutlet UIActionSheet* actionSheetBlurFilters;
@property (nonatomic, retain) IBOutlet UIActionSheet* actionSheetEdgeFilters;

- (IBAction)showPhotoLibrary:(id)sender;

- (IBAction)sliderValueChanged:(id)sender;

- (IBAction)switchCamera:(id)sender;
- (IBAction)switchProcessingOnOff:(id)sender;

- (IBAction)showBlurFilters:(id)sender;
- (IBAction)showEdgeFilters:(id)sender;

- (void)updateView;



@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, retain) ImagePickerController* imagePicker;


@end
