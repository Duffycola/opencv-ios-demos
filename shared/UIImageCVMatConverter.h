//
//  UIImageCVMatConverter.h
//  OpenCViOS
//
//  Created by CHARU HANS on 6/6/12.
//  Copyright (c) 2012 University of Houston - Main Campus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageCVMatConverter : NSObject

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat withUIImage:(UIImage*)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;

@end
