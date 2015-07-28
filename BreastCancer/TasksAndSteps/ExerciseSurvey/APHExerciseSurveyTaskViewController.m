// 
//  APHExerciseSurveyTaskViewController.m 
//  Share the Journey 
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
 
#import "APHExerciseSurveyTaskViewController.h"
#import "APHExerciseMotivationIntroViewController.h"
#import "APHQuestionViewController.h"
#import "APHExerciseMotivationSummaryViewController.h"

static  NSString  *MainStudyIdentifier = @"com.breastcancer.exercisesurvey";

static  NSString  *kExerciseSurveyStep100 = @"exercisesurvey100";
static  NSString  *kExerciseSurveyStep101 = @"exercisesurvey101";
static  NSString  *kExerciseSurveyStep102 = @"exercisesurvey102";
static  NSString  *kExerciseSurveyStep103 = @"exercisesurvey103";
static  NSString  *kExerciseSurveyStep104 = @"exercisesurvey104";
static  NSString  *kExerciseSurveyStep105 = @"exercisesurvey105";
static  NSString  *kExerciseSurveyStep106 = @"exercisesurvey106";
static  NSString  *kExerciseSurveyStep107 = @"exercisesurvey107";
static  NSString  *kExerciseSurveyStep108 = @"exercisesurvey108";

static NSString *kWalkFiveThousandSteps = @"Walk 5,000 steps every day";
static NSString *kExerciseEverySingleDay = @"Exercise Every Single Day for at least 30 minutes";
static NSString *kExerciseThreeTimesPerWeek = @"Exercise at least 3 times per week for at least 30 minutes";
static NSString *kWalkTenThousandSteps = @"Walk 10,000 steps at least 3 times per week";

@interface APHExerciseSurveyTaskViewController ()

@property (nonatomic, strong) NSString *previousStepIdentifier;
@property (strong, nonatomic) NSMutableDictionary *previousCachedAnswer;
@end

@implementation APHExerciseSurveyTaskViewController

/*********************************************************************************/
#pragma  mark  -  View Controller Methods
/*********************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.previousCachedAnswer = [NSMutableDictionary new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSString *)createResultSummary {
    
    NSMutableDictionary *resultCollectionDictionary = [NSMutableDictionary new];
    NSArray *arrayOfResults = self.result.results;
    
    for (ORKStepResult *stepResult in arrayOfResults) {
        if (stepResult.results.firstObject) {
            APCDataResult *questionResult = stepResult.results.firstObject;
            NSData *resultData = questionResult.data;
            
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:resultData
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
            
            NSString *answer = [result objectForKey:@"result"];
            
            if (answer != nil) {
                resultCollectionDictionary[stepResult.identifier] = answer;
            }
        }
    }
    
    NSError *error = nil;
    
    NSData  *moodAnswersJson = [NSJSONSerialization dataWithJSONObject:resultCollectionDictionary options:0 error:&error];
    
    NSString *contentString = nil;
    
    if (!error) {
        contentString = [[NSString alloc] initWithData:moodAnswersJson encoding:NSUTF8StringEncoding];
    } else {
        APCLogError2(error);
    }
    
    return contentString;
}


//NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
//NSError *error = nil;
//result = [NSJSONSerialization JSONObjectWithData:resultData
//                                         options:NSJSONReadingAllowFragments
//                                           error:&error];

/*********************************************************************************/
#pragma  mark  -  Task Creation Methods
/*********************************************************************************/

+ (ORKOrderedTask *)createTask:(APCScheduledTask *)scheduledTask
{
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    if ([scheduledTask.completed boolValue]) {
        ORKStep *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep100];
        
        [steps addObject:step];
    }
    
    {
        ORKStep *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep101];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep102];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep103];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep104];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep105];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep106];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep107];
        
        [steps addObject:step];
    }
    
    {
        ORKStep  *step = [[ORKStep alloc] initWithIdentifier:kExerciseSurveyStep108];
        
        [steps addObject:step];
    }
    
    //The identifier gets set as the title in the navigation bar.
    ORKOrderedTask  *task = [[ORKOrderedTask alloc] initWithIdentifier:@"Journal" steps:steps];
    
    return  task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/

- (ORKStepViewController *)taskViewController:(ORKTaskViewController *) __unused taskViewController viewControllerForStep:(ORKStep *)step {
    

    NSDictionary  *controllers = @{kExerciseSurveyStep100 : [APHExerciseMotivationSummaryViewController class],
                                   kExerciseSurveyStep101 : [APHExerciseMotivationIntroViewController class],
                                   kExerciseSurveyStep102 : [APHQuestionViewController class],
                                   kExerciseSurveyStep103 : [APHQuestionViewController class],
                                   kExerciseSurveyStep104 : [APHQuestionViewController class],
                                   kExerciseSurveyStep105 : [APHQuestionViewController class],
                                   kExerciseSurveyStep106 : [APHQuestionViewController class],
                                   kExerciseSurveyStep107 : [APHExerciseMotivationSummaryViewController class],
                                   kExerciseSurveyStep108 : [APCSimpleTaskSummaryViewController class]
                                   };
    
    Class  aClass = [controllers objectForKey:step.identifier];
    
    APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
    
    if (step.identifier == kExerciseSurveyStep108 ) {
        APCSimpleTaskSummaryViewController *stepVC = [[APCSimpleTaskSummaryViewController alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
        
        (void)stepVC.view;
        stepVC.delegate = self;
        stepVC.step = step;
        stepVC.youCanCompareMessage.text = nil;
        
        controller = stepVC;
    } else if ( step.identifier == kExerciseSurveyStep107 || step.identifier == kExerciseSurveyStep100) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"APHExerciseMotivationSummaryViewController"
                                                                 bundle:nil];
        
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"APHExerciseMotivationSummaryViewController"];
    }
    
    controller.delegate = self;
    controller.step = step;
    
    
    return controller;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    
    NSDictionary *stepQuestions = @{
                                    kExerciseSurveyStep102 : @"Why is this your goal?",
                                    kExerciseSurveyStep103 : @"What will you gain?",
                                    kExerciseSurveyStep104 : @"How does this benefit you?",
                                    kExerciseSurveyStep105 : @"Why?",
                                    kExerciseSurveyStep106 : @"How will you reach your goal?",
                                    };
    
    if (kExerciseSurveyStep100 == stepViewController.step.identifier) {
        APHExerciseMotivationSummaryViewController *questionSummaryVC = (APHExerciseMotivationSummaryViewController *)stepViewController;

        NSDictionary *result = nil;
        NSArray *scheduledTaskResults = [self.scheduledTask.results allObjects];
        
        NSSortDescriptor *sortByCreateAtDescending = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                                 ascending:NO];
        
        NSArray *sortedScheduleTaskresults = [scheduledTaskResults sortedArrayUsingDescriptors:@[sortByCreateAtDescending]];
        
        NSString *resultSummary = nil;
        
        for (APCResult *result in sortedScheduleTaskresults) {
            resultSummary = [result resultSummary];
            if (resultSummary) {
                break;
            }
        }
        
        if (resultSummary) {
            NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            result = [NSJSONSerialization JSONObjectWithData:resultData
                                                     options:NSJSONReadingAllowFragments
                                                       error:&error];
        }

        NSArray *stepQuestions = @[
                                    kExerciseSurveyStep102,
                                    kExerciseSurveyStep103,
                                    kExerciseSurveyStep104,
                                    kExerciseSurveyStep105,
                                    kExerciseSurveyStep106,
                                    ];
        
        NSMutableArray *arrayOfAnswers = [NSMutableArray new];
        
        for (NSString *identifiers in stepQuestions) {
            [arrayOfAnswers addObject:[result objectForKey:identifiers]];
        }
        
        
        NSDictionary *goalImages = @{
                                     kExerciseEverySingleDay : @"banner_exersiseeveryday",
                                     kExerciseThreeTimesPerWeek : @"banner_exersise3x",
                                     kWalkFiveThousandSteps : @"banner_5ksteps",
                                     kWalkTenThousandSteps : @"banner_10ksteps"
                                     };
        
        NSArray *arrayOfGoalChoices = @[kExerciseEverySingleDay, kExerciseThreeTimesPerWeek, kWalkFiveThousandSteps, kWalkTenThousandSteps];

        
        for (NSString *goalString in arrayOfGoalChoices) {
            if ([goalString isEqualToString:result[kExerciseSurveyStep101]]) {
                
                [questionSummaryVC.titleImageView setImage:[UIImage imageNamed:goalImages[goalString]]];
                
            }
        }

        [questionSummaryVC setAnswersInTableview:arrayOfAnswers];
        
    } else if (kExerciseSurveyStep101 == stepViewController.step.identifier) {
        
    } else if (kExerciseSurveyStep102 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep101;
        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kExerciseSurveyStep101];
        
        APHQuestionViewController *questionVC = (APHQuestionViewController *)stepViewController;
        questionVC.previousAnswer.text = [self extractResult:stepResult withIdentifier:kExerciseSurveyStep101];
        questionVC.currentQuestion.text = [stepQuestions objectForKey:stepViewController.step.identifier];
        
        questionVC.scriptorium.text = self.previousCachedAnswer[kExerciseSurveyStep102];
        
    } else if (kExerciseSurveyStep103 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep102;
        
        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kExerciseSurveyStep102];
        
        APHQuestionViewController *questionVC = (APHQuestionViewController *)stepViewController;
        questionVC.previousAnswer.text = [self extractResult:stepResult withIdentifier:self.previousStepIdentifier];
        questionVC.currentQuestion.text = [stepQuestions objectForKey:stepViewController.step.identifier];
        
        questionVC.scriptorium.text = self.previousCachedAnswer[kExerciseSurveyStep103];
        
    } else if (kExerciseSurveyStep104 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep103;
        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kExerciseSurveyStep103];
        
        APHQuestionViewController *questionVC = (APHQuestionViewController *)stepViewController;
        questionVC.previousAnswer.text = [self extractResult:stepResult withIdentifier:self.previousStepIdentifier];
        questionVC.currentQuestion.text = [stepQuestions objectForKey:stepViewController.step.identifier];
        
        questionVC.scriptorium.text = self.previousCachedAnswer[kExerciseSurveyStep104];
        
    } else if (kExerciseSurveyStep105 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep104;
        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kExerciseSurveyStep104];
        
        APHQuestionViewController *questionVC = (APHQuestionViewController *)stepViewController;
        questionVC.previousAnswer.text = [self extractResult:stepResult withIdentifier:self.previousStepIdentifier];
        questionVC.currentQuestion.text = [stepQuestions objectForKey:stepViewController.step.identifier];
        
        questionVC.scriptorium.text = self.previousCachedAnswer[kExerciseSurveyStep105];
        
    } else if (kExerciseSurveyStep106 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep105;
        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:kExerciseSurveyStep105];
        
        APHQuestionViewController *questionVC = (APHQuestionViewController *)stepViewController;
        questionVC.previousAnswer.text = [self extractResult:stepResult withIdentifier:self.previousStepIdentifier];
        questionVC.currentQuestion.text = [stepQuestions objectForKey:stepViewController.step.identifier];

        questionVC.scriptorium.text = self.previousCachedAnswer[kExerciseSurveyStep106];
        
    } else if (kExerciseSurveyStep107 == stepViewController.step.identifier) {
        self.previousStepIdentifier = kExerciseSurveyStep106;
        APHExerciseMotivationSummaryViewController *questionSummaryVC = (APHExerciseMotivationSummaryViewController *)stepViewController;
        
        questionSummaryVC.questionResult1 = @"";
        questionSummaryVC.questionResult2 = @"";
        questionSummaryVC.questionResult3 = @"";
        questionSummaryVC.questionResult4 = @"";
        questionSummaryVC.questionResult5 = @"";
        
        NSArray *summaryLabels = @[questionSummaryVC.questionResult1, questionSummaryVC.questionResult2, questionSummaryVC.questionResult3, questionSummaryVC.questionResult4, questionSummaryVC.questionResult5];
        
        NSArray *stepIdentifiers = @[kExerciseSurveyStep101, kExerciseSurveyStep102, kExerciseSurveyStep103, kExerciseSurveyStep104, kExerciseSurveyStep105, kExerciseSurveyStep106, kExerciseSurveyStep107, kExerciseSurveyStep108];
        
        NSMutableArray *arrayOfAnswers = [NSMutableArray new];
        for (NSUInteger i = 0; i < [summaryLabels count]; i++) {
            NSString *stringIdentifier = [NSString stringWithFormat:@"exercisesurvey10%d", (int) i+2];
            ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:stepIdentifiers[i + 1]];
            NSString *label = (NSString *) summaryLabels[i];
            label = (NSString *) [self extractResult:stepResult withIdentifier:stringIdentifier];
            [arrayOfAnswers addObject:label];
        }

        ORKStepResult *stepResult = [taskViewController.result stepResultForStepIdentifier:stepIdentifiers[0]];
        
        NSString *selectedGoal = [self extractResult:stepResult withIdentifier:kExerciseSurveyStep101];
        
        NSArray *arrayOfGoalChoices = @[kExerciseEverySingleDay, kExerciseThreeTimesPerWeek, kWalkFiveThousandSteps, kWalkTenThousandSteps];

        NSDictionary *goalImages = @{
                                        kExerciseEverySingleDay : @"banner_exersiseeveryday",
                                        kExerciseThreeTimesPerWeek : @"banner_exersise3x",
                                        kWalkFiveThousandSteps : @"banner_5ksteps",
                                        kWalkTenThousandSteps : @"banner_10ksteps"
                                        };
        
        for (NSString *goalString in arrayOfGoalChoices) {
            if ([goalString isEqualToString:selectedGoal]) {
                
                [questionSummaryVC.titleImageView setImage:[UIImage imageNamed:goalImages[goalString]]];
                
            }
        }
        
        [questionSummaryVC setAnswersInTableview:arrayOfAnswers];
        
        
    } else if (kExerciseSurveyStep108 == stepViewController.step.identifier) {
        

    }
    
}


- (void)stepViewControllerResultDidChange:(ORKStepViewController *) __unused stepViewController {
    NSLog(@"TaskVC didChangeResult");
    
    if (![self.currentStepViewController.step.identifier isEqualToString:kExerciseSurveyStep108]) {
        
        ORKStepResult *stepResult = [self.result stepResultForStepIdentifier:self.currentStepViewController.step.identifier];
        
        APCDataResult *contentResult = (APCDataResult *)[stepResult resultForIdentifier:self.currentStepViewController.step.identifier];
        
        NSError* error;
        NSDictionary* stepResultJson = [NSJSONSerialization JSONObjectWithData:contentResult.data
                                                                       options:kNilOptions
                                                                         error:&error];
        NSLog(@"%@", [[NSString alloc] initWithData:contentResult.data encoding:NSUTF8StringEncoding]);
        
        self.previousCachedAnswer[self.currentStepViewController.step.identifier] = stepResultJson[@"result"];
    }
}


/*********************************************************************************/
#pragma  mark  -  Helper Methods
/*********************************************************************************/
- (NSString *)extractResult:(ORKStepResult *)result withIdentifier:(NSString *)identifier {
    
    APCDataResult *contentResult = (APCDataResult *)[result resultForIdentifier:identifier];
    
    NSError* error;
    NSDictionary* stepResultJson = [NSJSONSerialization JSONObjectWithData:contentResult.data
                                                                   options:kNilOptions
                                                                     error:&error];
    NSLog(@"%@", [[NSString alloc] initWithData:contentResult.data encoding:NSUTF8StringEncoding]);
    
    return [stepResultJson valueForKey:@"result"];
}

@end
