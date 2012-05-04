//
//  ListsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListsViewController.h"
#import "ProjectsViewController.h"
#import "FocusedAndContextedViewController.h"
#import "NMTGTask.h"
#import "NMTGProject.h"
#import "NMTGContext.h"


#define TITLE_REGULAR @"Обычные"
#define TITLE_CONTEXTED @"С контекстом"

/*
//
// Данный контроллер предлагает пользователю выбор типа списка проектов или заданий.
// "Все", "В фокусе" и различные контекстные списки
//
*/


@implementation ListsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _numbersForCellsDataSource = [NSMutableDictionary new];
        [_numbersForCellsDataSource setObject:[NSMutableArray new] forKey:TITLE_REGULAR];
        [_numbersForCellsDataSource setObject:[NSMutableArray new] forKey:TITLE_CONTEXTED];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBarButtonItemTitleALLorUNDONE) name:@"ShouldRetitleBarButtonItem" object:nil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)setBarButtonItemTitleALLorUNDONE
{
    _shouldSetBarButtonItemTitleALLorUNDONE = !_shouldSetBarButtonItemTitleALLorUNDONE;
}

-(void) reloadData
{
    NSArray* regularTasks = [NSArray arrayWithObjects:@"Все", @"В фокусе", nil];
     
    NSManagedObjectContext* context;
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entity;
    context = [[NMTaskGraphManager sharedManager]managedContext];
    NSArray* resultsOfFetchExec;
    
    [[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] removeAllObjects];
    
    //подсчет общего числа заданий и числа сделанных из них
    entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
    [request setEntity:entity];
    resultsOfFetchExec = [context executeFetchRequest:request error:nil];
    
    NSUInteger done = 0;
    for (NMTGTask* task in resultsOfFetchExec) {
        if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
    }
    [_numbersForCellsDataSource setObject:[NSArray arrayWithObjects:[NSString stringWithFormat:@"сделано: %i (%i)",done, resultsOfFetchExec.count], [NSString stringWithFormat:@"сделано: %i (%i)",done, resultsOfFetchExec.count], nil] forKey:TITLE_REGULAR];

    
    //поиск всех контекстов
    entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
    [request setEntity:entity];
    NSArray* contextsUserMade = [context executeFetchRequest:request error:nil];
    
    _allContexts = [NSMutableArray arrayWithObjects:@"Дом", @"Работа", @"Семья", @"", nil]; //пустая строка - для пустого контекста. В tableViewCell будет написано (без контекста)

    [_allContexts addObjectsFromArray:contextsUserMade];
    
    _tableDataSource = [NSDictionary dictionaryWithObjectsAndKeys:regularTasks,TITLE_REGULAR, _allContexts, TITLE_CONTEXTED , nil];
    
    
    //подсчет общего числа заданий с заданным контекстом и числа сделанных из них
    int index = 0;
    for (NSString* contextName in _allContexts) {
//NSLog(@"contextName: %%%@",contextName);
        entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NMTGContext* contextObject;
        if ([[_allContexts objectAtIndex:index] isKindOfClass:[NMTGContext class]]) { 
            (contextObject = [_allContexts objectAtIndex:index]);
        }
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"context == %@",
                                  (contextObject != nil) ? (contextObject.name) : (contextName)];
        [request setPredicate:predicate];
        
        resultsOfFetchExec = [context executeFetchRequest:request error:nil];
        NSUInteger done = 0;
        for (NMTGAbstract* obj in resultsOfFetchExec) {
            if ([obj.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
        }
        [[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] addObject:[NSString stringWithFormat:@"сделано: %i (%i)",done, resultsOfFetchExec.count]];
         index++;
    }
//NSLog(@"_numbers if viewWillAppear: %@", [_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED]);
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray* arra1 = [_numbersForCellsDataSource objectForKey:TITLE_REGULAR];
    NSMutableArray* arra2 = [_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED];
    for (id obj in arra1) {
//        NSLog(@"------%@",arra1);
    }
    for (id obj in arra2) {
//        NSLog(@"------%@",arra2);
    }
    
    [self reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_tableDataSource allKeys]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [_tableDataSource allKeys];
    NSString* particularKey = [allKeys objectAtIndex:section];
    return [[_tableDataSource objectForKey:particularKey]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSArray* allKeys = [_tableDataSource allKeys];
    NSString* particularKey = [allKeys objectAtIndex:indexPath.section];
    NSArray* array = [_tableDataSource objectForKey:particularKey];
    switch (indexPath.section) {
        case 0: //иконки и лэйблы для ВСЕ и В ФОКУСЕ
        {
            cell.textLabel.text = [array objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [[_numbersForCellsDataSource objectForKey:TITLE_REGULAR] objectAtIndex:indexPath.row];
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"all_tasks_30x30.png"];
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"focused_30x30.png"];
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: //иконки и лэйблы для списков с контекстом
        {
            if (indexPath.row >=4) cell.textLabel.text = [[array objectAtIndex:indexPath.row] name];
            else cell.textLabel.text = [array objectAtIndex:indexPath.row];

//NSLog(@"[[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] objectAtIndex:indexPath.row] : %@",[[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] objectAtIndex:indexPath.row]);
            cell.detailTextLabel.text = [[_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED] objectAtIndex:indexPath.row];
            
            
//NSLog(@"_numbers in cellForRow: %@", [_numbersForCellsDataSource objectForKey:TITLE_CONTEXTED]);
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
                    cell.textLabel.text = @"(Без контекста)";
                    break;
                default:
                    cell.imageView.image = [UIImage imageNamed:@"context_30x30.png"];                    
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: //тут ВСЕ и В ФОКУСЕ
        {
            switch (indexPath.row) {
                case 0: //ВСЕ
                {
                    ProjectsViewController* pvc = [[ProjectsViewController alloc]init];
                    [pvc setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Projects" image:nil tag:0]];
                    
                    UIViewController* VASILENKO_VIEW_CONTROLLER = [UIViewController new];
                    [VASILENKO_VIEW_CONTROLLER setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"VASILENKO" image:nil tag:0]];
                    
                    UITabBarController* tvc = [[UITabBarController alloc]init];
                    [tvc setViewControllers:[NSArray arrayWithObjects:pvc, VASILENKO_VIEW_CONTROLLER, nil]];
                    [self.navigationController pushViewController:tvc animated:YES];
                    break;
                }
                case 1: //В ФОКУСЕ
                {
                    FocusedAndContextedViewController* vc = [[FocusedAndContextedViewController alloc]initWithStyle:UITableViewStylePlain];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: //тут список контекстов
        {
            NSArray* allContexts = [_tableDataSource objectForKey:TITLE_CONTEXTED];
//            TasksWithContextViewController* taskContextVC = [[TasksWithContextViewController alloc]initWithStyle:UITableViewStylePlain];
            FocusedAndContextedViewController* focusedVC = [[FocusedAndContextedViewController alloc]initWithStyle:UITableViewStylePlain];
            if (indexPath.row >= 4) {
                /*taskContextVC*/focusedVC.contextToFilterTasks = [[allContexts objectAtIndex:indexPath.row]name];
            } else {
                /*taskContextVC*/focusedVC.contextToFilterTasks = [allContexts objectAtIndex:indexPath.row];
            }
            focusedVC.shouldShowOnlyUnDone = _shouldSetBarButtonItemTitleALLorUNDONE;
            [self.navigationController pushViewController:/*taskContextVC*/focusedVC animated:YES];
            break;
        }
            
        default:
            break;
    }

}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return TITLE_REGULAR;
            break;
        case 1:
            return TITLE_CONTEXTED;
            break;
        default:
            return @"";
            break;
    }
}

@end
