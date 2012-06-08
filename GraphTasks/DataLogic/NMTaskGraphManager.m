//
//  NMTaskGraphManager.m
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//

#import "NMTaskGraphManager.h"


static  NMTaskGraphManager* st_sharedManager    =   nil;

const   NSString*   NMTaskGraphFileName =   @"NMTaskGraph2.sqlite";

@implementation NMTaskGraphManager

@synthesize managedModel        =   _managedModel,
            managedContext  =   _managedContext,
            persistenceCoordinator  =   _persistenceCoordinator,
            path = _path,
            pathComponents = _pathComponents ;

#pragma mark    -   LifeCycle

+   (void)  initialize{
    st_sharedManager    =   [[NMTaskGraphManager    alloc]  init];
}

-   (id)    init{
    self    =   [super  init];
    
    if (self){
        NSError*    error;
        NSURL*      url =   [NSURL  fileURLWithPath:[DOCUMENTS_PATH stringByAppendingPathComponent:[NMTaskGraphFileName copy]]];
        
        _managedModel           =   [NSManagedObjectModel   mergedModelFromBundles:nil];
        _persistenceCoordinator =   [[NSPersistentStoreCoordinator  alloc]  initWithManagedObjectModel:_managedModel];
        if (![_persistenceCoordinator    addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:url
                                                            options:nil
                                                              error:&error])
            NSLog(@"NMTaskGraphManager. Can't start persistence store coordinator with error:\n%@", error);
        else{
            _managedContext =   [[NSManagedObjectContext alloc] init];
            [_managedContext    setPersistentStoreCoordinator:_persistenceCoordinator];
        }
        _path = [NSMutableString new];
        _pathComponents = [NSMutableArray new];
    }
    
    return self;
}

+   (NMTaskGraphManager*)   sharedManager{
    return st_sharedManager;
}

-   (void) saveContext{
    NSError* error = nil;
    if(!([_managedContext save:&error])){
        NSLog(@"Failed to save context in NMTaskGraphManager");
    }
}



//ищет объект NMTGSettings. Если таковой не найден, то приложение запущено впервые. Тогда объект создается с нужными значениями полей. 
//Если же объект был найден, то сбрасывать настройки не требуется. Для того, чтобы сбросить настройки, пользователь удалит этот объект 
//Settings посредством кнопки "Сброс настроек"
-(void) resetSettingsToDefaults
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NMTGSettings" inManagedObjectContext:context];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity: entity];
    if ([context executeFetchRequest:request error:nil].count == 1) {
        return;
    } else {
        NMTGSettings *settings = [[NMTGSettings alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        [context insertObject:settings];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failed to save context in 'resetSettingsToDefaults'  part 1");
            NSLog(@"%@",error);
        }
        
        entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDefaultContext == YES"];
        [request setPredicate:predicate];
        
        error = nil;
        for (NMTGContext *obj in [context executeFetchRequest:request error:&error]) {
            [context deleteObject:obj];
        }
        
        NMTGContext* nmtgcontext1 = [[NMTGContext alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        [context insertObject:nmtgcontext1];
        nmtgcontext1.isDefaultContext = [NSNumber numberWithBool: YES];
        nmtgcontext1.name = @"Дом";
        nmtgcontext1.iconName = @"home_30x30.png";
        
        NMTGContext* nmtgcontext2 = [[NMTGContext alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        [context insertObject:nmtgcontext2];
        nmtgcontext2.isDefaultContext = [NSNumber numberWithBool: YES];
        nmtgcontext2.name = @"Работа";
        nmtgcontext2.iconName = @"job_30x30.png";
        
        NMTGContext* nmtgcontext3 = [[NMTGContext alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        [context insertObject:nmtgcontext3];
        nmtgcontext3.isDefaultContext = [NSNumber numberWithBool: YES];
        nmtgcontext3.name = @""; //без контекста
        nmtgcontext3.iconName = @"context_nil_30x30.png";
        
        error = nil;
        if (![context save:&error]) {
            NSLog(@"Failed to save context in 'resetSettingsToDefaults' part 2");
            NSLog(@"%@",error);
        }
        
        NSEntityDescription* entityJobPosition = [NSEntityDescription entityForName:@"NMTGJobPosition" inManagedObjectContext:context];
        
        NMTGJobPosition *position1 = [[NMTGJobPosition alloc] initWithEntity: entityJobPosition insertIntoManagedObjectContext: context];
        NMTGJobPosition *position2 = [[NMTGJobPosition alloc] initWithEntity: entityJobPosition insertIntoManagedObjectContext: context];
        
        [context insertObject: position1];
        [context insertObject: position2];
        
        position1.title = @"Директор";
        position2.title = @""; //будет отображаться "Без должности"
        
        [position1 addSubJobPositionsObject: position2];
        [position1 setParentJobPosition: position1];
     
        error = nil;
        if (![context save:&error]) {
            NSLog(@"Failed to save context in 'resetSettingsToDefaults' part 3");
            NSLog(@"%@",error);
        }        
    }
}

@end
