//
//  _43FoldersTableViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 05.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _43FoldersTableViewController : UITableViewController {
    NSMutableDictionary* _tableDataSource;
    NSMutableDictionary* _tableColorDataSource;
    
    NSArray* _titles;
    NSArray* _titles_with_declination;
    NSArray* _numberOfDaysInMonth;
    NSArray* _images;
    
    int _number_of_current_month;
    int _number_of_selected_row;
    int _additional_31_day;
    
    NSMutableArray* newDates;
    NSMutableArray* newTitles;
    NSMutableArray* newCompletencyLabels;
    NSMutableArray* newTitlesWithDeclination;
    NSMutableArray* newNumberOfDaysInMonth;
    NSMutableArray* newImages;
    
    UIBarButtonItem* hideBarButtonItem;
    NSArray* numberOfDaysInMonth;
}

-(void) reloadData;
-(BOOL) c211heckProjectIsDone:(NMTGProject*) aProject;
-(void) hide;
-(NSString*)countNumberOfDoneAndAllTasksBetweenDate:(NSDate *) date1 AndDate:(NSDate *) date;

@end