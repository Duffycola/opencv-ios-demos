//
//  CvCaptureController.h
//  TestHighgui
//
//  Created by Eduard Feicho on 11.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#endif



static NSString* CVCAPTURECONTROLLER_FRAME_NOTIFICATION = @"CvCaptureFrameCaptured";

@interface CvCaptureController : NSObject
{
#ifdef __cplusplus
    cv::VideoCapture* capture;
#else
    void* capture;
#endif
    
    BOOL running;
}

- (void)run;
- (void)stopRunning;


@end


