//
//  NMTGAbstract.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 02.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NMTGAbstract.h"
#import "NMTeamProfile.h"
#import "NMTGTask.h"
#import "NMTGProject.h"


@implementation NMTGAbstract

@dynamic alertDate_first;
@dynamic alertDate_second;
@dynamic comment;
@dynamic context;
@dynamic done;
@dynamic finishDate;
@dynamic title;
@dynamic created;
@dynamic employers;


-(BOOL) compare:(NMTGAbstract*)objectToCompareWith
{
    if (self.class == objectToCompareWith.class){
//if (self.created != objectToCompareWith.created) {return NO;}
//        if ([self.title isEqualToString:objectToCompareWith.title] == NO) { NSLog(@"//-1"); return NO;}
//        if (self.done != objectToCompareWith.done) { NSLog(@"//-1"); return NO;}
    }
    
    if (self.class == [NMTGTask class]) {
        NMTGTask* task = (NMTGTask*) self;
        NMTGTask* taskToCompareWith = (NMTGTask*) objectToCompareWith;
        BOOL parentsAreEqual = [task.parentProject compare:taskToCompareWith.parentProject];
        if (parentsAreEqual == NO) { NSLog(@"//-5"); return NO;}
//        if (self.created != objectToCompareWith.created) { NSLog(@"//2"); return NO;}
        if ([self.alertDate_first compare: objectToCompareWith.alertDate_first] != NSOrderedSame) { NSLog(@"//-4"); return NO;}
        if ([self.alertDate_second compare:objectToCompareWith.alertDate_second] != NSOrderedSame) { NSLog(@"//-5"); return NO;}
        if ([self.context isEqualToString:objectToCompareWith.context] == NO) { NSLog(@"//-6"); return NO;}    
        if ([self.comment isEqualToString:objectToCompareWith.comment] == NO) { NSLog(@"//-7"); return NO;} 
        return YES;
    }
    if (self.class == [NMTGProject class]) {
        NMTGProject* project = (NMTGProject*) self;
        NMTGProject* projectToCompareWith = (NMTGProject*) objectToCompareWith;

//if ([project.alertDate_first compare:projectToCompareWith.alertDate_first] != NSOrderedSame) { NSLog(@"//-8"); return NO;}
//if ([project.alertDate_second compare:projectToCompareWith.alertDate_second] != NSOrderedSame) { NSLog(@"//-9"); return NO;}
//if ([project.parentProject.created compare:projectToCompareWith.parentProject.created] != NSOrderedSame) { NSLog(@"//-10"); return NO;}  
        if (project.parentProject != nil && projectToCompareWith.parentProject != nil) {
            NSLog(@"//%@11", [project.parentProject compare:projectToCompareWith.parentProject] == YES ? @"+" : @"-" );
            return [project.parentProject compare:projectToCompareWith.parentProject]; 
        } else 
        if (project.parentProject == nil && projectToCompareWith.parentProject == nil) {
            NSLog(@"//+12");
            return YES;
        } else 
        if ( (project.parentProject !=nil) != (projectToCompareWith.parentProject != nil) ){
            NSLog(@"//-13");
            return NO;
        }
    }

    
}
@end
