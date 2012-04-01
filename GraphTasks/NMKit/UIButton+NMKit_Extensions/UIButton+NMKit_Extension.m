//
//  UIButton+NMKit_Extension.m
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//

#import "UIButton+NMKit_Extension.h"
#import "NSString+NMKit_Extenstion.h"

@implementation UIButton (NMKit_Extension)

-   (void)  setImages:(NSString *)baseName{
    [self   setImage:[UIImage   imageNamed:[baseName    statedImageName:UIControlStateNormal]]
            forState:UIControlStateNormal];
    
    [self   setImage:[UIImage   imageNamed:[baseName    statedImageName:UIControlStateHighlighted]]
            forState:UIControlStateHighlighted];
    
    [self   setImage:[UIImage   imageNamed:[baseName    statedImageName:UIControlStateDisabled]]
            forState:UIControlStateDisabled];
    
    [self   setImage:[UIImage   imageNamed:[baseName    statedImageName:UIControlStateSelected]]
            forState:UIControlStateSelected];
}

@end
