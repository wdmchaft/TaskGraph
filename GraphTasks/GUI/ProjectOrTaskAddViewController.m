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
    _scrollView.contentSize = CGSizeMake(320,700);
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
            UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
            self.navigationItem.rightBarButtonItem = save;
            
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
            
            
        }
    }
}


-(void)switchValueChanged:(id)sender{
    if(sender==_switchIsSpecialTask){
        if(_switchIsSpecialTask.on == YES){
            UILabel* label2 = [[UILabel alloc]initWithFrame: CGRectMake(90,120,170,20)];
            label2.text = @"Choose Task Type: ";
            label2.font = [UIFont systemFontOfSize:15];
            [_scrollView addSubview:label2];
            
            
            _segmentedControlTaskType = [[UISegmentedControl alloc]initWithItems:
                [NSArray arrayWithObjects:[UIImage imageNamed:@"call_mini.png"],
                                          [UIImage imageNamed:@"sms_mini.png"],
                                          [UIImage imageNamed:@"mail_mini.png"],
                                          [UIImage imageNamed:@"map_mini.png"],nil]];
            [_segmentedControlTaskType setFrame:CGRectMake(10,140,300,77)];
            [_scrollView addSubview:_segmentedControlTaskType];
        }
    }
}

-(void)cancel{
    [[NSNotificationCenter defaultCenter]postNotification:
            [NSNotification notificationWithName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                        object:nil]];
}

-(void)save{
    //
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
