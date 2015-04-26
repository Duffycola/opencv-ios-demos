//
//  imageFilter.h
//  OpenCViOSDemo
//
//  Created by CHARU HANS on 7/6/12.
//  Copyright (c) 2012 University of Houston - Main Campus. All rights reserved.
//



#ifdef __cplusplus

#include <opencv2/core/core.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/contrib/contrib.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/opencv_modules.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/photo/photo.hpp>



#endif
#import <UIKit/UIKit.h>

@interface imageFilter : NSObject

-(UIImage *)processImage:(UIImage *)inputImage oldImage:(UIImage *)maskImage number:(int)randomNumber sliderValueOne:(float)valueOne sliderValueTwo:(float)valueTwo;




#ifdef __cplusplus

-(cv::Mat)pixalizeMatConversion:(cv::Mat)inputMat pixelValue:(int)pixelSize;

-(cv::Mat)binaryMatConversion:(cv::Mat)inputMat thresholdValue:(float)value;

-(cv::Mat)sketchConversion:(cv::Mat)inputMat;

-(cv::Mat)inverseMatConversion:(cv::Mat)inputMat;

-(cv::Mat)sepiaConversion:(cv::Mat)inputMat;

-(cv::Mat)pencilSketchConversion:(cv::Mat)inputMat;

-(cv::Mat)grayMatConversion:(cv::Mat)inputMat;

-(cv::Mat)filmGrainConversion:(cv::Mat)inputMat;

-(cv::Mat)retroEffectConversion:(cv::Mat)inputMat;

-(cv::Mat)pinholeCameraConversion:(cv::Mat)inputMat;

-(cv::Mat)softFocusConversion:(cv::Mat)inputMat;

-(cv::Mat)cartoonMatConversion:(cv::Mat)inputMat;

-(cv::Mat)inpaintConversion:(cv::Mat)inputMat mask:(cv::Mat)maskMat;

-(cv::Mat)brightnessContrastEnhanceConversion:(cv::Mat)inputMat betaValue:(float)beta alphaValue:(float)alpha;

#endif



@end
