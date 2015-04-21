//
//  RootViewController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 02.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePickerController.h"
#import "VideoCameraController.h"

@interface RootViewController : UIViewController<VideoCameraControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	UIImageView* cameraImageView;
	UIImageView* photoLibraryImageView;
	UIImageView* videoCameraImageView;
	
	ImagePickerController* imagePicker;
	VideoCameraController* videoCamera;
	
}

@property (nonatomic, retain) ImagePickerController* imagePicker;
@property (nonatomic, retain) VideoCameraController* videoCamera;

@property (nonatomic, retain) IBOutlet UIImageView* cameraImageView;
@property (nonatomic, retain) IBOutlet UIImageView* photoLibraryImageView;
@property (nonatomic, retain) IBOutlet UIImageView* videoCameraImageView;




- (IBAction)showCameraImage:(id)sender;
- (IBAction)showPhotoLibrary:(id)sender;
- (IBAction)showVideoCamera:(id)sender;

@end
