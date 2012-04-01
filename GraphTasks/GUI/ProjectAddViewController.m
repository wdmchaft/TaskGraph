//
//  ProjectAddViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectAddViewController.h"
#import "ProjectsExtraSettingsViewController.h"
#import "NMTGProject.h"

@interface ProjectAddViewController ()

@end


@implementation ProjectAddViewController

@synthesize parentProject = _parentProject;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _context = [[NMTaskGraphManager sharedManager]managedContext];        
        _newProject = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        [_context insertObject:_newProject];
        
        
        _scrollView = [[UIScrollView alloc]initWithFrame: CGRectMake(0,0,320,480)];
        
        [_scrollView setCanCancelContentTouches:NO];
        _scrollView.clipsToBounds = YES;	
        _scrollView.scrollEnabled = YES;
        _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        _scrollView.contentSize = CGSizeMake(320,500);
        [self.view addSubview:_scrollView];        
        
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        self.navigationItem.leftBarButtonItem = cancel;
        [self.navigationItem setTitle:@"new Project"];
        

        UILabel* labelName = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 60, 15)];
        labelName.text = @"Name:";
        [_scrollView addSubview:labelName];
        
        
//        _textFieldNameOfProject = [[UITextField alloc]initWithFrame:CGRectMake(20, 30, 280, 25)];
        //        _textFieldNameOfProject.placeholder = @"<enter new project's name>";
        
        _textFieldNameOfProject = [[UITextField alloc]initWithFrame:CGRectMake(75, 10, 230, 25)];
        _textFieldNameOfProject.borderStyle = UITextBorderStyleRoundedRect;
        _textFieldNameOfProject.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textFieldNameOfProject.returnKeyType =  UIReturnKeyDefault;
        _textFieldNameOfProject.delegate = self;
        _textFieldNameOfProject.backgroundColor = [UIColor colorWithRed:0.0 green:0.888 blue:0.999 alpha:1.0];
        _textFieldNameOfProject.textColor = [UIColor yellowColor];
        //        [_textFieldNameOfProject becomeFirstResponder];
        [_scrollView addSubview:_textFieldNameOfProject];
        
        
        UILabel* labelDatePicker1 = [[UILabel alloc]initWithFrame:CGRectMake(15, _textFieldNameOfProject.frame.size.height + 10,280,35)];
        labelDatePicker1.text = @"First alert date: ";

        [_scrollView addSubview:labelDatePicker1];
        
        
        
        _datePickerAlert1 = [[UIDatePicker alloc]initWithFrame:CGRectZero];
        _datePickerAlert1.datePickerMode = UIDatePickerModeDateAndTime;
        CGSize pickerSize = [_datePickerAlert1 sizeThatFits:CGSizeZero];
        _datePickerAlert1.frame = CGRectMake(0, labelDatePicker1.frame.size.height + 30, pickerSize.width, pickerSize.height); 
//        [_datePickerAlert1 addTarget:self 
//                              action:@selector(datePickerChanged:)
//                    forControlEvents:UIControlEventValueChanged]; 
        [_scrollView addSubview: _datePickerAlert1];
        
        
        
        UILabel* labelExtraSettings = [[UILabel alloc]initWithFrame:CGRectMake(40, _datePickerAlert1.frame.size.height + 65,280,35)];
        labelExtraSettings.text = @"Additional settings: ";
        [_scrollView addSubview:labelExtraSettings];
        
        
        _tableViewExtraSettings = [[UITableView alloc]initWithFrame:CGRectMake(0,_datePickerAlert1.frame.size.height + 95,320,110) style:UITableViewStyleGrouped];
        _tableViewExtraSettings.delegate = self;
        _tableViewExtraSettings.dataSource = self;
        [_scrollView addSubview:_tableViewExtraSettings];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ProjectExtraSettingsViewControllerDidAddComment:) name:@"exTraCommentAdded" object:nil];
    
    return self;
}



-(void)save{
    if(( [_textFieldNameOfProject.text isEqualToString:@""]) ||
        !(_textFieldNameOfProject.text)){
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Enter Project's name" 
                                                      message: @"Don't forget to name your project"
                                                     delegate: self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    else{
        _newProject.title = [_textFieldNameOfProject.text copy];
        _newProject.alertDate_first = _datePickerAlert1.date;

        if(_parentProject != nil){
            [_parentProject addSubProjectObject:_newProject];
            _newProject.parentProject = _parentProject;
        }
        NSError* error = nil;
            if(! ([_context save:&error ]) ){
            NSLog(@"Failed to save contwxt in ProjectAddVC in 'save'");
        }
    }
    
    
//    if(_senderType == ProjectAddViewControllerSenderProjectsVC){
    if(senderIsProjectsVC == NO){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                       object:nil];
    }
//    else if(_senderType == ProjectAddViewControllerSenderProjectOrTaskAddVC){
    else {
        [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                  object:nil];
    }
}

-(void)cancel{
    [_context deleteObject:_newProject];
    
    NSError* error = nil;
    if(! ([_context save:&error ]) ){
        NSLog(@"Couldn't save the context in ProjectAddViewController");
    }
    
    
//    if(_senderType == ProjectAddViewControllerSenderProjectsVC){
    if (senderIsProjectsVC == NO){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                           object:nil];
    }
//    else if(_senderType == ProjectAddViewControllerSenderProjectOrTaskAddVC){
    else {
        [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                  object:nil];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _textFieldNameOfProject){
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = save;
        [textField resignFirstResponder];    
    }
    return YES;
}


-(void)ProjectExtraSettingsViewControllerDidAddComment:(NSNotification*)obj{
    _newProject.comment = obj.object;
}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
                                                                        
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableViewExtraSettingsCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; 
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(indexPath.row == 0) [[cell textLabel] setText: @"Project's Comment"];
    else if(indexPath.row == 1) [[cell textLabel] setText:@"Project's 2nd Alert Date"];

    return cell;
}
                                                                        
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}                                                                        
                                                                        
                                                                        
                
-(void)  tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectsExtraSettingsViewController* extraVC = [[ProjectsExtraSettingsViewController alloc]init];
    if(indexPath.row == 0){
//        extraVC->extraSettingType = ExtraSettingComment;
        extraVC->extraSettingTypeIsComment=YES;
    }
    else if(indexPath.row ==1) {
//        extraVC->extraSettingType = ExtraSettingAlertDateSecond;
        extraVC->extraSettingTypeIsComment=NO;
    }
    
    [self.navigationController  pushViewController:extraVC animated:YES];
}









- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation==UIInterfaceOrientationPortrait);
}

@end
