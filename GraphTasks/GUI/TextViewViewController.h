//
//  NameOfWhateverViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPropertiesViewController.h"

@interface TextViewViewController : UIViewController<UITextViewDelegate>{
    UITextView* _textViewNameOrComment;
    BOOL _isSentToEnterName;
    BOOL _isAddingProject;
    AddPropertiesViewController* _superVC;
    NMTGProject* _parentProject;
}
@property(nonatomic)        BOOL isSentToEnterName;
@property(nonatomic,retain) AddPropertiesViewController* superVC;
@property(nonatomic)        BOOL isAddingProject;
@property(nonatomic,strong) NMTGProject* parentProject;
@property(nonatomic,retain) UITextView* textViewNameOrComment;

@end
