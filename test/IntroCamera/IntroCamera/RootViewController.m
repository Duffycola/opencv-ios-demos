//
//  RootViewController.m
//  IntroCamera
//
//  Created by Eduard Feicho on 02.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "RootViewController.h"

#import "ImagePickerController.h"
#import "VideoCameraController.h"



@implementation RootViewController

#pragma mark - Properties

@synthesize imagePicker;
@synthesize videoCamera;

@synthesize cameraImageView;
@synthesize photoLibraryImageView;
@synthesize videoCameraImageView;

#pragma mark - Constructor

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.imagePicker = nil;
		
		self.videoCamera = [[VideoCameraController alloc] init];
		self.videoCamera.delegate = self;
    }
    return self;
}



#pragma mark - ViewController lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Protocol VideoCameraControllerDelegate


- (IBAction)switchCamera:(id)sender;
{
	[self.videoCamera switchCameras];
}



- (IBAction)showVideoCamera:(id)sender;
{
	NSLog(@"show video camera");
	
	UIButton* button = (UIButton*)sender;
	
	if (self.videoCamera.running) {
		[self.videoCamera stop];
		[button setTitle:@"Start Video Camera" forState:UIControlStateNormal];
	} else {
		[self.videoCamera start];
		[button setTitle:@"Stop Video Camera" forState:UIControlStateNormal];
	}
}


- (CGImageRef)processImage:(const vImage_Buffer)image withRenderContext:(CGContextRef)contextOverlay;
{
	return nil;
}


- (void)videoCameraViewController:(VideoCameraController*)videoCameraViewController capturedImage:(UIImage *)image;
{
	// custom per-frame actions, like visualization, augmented reality...
}


- (void)videoCameraViewControllerDone:(VideoCameraController*)videoCameraViewController;
{
	
}


- (BOOL)allowMultipleImages;
{
	return YES;
}


- (BOOL)allowPreviewLayer;
{
	return YES;
}


- (UIView*)getPreviewView;
{
	return videoCameraImageView;
}


#pragma mark - Protocol UIImagePickerControllerDelegate


- (IBAction)showCameraImage:(id)sender;
{
	NSLog(@"show camera image");
	
	self.imagePicker = [[ImagePickerController alloc] initAsCamera];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}


- (IBAction)showPhotoLibrary:(id)sender;
{
	NSLog(@"show photo library");
	
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSLog(@"imagePickerController didFinish: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	
	if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		[self.photoLibraryImageView setImage:image];
	} else {
		[self.cameraImageView setImage:image];
	}
	
	[self.imagePicker hidePicker:picker];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePicker hidePicker:picker];
}


@end
