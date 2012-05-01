//
//  ContextsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContextsViewController.h"
#import "NMTGTask.h"
#import "NMTGProject.h"
#import "NMTGContext.h"

#import "TextViewViewController.h"

#define TITLE_USUAL_CONTEXTS @"Стандартные"
#define TITLE_MADE_BY_USER @"Пользовательские"


@implementation ContextsViewController

@synthesize delegate = _delegate,
            defaultContextName = _defaultContextName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [NSMutableDictionary new];
        [self reloadData];
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
    if (section == 0) return TITLE_USUAL_CONTEXTS;
    else if (_numberOfAddedContexts != 0) return TITLE_MADE_BY_USER;
    else return @"";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIBarButtonItem* addContextButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContext)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, addContextButton, nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return _numberOfAddedContexts;
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
    NSString* key = [NSString stringWithFormat:@"%i.%i",indexPath.section, indexPath.row];
    if (indexPath.section == 0) {
        cell.textLabel.text = [_tableDataSource objectForKey:key];
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"home_30x30.png"];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"job_30x30.png"];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"family_30x30.png"];
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"context_nil_30x30.png"];
                if ([self.defaultContextName isEqualToString:@""]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [[_tableDataSource objectForKey:key] name];
        cell.imageView.image = [UIImage imageNamed:@"context_30x30.png"];
    }

//NSLog(@"cell.textLabel.text: %@",cell.textLabel.text);
//NSLog(@"self.defaultContextName: %@",self.defaultContextName);

    if ([cell.textLabel.text isEqualToString:self.defaultContextName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } 
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return NO;
    return YES;
}


-(void)addContext
{
    _numberOfAddedContexts++;
    TextViewViewController* vc = [[TextViewViewController alloc]init];
    vc.delegateContextAdd = self;
    vc.isAddingContextName = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)setContextName:(NSString *)thename
{
    NSManagedObjectContext* managedContext = [[NMTaskGraphManager sharedManager]managedContext];
    
    NMTGContext* contextName = [[NMTGContext alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:managedContext] insertIntoManagedObjectContext:managedContext];
    [managedContext insertObject:contextName];
    contextName.name = thename;
    
    NSError* error = nil;
    if(![managedContext save:&error ]){
        NSLog(@"FAILED TO SAVE CONTEXT IN saveContextName in ContextsVC");
        NSLog(@"%@",error);
    }
    [self reloadData];
}

-(NSArray*) getData
{
    NSMutableArray* result = [NSMutableArray new];
    for (NSIndexPath* indexPath in self.tableView.indexPathsForVisibleRows){
        NSString* key = [NSString stringWithFormat:@"%i.%i",indexPath.section, indexPath.row];
        if (indexPath.section == 0) {
            [result addObject: [_tableDataSource objectForKey:key]];
//NSLog(@"class: %@", [[_tableDataSource objectForKey:key] class]);
        } else if (indexPath.section == 1) {
//NSLog(@"class: %@", [[[_tableDataSource objectForKey:key] name] class]);
            [result addObject: [[_tableDataSource objectForKey:key] name]] ;
        }
    }
    return result;
}

-(void)reloadData
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager]managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    
    NSArray* fetchRes = [context executeFetchRequest:request error:nil];
    NSMutableArray* contextNames = [NSMutableArray arrayWithObjects:@"Дом", @"Работа", @"Семья", @"(Без контекста)", nil];
    for (NMTGContext* _NMTGContext in fetchRes){
        [contextNames addObject:_NMTGContext];
    }
    _numberOfAddedContexts = [contextNames count] - 4;
    
    for (int iteration_number = 0; iteration_number<contextNames.count; iteration_number++ ) {
        if (iteration_number < 4) {
            [_tableDataSource setObject:[contextNames objectAtIndex:iteration_number] forKey:[NSString stringWithFormat: @"0.%i",iteration_number]];
        } else {
            [_tableDataSource setObject:[contextNames objectAtIndex:iteration_number] forKey:[NSString stringWithFormat: @"1.%i",iteration_number - 4]];
        }
    }
    [self.tableView reloadData];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NMTGContext* _context = [_tableDataSource objectForKey:[NSString stringWithFormat:@"%i.%i",indexPath.section, indexPath.row]];
         NSManagedObjectContext* managedContext = [[NMTaskGraphManager sharedManager]managedContext];                         
        [managedContext deleteObject:_context];
        
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
    if (indexPath.section == 0) {
        NSString* _contextFromDefualtValues = (indexPath.row != 3) 
                        ? ([_tableDataSource objectForKey:[NSString stringWithFormat:@"%i.%i",indexPath.section, indexPath.row]])
                        : (@"");
        [self.delegate setTasksContext:_contextFromDefualtValues];
    } else if (indexPath.section == 1) {
        NSString* key = [NSString stringWithFormat:@"%i.%i",indexPath.section, indexPath.row];
        [self.delegate setTasksContext:[[_tableDataSource objectForKey:key] name]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
