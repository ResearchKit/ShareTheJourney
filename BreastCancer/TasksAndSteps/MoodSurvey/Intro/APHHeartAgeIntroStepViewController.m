// 
//  APHHeartAgeIntroStepViewController.m 
//  Share the Journey 
// 
// Copyright (c) 2015, Sage Bionetworks, Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this 
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
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

static CGFloat kTitleFontSize = 18.0f;
static CGFloat kDetailFontSize = 17.0f;

@interface APHHeartAgeIntroStepViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSAttributedString *purpose;
@property (nonatomic, strong) NSAttributedString *length;
@property (nonatomic, strong) UITableViewCell *purposeCell;

@property (nonatomic, strong) APHCustomSurveyQuestionViewController *questionController;
@end

@implementation APHHeartAgeIntroStepViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableView.allowsSelection = NO;
    
    [self createAttributedStrings];

    UINib *nib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APHCustomSurveyTableViewCell"
                                               bundle:[NSBundle mainBundle]]
                               forCellReuseIdentifier:@"APHCustomSurveyTableViewCellIdentifier"];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)tableView:(UITableView *) __unused tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *) __unused indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)getStartedWasTapped:(id) __unused sender
{
    [self.getStartedButton setEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

- (void)getStartedWithCustomSurvey {
    if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
        [self.delegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    }
}

/*********************************************************************************/
#pragma  mark  - tableView delegates
/*********************************************************************************/

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger) __unused section {
    
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    float height = 0;
    
    if (indexPath.row == 0) {
        
        height = 220.0;
        
    } else if (indexPath.row == 1) {
        
        height = 100.0;
        
    } else if (indexPath.row == 2) {

        height = 300.0;
    }

    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell* cell = nil;
    
    if (indexPath.row == 0) {
        
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.attributedText = self.purpose;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    } else if (indexPath.row == 1) {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.attributedText = self.length;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
    } else if (indexPath.row == 2) {

        cell = [tableView dequeueReusableCellWithIdentifier:@"APHCustomSurveyTableViewCellIdentifier"];

        APHCustomSurveyTableViewCell *customCell = (APHCustomSurveyTableViewCell *) cell;
        
        if (customCell.customizeSurveyButton.allTargets.count == 0) {
            [customCell.customizeSurveyButton addTarget:self action:@selector(showCustomizeSurveyView:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
}
- (void) showCustomizeSurveyView:(id) __unused sender{
    
    self.questionController = [[APHCustomSurveyQuestionViewController alloc] initWithNibName:@"APHCustomSurveyQuestionViewController" bundle:nil];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.questionController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
    
    [navController addChildViewController:self.questionController];
    [self.questionController didMoveToParentViewController:navController];
    
    navController.navigationBar.topItem.title = NSLocalizedString(@"Customize your question", @"");
    
}

/*********************************************************************************/
#pragma  mark  - Helper methods
/*********************************************************************************/

- (void)createAttributedStrings {
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"Purpose"];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Purpose" length])];
        [attribString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:kTitleFontSize] range:NSMakeRange(0,[attribString length])];
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"\n\nTell us how you feel. We'll ask you to rate your mental clarity, mood and energy level today as well as how well you slept and how much exercise you have done in the last day. You will also have an opportunity to track any activity or thought that you choose yourself."];

        [finalString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:kDetailFontSize] range:NSMakeRange(0,[attribString length])];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];
        
        [attribString appendAttributedString:finalString];
        
        
        self.purpose = attribString;
    }
    
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        
        NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:@"Length"];
        [attribString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Length" length])];
        [attribString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[attribString length])];
        
        [attribString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:kTitleFontSize] range:NSMakeRange(0,[attribString length])];
        
        NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@"\n\nThis activity should take less than two minutes to complete."];
        
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        [finalString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [finalString length])];
        [finalString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:kDetailFontSize] range:NSMakeRange(0,[attribString length])];
        [finalString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[finalString length])];

        [attribString appendAttributedString:finalString];
        
        self.length = attribString;
    }

}
@end
