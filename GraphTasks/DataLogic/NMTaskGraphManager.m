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

@end
