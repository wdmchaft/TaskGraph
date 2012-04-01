//
//  ProjectsExtraSettingsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 31.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectsExtraSettingsViewController.h"

@interface ProjectsExtraSettingsViewController ()

@end

@implementation ProjectsExtraSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        self.navigationItem.rightBarButtonItem = save;
        self.navigationItem.leftBarButtonItem = cancel;
        [self.navigationItem setTitle:@"Extra Settings"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if(self->extraSettingType == ExtraSettingComment){
    if(self->extraSettingTypeIsComment){
        NSLog(@"ExtraSettingTypeComment");
    
        _textViewComment = [[UITextView alloc]initWithFrame:CGRectMake(20, 50, 280, 100)];
        _textViewComment.returnKeyType =  UIReturnKeyDefault;
        _textViewComment.delegate = self;
        _textViewComment.backgroundColor = [UIColor colorWithRed:0.0 green:0.888 blue:0.999 alpha:1.0];
        _textViewComment.textColor = [UIColor yellowColor];
        [self.view addSubview:_textViewComment];
        
        UILabel* labelComment = [[UILabel alloc]initWithFrame:CGRectMake(40, 30, 240, 15)];
        labelComment.text = @"Comment: ";
        [self.view addSubview:labelComment];
    }
    
    else{
        NSLog(@"ExtraSettingTypeAlertDateSecond");
        _datePickerAlert2 = [[UIDatePicker alloc]initWithFrame:CGRectZero];
        _datePickerAlert2.datePickerMode = UIDatePickerModeDateAndTime;
        CGSize pickerSize = [_datePickerAlert2 sizeThatFits:CGSizeZero];
        _datePickerAlert2.frame = CGRectMake(0, 220, pickerSize.width, pickerSize.height); 
        [_datePickerAlert2 addTarget:self 
                              action:@selector(datePickerChanged:)
                    forControlEvents:UIControlEventValueChanged]; 
        [self.view addSubview: _datePickerAlert2];
    }
}


-(void)save{
    if(self->extraSettingTypeIsComment){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"exTraCommentAdded" 
                                                           object:[_textViewComment.text copy]];
    }
    else{
//        self.parentViewController->_newProject.alertDate_second = _datePickerAlert2.date;
    }
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)cancel{
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
