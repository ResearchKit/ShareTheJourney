// 
//  APHNotesViewController.m 
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
 
#import "APHNotesViewController.h"
#import "APHMoodLogDictionaryKeys.h"


typedef  enum  _TypingDirection
{
    TypingDirectionAdding,
    TypingDirectionDeleting
}  TypingDirection;

static  NSCharacterSet  *whitespaceAndNewLineSet = nil;

static  NSUInteger  kMaximumNumberOfWordsPerLog = 150;
static  NSUInteger  kThresholdForLimitWarning   = 140;

@interface APHNotesViewController  ( )  <UITextViewDelegate>

@property  (nonatomic, weak)  IBOutlet  UINavigationBar      *navigator;
@property  (nonatomic, weak)  IBOutlet  UILabel              *counterDisplay;

@property  (nonatomic, weak)  IBOutlet  NSLayoutConstraint   *containerSpacing;
@property  (nonatomic, assign)          CGFloat               savedContainerSpacing;

@property  (nonatomic, strong)          NSMutableDictionary  *noteContentModel;
@property  (nonatomic, strong)          NSMutableDictionary  *noteChangesModel;
@property  (nonatomic, strong)          NSMutableArray       *noteModifications;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
- (IBAction)submitTapped:(id)sender;

@property (nonatomic, strong) ORKStepResult *cachedResult;

@end

@implementation APHNotesViewController

+ (void)initialize
{
    whitespaceAndNewLineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
}

#pragma  mark  -  Menu Controller Methods

- (BOOL)canBecomeFirstResponder
{
    return  YES;
}

- (void)displayWordCount:(NSUInteger)count
{
    NSString  *numberOfWordsDisplay = [NSString stringWithFormat:@"%lu of %lu words", (unsigned long)count, (unsigned long)kMaximumNumberOfWordsPerLog];
    if (count < kThresholdForLimitWarning) {
        self.counterDisplay.textColor = [UIColor grayColor];
    } else {
        self.counterDisplay.textColor = [UIColor redColor];
    }
    self.counterDisplay.text = numberOfWordsDisplay;
}

- (NSUInteger)countWords:(NSString *)words
{
    typedef  enum  _WordState
    {
        WordStateInWord,
        WordStateNotInWord
    }  WordState;
    
    WordState  state = WordStateNotInWord;
    
    NSString  *text = words;
    NSUInteger  length = [text length];
    
    NSUInteger  count = 0;
    
    for (NSUInteger  i = 0; i < length;  i++) {
        unichar  character = [text characterAtIndex:i];
        if (state == WordStateNotInWord) {
            if ([whitespaceAndNewLineSet characterIsMember:character] == YES) {
                continue;
            } else {
                state = WordStateInWord;
                count = count + 1;
            }
        } else {
            if ([whitespaceAndNewLineSet characterIsMember:character] == NO) {
                continue;
            } else {
                state = WordStateNotInWord;
            }
        }
    }
    return  count;
}

#pragma  mark  -  Text View Delegate Methods

- (NSString *) adjustText: (NSString *) __unused text withRange:(NSRange) __unused range {
    
    
    return nil;
}

- (BOOL)textView:(UITextView *) __unused textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Enable button after text is entered.
    self.doneButton.enabled = YES;
    
    BOOL  answer = YES;
    
    NSDictionary  *record = nil;
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    
    NSUInteger  preCount = [self countWords:self.scriptorium.text];
    if ([text length] != 0) {
        if (preCount >= kMaximumNumberOfWordsPerLog) {
            //answer = NO;
        } else {
            record = @{
                       APHMoodLogEditTimeStampKey : @(timestamp),
                       APHMoodLogEditingTypeKey : APHMoodLogEditingTypeAddingKey,
                       };
        }
    } else {
        record = @{
                   APHMoodLogEditTimeStampKey : @(timestamp),
                   APHMoodLogEditingTypeKey : APHMoodLogEditingTypeDeletingKey,
                   };
    }
    if (record != nil) {
        [self.noteModifications addObject: record];
    }
        
    NSString *changedText = [self.scriptorium.text stringByReplacingCharactersInRange:range withString:text];
    
    NSUInteger  changedTextCount = [self countWords:changedText];
    
    [self displayWordCount:changedTextCount];
    
    if (changedTextCount == 0) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
    
    return  answer;
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
    
    self.bottomButtonConstraint.constant = keyboardHeight + 20;
    self.containerSpacing.constant = keyboardHeight + 20;
    
    [UIView animateWithDuration:animationDuration animations:^{

        [self.view layoutIfNeeded];
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
    
    [self.scriptorium becomeFirstResponder];
    
    if (self.scriptorium.text.length > 0) {
        self.doneButton.enabled = YES;
        [self countWords:self.scriptorium.text];
        NSUInteger  count = [self countWords:self.scriptorium.text];
        [self displayWordCount:count];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.scriptorium resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.doneButton.enabled = NO;
    
    self.scriptorium.text = @"";
    self.scriptorium.userInteractionEnabled = NO;
    self.navigator.topItem.title = @"";
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO];
    
    if (self.note == nil) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillEmerge:) name:UIKeyboardWillShowNotification object:nil];
        
        NSTimeInterval  timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
        
        self.noteContentModel = [NSMutableDictionary dictionary];
        [self.noteContentModel setObject:@(timestamp) forKey:APHMoodLogNoteTimeStampKey];
        
        self.noteChangesModel = [NSMutableDictionary dictionary];
        [self.noteChangesModel setObject:@(timestamp) forKey:APHMoodLogNoteTimeStampKey];
        
        self.noteModifications = [NSMutableArray array];
        
        [self displayWordCount:0];
        
    } else {
        self.scriptorium.editable   = NO;
        self.scriptorium.selectable = NO;
        
        UIBarButtonItem  *backsterTitle   = [[UIBarButtonItem alloc] initWithTitle:@"Back to List" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonWasTapped:)];
        backsterTitle.tintColor = [UIColor appPrimaryColor];
        
        self.navigator.topItem.leftItemsSupplementBackButton = NO;
        self.navigator.topItem.leftBarButtonItem = backsterTitle;
        
        self.scriptorium.text = self.note[APHMoodLogNoteTextKey];
        NSUInteger  count = [self countWords:self.scriptorium.text];
        [self displayWordCount:count];
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self.scriptorium becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)submitTapped:(id) __unused sender {
    self.doneButton.enabled = NO;
    
    [self.scriptorium resignFirstResponder];
    
    [self.noteContentModel setObject:self.scriptorium.text forKey:APHMoodLogNoteTextKey];
    [self.noteChangesModel setObject:self.noteModifications forKey:APHMoodLogNoteModificationsKey];
    
    NSError *changesError = nil;
    NSError *contentError = nil;
    APCDataResult *contentModel = [[APCDataResult alloc] initWithIdentifier:@"content"];
    APCDataResult *changesModel = [[APCDataResult alloc] initWithIdentifier:@"changes"];
    
    contentModel.data = [NSJSONSerialization dataWithJSONObject:self.noteContentModel options:0 error:&contentError];
    changesModel.data = [NSJSONSerialization dataWithJSONObject:self.noteChangesModel options:0 error:&changesError];
    
    NSArray *resultsArray = @[contentModel, changesModel];
    
    self.cachedResult = [[ORKStepResult alloc] initWithStepIdentifier:self.step.identifier results:resultsArray];
    
    [self.delegate stepViewControllerResultDidChange:self];

    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }}

- (ORKStepResult *)result {
    
    if (!self.cachedResult) {
        self.cachedResult = [[ORKStepResult alloc] initWithIdentifier:self.step.identifier];
    }
    
    return self.cachedResult;
}


@end
