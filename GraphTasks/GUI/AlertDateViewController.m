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

@synthesize superVC = _superVC,
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
        [self.navigationItem setTitle:@"Дата первого напоминания"];
    } else {
        [self.navigationItem setTitle:@"Дата второго напоминания"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.isLaunchedForAlertDateFirst){
        _datePickerAlert.date = self.superVC.projectAlertDateFirst;
    } else {
        _datePickerAlert.date = self.superVC.projectAlertDateSecond;
    }
}

-(void)save
{
    if(self.isLaunchedForAlertDateFirst){
        self.superVC.projectAlertDateFirst = _datePickerAlert.date;
        if([self.superVC.projectAlertDateFirst compare:self.superVC.projectAlertDateSecond] == NSOrderedDescending){ 
            //значит 1ое напоминание позже 2ого. смещаем 2ое на два дня вперед с момента нового 1ого 
            self.superVC.projectAlertDateSecond = [NSDate dateWithTimeInterval:2*86400 sinceDate:_datePickerAlert.date];
        }
    } else {
        self.superVC.projectAlertDateSecond = _datePickerAlert.date;
        if([self.superVC.projectAlertDateFirst compare:self.superVC.projectAlertDateSecond] == NSOrderedDescending){ 
            //значит 1ое напоминание позже 2ого. смещаем 1ое на два дня назад с момента нового 2ого 
            self.superVC.projectAlertDateFirst = [NSDate dateWithTimeInterval:-2*86400 sinceDate:_datePickerAlert.date];
        }
    }
    [self.superVC.tableView reloadData];
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
