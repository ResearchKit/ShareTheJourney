// 
//  APHExerciseSummaryContainerTableViewController.m 
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
 
#import "APHExerciseSummaryContainerTableViewController.h"
#import "APHExerciseMotivationSummaryViewController.h"

static NSString* const  kSummaryStepIdentifier       = @"exercisesurvey107";
static NSString* const  kBreastCancerRibbonImageName = @"BreastCancer-Ribbon";

@interface APHExerciseSummaryContainerTableViewController ()
@property (weak, nonatomic) IBOutlet    UILabel* answer1Label;
@property (weak, nonatomic) IBOutlet    UILabel* answer2Label;
@property (weak, nonatomic) IBOutlet    UILabel* answer3Label;
@property (weak, nonatomic) IBOutlet    UILabel* answer4Label;
@property (weak, nonatomic) IBOutlet    UILabel* answer5Label;

@property (nonatomic, strong) APHExerciseMotivationSummaryViewController *parent;
@end

@implementation APHExerciseSummaryContainerTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.parent = (APHExerciseMotivationSummaryViewController *) self.parentViewController;
    
    if ([self.parent.step.identifier isEqualToString:kSummaryStepIdentifier]) {
        
        [self.changeYourGoalButton setTitle:@"Next" forState:UIControlStateNormal];
    }

}
- (void)setAnswers:(NSMutableArray *)answers {

    _answers = answers;
    
    NSArray *answerLabels = @[self.answer1Label,
                              self.answer2Label,
                              self.answer3Label,
                              self.answer4Label,
                              self.answer5Label];
    
    int i = 0;
    
    for (UILabel *label in answerLabels) {
        label.text = [answers objectAtIndex:i];
        i++;
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *) __unused tableView viewForHeaderInSection:(NSInteger) __unused section {
 
    UIImageView *imgVew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBreastCancerRibbonImageName]];
    return imgVew;
}

- (IBAction)changeYourGoalHandler:(id) __unused sender {
    [self.parent changeExerciseGoalAction];
}

- (void)doneButtonTapped:(id) __unused sender
{
    if ([self.parent.step.identifier isEqualToString:kSummaryStepIdentifier]) {
        
        if ([self.parent.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.parent.delegate stepViewController:self.parent didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
        }
    }
}
@end
