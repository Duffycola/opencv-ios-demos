//
//  CvCaptureController.m
//  TestHighgui
//
//  Created by Eduard Feicho on 11.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CvCaptureController.h"

#import "UIImageCVMatConverter.h"

#ifdef __cplusplus
#include "opencv2/highgui/highgui.hpp"
#endif

@interface CvCaptureController(PrivateMethods)
- (UIImage*)grabImage;
@end

@implementation CvCaptureController


- (id)init;
{
    self = [super init];
    if (self) {
        capture = new cv::VideoCapture(CV_CAP_IOS);
        running = NO;
    }
    return self;
}

- (void)dealloc;
{
    delete capture;
    capture = NULL;
    running = NO;
}

- (void)run;
{
    @synchronized(self) {
        if (running == YES) {
            NSLog(@"call to -run ignored, already running");
            return;
        }
    }
    running = YES;
    
    NSLog(@"dispatching async run loop");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        while (running == YES) {
            NSLog(@"* in async runloop");
            cv::Mat image_mat;
            
            
            @synchronized(self) {
                if (capture == NULL) {
                    NSLog(@"capture is NULL, break!");
                    break;
                }
                if (!capture->grab()) {
                    NSLog(@"cannot grab frame, break!");
                    break;
                }
                if (!capture->read(image_mat)) {
                    NSLog(@"cannot read frame, break!");
                    break;
                }
            }
            
            UIImage* image = [UIImageCVMatConverter UIImageFromCVMat:image_mat];
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"posting new frame");
                [[NSNotificationCenter defaultCenter] postNotificationName:CVCAPTURECONTROLLER_FRAME_NOTIFICATION object:image];
            });
            
            NSLog(@"sleep 1 second");
            [NSThread sleepForTimeInterval:1];
        }
        
        NSLog(@"* async runloop stop");
        
    });
}

- (void)stopRunning;
{
    running = NO;
}


@end
