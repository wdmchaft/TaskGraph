//
//  NMTeamProfileEditController.m
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//

#import "NMTeamProfileEditController.h"

@implementation NMTeamProfileEditController
@synthesize profile =   _profile;

-   (id)    initWithTeamProfile:(NMTeamProfile *)profile{
    self    =   [super  init];
    
    if (self){
        [self.view  setBackgroundColor:[UIColor clearColor]];
        
        _photoView  =   [[UIImageView   alloc]  initWithFrame:CGRectMake(10.0, 10.0, 100.0, 100.0)];
        [_photoView setBackgroundColor:[UIColor clearColor]];
        [self.view  addSubview:_photoView];
        
        _nameLabel  =   [[UILabel   alloc]  initWithFrame:CGRectMake(120.0, 20.0, 190.0, 30.0)];
        [_nameLabel setTextColor:[UIColor   darkTextColor]];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [self.view  addSubview:_nameLabel];     
        
        [self   setProfile:profile];

        UIBarButtonItem *myEditButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"edit" style:UIBarButtonSystemItemEdit target:self action:@selector(startEditting)];
        [self.navigationItem    setRightBarButtonItem:myEditButtonItem];
        
        
        _textFieldFirstName = [[UITextField alloc]initWithFrame:CGRectMake(20, 130, 280, 25)];
        [_textFieldFirstName setDelegate:self];
        _textFieldFirstName.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textFieldFirstName.borderStyle = UITextBorderStyleRoundedRect;
        _textFieldFirstName.returnKeyType= UIReturnKeyDefault;
        _textFieldFirstName.placeholder = @"<enter first name here>";
        [_textFieldFirstName setHidden:YES];
        
        [self.view addSubview:_textFieldFirstName];
        
        _textFieldLastName = [[UITextField alloc]initWithFrame:CGRectMake(20, 160,280, 25)];
        [_textFieldLastName setDelegate:self];
        _textFieldLastName.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textFieldLastName.borderStyle = UITextBorderStyleRoundedRect;
        _textFieldLastName.placeholder = @"<enter last name here>";
        _textFieldLastName.returnKeyType = UIReturnKeyDefault;
        
        [_textFieldLastName setHidden:YES];
        [self.view addSubview:_textFieldLastName];
        
        
    }
    return self;
}
-(void)startEditting{

    self.navigationItem.rightBarButtonItem.title = @"save";
    self.navigationItem.rightBarButtonItem.action = @selector(saveProfile);
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;  
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem,cancelButton,nil];
    

    [_textFieldFirstName setHidden:NO];
    [_textFieldFirstName becomeFirstResponder];
    [_textFieldLastName setHidden:NO];
}

-(void) cancel{
    [_textFieldFirstName resignFirstResponder];
    [_textFieldLastName resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-   (void)  saveProfile{
    NSManagedObjectContext* context =   [[NMTaskGraphManager    sharedManager]  managedContext];
    
    _firstName = [NSString stringWithString:_textFieldFirstName.text];
    _lastName = [NSString stringWithString:_textFieldLastName.text];
    
    [_profile   setFirstName:_firstName];
    [_profile   setLastName:_lastName];
    
    NSError*    error;
    if (![context   save:&error])
        NSLog(@"NMTeamProfileEditController. Fail to update profile with error: %@", error);
    else
        [self.navigationController  popViewControllerAnimated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _textFieldFirstName) {
        _firstName = [NSString stringWithString:textField.text];
        [_textFieldFirstName resignFirstResponder];
    }
    if (textField == _textFieldLastName){
        _lastName = [NSString stringWithString:textField.text];
        [_textFieldLastName resignFirstResponder];
    }
    
    return YES;
}

-(id)init{
    return [self    initWithTeamProfile:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-   (void)  setProfile:(NMTeamProfile *)profile{
    _profile    =   profile;
    
    [_photoView setImage:profile.photo];
    
    [_nameLabel setText:[NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName]];
}



@end
