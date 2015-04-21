//
//  ImagePickerController.h
//  IntroCamera
//
//  Created by Eduard Feicho on 13.04.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImagePickerController : NSObject
{
	BOOL imagePickerShown;
	UIImagePickerControllerSourceType sourceType;
}

@property (nonatomic, assign) id<UINavigationControllerDelegate,UIImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) BOOL imagePickerShown;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;


- (id)initAsCamera;
- (id)initAsPhotoLibrary;

- (void)showPicker:(UIViewController*)parent;
- (void)hidePicker:(UIViewController*)viewController;

@end
