//
//  ViewControllerGrabCut.h
//  GrabCut
//
//  Created by Eduard Feicho on 15.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CvGrabCutController.h"

@interface ViewControllerGrabCut : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    IBOutlet UIImageView *imageView;
    
    IBOutlet UIBarButtonItem* buttonEdit;
    IBOutlet UIBarButtonItem* buttonGrabCut;
    IBOutlet UIBarButtonItem* buttonSave;
    IBOutlet UIBarButtonItem* buttonToggle;
    
    IBOutlet UILabel* label;
    
    IBOutlet UIView* activityView;
    IBOutlet UIActivityIndicatorView* activityIndicatorView;
    IBOutlet UILabel* activityLabel;
    
    CvGrabCutController* grabCutController;
    
    BOOL image_changed;
    BOOL edit_fg;
    
    float scale_x;
    float scale_y;
}

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, retain) CvGrabCutController *grabCutController;


- (IBAction)actionShowPhotoLibrary:(id)sender;
- (IBAction)actionEdit:(id)sender;
- (IBAction)actionGrabCut:(id)sender;
- (IBAction)actionSave:(id)sender;
- (IBAction)actionToggle:(id)sender;


@end
