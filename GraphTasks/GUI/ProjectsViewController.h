//
//  ProjectsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskViewController.h"
@class NMTGProject;

@interface ProjectsViewController : UITableViewController<SetProjectsProperties>{
    NSArray* _tableDataSource;
    NSManagedObjectContext* _context;
    NMTGProject* _selectedProject;
    BOOL _shouldPushEmidiately;
}

@property(nonatomic,retain) NMTGProject* selectedProject;
@property(nonatomic,      ) BOOL shouldPushEmidiately;

-(void)addNewProject:(NMTGProject*) newProject;
-(void)reloadData;
-(void)ProjectAddViewControllerDidAddProject;
@end
