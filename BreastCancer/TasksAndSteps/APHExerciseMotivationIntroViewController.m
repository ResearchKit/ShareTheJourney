// 
//  APHExerciseMotivationIntroViewController.m 
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
 
#import "APHExerciseMotivationIntroViewController.h"

@interface APHExerciseMotivationIntroViewController ()
- (IBAction)nextButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *exerciseEveryDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseThreeTimesAWeekLabel;

@property (weak, nonatomic) IBOutlet UILabel *walkTenThousandStepsLabel;

@property (weak, nonatomic) IBOutlet UILabel *fiveThousandStepsLabel;

@property (weak, nonatomic) IBOutlet APCConfirmationView *exerciseEveryDaySelectedView;
@property (weak, nonatomic) IBOutlet APCConfirmationView *exerciseThreeTimesAWeekSelectedView;
@property (weak, nonatomic) IBOutlet APCConfirmationView *fiveThousandStepsSelectedView;

@property (weak, nonatomic) IBOutlet APCConfirmationView *walkTenThousandStepsSelectedView;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) ORKStepResult *cachedResult;
@property (nonatomic, strong) NSString *selectedGoal;
@end

@implementation APHExerciseMotivationIntroViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor appSecondaryColor4]];
    
    [self.nextButton setEnabled:NO];
    [self.nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    
    NSArray *buttons = @[self.exerciseEveryDayLabel,
                         self.exerciseThreeTimesAWeekLabel,
                         self.fiveThousandStepsLabel,
                         self.walkTenThousandStepsLabel
                         ];
    
    NSArray *selectedViews = @[self.exerciseEveryDaySelectedView,
                               self.exerciseThreeTimesAWeekSelectedView,
                               self.fiveThousandStepsSelectedView,
                               self.walkTenThousandStepsSelectedView
                               ];
    
    for (NSUInteger i = 0; i<[buttons count]; i++) {
        UILabel *label = (UILabel *) buttons[i];
        APCConfirmationView *selectedView = (APCConfirmationView *)selectedViews[i];
        
        label.tag = i + 1;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
        singleTap.numberOfTapsRequired = 1;
        [label addGestureRecognizer:singleTap];
        [label setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *singleTapSelected = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
        singleTapSelected.numberOfTapsRequired = 1;
        [selectedView addGestureRecognizer:singleTapSelected];
        [selectedView setUserInteractionEnabled:YES];
        
        selectedView.tag = i + 1;
    }
}

- (void)oneTap:(UIGestureRecognizer *)gesture {
    [self.nextButton setEnabled:YES];
    [self.nextButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    
    NSInteger selectedViewTag = gesture.view.tag;
    UILabel *selectedLabel = (UILabel *) [self.view viewWithTag:selectedViewTag];
    self.selectedGoal = selectedLabel.text;
    NSLog(@"%@", selectedLabel.text);
    
    NSArray *selectedViews = @[self.exerciseEveryDaySelectedView, self.exerciseThreeTimesAWeekSelectedView, self.fiveThousandStepsSelectedView, self.walkTenThousandStepsSelectedView];
    
    for (APCConfirmationView *view in selectedViews) {
        [view setCompleted:NO];
    }
    
    APCConfirmationView *selectedView;
    selectedView.alpha = 0.3;
    
    switch (selectedViewTag)
    
    {
        case 1:
            
            selectedView = self.exerciseEveryDaySelectedView;
            [selectedView setAlpha:0];
            break;
            
        case 2:
            
            selectedView = self.exerciseThreeTimesAWeekSelectedView;
            [selectedView setAlpha:0];
            
            break;

        case 3:
            
            selectedView = self.fiveThousandStepsSelectedView;
            [selectedView setAlpha:0];
            
            break;
            
        case 4:
            
            selectedView = self.walkTenThousandStepsSelectedView;
            [selectedView setAlpha:0];
            
            break;
        
        default:
            
            break;
    }
    
    [selectedView setCompleted:YES];
    [UIView animateWithDuration:0.5 animations:^{
        [selectedView setAlpha:1];
    }];
}

#pragma mark - UINavigation Buttons

- (IBAction)nextButtonTapped:(id) __unused sender {
    [self.nextButton setEnabled:NO];
    self.dict = [NSMutableDictionary new];
    [self.dict setObject:self.selectedGoal forKey:@"result"];
    
    APCDataResult *contentModel = [[APCDataResult alloc] initWithIdentifier:self.step.identifier];
    
    NSError *error = nil;
    NSData  *exerciseMotivationAnswers = [NSJSONSerialization dataWithJSONObject:self.dict options:0 error:&error];
    
    if (error) {
        APCLogError2(error);
    }
    
    contentModel.data = exerciseMotivationAnswers;
    
    NSArray *resultsArray = @[contentModel];
    
    self.cachedResult = [[ORKStepResult alloc] initWithStepIdentifier:self.step.identifier results:resultsArray];

    [self.delegate stepViewControllerResultDidChange:self];

    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

- (ORKStepResult *)result {
    
    if (!self.cachedResult) {
        self.cachedResult = [[ORKStepResult alloc] initWithIdentifier:self.step.identifier];
    }
    
    return self.cachedResult;
}
@end
