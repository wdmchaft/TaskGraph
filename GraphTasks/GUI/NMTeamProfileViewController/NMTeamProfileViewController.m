//
//  NMTeamProfileViewController.m
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//

#import "NMTeamProfileViewController.h"
#import "NMTeamProfileEditController.h"

@implementation NMTeamProfileViewController

#pragma mark    -   LifeCycle
-   (id)    init{
    self    =   [super  init];
    
    if (self){
        [self.view  setBackgroundColor:[UIColor clearColor]];
        
        UIBarButtonItem*    addButton   =   [[UIBarButtonItem   alloc]  
                        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                             target:self 
                                             action:@selector(addTeamProfile)];
        
        [self.navigationItem    setRightBarButtonItems:
            [NSArray arrayWithObjects:self.editButtonItem,addButton, nil]];
        
        _context    =   [[NMTaskGraphManager    sharedManager]  managedContext];
        
        _profilesTableView  =   [[UITableView   alloc]  initWithFrame:CGRectOffset(self.view.frame, 0.0, -1 * self.view.frame.origin.y) style:UITableViewStylePlain];
        [_profilesTableView setDelegate:self];
        [_profilesTableView setDataSource:self];
        [self.view  addSubview:_profilesTableView];
        
        [self   reloadData];
    }
    
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)  viewDidAppear:(BOOL)animated{
    [super  viewDidAppear:animated];
    
    [self   reloadData];
}

-(void)  reloadData{
    NSFetchRequest* request =   [[NSFetchRequest    alloc]  init];

    NSEntityDescription* entity = [NSEntityDescription  entityForName:@"NMTGProfile"
                                               inManagedObjectContext:_context];
    [request setEntity:entity];
    
    NSError* error = nil;
    _fetchedProfiles    =   [_context   executeFetchRequest:request error:&error];
     
    [_profilesTableView reloadData];
}

-   (void)  addTeamProfile{
    NSLog(@"Add team profile");
    
    NSEntityDescription*    entity  =   [NSEntityDescription    entityForName:@"NMTGProfile" inManagedObjectContext:_context];
    NMTeamProfile*          profile =   [[NMTeamProfile alloc]  initWithEntity:entity
                                                insertIntoManagedObjectContext:_context];
    [profile    setFirstName:@"Владмир"];
    [profile    setLastName:@"Конев"];
    [profile    setPhone:@"+7(926)153-45-05"];
    [profile    setMail:@"pmvovchik@gmail.com"];
    [profile    setPhoto:[UIImage imageNamed:@"profile"]];
    
    [_context   insertObject:profile];
    
    NSError*    error;
    if (![_context save:&error])
        NSLog(@"NMTeamProfileViewController. Failed to add profile: %@", error);
    
    [self   reloadData];
}




#pragma mark    -   UITableViewDelegate & UITableViewDataSource

-   (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-   (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_fetchedProfiles   count];
}

-   (UITableViewCell*)  tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString*   cellID  =   @"TeamCell";
    
    UITableViewCell*    cell    =   [tableView  dequeueReusableCellWithIdentifier:cellID];
    if (cell    ==  nil)
        cell    =   [[UITableViewCell   alloc]  initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:cellID];
    
    NMTeamProfile*  profile =   [_fetchedProfiles   objectAtIndex:[indexPath    row]];
    
    [[cell  textLabel]          setText:[NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName]];
    [[cell  detailTextLabel]    setText:profile.phone];
    [[cell  imageView]          setImage:profile.photo];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-   (void)  tableView:(UITableView *)tableView
   commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle    ==  UITableViewCellEditingStyleDelete){
        NMTeamProfile*  profile =   [_fetchedProfiles   objectAtIndex:[indexPath row]];
        [_context   deleteObject:profile];
        
        NSError*    error;
        if (![_context   save:&error])
            NSLog(@"NMTeamProfileViewController. Error while try to delete object:\n%@", error);
        else
            [self   reloadData];
    }
}

-   (BOOL)  tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-   (void)  tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NMTeamProfile*  profile  =   [_fetchedProfiles   objectAtIndex:[indexPath    row]];
    
    [self.navigationController  pushViewController:[[NMTeamProfileEditController alloc] initWithTeamProfile:profile]      animated:YES];
}

@end
