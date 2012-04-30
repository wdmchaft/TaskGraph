//
//  NMTGProject.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NMTGAbstract.h"

@class NMTGProject, NMTGTask;

@interface NMTGProject : NMTGAbstract

@property (nonatomic, retain) NMTGProject *parentProject;
@property (nonatomic, retain) NSSet *subProject;
@property (nonatomic, retain) NSSet *subTasks;
@end

@interface NMTGProject (CoreDataGeneratedAccessors)

- (void)addSubProjectObject:(NMTGProject *)value;
- (void)removeSubProjectObject:(NMTGProject *)value;
- (void)addSubProject:(NSSet *)values;
- (void)removeSubProject:(NSSet *)values;

- (void)addSubTasksObject:(NMTGTask *)value;
- (void)removeSubTasksObject:(NMTGTask *)value;
- (void)addSubTasks:(NSSet *)values;
- (void)removeSubTasks:(NSSet *)values;

@end
