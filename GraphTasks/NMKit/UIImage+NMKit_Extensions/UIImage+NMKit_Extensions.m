//
//  UIImage+NMKit_Extensions.m
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//

#import "UIImage+NMKit_Extensions.h"

@implementation UIImage (NMKit_Extensions)

-   (UIImage*)  scaledImageToSize:(CGSize)targetSize{
    CGFloat sWidth  =   self.size.width;
    CGFloat rWidth  =   targetSize.width    /   sWidth;
    CGFloat sHeight =   self.size.height;
    CGFloat rHeight =   targetSize.height   /   sHeight;
    
    CGFloat rate    =  MIN(rWidth, rHeight);
    
    return [self    scaledImageWithFactor:rate];
}
-   (UIImage*)  scaledImageWithFactor:(CGFloat)scaleFactor{
    CGSize  newSize =   CGSizeMake(self.size.width  *   scaleFactor,
                                   self.size.height *   scaleFactor);
    UIGraphicsBeginImageContext(newSize);
    [self   drawInRect:CGRectMake(0.0,
                                  0.0,
                                  newSize.width,
                                  newSize.height)];
    UIImage*    result  =   UIGraphicsGetImageFromCurrentImageContext();
    
    return result;
}

@end
