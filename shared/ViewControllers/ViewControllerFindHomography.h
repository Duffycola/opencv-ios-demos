//
//  ViewController.h
//  FindHomography
//
//  Created by Eduard Feicho on 26.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>

#import "ImagePickerController.h"
#import "CvHomographyController.h"


#ifdef __cplusplus
using namespace std;
#endif

@interface ViewControllerFindHomography : UIViewController<CvVideoCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
	UIImageView* imageView;
	UIImageView* imageViewObject;
	UIImageView* imageViewScene;
	
	UILabel* labelObject;
	UILabel* labelScene;
	
	UILabel* labelMin;
	UILabel* labelMax;
	UILabel* labelSlider;
	
	UISlider* slider;
	
	
	CvVideoCamera* videoCamera;
	
	CvHomographyController* homographyController;
	
	BOOL enableProcessing;
	BOOL objectLoaded;
	
	ImagePickerController* imagePicker;
	
	UIActionSheet* actionSheetDetectors;
	UIActionSheet* actionSheetDescriptors;
	
	UISwitch* processingSwitch;
	
	enum CVFeatureDetectorType detector;
	enum CVFeatureDescriptorType descriptor;
}


@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UISlider* slider;
@property (nonatomic, retain) IBOutlet UIImageView* imageViewObject;
@property (nonatomic, retain) IBOutlet UIImageView* imageViewScene;
@property (nonatomic, retain) IBOutlet UILabel* labelObject;
@property (nonatomic, retain) IBOutlet UILabel* labelScene;
@property (nonatomic, retain) IBOutlet UILabel* labelMin;
@property (nonatomic, retain) IBOutlet UILabel* labelMax;
@property (nonatomic, retain) IBOutlet UILabel* labelSlider;
@property (nonatomic, retain) IBOutlet UISwitch* processingSwitch;


@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, retain) CvHomographyController* homographyController;
@property (nonatomic, retain) ImagePickerController* imagePicker;

@property (nonatomic, retain) IBOutlet UIActionSheet* actionSheetDetectors;
@property (nonatomic, retain) IBOutlet UIActionSheet* actionSheetDescriptors;


- (IBAction)changeSlider:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)switchProcessingOnOff:(id)sender;
- (IBAction)showCameraImage:(id)sender;
- (IBAction)showPhotoLibrary:(id)sender;
- (IBAction)showVideoCamera:(id)sender;

- (IBAction)showDetectors:(id)sender;
- (IBAction)showDescriptors:(id)sender;

- (void)updateView;

@end

