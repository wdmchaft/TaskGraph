//
//  NMTGTask.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 06.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NMTGAbstract.h"

@class NMTGProject;

@interface NMTGTask : NMTGAbstract

@property (nonatomic, retain) NSString * keyDescribingTaskType;
@property (nonatomic, retain) NSString * valueForKeyDescribingTaskType;
@property (nonatomic, retain) NMTGProject *parentProject;

@end
