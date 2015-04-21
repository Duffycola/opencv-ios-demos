//
//  ViewController.h
//  HelloWorld_iOS
//
//  Created by Vadim Pisarevsky on 6/16/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoCameraController.h"

@interface ViewController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
VideoCameraControllerDelegate>
{
    UIImage* image;
    VideoCameraController* videoCamera;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadButton;

-(IBAction)loadButtonPressed:(id)sender;
@end
