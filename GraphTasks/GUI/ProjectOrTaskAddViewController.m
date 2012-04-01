//
//  ProjectOrTaskAddViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectOrTaskAddViewController.h"
#import "ProjectAddViewController.h"
#import "ProjectsViewController.h"
#import "NMTGTask.h"

@interface ProjectOrTaskAddViewController ()

@end

@implementation ProjectOrTaskAddViewController

@synthesize parentProject=_parentProject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _context = [[NMTaskGraphManager sharedManager]managedContext];
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc]initWithFrame: CGRectMake(0,0,320,480)];

    [_scrollView setCanCancelContentTouches:NO];
    _scrollView.clipsToBounds = YES;	
    _scrollView.scrollEnabled = YES;
    
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _scrollView.contentSize = CGSizeMake(320,710);
    [self.view addSubview:_scrollView];
    
    UILabel* label = [[UILabel alloc]initWithFrame: CGRectMake(95,5,160,15)];
    label.text = @"Choose an item :";
    [_scrollView addSubview:label];
    
    _segmentedControlProjectOrTask = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"SubProject",@"Task", nil]]; 
    [_segmentedControlProjectOrTask addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [_segmentedControlProjectOrTask setFrame:CGRectMake(20,30, 280, 30)];
    [_segmentedControlProjectOrTask setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    [_scrollView addSubview:_segmentedControlProjectOrTask];
    
    [self.navigationItem setTitle:@"new Project/Task"];
    
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];

    self.navigationItem.leftBarButtonItem = cancel;
    
}


-(void)segmentChanged:(id)sender{
    if(sender==_segmentedControlProjectOrTask){
        if([_segmentedControlProjectOrTask selectedSegmentIndex]==0){
            ProjectAddViewController* vc = [[ProjectAddViewController alloc]init];
            
//            vc->_senderType = ProjectAddViewControllerSenderProjectOrTaskAddVC;
            vc->senderIsProjectsVC = NO;
            
            vc.parentProject = self.parentProject;
            
            UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentModalViewController:nvc animated:YES];
        }
        else if([_segmentedControlProjectOrTask selectedSegmentIndex]==1){
            [self.navigationItem setTitle:@"new Task"];
            
            UILabel* label3 = [[UILabel alloc]initWithFrame:CGRectMake(70,75,200,20)];
            label3.text = @"Task of a specific type";
            label3.font = [UIFont systemFontOfSize:15];
            [_scrollView addSubview:label3];
            
            _switchIsSpecialTask = [[UISwitch alloc]initWithFrame: CGRectMake(225,75,50,30)];
            _switchIsSpecialTask.on = NO;
            [_switchIsSpecialTask addTarget:self 
                                     action:@selector(switchValueChanged:) 
                           forControlEvents: UIControlEventValueChanged] ;
            [_scrollView addSubview:_switchIsSpecialTask];
            
            
            
            
            labelName = [[UILabel alloc]init];

            _textFieldNameOfTask = [[UITextField alloc]init];
            labelDatePicker1 = [[UILabel alloc]init];
            _datePickerAlert1 = [[UIDatePicker alloc]initWithFrame:CGRectZero];
            labelExtraSettings = [[UILabel alloc]init];
            _tableViewExtraSettings = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            _tableViewExtraSettings.delegate = self;
            _tableViewExtraSettings.dataSource = self;
            [self setUpMovableGUI:100];
        }
    }
}




-(void)setUpMovableGUI:(int)offset {
    labelName.frame = CGRectMake(15, offset + 15, 60, 15);
    labelName.text = @"Name:";
    [_scrollView addSubview:labelName];
    
    
    _textFieldNameOfTask.frame = CGRectMake(75, offset + 10, 230, 25);
    _textFieldNameOfTask.borderStyle = UITextBorderStyleRoundedRect;
    _textFieldNameOfTask.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textFieldNameOfTask.returnKeyType =  UIReturnKeyDefault;
    _textFieldNameOfTask.delegate = self;
    _textFieldNameOfTask.backgroundColor = [UIColor colorWithRed:0.0 green:0.888 blue:0.999 alpha:1.0];
    _textFieldNameOfTask.textColor = [UIColor yellowColor];
    [_scrollView addSubview:_textFieldNameOfTask];
    
    
    labelDatePicker1.frame = CGRectMake(15, _textFieldNameOfTask.frame.size.height + offset + 10,280,35);
    labelDatePicker1.text = @"First alert date: ";
    
    [_scrollView addSubview:labelDatePicker1];
    
    
    _datePickerAlert1.datePickerMode = UIDatePickerModeDateAndTime;
    CGSize pickerSize = [_datePickerAlert1 sizeThatFits:CGSizeZero];
    _datePickerAlert1.frame = CGRectMake(0, labelDatePicker1.frame.size.height + offset + 30, pickerSize.width, pickerSize.height); 
    [_scrollView addSubview: _datePickerAlert1];
    
    
    
    labelExtraSettings.frame = CGRectMake(40, _datePickerAlert1.frame.size.height + offset + 65,280,35);
    labelExtraSettings.text = @"Additional settings: ";
    [_scrollView addSubview:labelExtraSettings];
    
    
    _tableViewExtraSettings.frame = CGRectMake(0,_datePickerAlert1.frame.size.height + offset + 95,320,110);
    [_scrollView addSubview:_tableViewExtraSettings];
}


-(void)switchValueChanged:(id)sender{
    if(sender==_switchIsSpecialTask){
        if(_switchIsSpecialTask.on == YES){
            _labelTaskType = [[UILabel alloc]initWithFrame: CGRectMake(90,120,170,20)];
            _labelTaskType.text = @"Choose Task Type: ";
            _labelTaskType.font = [UIFont systemFontOfSize:15];
            [_scrollView addSubview:_labelTaskType];
            
            
            _segmentedControlTaskType = [[UISegmentedControl alloc]initWithItems:
                [NSArray arrayWithObjects:[UIImage imageNamed:@"call_mini.png"],
                                          [UIImage imageNamed:@"sms_mini.png"],
                                          [UIImage imageNamed:@"mail_mini.png"],
                                          [UIImage imageNamed:@"map_mini.png"],nil]];
            [_segmentedControlTaskType setFrame:CGRectMake(10,140,300,77)];
            [_scrollView addSubview:_segmentedControlTaskType];
            [self setUpMovableGUI:230];
        }
        else{
            [_labelTaskType setFrame: CGRectMake(-1000,120,170,20)];
            [_segmentedControlTaskType setFrame:CGRectMake(-1000,140,300,77)];
            [self setUpMovableGUI:100];
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _textFieldNameOfTask){
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
        self.navigationItem.rightBarButtonItem = save;
        [textField resignFirstResponder];    
    }
    return YES;
}


-(void)cancel{
    [[NSNotificationCenter defaultCenter]postNotification:
            [NSNotification notificationWithName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                        object:nil]];
}

-(void)save{
    if(( [_textFieldNameOfTask.text isEqualToString:@""]) ||
       !(_textFieldNameOfTask.text)){
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Enter Task's name" 
                                                       message:@"Don't forget to name your task"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    else{
//        NSLog(@"%@",_parentProject);
        NMTGTask* _newTask = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        _newTask.title = [_textFieldNameOfTask.text copy];
        _newTask.alertDate_first = _datePickerAlert1.date;
        
        [_parentProject addSubProjectObject:_newTask];
        _newTask.parentProject = _parentProject;
        
        NSError* error = nil;
        if(! ([_context save:&error ]) ){
            NSLog(@"Failed to save context in ProjectOrTaskAddVC in 'save'");
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
         object:nil];
    }
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
