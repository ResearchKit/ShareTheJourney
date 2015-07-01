// 
//  APHQuestionViewController.m 
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
 
#import "APHQuestionViewController.h"
#import "APHMoodLogDictionaryKeys.h"


typedef  enum  _TypingDirection
{
    TypingDirectionAdding,
    TypingDirectionDeleting
}  TypingDirection;

static NSUInteger kMaximumNumberOfCharacters = 90;

static  NSString  *kExerciseSurveyStep102 = @"exercisesurvey102";
static  NSString  *kExerciseSurveyStep103 = @"exercisesurvey103";
static  NSString  *kExerciseSurveyStep104 = @"exercisesurvey104";
static  NSString  *kExerciseSurveyStep105 = @"exercisesurvey105";
static  NSString  *kExerciseSurveyStep106 = @"exercisesurvey106";

@interface APHQuestionViewController  ( )  <UITextViewDelegate>



@property  (nonatomic, weak)  IBOutlet  UINavigationBar      *navigator;
@property  (nonatomic, weak)  IBOutlet  UILabel              *counterDisplay;

@property  (nonatomic, weak)  IBOutlet  NSLayoutConstraint   *containerSpacing;
@property  (nonatomic, assign)          CGFloat               savedContainerSpacing;

@property  (nonatomic, strong)          NSMutableDictionary  *noteContentModel;
@property  (nonatomic, strong)          NSMutableArray       *noteModifications;


@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonConstraint;

@property (weak, nonatomic) IBOutlet UILabel *placeHolderText;


@property (weak, nonatomic) IBOutlet UIView *containerView;
- (IBAction)submitTapped:(id)sender;

@property (nonatomic, strong) ORKStepResult *cachedResult;

@property (weak, nonatomic) IBOutlet UILabel *characterCounterLabel;
@end

@implementation APHQuestionViewController

#pragma  mark  -  Menu Controller Methods

- (BOOL)canBecomeFirstResponder
{
    return  YES;
}

#pragma  mark  -  Text View Delegate Methods

- (BOOL)textView:(UITextView *) __unused textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *updatedText = [self.scriptorium.text stringByReplacingCharactersInRange:range withString:text];
    
    BOOL shouldChangeText = NO;
    
    if (updatedText.length <= 90) {
        shouldChangeText = YES;
    
        self.characterCounterLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)updatedText.length, (unsigned long)kMaximumNumberOfCharacters];
        
        if (updatedText.length > 0) {
            [self.doneButton setEnabled:YES];
            [self.doneButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
            self.placeHolderText.alpha = 0;
        } else {
            [self.doneButton setEnabled:NO];
            [self.doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.placeHolderText.alpha = 1;
        }
    }
    
    return shouldChangeText;
}

- (void)backBarButtonWasTapped:(UIBarButtonItem *) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark  -  Keyboard Notification Methods

- (void)keyboardWillEmerge:(NSNotification *)notification
{
    CGFloat  keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.savedContainerSpacing = self.containerSpacing.constant;
    
    double   animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.containerSpacing.constant = keyboardHeight;
    
    [UIView animateWithDuration:animationDuration animations:^{

        [self.view layoutIfNeeded];
        self.placeHolderText.alpha = 0;
    }];
}

#pragma mark - UINavigation Buttons

//- (void)cancelButtonTapped:(id)sender
//{
////    if ([self.delegate respondsToSelector:@selector(stepViewControllerDidCancel:)] == YES) {
////        [self.delegate stepViewControllerDidCancel:self];
////    }
//}

#pragma  mark  -  View Controller Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.scriptorium.text.length > 0) {
        [self.doneButton setEnabled:YES];
        [self.doneButton setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
        self.placeHolderText.alpha = 0;
    }
    self.characterCounterLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.scriptorium.text.length, (unsigned long)kMaximumNumberOfCharacters];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [self.scriptorium resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Done button is disabled.
    [self.doneButton setEnabled:NO];
    
    if ([self.step.identifier isEqualToString:kExerciseSurveyStep106]) {
        [self.doneButton setTitle:@"Finish" forState:UIControlStateNormal];
    }
    
    [self.view setBackgroundColor:[UIColor appSecondaryColor4]];
    
    [self.doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    
    self.scriptorium.text = @"";
    self.navigator.topItem.title = @"";
    
    [self.scriptorium setUserInteractionEnabled:YES];
    [self.scriptorium setEditable:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillEmerge:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)submitTapped:(id) __unused sender {
    [self.doneButton setEnabled:NO];
    [self.scriptorium resignFirstResponder];
    
    self.noteContentModel = [NSMutableDictionary new];
    
    [self.noteContentModel setObject:self.scriptorium.text forKey:@"result"];
    
    APCDataResult *contentModel = [[APCDataResult alloc] initWithIdentifier:self.step.identifier];
    
    NSError *error = nil;
    
    contentModel.data = [NSJSONSerialization dataWithJSONObject:self.noteContentModel options:0 error:&error];
    
    if (error) {
        APCLogError2(error);
    }
    
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
