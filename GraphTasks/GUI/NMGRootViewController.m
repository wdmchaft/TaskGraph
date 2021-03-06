//
//  NMGRootViewController.m
//  GraphTasks
//
//  Created by Mephi Skib on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NMGRootViewController.h"
#import "ProjectsViewController.h"
#import "AddWhateverViewController.h"
#import "ListsViewController.h"
#import "EmployersViewController.h"

CGFloat kNMGButtonHeight;
CGFloat kNMGButtonWidth;
CGFloat kNMGButtonOffset;

CGRect  kNMGFullFrame;

CGRect  kNMGTasksRect;
CGRect  kNMGTeamRect;
CGRect  kNMGContextsRect;
CGRect  kNMGSettingsRect;

@interface NMGRootViewController (Internal)

-   (void)  tasksButtonClicked;
-   (void)  teamButtonClicked;
-   (void)  contextsButtonClicked;
-   (void)  settingsButtonClicked;

@end

@implementation NMGRootViewController

+   (void)  initialize{
    if (IS_PAD()){
        
    }else{
        kNMGButtonHeight    =   54;
        kNMGButtonWidth     =   254;
        kNMGButtonOffset    =   15;
        
        kNMGFullFrame       =   CGRectMake(0, 0, 320, 480);
        
        CGRect  buttonRect  =   CGRectMake((kNMGFullFrame.size.width - kNMGButtonWidth) / 2,
                                           35,
                                           kNMGButtonWidth,
                                           kNMGButtonHeight);
        
        kNMGTasksRect       =   buttonRect;
        kNMGTeamRect        =   CGRectOffset(kNMGTasksRect, 0, kNMGButtonHeight + kNMGButtonOffset);
        kNMGContextsRect    =   CGRectOffset(kNMGTeamRect, 0, kNMGButtonHeight + kNMGButtonOffset);
        kNMGSettingsRect    =   CGRectOffset(kNMGContextsRect, 0, kNMGButtonHeight + kNMGButtonOffset);
    }
}

#pragma mark LifeCycle

-   (id)    init{
    self    =   [super  init];
    
    if (self){
        //[self.view  setBackgroundColor:NMG_BKG_COLOR];
        UIImageView*    bkg =   [[UIImageView   alloc]  initWithFrame:CGRectMake(0, -20, 320, 480)];
        [bkg    setImage:[UIImage   imageNamed:[@"nmg_bkg"  deviced]]];
        [self.view  addSubview:bkg];
        
        UIButton*   tasksButton =   [[UIButton  alloc]  initWithFrame:kNMGTasksRect];
        [tasksButton    setImages:@"nmg_main_tasks"];
        [tasksButton    addTarget:self
                           action:@selector(tasksButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view      addSubview:tasksButton];        
        
        UIButton*   teamButton  =   [[UIButton  alloc]  initWithFrame:kNMGTeamRect];
        [teamButton     setImages:@"nmg_main_team"];
        [teamButton     addTarget:self
                           action:@selector(teamButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view      addSubview:teamButton];
        
        UIButton*   contButton  =   [[UIButton  alloc]  initWithFrame:kNMGContextsRect];
        [contButton     setImages:@"nmg_main_contexts"];
        [contButton     addTarget:self
                           action:@selector(contextsButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view      addSubview:contButton];
        
        UIButton*   setButton   =   [[UIButton  alloc]  initWithFrame:kNMGSettingsRect];
        [setButton      setImages:@"nmg_main_settings"];
        [setButton      addTarget:self
                           action:@selector(settingsButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view      addSubview:setButton];
        
        [self.navigationController.navigationBar  setBarStyle:UIBarStyleBlack];
        
        [[NMTaskGraphManager sharedManager] resetSettingsToDefaults]; 
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark    -   Logic

-   (void)  tasksButtonClicked{
    
    ListsViewController* LstVC = [[ListsViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    [LstVC setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Проекты" image:nil tag:0]];
    
//    UIViewController* VASILENKO_VIEW_CONTROLLER = [UIViewController new];
//    [VASILENKO_VIEW_CONTROLLER setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Графы" image:nil tag:0]];
    
//    UITabBarController* tvc = [[UITabBarController alloc]init];
//    [tvc setViewControllers:[NSArray arrayWithObjects:LstVC, VASILENKO_VIEW_CONTROLLER, nil]];

    
    [self.navigationController pushViewController:LstVC animated:YES];
    
}

-   (void)  teamButtonClicked{
    EmployersViewController *vc = [[EmployersViewController alloc] initWithStyle: UITableViewStylePlain];
    [self.navigationController  pushViewController:vc animated:YES];
}

-   (void)  contextsButtonClicked{
    //
}

-   (void)  settingsButtonClicked{
    //
}







@end
