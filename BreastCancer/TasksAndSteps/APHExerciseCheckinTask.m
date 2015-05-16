//
//  APHExerciseCheckinTask.m
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

#import "APHExerciseCheckinTask.h"

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

// constants for result queries
static NSString* const kAPCTaskAttributeUpdatedAt   = @"updatedAt";

//  task identifier
static NSString* const kExerciseCheckInID   = @"Weekly Exercise Check-in";

//  step index
static NSInteger const kNegativeStepIndex      = -1;
static NSString* const kInstructionStepIndex   = @"0";
static NSString* const kUserProgressStepIndex  = @"1";
static NSString* const kUserSucceededStepIndex = @"2";
static NSString* const kUserInputStepIndex     = @"4";
static NSString* const kUserFailedStepIndex    = @"3";
static NSString* const kUserUncertainIndex     = @"5";
static NSString* const kReasonsStepIndex       = @"6";
static NSString* const kReasonsTwoStepIndex    = @"7";

//  step identifiers
static NSString* const kInstructionStepID   = @"instruction";
static NSString* const kUserProgressStepID  = @"progress";
static NSString* const kUserSucceededStepID = @"success";
static NSString* const kUserFailedStepID    = @"failure";
static NSString* const kUserInputStepID     = @"failure.reason";
static NSString* const kUserUncertainID     = @"uncertain";
static NSString* const kReasonsStepID       = @"reasons";
static NSString* const kReasonsTwoStepID    = @"reasons.two";

//  localized text
static NSString* const kInstructionTitle    = @"Exercise Motivator Check-in";
static NSString* const kInstructionDetail   = @"Let's do a quick check on how you did with your exercise goal "
                                                @"this week. Remember, the goal below is the one you had set for "
                                                @"yourself.";
static NSString* const kInstructionDetail2  = @"This activity is based on your completion of the \"Exercise "
                                                @"Motivator\" activity. Please complete the \"Exercise Motivator\" "
                                                @"first. This activity will then help you track your performance "
                                                @"towards your exercise goal.";
static NSString* const kProgressTitle       = @"How did you do this week?";
static NSString* const kSucceededTitle      = @"Great Job!\nKeep it up!";
static NSString* const kSucceededDetail     = @"Exercise is an important part of a healthy lifestyle. Continue "
                                                @"to push yourself and achieve your goals.\n\nRemember that "
                                                @"you can always set a new goal to keep challenging yourself "
                                                @"and stay motivated!";
static NSString* const kFailedTitle         = @"Some weeks are tougher than others — we totally get it.";
static NSString* const kFailedDetail        = @"Don't beat yourself up — just keep trying your best and "
                                                @"remember that exercise is a very important part of achieving "
                                                @"a healthy lifestyle.\n\n"
                                                @"To help your motivation, you can review your reasons for "
                                                @"selecting your goal.\n\n"
                                                @"We would also love to better understand why you found it hard "
                                                @"to reach your goal. Help us by sharing your thoughts in the "
                                                @"link below.";
static NSString* const kReasonTitle         = @"Help us understand why reaching your goal proved to be a challenge.";
static NSString* const kReasonDetail        = @"Remember, if it feels like your goal is too ambitious, you can "
                                                @"always select an easier goal.";
static NSString* const kPlaceHolder         = @"I didn't reach my exercise target because...";
static NSString* const kUncertainTitle      = @"Exercise is a very important part of achieving a healthy lifestyle.";
static NSString* const kUncertainDetail     = @"Tracking your exercise and comparing it to your "
                                                @"goal is a great motivator — try to be consistent in tracking. "
                                                @"The dashboard will help you see your daily steps, so it's a "
                                                @"good place to start!\n\nTap below to see a summary of why you set your "
                                                @"exercise goal.";
// text choice answers
static NSString* const kUserSucceededChoice = @"I accomplished my goal!";
static NSString* const kUserFailedChoice    = @"I wasn't able to meet my goal";
static NSString* const kUserUncertainChoice = @"I'm not sure";
static NSString* const kUserReasonsChoice   = @"Review your answers to the exercise motivator";
static NSString* const kUserInformation     = @"Tell us a bit more about why you didn't meet your goal";

// max length for text input
static NSInteger const kMaxTextInput        = 300;

@interface APHExerciseCheckinTask()

@property (assign, nonatomic) ORKStep* lastStep;

@end

@implementation APHExerciseCheckinTask

- (NSDictionary*)mostRecentReasons
{
    NSDictionary*       result      = nil;
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

- (instancetype) init
{
    NSMutableArray* steps = [NSMutableArray array];
    
    NSDictionary* motivatorResults = [self mostRecentReasons];
    
    {
        ORKInstructionStep* step = [[ORKInstructionStep alloc] initWithIdentifier:kInstructionStepID];

        step.title      = NSLocalizedString(kInstructionTitle, nil);
        step.detailText = NSLocalizedString(kInstructionDetail2, nil);
        
        if (motivatorResults)
        {
            NSString* imageName = [self imageName:motivatorResults];
            
            step.detailText = NSLocalizedString(kInstructionDetail, nil);
            step.image      = [UIImage imageNamed:imageName];
        }
        
        [steps addObject:step];
    }
    
    if (motivatorResults)
    {
        {
            NSArray*                    textChoices         = @[NSLocalizedString(kUserSucceededChoice, nil),
                                                                NSLocalizedString(kUserFailedChoice, nil),
                                                                NSLocalizedString(kUserUncertainChoice, nil)];
            
            ORKTextChoiceAnswerFormat* pickerAnswerFormat   = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                                   textChoices:textChoices];
            ORKQuestionStep*            step                = [ORKQuestionStep questionStepWithIdentifier:kUserProgressStepID
                                                                                                    title:NSLocalizedString(kProgressTitle, nil)
                                                                                                   answer:pickerAnswerFormat];

            step.optional = NO;
            
            [steps addObject:step];
        }
        {
            ORKInstructionStep* step = [[ORKInstructionStep alloc] initWithIdentifier:kUserSucceededStepID];
            step.title      = NSLocalizedString(kSucceededTitle, nil);
            step.detailText = NSLocalizedString(kSucceededDetail, nil);
            step.optional   = NO;
            
            [steps addObject:step];
        }
        {
            NSArray*                    textChoices         = @[NSLocalizedString(kUserReasonsChoice, nil),
                                                                NSLocalizedString(kUserInformation, nil)];
            ORKTextChoiceAnswerFormat* pickerAnswerFormat   = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                                   textChoices:textChoices];
            ORKQuestionStep*            step                = [ORKQuestionStep questionStepWithIdentifier:kUserFailedStepID
                                                                                                    title:NSLocalizedString(kFailedTitle, nil)
                                                                                                   answer:pickerAnswerFormat];
            
            step.text           = NSLocalizedString(kFailedDetail, nil);
            step.optional       = NO;
            
            [steps addObject:step];
        }
        {
            ORKTextAnswerFormat*    textAnswerFormat    = [[ORKTextAnswerFormat alloc] initWithMaximumLength:kMaxTextInput];
            ORKQuestionStep*        step                = [ORKQuestionStep questionStepWithIdentifier:kUserInputStepID
                                                                                                title:NSLocalizedString(kReasonTitle, nil)
                                                                                               answer:textAnswerFormat];
            
            step.text           = NSLocalizedString(kReasonDetail, nil);
            step.placeholder    = NSLocalizedString(kPlaceHolder, nil);
            step.optional       = NO;
            
            [steps addObject:step];
        }
        {
            NSArray*                    textChoices         = @[NSLocalizedString(kUserReasonsChoice, nil)];
            ORKTextChoiceAnswerFormat* pickerAnswerFormat   = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                                   textChoices:textChoices];
            ORKQuestionStep*            step                = [ORKQuestionStep questionStepWithIdentifier:kUserUncertainID
                                                                                                    title:NSLocalizedString(kUncertainTitle, nil)
                                                                                                   answer:pickerAnswerFormat];
        
            step.text       = NSLocalizedString(kUncertainDetail, nil);
            step.optional   = NO;
            
            [steps addObject:step];
        }
        {
            ORKInstructionStep* step = [[ORKInstructionStep alloc] initWithIdentifier:kReasonsStepID];
            
            step.title      = NSLocalizedString(@"No reason", nil);
            step.detailText = NSLocalizedString(@"None at all", nil);
            
            [steps addObject:step];
        }
        {
            ORKInstructionStep* step = [[ORKInstructionStep alloc] initWithIdentifier:kReasonsTwoStepID];
            
            step.title      = NSLocalizedString(@"No reason", nil);
            step.detailText = NSLocalizedString(@"None at all", nil);
            
            [steps addObject:step];
        }
    }
    
    self = [super initWithIdentifier:kExerciseCheckInID steps:steps];
    
    return self;
}

- (nullable ORKStep *)stepAfterStep:(nullable ORKStep *)step withResult:(ORKTaskResult *)result
{
    self.lastStep = step;
    
    NSInteger stepIndex = 0;
    
    NSInteger(^DetermineStepDepth)(ORKStep*, ORKTaskResult*) = ^NSInteger(ORKStep* step, ORKTaskResult* __unused result)
    {
        NSInteger depth = 0;
        
        if ([step.identifier isEqualToString:kInstructionStepID])
        {
            depth = 1;
        }
        else if ([step.identifier isEqualToString:kUserProgressStepID])
        {
            depth = 2;
        }
        else if ([step.identifier isEqualToString:kUserSucceededStepID] || [step.identifier isEqualToString:kUserFailedStepID] || [step.identifier isEqualToString:kUserUncertainID])
        {
            depth = 3;
        }
        else if ([step.identifier isEqualToString:kUserInputStepID])
        {
            depth = 4;
        }
        
        return depth;
    };
    
    NSInteger(^DepthTwoResult)(ORKStep*, ORKTaskResult*) = ^NSInteger(ORKStep* step, ORKTaskResult* result)
    {
        NSInteger stepIndex = kNegativeStepIndex;
        
        ORKStepResult* stepResult = (ORKStepResult*)[result resultForIdentifier:step.identifier];
        
        if (stepResult)
        {
            ORKChoiceQuestionResult* choiceResult = (ORKChoiceQuestionResult*)[stepResult firstResult];
            
            if (choiceResult.choiceAnswers)
            {
                NSArray* answers        = choiceResult.choiceAnswers;
                NSArray* textChoices    = @[NSLocalizedString(kUserSucceededChoice, nil),
                                            NSLocalizedString(kUserFailedChoice, nil),
                                            NSLocalizedString(kUserUncertainChoice, nil)];
                NSInteger index         = [textChoices indexOfObject:[answers firstObject]];
                
                //  Based on the selected answer lead the user to the correct step
                switch (index) {
                    case 0:
                    {
                        stepIndex = [kUserSucceededStepIndex integerValue];
                        break;
                    }
                    case 1:
                    {
                        stepIndex = [kUserFailedStepIndex integerValue];
                        break;
                    }
                    case 2:
                    {
                        stepIndex = [kUserUncertainIndex integerValue];
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        
        return stepIndex;
    };
    
    NSInteger(^DepthThreeResult)(ORKStep*, ORKTaskResult*) = ^NSInteger(ORKStep* step, ORKTaskResult* result)
    {
        NSInteger stepIndex = kNegativeStepIndex;
        
        if ([step.identifier isEqualToString:kUserFailedStepID])
        {
            ORKStepResult* stepResult = (ORKStepResult*)[result resultForIdentifier:step.identifier];
            
            if (stepResult)
            {
                ORKChoiceQuestionResult* choiceResult = (ORKChoiceQuestionResult*)[stepResult firstResult];
                
                if (choiceResult.choiceAnswers)
                {
                    NSArray* answers        = choiceResult.choiceAnswers;
                    NSArray* textChoices    = @[NSLocalizedString(kUserReasonsChoice, nil),
                                                NSLocalizedString(kUserInformation, nil)];
                    NSInteger index         = [textChoices indexOfObject:[answers firstObject]];
                    
                    //  Based on the selected answer lead the user to the correct step
                    switch (index) {
                        case 0:
                        {
                            stepIndex = [kReasonsStepIndex integerValue];
                            break;
                        }
                        case 1:
                        {
                            stepIndex = [kUserInputStepIndex integerValue];
                            break;
                        }
                        default:
                            break;
                    }
                }
            }
        }
        else if ([step.identifier isEqualToString:kUserUncertainID])
        {
            ORKStepResult* stepResult = (ORKStepResult*)[result resultForIdentifier:step.identifier];
            
            if (stepResult)
            {
                ORKChoiceQuestionResult* choiceResult = (ORKChoiceQuestionResult*)[stepResult firstResult];
                
                if (choiceResult.choiceAnswers)
                {
                    NSArray*    answers     = choiceResult.choiceAnswers;
                    NSArray*    textChoices = @[NSLocalizedString(kUserReasonsChoice, nil)];
                    NSInteger   index       = [textChoices indexOfObject:[answers firstObject]];
                    
                    //  Based on the selected answer lead the user to the correct step
                    switch (index) {
                        case 0:
                        {
                            stepIndex = [kReasonsTwoStepIndex integerValue];
                            break;
                        }
                        default:
                            break;
                    }
                }
            }
        }
        
        return stepIndex;
    };
    
    NSInteger(^DetermineNextStep)(ORKStep*, ORKTaskResult*) = ^NSInteger(ORKStep* step, ORKTaskResult* result)
    {
        NSInteger stepIndex = 0;
        
        if (step != nil)
        {
            if (self.steps.count > 1)
            {
                //  Determine the level or depth of the step
                NSInteger depth = DetermineStepDepth(step, result);
                
                //  Get the result, find the step identifier in steps corresponding to logical next step
                //  Pass back the index.
                switch (depth) {
                    case 1:
                    {
                        //  Always the second index!
                        stepIndex = [kUserProgressStepIndex integerValue];
                        
                        break;
                    }
                    case 2:
                    {
                        stepIndex = DepthTwoResult(step, result);
                        
                        break;
                    }
                    case 3:
                    {
                        stepIndex = DepthThreeResult(step, result);
                        
                        break;
                    }
                    case 4:
                    {
                        stepIndex = kNegativeStepIndex;
                        
                        break;
                    }
                        
                    default:
                    {
                        stepIndex = kNegativeStepIndex;
                        
                        break;
                    }
                }
            }
            else
            {
                stepIndex = kNegativeStepIndex;
            }
        }
        
        return stepIndex;
    };
    
    stepIndex = DetermineNextStep(step, result);
    
    if (stepIndex < 0)
    {
        step = nil;
    }
    else
    {
        step = self.steps[stepIndex];
    }
    
    return step;
}

- (nullable ORKStep *)stepBeforeStep:(nullable ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    NSInteger stepIndex = [kInstructionStepIndex integerValue];

    if ([step.identifier isEqualToString:kInstructionStepID])
    {
        stepIndex = kNegativeStepIndex;
    }
    else if ([step.identifier isEqualToString:kUserProgressStepID])
    {
        stepIndex = [kInstructionStepIndex integerValue];;
    }
    else if ([step.identifier isEqualToString:kUserSucceededStepID] || [step.identifier isEqualToString:kUserFailedStepID] || [step.identifier isEqualToString:kUserUncertainID])
    {
         stepIndex = [kUserProgressStepIndex integerValue];
    }
    else if ([step.identifier isEqualToString:kUserInputStepID])
    {
        stepIndex = [kUserFailedStepIndex integerValue];
    }
    else if ([step.identifier isEqualToString:kReasonsStepID])
    {
        stepIndex = [kUserFailedStepIndex integerValue];
    }
    else if ([step.identifier isEqualToString:kReasonsTwoStepID])
    {
        stepIndex = [kUserUncertainIndex integerValue];
    }
    
    if (stepIndex < 0)
    {
        step = nil;
    }
    else
    {
        step = self.steps[stepIndex];
    }
    
    return step;
}

@end
