//
//  UIToolbar+NMKit_Extensions.m
//  iCurrency_Lite
//
//  Created by Konev Vladimir on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIToolbar+NMKit_Extensions.h"

#define COUNT   [[self items] count]

@implementation UIToolbar (NMKit_Extensions)

//INSERT AT INDEX
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                        atIndex:(NSUInteger)index
                       animated:(BOOL)animated{
    NSMutableArray* currentItems    =   [NSMutableArray arrayWithArray:[self    items]];
    
    index   =   (index  <   COUNT)  ?   index   :  COUNT;
    
    [currentItems   insertObject:item
                         atIndex:index];
    
    [self   setItems:currentItems
            animated:animated];
}
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item atIndex:(NSUInteger)index{
    [self   insertBarButtonItem:item
                        atIndex:index
                       animated:NO];
}

//ADD
-   (void)  addBarButtonItem:(UIBarButtonItem *)item 
                    animated:(BOOL)animated{
    [self   insertBarButtonItem:item
                        atIndex:COUNT
                       animated:animated];
}
-   (void)  addBarButtonItem:(UIBarButtonItem *)item{
    [self   addBarButtonItem:item
                    animated:NO];
}

//INSERT BEFORE
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                     beforeItem:(UIBarButtonItem *)beforeItem
                       animated:(BOOL)animated{
    NSUInteger  index   =   [[self  items]  indexOfObject:beforeItem];
    if (index   ==  NSNotFound)
        index   =   0;
    
    [self   insertBarButtonItem:item
                        atIndex:index
                       animated:animated];
}
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item
                     beforeItem:(UIBarButtonItem *)beforeItem{
    [self   insertBarButtonItem:item
                     beforeItem:beforeItem
                       animated:NO];
}

//INSERT AFTER
-   (void)  insertBarButtonItem:(UIBarButtonItem *)item 
                      afterItem:(UIBarButtonItem *)afterItem 
                       animated:(BOOL)animated{
    NSUInteger  index   =   [[self  items]  indexOfObject:afterItem];
    if (index   ==  NSNotFound)
        index   =   COUNT - 1;
    
    [self   insertBarButtonItem:item
                        atIndex:index + 1
                       animated:animated]; 
}

-   (void)  insertBarButtonItem:(UIBarButtonItem *)item 
                      afterItem:(UIBarButtonItem *)afterItem{
    [self   insertBarButtonItem:item
                      afterItem:afterItem
                       animated:NO];
}

//REMOVE AT INDEX
-   (void)  removeBarButtonItemAtIndex:(NSUInteger)index animated:(BOOL)animated{
    if (index   <   COUNT){
        NSMutableArray* currentItmes    =   [NSMutableArray arrayWithArray:[self    items]];
        [currentItmes   removeObjectAtIndex:index];
        [self           setItems:currentItmes
                        animated:animated];
    }
}

-   (void)  removeBarButtonItemAtIndex:(NSUInteger)index{
    [self   removeBarButtonItemAtIndex:index
                              animated:NO];
}

//REMOVE
-   (void)  removeBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated{
    NSUInteger  index   =   [[self  items]  indexOfObject:item];
    if (index   !=  NSNotFound)
        [self   removeBarButtonItemAtIndex:index
                                  animated:animated];
}
-   (void)  removeBarButtonItem:(UIBarButtonItem *)item{
    [self   removeBarButtonItem:item
                       animated:NO];
}



@end
