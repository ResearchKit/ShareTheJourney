//
//  APHExerciseCheckInTaskViewController.m
//  BreastCancer
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APHExerciseCheckInTaskViewController.h"
#import "APHExerciseCheckinTask.h"
#import "APHExerciseMotivationSummaryViewController.h"

// important step identifiers
static NSString* const kReasonsStepID                   = @"reasons";
static NSString* const kReasonsTwoStepID                = @"reasons.two";
static NSString* const kStoryboardName                  = @"APHExerciseMotivationSummaryViewController";

// constants for result queries
static NSString* const kAPCTaskAttributeUpdatedAt   = @"updatedAt";

//  Exercise Motivator Task Items
static NSString* const kMotivatorTaskID                 = @"4-APHExerciseSurvey-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
static NSString* const kWalkFiveThousandSteps           = @"Walk 5,000 steps every day";
static NSString* const kExerciseEverySingleDay          = @"Exercise Every Single Day for at least 30 minutes";
static NSString* const kExerciseThreeTimesPerWeek       = @"Exercise at least 3 times per week for at least 30 minutes";
static NSString* const kWalkTenThousandSteps            = @"Walk 10,000 steps at least 3 times per week";
static NSString* const kExerciseEverySingleDayImage     = @"banner_exersiseeveryday";
static NSString* const kExerciseThreeTimesPerWeekImage  = @"banner_exersise3x";
static NSString* const kWalkFiveThousandStepsImage      = @"banner_5ksteps";
static NSString* const kWalkTenThousandStepsImage       = @"banner_10ksteps";
static NSString* const kImageResultKey                  = @"exercisesurvey101";
static NSString* const kExerciseSurveyStep102           = @"exercisesurvey102";
static NSString* const kExerciseSurveyStep103           = @"exercisesurvey103";
static NSString* const kExerciseSurveyStep104           = @"exercisesurvey104";
static NSString* const kExerciseSurveyStep105           = @"exercisesurvey105";
static NSString* const kExerciseSurveyStep106           = @"exercisesurvey106";

@interface APHExerciseCheckInTaskViewController ()

@end

@implementation APHExerciseCheckInTaskViewController

+ (id<ORKTask>)createTask:(APCScheduledTask *) __unused scheduledTask
{
    APHExerciseCheckinTask* task = [[APHExerciseCheckinTask alloc] init];
    
    return task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (void)taskViewController:(ORKTaskViewController*) __unused taskViewController stepViewControllerWillAppear:(ORKStepViewController*)stepViewController
{
    if ([stepViewController.step.identifier isEqualToString:kReasonsStepID] || [stepViewController.step.identifier isEqualToString:kReasonsTwoStepID])
    {
        APHExerciseMotivationSummaryViewController* reasonsController = (APHExerciseMotivationSummaryViewController*)stepViewController;
        
        NSDictionary*   answ    = [self mostRecentReasons];
        NSArray*        reasons = @[[answ valueForKey:kExerciseSurveyStep102],
                                    [answ valueForKey:kExerciseSurveyStep103],
                                    [answ valueForKey:kExerciseSurveyStep104],
                                    [answ valueForKey:kExerciseSurveyStep105],
                                    [answ valueForKey:kExerciseSurveyStep106]];
        
        [reasonsController.titleImageView setImage:[UIImage imageNamed:[self imageName:answ]]];
        [reasonsController setAnswersInTableview:(NSMutableArray*)reasons];
        [reasonsController setGoalButtonTitle:NSLocalizedString(@"Done", nil)];
    }
}

- (NSString*)imageName:(NSDictionary*)motivatorResults
{
    NSDictionary*   goalImages  = @{
                                    kExerciseEverySingleDay    : kExerciseEverySingleDayImage,
                                    kExerciseThreeTimesPerWeek : kExerciseThreeTimesPerWeekImage,
                                    kWalkFiveThousandSteps     : kWalkFiveThousandStepsImage,
                                    kWalkTenThousandSteps      : kWalkTenThousandStepsImage
                                    };
    NSString*       key         = [motivatorResults objectForKey:kImageResultKey];
    
    return goalImages[key];
}

- (ORKStepViewController*)taskViewController:(ORKTaskViewController*) __unused taskViewController viewControllerForStep:(ORKStep*)step
{
    APCStepViewController* controller = nil;
    
    if ( step.identifier == kReasonsStepID || step.identifier == kReasonsTwoStepID)
    {
        UIStoryboard* mainStoryboard    = [UIStoryboard storyboardWithName:kStoryboardName
                                                                 bundle:nil];
        
        APHExerciseMotivationSummaryViewController* reasonsController = (APHExerciseMotivationSummaryViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:kStoryboardName];

        controller                          = reasonsController;
        controller.delegate                 = self;
        controller.step                     = step;
    }
    
    return controller;
}

- (NSDictionary*)mostRecentReasons
{
    NSDictionary*       result       = nil;
    NSString*           taskId      = kMotivatorTaskID;
    APCAppDelegate*     appDelegate = (APCAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAPCTaskAttributeUpdatedAt
                                                                     ascending:NO];
    NSFetchRequest*     request     = [APCScheduledTask request];
    NSPredicate*        predicate   = [NSPredicate predicateWithFormat:@"(task.taskID == %@) AND (completed == YES)", taskId];
    
    request.predicate       = predicate;
    request.sortDescriptors = @[sortDescriptor];
    
    NSError*            error       = nil;
    NSArray*            tasks       = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request
                                                                                           error:&error];
    
    if (tasks == nil)
    {
        if (error)
        {
            APCLogError2(error);
        }
    }
    else
    {
        APCScheduledTask*   task            = [tasks firstObject];
        NSArray*            schedTaskResult = [task.results allObjects];
        NSSortDescriptor* sorDescrip        = [[NSSortDescriptor alloc] initWithKey:kAPCTaskAttributeUpdatedAt
                                                                          ascending:NO];
        NSArray*            taskResults     = [schedTaskResult sortedArrayUsingDescriptors:@[sorDescrip]];
        NSString*           resultSummary   = nil;
        APCResult*          recentResult    = [taskResults firstObject];
        
        resultSummary = [recentResult resultSummary];
        
        if (resultSummary)
        {
            NSData*     resultData  = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
            NSError*    error       = nil;
            
            result = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&error];
            
            if (result == nil)
            {
                if (error)
                {
                    APCLogError2(error);
                }
            }
        }
    }
    
    return result;
}

@end
