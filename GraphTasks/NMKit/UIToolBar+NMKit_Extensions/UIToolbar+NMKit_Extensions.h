//
//  UIToolbar+NMKit_Extensions.h
//  iCurrency_Lite
//
//  Created by Konev Vladimir on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (NMKit_Extensions)

-   (void)  addBarButtonItem:(UIBarButtonItem*)item;
-   (void)  addBarButtonItem:(UIBarButtonItem *)item
                    animated:(BOOL)animated;

-   (void)  insertBarButtonItem:(UIBarButtonItem*)item
                        atIndex:(NSUInteger)index;
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                        atIndex:(NSUInteger)index
                       animated:(BOOL)animated;

-   (void)  insertBarButtonItem:(UIBarButtonItem*)item
                     beforeItem:(UIBarButtonItem*)beforeItem;
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                     beforeItem:(UIBarButtonItem *)beforeItem
                       animated:(BOOL)animated;

-   (void)  insertBarButtonItem:(UIBarButtonItem*)item
                      afterItem:(UIBarButtonItem*)afterItem;
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                      afterItem:(UIBarButtonItem *)afterItem
                       animated:(BOOL)animated;

-   (void)  removeBarButtonItem:(UIBarButtonItem*)item;
-   (void)  removeBarButtonItem:(UIBarButtonItem *)item
                       animated:(BOOL)animated;

-   (void)  removeBarButtonItemAtIndex:(NSUInteger)index;
-   (void)  removeBarButtonItemAtIndex:(NSUInteger)index
                       animated:(BOOL)animated;

@end
