//
//  ProjectsExtraSettingsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 31.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum{
//    ExtraSettingComment=0,
//    ExtraSettingAlertDateSecond=1
//}ExtraSettingType;

@interface ProjectsExtraSettingsViewController : UIViewController<UITextViewDelegate>{
    //GUI
    UITextView* _textViewComment;
    UIDatePicker* _datePickerAlert2;
    
    //Logic
//    @public ExtraSettingType extraSettingType;
    @public BOOL extraSettingTypeIsComment;
}

-(void)save;
-(void)cancel;

@end
