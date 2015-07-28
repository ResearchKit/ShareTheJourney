// 
//  APHDynamicMoodSurveyTask.m 
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
 
#import "APHDynamicMoodSurveyTask.h"

static  NSString  *MainStudyIdentifier  = @"com.breastcancer.moodsurvey";
static  NSString  *kMoodSurveyTaskIdentifier  = @"Mood Survey";

static  NSString  *kMoodSurveyStep101   = @"moodsurvey101";
static  NSString  *kMoodSurveyStep102   = @"moodsurvey102";
static  NSString  *kMoodSurveyStep103   = @"moodsurvey103";
static  NSString  *kMoodSurveyStep104   = @"moodsurvey104";
static  NSString  *kMoodSurveyStep105   = @"moodsurvey105";
static  NSString  *kMoodSurveyStep106   = @"moodsurvey106";
static  NSString  *kMoodSurveyStep107   = @"moodsurvey107";
static  NSString  *kMoodSurveyStep108   = @"moodsurvey108";

static  NSString  *kCustomMoodSurveyStep101   = @"customMoodSurveyStep101";
static  NSString  *kCustomMoodSurveyStep102   = @"customMoodSurveyStep102";
static  NSString  *kCustomMoodSurveyStep103   = @"customMoodSurveyStep103";

static NSInteger const kNumberOfCompletionsUntilDisplayingCustomSurvey = 6;

static NSInteger const kTextAnswerFormatWithMaximumLength = 90;

typedef NS_ENUM(NSUInteger, APHDynamicMoodSurveyType) {
    APHDynamicMoodSurveyTypeIntroduction = 0,
    APHDynamicMoodSurveyTypeCustomInstruction,
    APHDynamicMoodSurveyTypeCustomQuestionEntry,
    APHDynamicMoodSurveyTypeClarity,
    APHDynamicMoodSurveyTypeMood,
    APHDynamicMoodSurveyTypeEnergy,
    APHDynamicMoodSurveyTypeSleep,
    APHDynamicMoodSurveyTypeExercise,
    APHDynamicMoodSurveyTypeCustomSurvey,
    APHDynamicMoodSurveyTypeConclusion
};

@interface APHDynamicMoodSurveyTask()
@property (nonatomic, strong) NSDictionary *keys;
@property (nonatomic, strong) NSDictionary *backwardKeys;

@property (nonatomic, strong) NSString *customSurveyQuestion;

@property (nonatomic) NSInteger currentState;
@property (nonatomic) NSInteger currentCount;
@property (nonatomic, strong) NSDictionary *currentOrderedSteps;


@end
@implementation APHDynamicMoodSurveyTask

- (instancetype) init {
    
    NSArray* moodValueForIndex = @[@(5), @(4), @(3), @(2), @(1)];
    
    NSDictionary  *questionAnswerDictionary = @{
                                                
                                                
                                                
                                                kMoodSurveyStep102 : @[NSLocalizedString(@"perfectly crisp!", @""),
                                                                       NSLocalizedString(@"crisp", @""),
                                                                       NSLocalizedString(@"\"not great, but not too bad\"", @""),
                                                                       NSLocalizedString(@"foggy", @""),
                                                                       NSLocalizedString(@"poor", @"")
                                                                       ],
                                                
                                                kMoodSurveyStep103 : @[NSLocalizedString(@"fantastic!", @""),
                                                                       NSLocalizedString(@"better than usual", @""),
                                                                       NSLocalizedString(@"normal", @""),
                                                                       NSLocalizedString(@"down", @""),
                                                                       NSLocalizedString(@"at my lowest", @"")
                                                                       ],
                                                
                                                kMoodSurveyStep104 : @[NSLocalizedString(@"ready to take on the world!", @""),
                                                                       NSLocalizedString(@"good energy", @""),
                                                                       NSLocalizedString(@"OK to make it through the day", @""),
                                                                       NSLocalizedString(@"low energy", @""),
                                                                       NSLocalizedString(@"no energy", @"")
                                                                      ],
                                                
                                                kMoodSurveyStep105 : @[NSLocalizedString(@"best sleep ever", @""),
                                                                       NSLocalizedString(@"better sleep than usual", @""),
                                                                       NSLocalizedString(@"OK sleep", @""),
                                                                       NSLocalizedString(@"I wish I slept more", @""),
                                                                       NSLocalizedString(@"no sleep", @"")
                                                                     ],
  
                                                kMoodSurveyStep106 : @[NSLocalizedString(@"strenuous exercise (heart beats rapidly)", @""),
                                                                       NSLocalizedString(@"moderate exercise (tiring but not exhausting)", @""),
                                                                       NSLocalizedString(@"mild exercise (some effort)", @""),
                                                                       NSLocalizedString(@"minimal exercise (no effort)", @""),
                                                                       NSLocalizedString(@"no exercise", @"")
                                                                       ],

                                                kMoodSurveyStep107 : @[NSLocalizedString(@"great", @""),
                                                                       NSLocalizedString(@"good", @""),
                                                                       NSLocalizedString(@"average", @""),
                                                                       NSLocalizedString(@"bad", @""),
                                                                       NSLocalizedString(@"terrible", @"")
                                                                       ],
                                                };
    
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kMoodSurveyStep101];
        step.detailText = nil;
        
        
        [steps addObject:step];
    }
    
    
    /**** Custom Survey Steps */
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kCustomMoodSurveyStep101];
        step.title = NSLocalizedString(@"Customize Survey", @"");
        step.detailText = NSLocalizedString(@"You now have the ability to create your own survey question. Tap Get Started to enter your question.", @"");

        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:kCustomMoodSurveyStep102];
        
        step.text = NSLocalizedString(@"Customize your question.", @"");
        
        
        ORKAnswerFormat *textAnswerFormat = [ORKAnswerFormat textAnswerFormatWithMaximumLength:kTextAnswerFormatWithMaximumLength];

        [step setAnswerFormat:textAnswerFormat];
        
        [steps addObject:step];
    }
    
    /*****/
    
    
    
    {
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Clarity-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Clarity-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Clarity-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Clarity-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Clarity-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Clarity-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Clarity-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Clarity-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Clarity-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Clarity-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep102];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep102
                                                                        title:NSLocalizedString(@"Today, my thinking is:", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    {
        
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Mood-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Mood-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Mood-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Mood-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Mood-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Mood-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Mood-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Mood-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Mood-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Mood-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep103];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep103
                                                                        title:NSLocalizedString(@"Today, my mood is:", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    {
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Energy-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Energy-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Energy-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Energy-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Energy-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Energy-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Energy-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Energy-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Energy-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Energy-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep104];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep104
                                                                        title:NSLocalizedString(@"Today, my energy level is:", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    {
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Sleep-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Sleep-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Sleep-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Sleep-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Sleep-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Sleep-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Sleep-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Sleep-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Sleep-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Sleep-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep105];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep105
                                                                        title:NSLocalizedString(@"The quality of my sleep last night was:", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    {
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Exercise-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Exercise-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Exercise-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Exercise-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Exercise-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Exercise-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Exercise-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Exercise-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Exercise-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Exercise-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep106];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep106
                                                                        title:NSLocalizedString(@"The most I exercised in the last day was:", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    {
        NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Custom-1g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Custom-2g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Custom-3g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Custom-4g"],
                                  [UIImage imageNamed:@"Breast-Cancer-Custom-5g"]];
        
        NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Custom-1p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Custom-2p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Custom-3p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Custom-4p"],
                                          [UIImage imageNamed:@"Breast-Cancer-Custom-5p"]];
        
        NSArray *textDescriptionChoice = [questionAnswerDictionary objectForKey:kMoodSurveyStep107];
        
        
        NSMutableArray *answerChoices = [NSMutableArray new];
        
        for (NSUInteger i = 0; i<[imageChoices count]; i++) {
            
            ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
            
            [answerChoices addObject:answerOption];
        }
        
        ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep107
                                                                        title:NSLocalizedString(@"Custom Survey Question?", @"")
                                                                       answer:format];
        
        [steps addObject:step];
    }
    
    
    {
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep108
                                                                        title:NSLocalizedString(@"What level exercise are you getting today?", @"")
                                                                       answer:nil];
        
        [steps addObject:step];
    }
    self  = [super initWithIdentifier:kMoodSurveyTaskIdentifier steps:steps];
    
    return self;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    BOOL completedNumberOfTimes = NO;
    
    //Check if we have reached the threshold to display customizing a survey question.
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        
    if (delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter == kNumberOfCompletionsUntilDisplayingCustomSurvey && delegate.dataSubstrate.currentUser.customSurveyQuestion == nil) {
        completedNumberOfTimes = YES;
        
        ORKStepResult *stepResult = [result stepResultForStepIdentifier:kCustomMoodSurveyStep102];
        NSString *skipQuestion = [stepResult.results.firstObject textAnswer];
        
        if (skipQuestion != nil) {
            if ([step.identifier isEqualToString:kMoodSurveyStep108])
            {
                [delegate.dataSubstrate.currentUser setCustomSurveyQuestion:skipQuestion];
            }
            
            self.customSurveyQuestion = skipQuestion;
        } else {
            [delegate.dataSubstrate.currentUser setCustomSurveyQuestion:skipQuestion];
            self.customSurveyQuestion = skipQuestion;
        }
    }
    
    if (delegate.dataSubstrate.currentUser.customSurveyQuestion) {
        self.customSurveyQuestion = delegate.dataSubstrate.currentUser.customSurveyQuestion;
    }

    //set the basic state
    [self setFlowState:0];
    
    
    if ([step.identifier isEqualToString:kMoodSurveyStep108] && delegate.dataSubstrate.currentUser.customSurveyQuestion && delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter == kNumberOfCompletionsUntilDisplayingCustomSurvey)
    {
        [self setFlowState:4];
    }
    else if (delegate.dataSubstrate.currentUser.customSurveyQuestion)
    {
        //Used only if the custom question is already being set in profile.
        [self setFlowState:1];
    }
    
    else if (self.customSurveyQuestion != nil && ![step.identifier isEqualToString:kCustomMoodSurveyStep102] && delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter != kNumberOfCompletionsUntilDisplayingCustomSurvey)
    {
        //If there is a custom question present custom survey
        [self setFlowState:2];
    }
    
    else if (completedNumberOfTimes && self.customSurveyQuestion == nil)

    {
        [self setFlowState:3];
        
    }

    else if (completedNumberOfTimes)
    
    {
        //This is the Daily Check-in with custom survey question and with custom survey
        [self setFlowState:4];
    }

    
    if (step == nil)
    {
        step = self.steps[0];
        self.currentCount = 1;
    }
    
    else if ([[self.steps[self.steps.count - 1] identifier] isEqualToString:step.identifier])
    {
        step = nil;
    }
    else
    {
        NSNumber *index = (NSNumber *) self.keys[step.identifier];
        
        step = self.steps[[index intValue]];
        
        self.currentCount = [index integerValue];
    
    }
    
    if ([step.identifier isEqualToString:kMoodSurveyStep107] && self.customSurveyQuestion != nil) {
        step = [self customQuestionStep:self.customSurveyQuestion];
    }
    
    return step;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    if ([[self.steps[0] identifier] isEqualToString:step.identifier]) {
        step = nil;
    }
    
    else
    {
        NSNumber *index = (NSNumber *) self.backwardKeys[step.identifier];
        
        step = self.steps[[index intValue]];
    }
    
    if ([step.identifier isEqualToString:kMoodSurveyStep107] && self.customSurveyQuestion != nil) {
        step = [self customQuestionStep:self.customSurveyQuestion];
    }
    
    return step;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    
    return ORKTaskProgressMake([[self.currentOrderedSteps objectForKey:step.identifier] integerValue] - 1, self.currentOrderedSteps.count);
}

- (void) setFlowState:(NSInteger)state {
    
    self.currentState = state;
    
    switch (state) {
        case 0:
        {
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeExercise),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeClarity),
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kMoodSurveyStep102       : @(2),
                                            kMoodSurveyStep103       : @(3),
                                            kMoodSurveyStep104       : @(4),
                                            kMoodSurveyStep105       : @(5),
                                            kMoodSurveyStep106       : @(6),
                                            kMoodSurveyStep108       : @(7)
                                            };
            
        }
            break;
        case 1:
        {
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeConclusion),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kMoodSurveyStep107       : @(2),
                                            kMoodSurveyStep102       : @(3),
                                            kMoodSurveyStep103       : @(4),
                                            kMoodSurveyStep104       : @(5),
                                            kMoodSurveyStep105       : @(6),
                                            kMoodSurveyStep106       : @(7),
                                            kMoodSurveyStep108       : @(8)
                                            };

        }
            break;
        case 2:
        {
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeConclusion),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kMoodSurveyStep107       : @(2),
                                            kMoodSurveyStep102       : @(3),
                                            kMoodSurveyStep103       : @(4),
                                            kMoodSurveyStep104       : @(5),
                                            kMoodSurveyStep105       : @(6),
                                            kMoodSurveyStep106       : @(7),
                                            kMoodSurveyStep108       : @(8)
                                            };


        }
            break;
            
        case 3:
        {
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kCustomMoodSurveyStep102 : @(APHDynamicMoodSurveyTypeCustomInstruction),
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeCustomQuestionEntry),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeCustomInstruction),
                                            kCustomMoodSurveyStep101 : @(APHDynamicMoodSurveyTypeCustomQuestionEntry),
                                            kCustomMoodSurveyStep102 : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kCustomMoodSurveyStep101 : @(2),
                                            kCustomMoodSurveyStep102 : @(3),
                                            kMoodSurveyStep102       : @(4),
                                            kMoodSurveyStep103       : @(5),
                                            kMoodSurveyStep104       : @(6),
                                            kMoodSurveyStep105       : @(7),
                                            kMoodSurveyStep106       : @(8),
                                            kMoodSurveyStep108       : @(9)
                                            };

        }
            break;
            
        case 4:
        {
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kCustomMoodSurveyStep102 : @(APHDynamicMoodSurveyTypeCustomInstruction),
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeCustomQuestionEntry),
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeExercise),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeCustomInstruction),
                                            kCustomMoodSurveyStep101 : @(APHDynamicMoodSurveyTypeCustomQuestionEntry),
                                            kCustomMoodSurveyStep102 : @(APHDynamicMoodSurveyTypeCustomSurvey),
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kCustomMoodSurveyStep101 : @(2),
                                            kCustomMoodSurveyStep102 : @(3),
                                            kMoodSurveyStep107       : @(4),
                                            kMoodSurveyStep102       : @(5),
                                            kMoodSurveyStep103       : @(6),
                                            kMoodSurveyStep104       : @(7),
                                            kMoodSurveyStep105       : @(8),
                                            kMoodSurveyStep106       : @(9),
                                            kMoodSurveyStep108       : @(10)
                                            };
        }
            break;
            
        default:{
            self.backwardKeys           = @{
                                            kMoodSurveyStep101       : [NSNull null],
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeIntroduction),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeClarity),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : @(APHDynamicMoodSurveyTypeExercise),
                                            
                                            };
            
            self.keys                   = @{
                                            kMoodSurveyStep101       : @(APHDynamicMoodSurveyTypeClarity),
                                            kCustomMoodSurveyStep101 : [NSNull null],
                                            kCustomMoodSurveyStep102 : [NSNull null],
                                            kMoodSurveyStep102       : @(APHDynamicMoodSurveyTypeMood),
                                            kMoodSurveyStep103       : @(APHDynamicMoodSurveyTypeEnergy),
                                            kMoodSurveyStep104       : @(APHDynamicMoodSurveyTypeSleep),
                                            kMoodSurveyStep105       : @(APHDynamicMoodSurveyTypeExercise),
                                            kMoodSurveyStep106       : @(APHDynamicMoodSurveyTypeConclusion),
                                            kMoodSurveyStep107       : [NSNull null],
                                            kMoodSurveyStep108       : [NSNull null]
                                            };
            
            self.currentOrderedSteps    = @{
                                            kMoodSurveyStep101       : @(1),
                                            kMoodSurveyStep102       : @(2),
                                            kMoodSurveyStep103       : @(3),
                                            kMoodSurveyStep104       : @(4),
                                            kMoodSurveyStep105       : @(5),
                                            kMoodSurveyStep106       : @(6),
                                            kMoodSurveyStep108       : @(7)
                                            };
           
        }
            break;
    }
}

- (ORKQuestionStep *) customQuestionStep:(NSString *) __unused question {
    
    NSArray* moodValueForIndex = @[@(5), @(4), @(3), @(2), @(1)];
    
    NSArray *imageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Custom-1g"],
                              [UIImage imageNamed:@"Breast-Cancer-Custom-2g"],
                              [UIImage imageNamed:@"Breast-Cancer-Custom-3g"],
                              [UIImage imageNamed:@"Breast-Cancer-Custom-4g"],
                              [UIImage imageNamed:@"Breast-Cancer-Custom-5g"]];
    
    NSArray *selectedImageChoices = @[[UIImage imageNamed:@"Breast-Cancer-Custom-1p"],
                                      [UIImage imageNamed:@"Breast-Cancer-Custom-2p"],
                                      [UIImage imageNamed:@"Breast-Cancer-Custom-3p"],
                                      [UIImage imageNamed:@"Breast-Cancer-Custom-4p"],
                                      [UIImage imageNamed:@"Breast-Cancer-Custom-5p"]];
    
    NSArray *textDescriptionChoice = @[NSLocalizedString(@"Great", @""),
                                      NSLocalizedString(@"Good", @""),
                                      NSLocalizedString(@"Average", @""),
                                      NSLocalizedString(@"Bad", @""),
                                      NSLocalizedString(@"Terrible", @"")
                                      ];
    
    NSMutableArray *answerChoices = [NSMutableArray new];
    
    for (NSUInteger i = 0; i<[imageChoices count]; i++) {
        
        ORKImageChoice *answerOption = [ORKImageChoice choiceWithNormalImage:imageChoices[i] selectedImage:selectedImageChoices[i] text:textDescriptionChoice[i] value:[moodValueForIndex objectAtIndex:i]];
        
        [answerChoices addObject:answerOption];
    }
    
    ORKImageChoiceAnswerFormat *format = [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:answerChoices];
    
    ORKQuestionStep *questionStep = [ORKQuestionStep questionStepWithIdentifier:kMoodSurveyStep107
                                                                            title:self.customSurveyQuestion
                                                                           answer:format];
    
    return questionStep;
}

@end
