//
//  CvGrabCutController.m
//  GrabCut
//
//  Created by Eduard Feicho on 15.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "CvGrabCutController.h"

#import "UIImageCVMatConverter.h"




@interface CvGrabCutController(Private)

- (void)reset;

@end



@implementation CvGrabCutController




@synthesize iterCount;
@synthesize processing;

- (id)init;
{
    self = [super init];
    if (self) {
        initialized = false;
        self.processing = false;
    }
    return self;
}



- (void)reset;
{
    if( !mask.empty() )
        mask.setTo(Scalar::all(GC_BGD));
    
    
    bgdPxls = Mat::zeros(image.size(), CV_8UC1);
    fgdPxls = Mat::zeros(image.size(), CV_8UC1);
    
    mFG.create(image.size(),CV_8UC3);
    mFG.setTo(RED);
    mBG.create(image.size(),CV_8UC3);
    mBG.setTo(BLUE);
    
    m255.create( image.size(), CV_8UC1);
    m255.setTo(255);
    
    
    int off_x = 1; //image.cols * 0.1;
    int off_y = 1; //image.rows * 0.1;
    
    rect = cv::Rect(off_x, off_y, image.cols - 2 * off_x, image.rows - 2 * off_y);
    [self setRectInMask];
    
    initialized = false;
    iterCount = 0;
}



- (Mat)getBinMask:(const Mat&)comMask;
{
    Mat binMask;
    if( comMask.empty() || comMask.type() != CV_8UC1 )
        CV_Error( CV_StsBadArg, "comMask is empty or has incorrect type (not CV_8UC1)" );
    if( binMask.empty() || binMask.rows != comMask.rows || binMask.cols != comMask.cols )
        binMask.create( comMask.size(), CV_8UC1 );
    binMask = comMask & 1;
    
    return binMask;
}


#pragma mark - Public interface

- (void)setImage:(UIImage*)uiimage;
{
    image = [UIImageCVMatConverter cvMatFromUIImage:uiimage];
    vector<Mat> planes;
    vector<Mat> planesRGB;
    
    split(image, planes);
    planesRGB.push_back(planes[0]);
    planesRGB.push_back(planes[1]);
    planesRGB.push_back(planes[2]);
    merge(planesRGB, image);
    
    mask.create( image.size(), CV_8UC1);
    [self reset];
}


- (void)nextIteration;
{
    if (self.processing) {
        return;
    }
    self.processing = true;
    
    NSLog(@"nextIter start");
    NSLog(@" initialized: %@", (initialized == false) ? @"NO" : @"YES");
    NSLog(@" rect: x,y,w,h: %d, %d, %d, %d", rect.x, rect.y, rect.width, rect.height);
    
    if (initialized) {
        cout << " grabCut(im, mask, rect, bg, fg, 1) " << endl;
		[self dumpInfo];
        grabCut( image, mask, rect, bgdModel, fgdModel, 1 );
		[self dumpInfo];
    } else {
        
        cout << " grabCut(im, mask, rect, bg, fg, 1, GC_INIT_WITH_MASK) " << endl;
        [self dumpInfo];
        grabCut( image, mask, rect, bgdModel, fgdModel, 1, GC_INIT_WITH_MASK );
        [self dumpInfo];
        
        initialized = true;
    }
    iterCount++;
    
    bgdPxls.setTo(0);
    fgdPxls.setTo(0);
    
    self.processing = false;
}


- (UIImage*)getImage;
{
    Mat result;
    Mat binMask;
    
    if (initialized == NO) {
        image.copyTo(result);
    } else {
        binMask = [self getBinMask:mask];
        image.copyTo(result, binMask);
    }
    
    
    // TODO: alpha blending with a mask
    mFG.copyTo(result, fgdPxls);
    mBG.copyTo(result, bgdPxls);
    rectangle( result, cv::Point( rect.x, rect.y ), cv::Point(rect.x + rect.width-1, rect.y + rect.height-1 ), GREEN, 2);
        
    return [UIImageCVMatConverter UIImageFromCVMat:result];
}


- (UIImage*)getSaveImage;
{
    Mat result;
    Mat binMask;
    
    if (initialized == NO) {
        image.copyTo(result);
    } else {
        binMask = [self getBinMask:mask];
        image.copyTo(result, binMask);
        
        // add alpha channel from mask
        Mat alpha;
        m255.copyTo( alpha, binMask );
        
        vector<Mat> v;
        v.push_back(result);
        v.push_back(alpha);
        merge(v, result);
    }
    
    return [UIImageCVMatConverter UIImageFromCVMat:result];
}


- (void)resetImage;
{
    [self reset];
}


- (void)maskLabel:(CGPoint)point foreground:(BOOL)isForeground;
{
    NSLog(@" mask foreground begin");
    
    cv::Point p(point.x, point.y);
    
    [self dumpMask];
    
    if (isForeground) {
        circle( fgdPxls, p, radius, 1, thickness );
        circle( bgdPxls, p, radius, 0, thickness );
        circle( mask, p, radius, GC_FGD, thickness );
    } else {
        circle( bgdPxls, p, radius, 1, thickness );
        circle( fgdPxls, p, radius, 0, thickness );
        circle( mask, p, radius, GC_BGD, thickness );
    }
    
    [self dumpMask];
    
    NSLog(@" mask foreground end");
}



- (void)dumpMask;
{
    /*
    NSLog(@" mask: ");
    for (int y=0; y<mask.rows; y++) {
		for (int x=0; x<mask.cols; x++) {
			if (mask.at<unsigned char>(y,x) == GC_FGD) {
				cout << "F";
			} else if (mask.at<unsigned char>(y,x) == GC_BGD) {
				cout << "B";
			} else if (mask.at<unsigned char>(y,x) == GC_PR_FGD) {
	            cout << "f";
		    } else if (mask.at<unsigned char>(y,x) == GC_PR_BGD) {
				cout << "b";
			} else {
				cout << "?";
			}
	    }
		cout << endl;
	}
    cout << endl;
    */
}

- (void)dumpInfo;
{
    /*
    cout << "=== DUMP === " << endl;
	cout << "RECT: " << rect.x << "," << rect.y << "," << rect.width << "," << rect.height << endl;
	cout << "MASK:" << endl;
	for (int y=0; y<mask.rows; y++) {
		for (int x=0; x<mask.cols; x++) {
			if (mask.at<unsigned char>(y,x) == GC_FGD) {
				cout << "F";
			} else if (mask.at<unsigned char>(y,x) == GC_BGD) {
				cout << "B";
			} else if (mask.at<unsigned char>(y,x) == GC_PR_FGD) {
	            cout << "f";
		    } else if (mask.at<unsigned char>(y,x) == GC_PR_BGD) {
				cout << "b";
			} else {
				cout << "?";
			}
	    }
		cout << endl;
	}
	cout << "=== ==== === " << endl;
	cout << endl;
     */
}

- (void)setRectInMask;
{
    assert( !mask.empty() );
    mask.setTo( GC_BGD );
    rect.x = max(0, rect.x);
    rect.y = max(0, rect.y);
    rect.width = min(rect.width, image.cols-rect.x);
    rect.height = min(rect.height, image.rows-rect.y);
    (mask(rect)).setTo( Scalar(GC_PR_FGD) );
}

@end
