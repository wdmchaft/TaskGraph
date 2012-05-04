//
//  AddSpecialTaskViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddSpecialTaskViewController : UITableViewController  <ABPeoplePickerNavigationControllerDelegate,
        ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate> {
      NSMutableArray* _tableDataSource;  
            
}

-(void)showPeoplePickerController;
-(void)showPersonViewController;
-(void)showNewPersonViewController;

@end
