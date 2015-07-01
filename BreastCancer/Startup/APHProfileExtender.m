// 
//  APHProfileExtender.m 
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
 
#import "APHProfileExtender.h"
#import "APHCustomSurveyQuestionViewController.h"

static NSInteger const kNumberOfCompletionsUntilDisplayingCustomSurvey = 6;

@implementation APHProfileExtender

- (instancetype) init {
    self = [super init];

    if (self) {
        
        
    }
    
    return self;
}

- (BOOL)willDisplayCell:(NSIndexPath *) __unused indexPath {
    return YES;
}

//This is all the content (rows, sections) that is prepared at the appCore level
/*
- (NSArray *)preparedContent:(NSArray *)array {
    return array;
}
*/

//Add to the number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView {
    
    //Check if we have reached the threshold to display customizing a survey question.
    APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSNumber *completedNumberOfTimes = @(0);
    
    if (delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter >= kNumberOfCompletionsUntilDisplayingCustomSurvey && delegate.dataSubstrate.currentUser.customSurveyQuestion != nil)
    {
        completedNumberOfTimes = @(2);
    }
    else if (delegate.dataSubstrate.currentUser.dailyScalesCompletionCounter > kNumberOfCompletionsUntilDisplayingCustomSurvey)
    {
        completedNumberOfTimes = @(2);
    }
    
    return [completedNumberOfTimes integerValue];
}

//Add to the number of sections
- (NSInteger) tableView:(UITableView *) __unused tableView numberOfRowsInAdjustedSection:(NSInteger)section {
    
    NSInteger count = 0;
    
    if (section == 0) {
        count = 1;
    }
    
    return count;
}

- (UITableViewCell *)decorateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)__unused indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = NSLocalizedString(@"Customize your survey question", nil);
    cell.detailTextLabel.text = @"";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtAdjustedIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    
    if (indexPath.section == 0) {
        height = 60.0;
    }
    
    return height;
}

- (void)navigationController:(UINavigationController *)navigationController didSelectRowAtIndexPath:(NSIndexPath *) __unused indexPath {
    
    APHCustomSurveyQuestionViewController *controller = [[APHCustomSurveyQuestionViewController alloc] init];
    
    controller.navigationController.navigationBar.topItem.title = @"Customize your survey question";
    
    [navigationController pushViewController:controller animated:YES];
}

@end
