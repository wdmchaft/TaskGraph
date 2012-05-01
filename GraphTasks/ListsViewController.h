//
//  ListsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListsViewController : UITableViewController{
    NSDictionary* _tableDataSource;
}
-(void)reloadData;

@end
