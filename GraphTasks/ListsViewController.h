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
    NSMutableDictionary* _numbersForCellsDataSource;
    NSMutableArray* _allContexts;
    BOOL _shouldSetBarButtonItemTitleALLorUNDONE;
}
-(void)reloadData;
-(void)setBarButtonItemTitleALLorUNDONE;
@end
