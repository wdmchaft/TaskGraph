//
//  FocusedAndContextedViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 02.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FocusedAndContextedViewController : UITableViewController {
    NSMutableDictionary* _tableDataSource;
    NSMutableDictionary* _tableColorDataSource;
    NSArray* _titles;
    NSString* _contextToFilterTasks;
    UIBarButtonItem* _showAllOrShowUnDoneOnly;
    BOOL _shouldShowOnlyUnDone;
}
@property(nonatomic,retain) NSString* contextToFilterTasks;
@property(nonatomic       ) BOOL shouldShowOnlyUnDone;

-(void) reloadData;
-(void) showAllOrShowUnDoneOnlyClicked;
-(BOOL) checkProjectIsDone:(NMTGProject*) aProject;
-(void) hideModalController;

@end

