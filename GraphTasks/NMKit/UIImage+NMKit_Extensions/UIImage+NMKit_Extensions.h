//
//  UIImage+NMKit_Extensions.h
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NMKit_Extensions)

/*
 Return scaled image, by multiplying image width and height on scaleFactor
 */
-   (UIImage*)  scaledImageWithFactor:(CGFloat)scaleFactor;

/*
 Return scaled image, that fill targetSize ascpeting fit
 */
-   (UIImage*)  scaledImageToSize:(CGSize)targetSize;

@end
