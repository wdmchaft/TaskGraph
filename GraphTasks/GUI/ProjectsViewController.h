//
//  ProjectsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NMTGProject;

@interface ProjectsViewController : UITableViewController{
    NSArray* _fetchedProjects;
    NSManagedObjectContext* _context;
                                                                
                                                
}
-(void)addNewProject:(NMTGProject*) newProject;
-(void)reloadData;
-(void)ProjectAddViewControllerDidAddProject;
@end
