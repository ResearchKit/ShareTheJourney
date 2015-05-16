// 
//  APHExerciseMotivationSummaryViewController.m 
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
 
#import "APHExerciseMotivationSummaryViewController.h"
#import "APHExerciseSummaryContainerTableViewController.h"

static NSString* const  kAPHExerciseSummaryContainerTableViewControllerSegue = @"APHExerciseSummaryContainerTableViewControllerSegue";
static NSString* const  kSummaryStepIdentifier                               = @"exercisesurvey107";

@interface APHExerciseMotivationSummaryViewController ()
@property (nonatomic, strong) ORKStepResult *cachedResult;
@property (nonatomic, strong) APHExerciseSummaryContainerTableViewController *childViewController;
@end

@implementation APHExerciseMotivationSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor appSecondaryColor4]];
}

- (void) setAnswersInTableview:(NSMutableArray*)answers {
        
    [self.childViewController setAnswers:answers];
}

- (void)setGoalButtonTitle:(NSString*)title
{
    [self.childViewController.changeYourGoalButton setTitle:title forState:UIControlStateNormal];
}

- (void)changeExerciseGoalAction {
    
    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:(ORKStepViewController *)self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

- (void)doneButtonTapped:(id) __unused sender
{
    if ([self.step.identifier isEqualToString:kSummaryStepIdentifier]) {
        
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id) __unused sender {
    
    if ([segue.identifier isEqualToString:kAPHExerciseSummaryContainerTableViewControllerSegue]) {
        self.childViewController = (APHExerciseSummaryContainerTableViewController *) [segue destinationViewController];
    }
}

- (ORKStepResult *)result {
    
    self.cachedResult = [[ORKStepResult alloc] initWithIdentifier:self.step.identifier];
    
    return self.cachedResult;
}

@end
