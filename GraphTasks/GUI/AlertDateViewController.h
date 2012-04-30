//
//  AlertDateViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPropertiesViewController.h"

@interface AlertDateViewController : UIViewController<UITabBarDelegate,UITableViewDataSource>
{
    UIDatePicker* _datePickerAlert;
    NSDate* _defaultDate;
    id<SetNewTasksProperties> _delegate;
    
    BOOL _isLaunchedForAlertDateFirst;
}

@property(nonatomic,retain) id<SetNewTasksProperties> delegate;
@property(nonatomic       ) BOOL isLaunchedForAlertDateFirst;
@property(nonatomic,retain) NSDate* defaultDate;

@end