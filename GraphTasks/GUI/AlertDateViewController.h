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
    AddPropertiesViewController* _superVC;//В этот контроллер из текущего будут выставляться даты напоминаний.        
                                         //Когда superVC выполнит push в текущий контроллер, он уставновит 
                                         //значение superVC в self
    
    BOOL _isLaunchedForAlertDateFirst;
}

@property(nonatomic,retain) AddPropertiesViewController* superVC;
@property(nonatomic) BOOL isLaunchedForAlertDateFirst;

@end