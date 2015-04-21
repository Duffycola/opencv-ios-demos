//
//  ViewControllerFindHomographyLoadObject.h
//  FindHomography
//
//  Created by Eduard Feicho on 23.07.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>

#import "ImagePickerController.h"
#import "CvHomographyController.h"


#ifdef __cplusplus
using namespace std;
#endif

@interface ViewControllerFindHomographyLoadObject : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UIImageView* imageViewObject;
	
		
	CvHomographyController* homographyController;
	
	BOOL objectLoaded;
	
	ImagePickerController* imagePicker;
	
	UIButton* buttonContinue;
	
}
@property (nonatomic, retain) IBOutlet UIImageView* imageViewObject;
@property (nonatomic, retain) IBOutlet UIButton* buttonContinue;

@property (nonatomic, retain) CvHomographyController* homographyController;
@property (nonatomic, retain) ImagePickerController* imagePicker;


- (IBAction)showCameraImage:(id)sender;
- (IBAction)showPhotoLibrary:(id)sender;

@end
