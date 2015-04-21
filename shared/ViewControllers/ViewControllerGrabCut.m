//
//  ViewControllerGrabCut.m
//  GrabCut
//
//  Created by Eduard Feicho on 15.08.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ViewControllerGrabCut.h"


#import <MobileCoreServices/UTCoreTypes.h>


@interface ViewControllerGrabCut ()
- (void)calculateScale;
- (void)indicateActivity:(BOOL)active;
@end




@implementation ViewControllerGrabCut


@synthesize imagePicker;
@synthesize grabCutController;


- (void)calculateScale;
{
    NSLog(@"imageView bounds: %f,%f", imageView.bounds.size.width, imageView.bounds.size.height);
    NSLog(@"imageView.image bounds: %f,%f", imageView.image.size.width, imageView.image.size.height);
    
    scale_x = imageView.image.size.width / imageView.bounds.size.width;
    scale_y = imageView.image.size.height / imageView.bounds.size.height;
    
    NSLog(@"scale_x: %f", scale_x);
    NSLog(@"scale_y: %f", scale_y);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    edit_fg = YES;
    
    imageView.exclusiveTouch = YES;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.delegate = self;
    self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    if ([UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    grabCutController = [[CvGrabCutController alloc] init];
    
    
    [grabCutController setImage:imageView.image];
    [self calculateScale];
    image_changed = NO;
    
    
    // Gestures
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
    [imageView addGestureRecognizer:panGesture];
    
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
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



#pragma mark - Protocol UIImagePickerControllerDelegate



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    imageView.image = img;
    [grabCutController setImage:img];
    image_changed = NO;
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    [self calculateScale];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}



#pragma mark - GUI actions



- (IBAction)actionShowPhotoLibrary:(id)sender;
{
    [self presentModalViewController:self.imagePicker animated:YES];
}


- (IBAction)actionEdit:(id)sender;
{
    self.editing = !self.editing;
    [self updateView];
}


- (IBAction)actionSave:(id)sender;
{
    if (image_changed == YES) {
        UIImageWriteToSavedPhotosAlbum([grabCutController getSaveImage], nil, nil, nil);
        image_changed = NO;
        [self updateView];
    }
}

- (IBAction)actionToggle:(id)sender;
{
    edit_fg = !edit_fg;
    if (edit_fg) {
        buttonToggle.title = @"FG";
    } else {
        buttonToggle.title = @"BG";
    }
}

- (IBAction)actionGrabCut:(id)sender;
{
    [self indicateActivity:YES];
    
    [self performSelectorOnMainThread:@selector(actionGrabCutIteration) withObject:nil waitUntilDone:NO];
}


- (void)actionGrabCutIteration;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [grabCutController nextIteration];
        [self performSelectorOnMainThread:@selector(grabCutDone) withObject:nil waitUntilDone:NO];
    });
}

- (void)grabCutDone;
{
    label.text = [NSString stringWithFormat:@"Iteration %d", grabCutController.iterCount];
    
    image_changed = YES;
    
    imageView.image = [grabCutController getImage];
    [self updateView];
    
    [self indicateActivity:NO];
}


- (void)updateView;
{
    if (self.editing == YES) {
        buttonEdit.style = UIBarButtonItemStyleDone;
        imageView.image = [grabCutController getImage];
    } else {
        buttonEdit.style = UIBarButtonItemStyleBordered;
        imageView.image = [grabCutController getSaveImage];
    }
    
    if (image_changed == YES) {
        buttonSave.style = UIBarButtonItemStyleDone;
    } else {
        buttonSave.style = UIBarButtonItemStyleBordered;
    }
    
    if (grabCutController.processing) {
        [self indicateActivity:YES];
    } else {
        [self indicateActivity:NO];
    }
    
    buttonToggle.enabled = self.editing;
}


#pragma mark - Gesture Recognizers

- (IBAction)handleTapGesture:(UIGestureRecognizer *)sender;
{
    if (self.editing == NO) {
        return;
    }
    
    
    CGPoint tapPoint = [sender locationInView:sender.view.superview];
    NSLog(@"tap (%f,%f)", tapPoint.x, tapPoint.y);
    NSLog(@"->  (%f,%f)", tapPoint.x*scale_x, tapPoint.y*scale_y);
    tapPoint = CGPointMake(tapPoint.x * scale_x, tapPoint.y * scale_y);
    
    
    [grabCutController maskLabel:tapPoint foreground:edit_fg];
    
    
    imageView.image = [grabCutController getImage];
}


- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
{
    if (self.editing == NO) {
        return;
    }
    
    CGPoint tapPoint = [sender locationInView:sender.view.superview];
    NSLog(@"tap (%f,%f)", tapPoint.x, tapPoint.y);
    
    tapPoint = CGPointMake(tapPoint.x * scale_x, tapPoint.y * scale_y);
    [grabCutController maskLabel:tapPoint foreground:edit_fg];
    
    imageView.image = [grabCutController getImage];
}


- (void)indicateActivity:(BOOL)active;
{
    buttonEdit.enabled = !active;
    buttonToggle.enabled = !active;
    buttonGrabCut.enabled = !active;
    buttonSave.enabled = !active;
    
    activityView.hidden = !active;
    activityIndicatorView.hidden = !active;
    activityLabel.hidden = !active;
    
    if (active) {
        [activityIndicatorView startAnimating];
    } else {
        [activityIndicatorView stopAnimating];
    }
}



@end
