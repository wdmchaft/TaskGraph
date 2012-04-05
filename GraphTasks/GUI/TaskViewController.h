//
//  TaskViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMTGProject.h"

@interface TaskViewController : UITableViewController{
    NSManagedObjectContext* _context;
    NSMutableArray* _fetchedProjectsOrTasks;
    NMTGProject* _parentProject;
}

@property(nonatomic,retain)NMTGProject* parentProject;

-(void) addNewProjectOrTask;
-(void) reloadData;
-(void) projectOrTaskAddViewControllerDidAddProjectOrTask;

@end

