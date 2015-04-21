//
//  ViewControllerFindHomographyLoadObject.m
//  FindHomography
//
//  Created by Eduard Feicho on 23.07.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerFindHomographyLoadObject.h"

#import "UIImage+Resize.h"
#import "UIImageCVMatConverter.h"

@interface ViewControllerFindHomographyLoadObject ()

@end

@implementation ViewControllerFindHomographyLoadObject




@synthesize imagePicker;
@synthesize homographyController;
@synthesize imageViewObject;
@synthesize buttonContinue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - UIViewController lifecycle


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = @"Load Object";
	
	self.homographyController = [CvHomographyController sharedInstance];
		
	[self.imageViewObject.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[self.imageViewObject.layer setBorderWidth:1.5];
	
	objectLoaded = NO;
	
	[self updateView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	} else {
	    return YES;
	}
}


- (void)updateView;
{
	self.buttonContinue.enabled = objectLoaded == YES;
	
	NSLog(@"Slider value: %f", [self.homographyController getDetectorThreshold]);
}


#pragma mark - UI Interface

- (IBAction)showCameraImage:(id)sender;
{
	self.imagePicker = [[ImagePickerController alloc] initAsCamera];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}



- (IBAction)showPhotoLibrary:(id)sender;
{
	self.imagePicker = [[ImagePickerController alloc] initAsPhotoLibrary];
	self.imagePicker.delegate = self;
	[self.imagePicker showPicker:self];
}


#pragma mark - Protocol UIImagePickerControllerDelegate



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	CGSize desiredSize;
	if (image.size.width > image.size.height) {
		desiredSize = CGSizeMake(352, 288);
	} else {
		desiredSize = CGSizeMake(288, 352);
	}
	image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:desiredSize];
	
	NSLog(@"imagePickerController didFinish: image info [w,h] = [%f,%f]", image.size.width, image.size.height);
	
	[self.homographyController reset];
	[self.homographyController setObjectImage:image];
	[self.imageViewObject setImage:[self.homographyController getObjectImage]];
	
	[self.homographyController match];
	[self.homographyController drawObject];
	[self.imageViewObject setImage:[UIImageCVMatConverter UIImageFromCVMat:*[self.homographyController getMatchImage] ]];
	
	objectLoaded = YES;
	
	[self.imagePicker hidePicker:picker];
	
	[self updateView];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePicker hidePicker:picker];
}




@end
