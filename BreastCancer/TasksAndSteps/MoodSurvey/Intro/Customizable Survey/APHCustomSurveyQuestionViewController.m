// 
//  Customizable 
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
 
#import "APHCustomSurveyQuestionViewController.h"
#import "APHHeartAgeIntroStepViewController.h"

static NSInteger const doneButtonYOffset = 20;
static NSInteger const kMaximumNumberOfCharacters = 90;

@interface APHCustomSurveyQuestionViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *characterCounterLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;
@property  (nonatomic, assign) CGFloat savedContainerSpacing;
@end

@implementation APHCustomSurveyQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        self.edgesForExtendedLayout = UIRectEdgeNone;

    self.title = NSLocalizedString(@"Custom Daily Question", @"");
    
    [self.textView setDelegate:self];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillEmerge:) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL) __unused animated {
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *customQuestion = delegate.dataSubstrate.currentUser.customSurveyQuestion;
    
    if (customQuestion != nil) {
        self.textView.text = customQuestion;
        self.characterCounterLabel.text = [NSString     stringWithFormat:@"%lu / %lu", (unsigned long)self.textView.text.length, (unsigned long)kMaximumNumberOfCharacters];
    }
        
}

#pragma  mark  -  Text View Delegate Methods

- (BOOL)textView:(UITextView *) __unused textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *updatedText = [self.textView.text stringByReplacingCharactersInRange:range withString:text];
    
    BOOL shouldChangeText = NO;
    
    if (updatedText.length <= kMaximumNumberOfCharacters) {
        shouldChangeText = YES;
        
        self.characterCounterLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)updatedText.length, (unsigned long)kMaximumNumberOfCharacters];
    }
    
    return shouldChangeText;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.dataSubstrate.currentUser.customSurveyQuestion = textView.text;
    
    if ([textView.text isEqualToString:@""]) {
        delegate.dataSubstrate.currentUser.customSurveyQuestion = nil;
    }
    
}

#pragma  mark  -  Keyboard Notification Methods

- (void)keyboardWillEmerge:(NSNotification *)notification
{
    CGFloat  keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    double   animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.bottomSpaceConstraint.constant = keyboardHeight - doneButtonYOffset;
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)doneButtonHandler:(id) __unused sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillDisappear:(BOOL) __unused animated {
    [self.textView resignFirstResponder];
}

@end
