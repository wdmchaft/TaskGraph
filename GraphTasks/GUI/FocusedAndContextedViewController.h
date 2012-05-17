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
    
    NSDate* ALERT_DATE_1;
    NSDate* ALERT_DATE_2;
}
@property(nonatomic,retain) NSString* contextToFilterTasks;
@property(nonatomic,      ) BOOL shouldShowOnlyUnDone;

@property(nonatomic,retain) NSDate* alert_date_1;
@property(nonatomic,retain) NSDate* alert_date_2;

-(void) reloadData;
-(void) showAllOrShowUnDoneOnlyClicked;
-(BOOL) checkProjectIsDone:(NMTGProject*) aProject;
-(void) hideModalController;

@end

