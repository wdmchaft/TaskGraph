//
//  TasksWithContextViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksWithContextViewController : UITableViewController{
    NSArray* _tableDataSource;
    NSString* _contextToFilterTasks;
}

@property (nonatomic,retain) NSString* contextToFilterTasks;

-(void)reloadData;
-(NSString*)fullPathToATask:(NMTGTask*)aTask;
@end
