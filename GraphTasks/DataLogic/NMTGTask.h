//
//  NMTGTask.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NMTGAbstract.h"

@class NMTGProject;

@interface NMTGTask : NMTGAbstract

@property (nonatomic, retain) NMTGProject *parentProject;

@end
