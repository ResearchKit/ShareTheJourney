// 
//  APHDisplayLogHistoryViewController.m 
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
 
#import "APHDisplayLogHistoryViewController.h"

@interface APHDisplayLogHistoryViewController ()

@property (weak) UIViewController *previousViewController;
@property (weak) NSString *previousViewControllerTitle;

- (IBAction)doneButton:(id)sender;
@end

@implementation APHDisplayLogHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = self.logText;
    
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle: NSDateFormatterShortStyle];
    [formatter setTimeStyle: NSDateFormatterNoStyle];
    
    self.dateLabel.text = [formatter stringFromDate:self.logDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUInteger previousIndex = ([self.navigationController.viewControllers indexOfObject:self] - 1);
    self.previousViewController = ((UIViewController *)self.navigationController.viewControllers[previousIndex]);
    self.previousViewControllerTitle = self.previousViewController.navigationItem.title;
    self.previousViewController.title = NSLocalizedString(@"Back", @"Text for back bar button item on daily journel entry");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.previousViewController.title = self.previousViewControllerTitle;
}

- (void)setTextViewText:(NSString *)text {
    self.textView.text = text;
}

- (IBAction)doneButton:(id) __unused sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
