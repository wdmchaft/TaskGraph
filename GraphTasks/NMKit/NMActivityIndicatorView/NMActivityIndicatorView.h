//
//  SKActivityIndicatorView.h
//  seeker-client
//
//  Created by Владимир Конев on 10.05.11.
//  Copyright 2011 МИФИ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NMActivityIndicatorView : UIView {
    UIActivityIndicatorView*    _activityIndicator;
    UILabel*                    _activityLabel;
    
    BOOL                        _hidesWhenStopped;
}

@property(nonatomic,
          assign,
          setter = setActivityIndicatorViewStyle:,
          getter = activityIndicatorViewStyle)    UIActivityIndicatorViewStyle    activityIndicatorViewStyle;

@property(nonatomic,
          copy,
          setter = setActivityIndicatorViewText:,
          getter = activityIndicatorViewText)     NSString*                       activityIndicatorViewText;

@property(nonatomic,
          assign,
          setter = setHidesWhenStopped:,
          getter = isHidesWhenStopped)            BOOL                            hidesWhenStopped;

-   (void)  start;
-   (void)  stop;

@end
