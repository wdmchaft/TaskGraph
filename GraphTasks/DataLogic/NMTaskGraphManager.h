//
//  NMTaskGraphManager.h
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMTeamProfile.h"
#import "NMTGProject.h"

extern  const   NSString*   NMTaskGraphFileName;

@interface NMTaskGraphManager : NSObject{
    NSManagedObjectContext*         _managedContext;
    NSManagedObjectModel*           _managedModel;
    NSPersistentStoreCoordinator*   _persistenceCoordinator;
//added
    NMTGProject* _projectFantom;
}

@property(nonatomic,    strong) NSManagedObjectModel*           managedModel;
@property(nonatomic,    strong) NSManagedObjectContext*         managedContext;
@property(nonatomic,    strong) NSPersistentStoreCoordinator*   persistenceCoordinator;

+   (NMTaskGraphManager*)   sharedManager;
-   (void) saveContext;

//added
@property(nonatomic,strong) NMTGProject* projectFantom;
@end
