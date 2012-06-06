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

@interface AddSpecialTaskViewController : UITableViewController  <  ABPeoplePickerNavigationControllerDelegate,
    ABPersonViewControllerDelegate,
    ABNewPersonViewControllerDelegate> {
      
    NSMutableArray* _tableDataSource;  
        BOOL _taskPhone;
        BOOL _taskSMS;
        BOOL _taskEmail;
        
        NMTGProject* _parentProject;
        
}
@property (nonatomic, retain) NMTGProject* parentProject;
@property (nonatomic) BOOL taskPhone;
@property (nonatomic) BOOL taskSMS;
@property (nonatomic) BOOL taskEmail;


-(void)showPeoplePickerController;
-(void)showPersonViewController;
-(void)showNewPersonViewController;

@end
