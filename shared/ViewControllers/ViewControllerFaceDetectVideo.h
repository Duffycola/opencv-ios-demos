//
//  ViewController.h
//  FaceDetectVideo
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImagePickerController.h"
#import <opencv2/highgui/cap_ios.h>
#import "CvFaceDetector.h"


@interface ViewControllerFaceDetectVideo : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CvVideoCameraDelegate>
{
	UIImageView* imageView;
	UILabel* labelFPS;
	UISlider* sliderFPS;
	
	BOOL enableProcessing;
	
	
	CvVideoCamera* videoCamera;
	CvFaceDetector* cvFaceDetector;
	ImagePickerController* imagePicker;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UILabel* labelFPS;

- (IBAction)changeFPS:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)switchProcessingOnOff:(id)sender;
- (IBAction)showCameraImage:(id)sender;
- (IBAction)showPhotoLibrary:(id)sender;
- (IBAction)showVideoCamera:(id)sender;


@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, retain) CvFaceDetector* cvFaceDetector;
@property (nonatomic, retain) ImagePickerController* imagePicker;





@end
