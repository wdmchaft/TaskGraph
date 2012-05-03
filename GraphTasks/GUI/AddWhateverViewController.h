//
//  AddWhateverViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWhateverViewController : UITableViewController{
    NSDictionary* _tableData;
    NMTGProject* _parentProject;
    NSIndexPath* _indexPathOfSelectedCell;
}
@property(nonatomic,retain) NMTGProject* parentProject;

@end
