//
//  NMActivityIndicatorView.m
//
//  Created by Konev Vladimir. Novilab-Mobile, LLC 2011
//

#import "NMActivityIndicatorView.h"


@interface NMActivityIndicatorView (PrivateMethods)

-   (void)  setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle;
-   (UIActivityIndicatorViewStyle)  activityIndicatorViewStyle;

-   (void)  setActivityIndicatorViewText:(NSString*)activityIndicatorViewText;
-   (NSString*) activityIndicatorViewText;

-   (void)  setHidesWhenStopped:(BOOL)hidesWhenStopped;
-   (BOOL)  isHidesWhenStopped;

@end

@implementation NMActivityIndicatorView
@synthesize hidesWhenStopped    =   _hidesWhenStopped;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self   setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
        
        _activityIndicator  =   [[UIActivityIndicatorView    alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicator setFrame:CGRectMake(frame.size.width / 2 - 15.0, frame.size.height / 2 - 15.0, 30.0, 30.0)];
        [self   addSubview:_activityIndicator];
        
        _activityLabel      =   [[UILabel    alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 60.0, frame.size.height / 2 + 30.0, 120.0, 25.0)];
        [_activityLabel     setBackgroundColor:[UIColor clearColor]];
        [_activityLabel     setTextColor:[UIColor       whiteColor]];
        [_activityLabel     setTextAlignment:UITextAlignmentCenter];
        [_activityLabel     setShadowColor:[UIColor     blackColor]];
        [_activityLabel     setShadowOffset:CGSizeMake(0.0, -1.0)];
        [_activityLabel     setFont:[UIFont boldSystemFontOfSize:18.0]];
        [self   addSubview:_activityLabel];
    }
    return self;
}

#pragma mark    -   Private methods for properties
-   (void)  setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle{
    [_activityIndicator setActivityIndicatorViewStyle:activityIndicatorViewStyle];
}

-   (UIActivityIndicatorViewStyle)activityIndicatorViewStyle{
    return [_activityIndicator  activityIndicatorViewStyle];
}

-   (void)  setActivityIndicatorViewText:(NSString *)activityIndicatorViewText{
    [_activityLabel setText:activityIndicatorViewText];
}

-   (NSString*) activityIndicatorViewText{
    return [_activityLabel  text];
}

-   (void)  setHidesWhenStopped:(BOOL)hidesWhenStopped{
    _hidesWhenStopped   =   hidesWhenStopped;
    
    if (_hidesWhenStopped)
        [self   setHidden:YES];
}

-   (BOOL)  isHidesWhenStopped{
    return _hidesWhenStopped;
}

-   (void)start{
    [self   setHidden:NO];
    [_activityIndicator startAnimating];
}

-   (void)  stop{
    [_activityIndicator stopAnimating];
    if (_hidesWhenStopped)
        [self   setHidden:YES];
}


@end
