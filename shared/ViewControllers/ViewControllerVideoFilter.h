//
//  ViewController.h
//  VideoFilter
//
//  Created by Eduard Feicho on 17.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ImagePickerController.h"


#import <opencv2/highgui/cap_ios.h>

#import "imageFilter.h"
#import "CvConvolutionController.h"


@interface ViewControllerVideoFilter : UIViewController<CvVideoCameraDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    ImagePickerController* imagePicker;
    
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel* saveLabel;
    IBOutlet UIButton* saveButton;
    
    BOOL enablePixelize;
    BOOL enableInvert;
    BOOL enableRetro;
    BOOL enableSoftFocus;
    BOOL enableCartoon;
    BOOL enablePinhole;
    
    BOOL enableBlurMedian;
    BOOL enableSobel;
    BOOL enableCanny;
    
    BOOL hasVideo;
    BOOL videoSaved;
    
    BOOL enableProcessing;
    
    CvVideoCamera* videoCamera;
    
    imageFilter* imageFilterController;
    
    UIInterfaceOrientation startOrientation;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, retain) imageFilter* imageFilterController;

@property (nonatomic, retain) ImagePickerController* imagePicker;

- (IBAction)actionPixelize:(id)sender;
- (IBAction)actionInvert:(id)sender;
- (IBAction)actionRetro:(id)sender;
- (IBAction)actionSoftFocus:(id)sender;
- (IBAction)actionCartoon:(id)sender;
- (IBAction)actionPinhole:(id)sender;
- (IBAction)actionBlurMedian:(id)sender;
- (IBAction)actionSobel:(id)sender;
- (IBAction)actionCanny:(id)sender;


- (IBAction)actionEnableProcessing:(id)sender;

- (IBAction)saveVideo:(id)sender;


- (IBAction)showPhotoLibrary:(id)sender;


@end
