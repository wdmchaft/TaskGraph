//
//  NMTeamProfileEditController.h
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//


#import "NMTaskGraphManager.h"


@interface NMTeamProfileEditController : UIViewController<UITextFieldDelegate>{//<UITableViewDataSource, UITableViewDelegate>{
    UIImageView*    _photoView;
    UILabel*        _nameLabel;
    
    UITableView*    _fieldTableView;
    
    NMTeamProfile*  _profile;
    UITextField* _textFieldFirstName;
    UITextField* _textFieldLastName;
    
    NSString* _firstName;
    NSString* _lastName;
}

@property(nonatomic, strong, setter = setProfile:)    NMTeamProfile*  profile;

-   (id)    initWithTeamProfile:(NMTeamProfile*)profile;
-   (void)  saveProfile;
-   (void)  startEditting;
-   (void) cancel;
//-   (void)  didEndEditting;

@end
