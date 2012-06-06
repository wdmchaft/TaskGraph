//
//  TaskViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMTGProject.h"

@protocol SetProjectsProperties <NSObject>
-(void) setProjectsName: (NSString*)name;

@end

@interface TaskViewController : UITableViewController<SetProjectsProperties>{
    NSManagedObjectContext* _context;
    NSMutableArray* _fetchedProjectsOrTasks;
    NMTGProject* _parentProject;
    UIBarButtonItem* _plusOrSettingsButtonItem;
    NMTGProject* _projectToRename;
}

@property(nonatomic,retain)NMTGProject* parentProject;

-(void) addNewProjectOrTask;
-(void) reloadData;
-(void) projectOrTaskAddViewControllerDidAddProjectOrTask;
-(BOOL) checkProjectIsDone:(NMTGProject*) aProject;
-(void) changeParentProjectsSettings;
-(void) hide;
-(NSArray *) checkCompeletencyState:(NMTGProject *)project;
-(void) setProjectAlertDates:(NMTGProject *)proj;

@end

