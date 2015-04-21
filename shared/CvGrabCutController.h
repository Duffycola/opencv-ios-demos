//
//  CvGrabCutController.h
//  GrabCut
//
//  Created by Eduard Feicho on 15.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef __cplusplus

#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;



const Scalar RED = Scalar(0,0,255);
const Scalar PINK = Scalar(230,130,255);
const Scalar BLUE = Scalar(255,0,0);
const Scalar LIGHTBLUE = Scalar(255,255,160);
const Scalar GREEN = Scalar(0,255,0);

static const int radius = 15;
static const int thickness = -1;


#include <vector>
using namespace std;

#endif



@interface CvGrabCutController : NSObject
{
#ifdef __cplusplus
    Mat image;
    
    Mat image_canvas;
    
    Mat mask;
    Mat bgdModel;
    Mat fgdModel;
    
    Mat foreground;
    
    Mat mFG;
    Mat mBG;
    Mat m255;
    
    
    cv::Rect rect;
    
    Mat fgdPxls;
    Mat bgdPxls;
    
#endif
        
    
    bool initialized;
    bool processing;
    
    int iterCount;
    
}

@property (atomic, assign) bool processing;
@property (nonatomic, assign) int iterCount;

- (UIImage*)getSaveImage;
- (void)setImage:(UIImage*)image;
- (void)nextIteration;
- (void)resetImage;


- (void)maskLabel:(CGPoint)point foreground:(BOOL)isForeground;

- (UIImage*)getImage;




@end
