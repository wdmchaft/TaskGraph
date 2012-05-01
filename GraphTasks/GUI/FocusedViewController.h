//
//  FocusedViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FocusedViewController : UITableViewController{
    NSMutableDictionary* _tableDataSource;
    NSArray* _titles;
    NSString* _contextToFilterTasks;
}
@property(nonatomic,retain) NSString* contextToFilterTasks;

-(void)reloadData;
@end
