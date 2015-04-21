//
//  ViewController.m
//  HelloWorld_iOS
//
//  Created by Vadim Pisarevsky on 6/16/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "ViewController.h"

static UIImage* MatToUIImage(const cv::Mat& m)
{
    CV_Assert(m.depth() == CV_8U);
    NSData *data = [NSData dataWithBytes:m.data length:m.step*m.rows];
    CGColorSpaceRef colorSpace = m.channels() == 1 ?
        CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(m.cols, m.cols, m.elemSize1()*8, m.elemSize()*8,
        m.step[0], colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault,
        provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

static void UIImageToMat(const UIImage* image, cv::Mat& m)
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGContextRef contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
        m.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
}

static UIImage* processWithOpenCV(const UIImage* image)
{
    cv::Mat m, gray;
    UIImageToMat(image, m);
    cv::cvtColor(m, gray, CV_RGBA2GRAY);
    cv::GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
    cv::Canny(gray, gray, 0, 50);
    m = cv::Scalar::all(255);
    m.setTo(cv::Scalar(0, 128, 255, 255), gray);
    return MatToUIImage(m);
}

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView, loadButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*NSString* filename = [[NSBundle mainBundle] pathForResource:@"helloworld" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:filename];
    
    if( image != nil )
    {
        imageView.image = processWithOpenCV(image);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }*/
    videoCamera = [[VideoCameraController alloc] init];
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    videoCamera.defaultFPS = 15;
    videoCamera.delegate = self;
    [videoCamera start];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)loadButtonPressed:(id)sender
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *temp = [info objectForKey:@"UIImagePickerControllerOriginalImage"]; 
    imageView.image = processWithOpenCV(temp);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark VideoCameraController protocol

- (void)processImage:(const vImage_Buffer)imagebuf withRenderContext:(CGContextRef)contextOverlay
{
	// do nothing
    cv::Mat gray((int)imagebuf.height, (int)imagebuf.width, CV_8U, imagebuf.data, imagebuf.rowBytes);
    cv::GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
    cv::Canny(gray, gray, 0, 30);
}


- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)result
{
	// custom per-frame actions, like visualization, augmented reality...
    [self.imageView setImage:result];
}


- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController
{
	
}


- (BOOL)allowMultipleImages;
{
	return YES;
}


- (BOOL)allowPreviewLayer;
{
	return NO;
}

- (UIView*)getPreviewView;
{
	return imageView;
}

@end
