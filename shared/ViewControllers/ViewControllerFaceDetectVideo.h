//
//  ViewController.h
//  FaceDetectVideo
//
//  Created by Eduard Feicho on 08.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "ImagePickerController.h"
#import "CvFaceDetector.h"

@interface ViewControllerFaceDetectVideo : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	UIImageView* imageView;
	UILabel* labelFPS;
	UISlider* sliderFPS;
	
	BOOL enableProcessing;

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



@property (nonatomic, retain) CvFaceDetector* cvFaceDetector;
@property (nonatomic, retain) ImagePickerController* imagePicker;





@end
