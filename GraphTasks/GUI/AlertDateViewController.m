//
//  AlertDateViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertDateViewController.h"



/*
 //
 // Данный контроллер вызывается для задания дат напоминаний пользователю о задании. 
 //
 */




@interface AlertDateViewController(internal)
    -(void)save;
    -(void)cancel;
@end

@implementation AlertDateViewController

@synthesize delegate = _delegate,
            defaultDate = _defaultDate,
            isLaunchedForAlertDateFirst = _isLaunchedForAlertDateFirst;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        self.navigationItem.rightBarButtonItem = save;
        self.navigationItem.leftBarButtonItem = cancel;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _datePickerAlert = [[UIDatePicker alloc]initWithFrame:CGRectZero];
    _datePickerAlert.datePickerMode = UIDatePickerModeDate;
    CGSize pickerSize = [_datePickerAlert sizeThatFits:CGSizeZero];
    _datePickerAlert.frame = CGRectMake(0, 200, pickerSize.width, pickerSize.height);
    [self.view addSubview: _datePickerAlert];
    
    if(self.isLaunchedForAlertDateFirst){
        [self.navigationItem setTitle:@"Первое напоминание"];
    } else {
        [self.navigationItem setTitle:@"Второе напоминание"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _datePickerAlert.date = _defaultDate;
}

-(void)save
{
    NSDate* date = _datePickerAlert.date;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    
    [components setYear:0];
    [components setMonth:0];
    [components setDay:0];  
    [components setHour:-1*components.hour];
    [components setMinute:-1*components.minute];
    [components setSecond:-1*components.second];
    
    NSDate *dateToSet = [calendar dateByAddingComponents:components toDate:date options:0];
    
    (self.isLaunchedForAlertDateFirst) ? ([_delegate setTasksAlertDateFirst:dateToSet])
                                       : ([_delegate setTasksAlertDateSecond:dateToSet]);
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
