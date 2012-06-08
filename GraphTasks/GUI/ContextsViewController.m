//
//  ContextsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContextsViewController.h"
#import "TextViewViewController.h"
#import "NMTaskGraphManager.h"

#define TITLE_USUAL_CONTEXTS @"Стандартные"
#define TITLE_MADE_BY_USER @"Пользовательские"


@implementation ContextsViewController

@synthesize delegate = _delegate,
            defaultContextName = _defaultContextName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ( [[_tableDataSource allKeys] containsObject:TITLE_USUAL_CONTEXTS] ) {
            return TITLE_USUAL_CONTEXTS;
        } else {
            return TITLE_MADE_BY_USER;
        }
    } else {
        return TITLE_MADE_BY_USER;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIBarButtonItem* addContextButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContext)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, addContextButton, nil];
    self.navigationItem.title = @"Контексты";
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = 0;
    for (NSString *key in [_tableDataSource allKeys]) {
        if ( [[_tableDataSource objectForKey:key] count] != 0 ) { result ++; }
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[_tableDataSource objectForKey:TITLE_USUAL_CONTEXTS] count];
            break;
        case 1:
            return [[_tableDataSource objectForKey:TITLE_MADE_BY_USER] count];
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSArray *allkeys = [_tableDataSource allKeys];
    NSString *key = [allkeys objectAtIndex:indexPath.section];
    
    NMTGContext *nmtgcontext = [[_tableDataSource objectForKey:key] objectAtIndex:indexPath.row];

    cell.imageView.image = [UIImage imageNamed:nmtgcontext.iconName];
    cell.textLabel.text = ([nmtgcontext.name isEqualToString: @""]) ? (@"Без контекста") : (nmtgcontext.name);

    if ([nmtgcontext.name isEqualToString:self.defaultContextName]) { //ставим галочку на установленном в прошлый раз контексте
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } 
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(void)addContext
{
    TextViewViewController* vc = [[TextViewViewController alloc]init];
    vc.delegateContextAdd = self;
    vc.isAddingContextName = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)createNewContextWithName:(NSString *)thename
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager]managedContext];
    
    NMTGContext* contextName = [[NMTGContext alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    [context insertObject:contextName];
    contextName.name = thename;
    contextName.iconName = @"context_30x30.png";
    NSError* error = nil;
    if(![context save:&error ]){
        NSLog(@"FAILED TO SAVE CONTEXT IN saveContextName in ContextsVC");
        NSLog(@"%@",error);
    }
    [self reloadData];
}


-(void)reloadData
{
    _tableDataSource = [NSMutableDictionary new];
    
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];

    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDefaultContext == YES"];
    [request setPredicate:predicate];
    NSArray* fetchResults = [context executeFetchRequest:request error:nil];
    NSMutableArray *defaultContexts = [NSMutableArray arrayWithArray:fetchResults];
    
    predicate = [NSPredicate predicateWithFormat:@"isDefaultContext == NO"];
    [request setPredicate:predicate];
    fetchResults = [context executeFetchRequest:request error:nil];
    NSMutableArray *undefaultContexts = [NSMutableArray arrayWithArray:fetchResults];

    if (defaultContexts.count!=0)    [_tableDataSource setObject:defaultContexts forKey:TITLE_USUAL_CONTEXTS];
    if (undefaultContexts.count!=0)  [_tableDataSource setObject:undefaultContexts forKey:TITLE_MADE_BY_USER];
    
    [self.tableView reloadData];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NMTGContext *nmtgcontext;
        if ( indexPath.section == 0 ) {
            if ( [[_tableDataSource allKeys] containsObject:TITLE_USUAL_CONTEXTS] ){
                nmtgcontext = [[_tableDataSource objectForKey:TITLE_USUAL_CONTEXTS] objectAtIndex:indexPath.row];
            } else {
                nmtgcontext = [[_tableDataSource objectForKey:TITLE_MADE_BY_USER] objectAtIndex:indexPath.row];
            }
        } else {
            nmtgcontext = [[_tableDataSource objectForKey:TITLE_MADE_BY_USER] objectAtIndex:indexPath.row];
        }
         NSManagedObjectContext* managedContext = [[NMTaskGraphManager sharedManager]managedContext];                         
        [managedContext deleteObject:nmtgcontext];
        
         NSError* error = nil;
        if (![managedContext save:&error]) {
            NSLog(@"FAILED TO SAVE CONTEXT IN ContextsVC in commitEditingStyle");
            NSLog(@"%@",error);
        }
        [self reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //
    }   
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSString *contextName;
    if (indexPath.section == 0) {
        if ([[_tableDataSource allKeys] containsObject:TITLE_USUAL_CONTEXTS]) {
            contextName = [[[_tableDataSource objectForKey:TITLE_USUAL_CONTEXTS] objectAtIndex:indexPath.row] name];
        } else {
            contextName = [[[_tableDataSource objectForKey:TITLE_MADE_BY_USER] objectAtIndex:indexPath.row] name];
        }
    } else {
        contextName = [[[_tableDataSource objectForKey:TITLE_MADE_BY_USER] objectAtIndex:indexPath.row] name];        
    }
    [self.delegate setTasksContext:contextName];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
