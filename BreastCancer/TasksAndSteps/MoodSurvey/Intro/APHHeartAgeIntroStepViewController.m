// 
//  APHHeartAgeIntroStepViewController.m 
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
 
#import "APHHeartAgeIntroStepViewController.h"
#import "APHCustomSurveyTableViewCell.h"
#import "APHCustomSurveyQuestionViewController.h"
#import "APHQuestionViewController.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kCellMargins = 40.0f;
static CGFloat kCellTextPadding = 20;

@interface APHHeartAgeIntroStepViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *purpose;
@property (nonatomic, strong) NSString *length;
@property (nonatomic, strong) UITableViewCell *purposeCell;

@property (nonatomic, strong) APHCustomSurveyQuestionViewController *questionController;
@end

@implementation APHHeartAgeIntroStepViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView.allowsSelection = NO;
    
    [self initializeStrings];

    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APHCustomSurveyTableViewCell"
                                               bundle:[NSBundle mainBundle]]
                               forCellReuseIdentifier:@"APHCustomSurveyTableViewCellIdentifier"];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)getStartedWasTapped:(id) __unused sender
{
    [self.getStartedButton setEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

/*********************************************************************************/
#pragma  mark  - tableView delegates
/*********************************************************************************/

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section {
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    float height = 0;
    NSString *contentText = nil;
    
    switch (indexPath.section) {
        case 0:
            contentText = self.purpose;
            break;
        case 1:
            contentText = self.length;
            break;
            
        default:
            break;
    }
    
    height = ceil([contentText boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - kCellMargins, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}
                                            context:nil].size.height) + kCellTextPadding;
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.purpose;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    } else if (indexPath.section == 1) {
        cell.textLabel.text = self.length;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)__unused tableView viewForHeaderInSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc]init];
    if (section == 0) {
        headerView.textLabel.text = NSLocalizedString(@"Purpose", nil);
    }else if (section == 1) {
        headerView.textLabel.text = NSLocalizedString(@"Length", nil);
    }else{
        headerView = [UITableViewHeaderFooterView new];
    }
    
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section{
    
    return 44.0;
    
}

/*********************************************************************************/
#pragma  mark  - Helper methods
/*********************************************************************************/

- (void)initializeStrings {
    
    self.purpose = NSLocalizedString(@"Tell us how you feel. We'll ask you to rate your mental clarity, mood and energy level today as well as how well you slept and how much exercise you have done in the last day. You will also have an opportunity to track any activity or thought that you choose yourself.", nil);
    
    self.length = NSLocalizedString(@"This activity should take less than two minutes to complete.", nil);
    
}

@end
