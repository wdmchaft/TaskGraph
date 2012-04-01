//
//  NMKitDefines.h
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef  UI_USER_INTERFACE_IDIOM
    #define IS_PAD()    (UI_USER_INTERFACE_IDIOM()  ==  UIUserInterfaceIdiomPad)
#else
    #define IS_PAD()    NO
#endif

#define IS_PORTRAIT()   UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
#define IS_LANDSCAPE()  !IS_PORTRAIT()

#define IS_PORTRAIT_(_orientation_)   UIInterfaceOrientationIsPortrait(_orientation_)
#define IS_LANDSCAPE_(_orientation_)  !IS_PORTRAIT_(_orientation_)

#define DOCUMENTS_PATH  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)  lastObject]
