//
//  ViewController.h
//  HelloIOS
//
//  Created by Eduard Feicho on 27.08.12.
//  Copyright (c) 2012 OpenCV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton* button;
    
    CvVideoCamera* videoCamera;
}

- (IBAction)actionStart:(id)sender;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end
