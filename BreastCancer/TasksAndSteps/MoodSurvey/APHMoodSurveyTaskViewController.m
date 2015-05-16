// 
//  APHMoodSurveyTaskViewController.m 
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
 
#import "APHMoodSurveyTaskViewController.h"
#import "APHHeartAgeIntroStepViewController.h"
#import "APHCustomSurveyIntroViewController.h"
#import "APHCustomSurveyQuestionViewController.h"
#import "APHDynamicMoodSurveyTask.h"
#import <QuartzCore/QuartzCore.h>

static  NSString  *MainStudyIdentifier  = @"com.breastcancer.moodsurvey";

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

static NSString   *kLearnMoreString = @"Creating a custom question will help you track something personal to you over time. Think about something you care deeply about and would like to see how your performance in that area changes with your post-treatment evolution.\nSome examples may include:\n- How was your morning run today?\n- My work day today was...\n\nWe will track your question in the dashboard (shown as \"Custom Question\") over time. Remember that you can always go to your profile and change this question.";

static NSInteger const kFontSize = 17;

static NSInteger const kNumberOfCompletionsUntilDisplayingCustomSurvey = 7;

@interface APHMoodSurveyTaskViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableDictionary *previousCachedAnswer;
@property (strong, nonatomic) UIImageView *customSurveylearnMoreView;

@end

@implementation APHMoodSurveyTaskViewController

/*********************************************************************************/
#pragma  mark  -  View Controller Methods
/*********************************************************************************/

- (NSString *)createResultSummary {
    
    NSMutableDictionary *resultCollectionDictionary = [NSMutableDictionary new];
    NSArray *arrayOfResults = self.result.results;
    
    for (ORKStepResult *stepResult in arrayOfResults) {
        if (stepResult.results.firstObject) {
            
            if ( ![stepResult.results.firstObject isKindOfClass:[ORKTextQuestionResult class]]) {
                ORKChoiceQuestionResult *questionResult = stepResult.results.firstObject;
                
                if (questionResult.choiceAnswers != nil) {
                    id selectedAnswer = [questionResult.choiceAnswers firstObject];
                    
                    if (selectedAnswer) {
                        resultCollectionDictionary[stepResult.identifier] = (NSNumber *)selectedAnswer;
                    }
                }
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

/*********************************************************************************/
#pragma mark - Initialize
/*********************************************************************************/

+ (id<ORKTask>)createTask:(APCScheduledTask *) __unused scheduledTask
{
    APHDynamicMoodSurveyTask *task = [[APHDynamicMoodSurveyTask alloc] init];
    
    return task;
}

/*********************************************************************************/
#pragma  mark  - TaskViewController delegates
/*********************************************************************************/


- (ORKStepViewController *)taskViewController:(ORKTaskViewController *) __unused taskViewController viewControllerForStep:(ORKStep *)step {
    
    NSDictionary  *controllers = @{
                                   kMoodSurveyStep101 : [APHHeartAgeIntroStepViewController class],
                                   kMoodSurveyStep108 : [APCSimpleTaskSummaryViewController class]
                                   };
    
    Class  aClass = [controllers objectForKey:step.identifier];
    
    APCStepViewController  *controller = [[aClass alloc] initWithNibName:nil bundle:nil];
    
    if (step.identifier == kMoodSurveyStep108)
    {
        controller = [[aClass alloc] initWithNibName:nil bundle:[NSBundle appleCoreBundle]];
    }
    
    controller.delegate = self;
    controller.step = step;
    
    
    return controller;
}

- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error
{
    [super taskViewController:taskViewController didFinishWithReason:reason error:error];

    //Here we are keeping a count of the Daily Check-IN being completed. We are keeping track only up to 7.
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    if (delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter < kNumberOfCompletionsUntilDisplayingCustomSurvey) {
        delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter++;
    }
}

- (BOOL)taskViewController:(ORKTaskViewController *) __unused taskViewController hasLearnMoreForStep:(ORKStep *)step {
    
    BOOL hasLearnMore = NO;
    
    if ([step.identifier isEqualToString:kCustomMoodSurveyStep101]) {
        hasLearnMore = YES;
    }
    
    return hasLearnMore;
}

- (void)taskViewController:(ORKTaskViewController *) __unused taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    
    //[stepViewController.view setUserInteractionEnabled:NO];
    
    UIImage *blurredImage = [self.view blurredSnapshotDark];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.customSurveylearnMoreView = imageView;
    imageView.alpha = 0;
    [imageView setBounds:[UIScreen mainScreen].bounds];

    [stepViewController.view addSubview:imageView];
    imageView.image = blurredImage;
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 1;
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLearnMore:)];
    [imageView setUserInteractionEnabled:YES];

    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    
    [imageView addGestureRecognizer:tapGesture];

    UIView *learnMoreBubble = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [learnMoreBubble setBackgroundColor:[UIColor whiteColor]];
    learnMoreBubble.layer.cornerRadius = 5;
    learnMoreBubble.layer.masksToBounds = YES;
    
    [imageView addSubview:learnMoreBubble];
    
    [learnMoreBubble setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // SET THE WIDTH
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.9
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.5
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeCenterY
                              multiplier:0.6
                              constant:0.0]];
    
    [imageView addConstraint:[NSLayoutConstraint
                              constraintWithItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:imageView
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0.0]];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, learnMoreBubble.bounds.size.width, 100.0)];
    [learnMoreBubble addSubview:textView];
    
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                              constraintWithItem:textView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:learnMoreBubble
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.85
                              constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                              constraintWithItem:textView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:learnMoreBubble
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.9
                              constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                              constraintWithItem:textView
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1
                              constant:0.0]];
    
    [learnMoreBubble addConstraint:[NSLayoutConstraint
                              constraintWithItem:textView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:learnMoreBubble
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0.0]];
    
    textView.text =NSLocalizedString( kLearnMoreString, kLearnMoreString);

    textView.textColor = [UIColor blackColor];
    [textView setFont:[UIFont appRegularFontWithSize:kFontSize]];
    textView.numberOfLines = 0;
    textView.adjustsFontSizeToFitWidth  = YES;
    
}

- (void)removeLearnMore:(id) __unused sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.customSurveylearnMoreView.alpha = 0;
    } completion:^(BOOL __unused finished) {
        [self.customSurveylearnMoreView removeFromSuperview];
    }];
}

@end
