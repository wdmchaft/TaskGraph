//
//  EmployersViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployersViewController : UITableViewController {
    NSMutableDictionary *_tableDataSource;
    
}
-(void) addYmployer; //вызов контроллера добавления работника
-(void) addingEmployerFinished;
-(void) reloadData;
@end
