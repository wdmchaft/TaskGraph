//
//  AddWhateverViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddWhateverViewController : UITableViewController <UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate,
ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate> {
    NSDictionary* _tableData;
    NMTGProject* _parentProject;
    NSIndexPath* _indexPathOfSelectedCell;
}
@property(nonatomic,retain) NMTGProject* parentProject;
@property (nonatomic) BOOL taskPhone;
@property (nonatomic) BOOL taskSMS;
@property (nonatomic) BOOL taskEmail;
@property (nonatomic) BOOL taskMap;

-(void)cancel;

-(void)showPeoplePickerController;
-(void)showPersonViewController;
-(void)showNewPersonViewController;

@end
