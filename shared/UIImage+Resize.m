// UIImage+Resize.m

#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"

@implementation UIImage (Resize)


// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds {
	float hfactor = self.size.width / bounds.width;
	float vfactor = self.size.height / bounds.height;
	
	float factor = fmax(hfactor, vfactor);
	
	// Divide the size by the greater of the vertical or horizontal shrinkage factor
	float newWidth = self.size.width / factor;
	float newHeight = self.size.height / factor;
	
	// Then figure out if you need to offset it to center vertically or horizontally
	float leftOffset = (bounds.width - newWidth) / 2;
	float topOffset = (bounds.height - newHeight) / 2;
	
	CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	
	UIGraphicsBeginImageContext(bounds);
	[self drawInRect:newRect blendMode:kCGBlendModePlusDarker alpha:1];
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [result transparentBorderImage:1];
}


@end
