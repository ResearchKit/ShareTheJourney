//
//  APHAppDelegate.m
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

@import APCAppCore;
#import "APHAppDelegate.h"
#import "APHProfileExtender.h"


#pragma mark - Survey Identifiers

static NSString* const  kDailySurveyIdentifier              = @"3-APHMoodSurvey-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
static NSString* const  kDailyJournalSurveyIdentifier       = @"6-APHDailyJournal-80F09109-265A-49C6-9C5D-765E49AAF5D9";
static NSString* const  kExerciseSurveyIdentifier           = @"4-APHExerciseSurvey-7259AC18-D711-47A6-ADBD-6CFCECDED1DF";
static NSString* const  kFeedbackSurveyIdentifier           = @"8-Feedback-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kMyThoughtsSurveyIdentifier         = @"7-MyThoughts-14ffde40-1551-4b48-aae2-8fef38d61b61";
static NSString* const  kSymptomsSurveyIdentifier           = @"2-BCPTSymptomsSurvey-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kBCSPAOFISurveyIdentifier           = @"e-PAOFI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kPersonalHealthSurveyIdentifier     = @"9-PHQ8GAD7-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kSleepQualitySurveyIdentifier       = @"a-PSQI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kGeneralHealthSurveyIdentifier      = @"b-SF36-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kWeeklySurveyIdentifier             = @"c-Weekly-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";
static NSString* const  kExerciseReadinessSurveyIdentifier  = @"5-parqquiz-1E174061-5B02-11E4-8ED6-0800200C9A77";
static NSString* const  kBackgroundSurveyIdentifier         = @"1-BackgroundSurvey-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e";

#pragma mark - Initializations Options

static NSString* const  kStudyIdentifier                = @"studyname";
static NSString* const  kAppPrefix                      = @"studyname";
static NSString* const  kVideoShownKey                  = @"VideoShown";
static NSString* const  kConsentPropertiesFileName      = @"APHConsentSection";

static NSString *const kJsonScheduleStringKey           = @"scheduleString";
static NSString *const kJsonTasksKey                    = @"tasks";
static NSString *const kJsonScheduleTaskIDKey           = @"taskID";
static NSString *const kJsonSchedulesKey                = @"schedules";

static NSString *const kMigrationTaskIdKey              = @"taskId";
static NSString *const kMigrationOffsetByDaysKey        = @"offsetByDays";
static NSString *const kMigrationGracePeriodInDaysKey   = @"gracePeriodInDays";
static NSString *const kMigrationRecurringKindKey       = @"recurringKind";


typedef NS_ENUM(NSUInteger, APHMigrationRecurringKinds) {
	APHMigrationRecurringKindWeekly = 0,
	APHMigrationRecurringKindMonthly,
	APHMigrationRecurringKindQuarterly,
	APHMigrationRecurringKindSemiAnnual,
	APHMigrationRecurringKindAnnual
};


@interface APHAppDelegate()

@property (nonatomic, strong) APHProfileExtender *profileExtender;
@property (nonatomic, assign) NSInteger environment;

@end


@implementation APHAppDelegate

- (void)setUpInitializationOptions
{
	[APCUtilities setRealApplicationName: @"Share the Journey"];
	
	NSDictionary *permissionsDescriptions = @{ @(kSignUpPermissionsTypeLocation) : NSLocalizedString(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @""),
                                               @(kSignUpPermissionsTypeCoremotion) : NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @""),
                                               @(kSignUpPermissionsTypeMicrophone) : NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @""),
                                               @(kSignUpPermissionsTypeLocalNotifications) : NSLocalizedString(@"Allowing notifications enables the app to show you reminders.", @""),
                                               @(kSignUpPermissionsTypeHealthKit) : NSLocalizedString(@"On the next screen, you will be prompted to grant Share the Journey access to read and write some of your general and health information, such as height, weight and steps taken so you don't have to enter it again.", @"") };
	
	NSMutableDictionary * dictionary = [super defaultInitializationOptions];
#ifdef DEBUG
	self.environment = SBBEnvironmentStaging;
#else
	self.environment = SBBEnvironmentProd;
#endif
	
	[dictionary addEntriesFromDictionary:@{ kStudyIdentifierKey : kStudyIdentifier,
                                            kAppPrefixKey : kAppPrefix,
                                            kBridgeEnvironmentKey : @(self.environment),
                                            kHKReadPermissionsKey : @[ HKQuantityTypeIdentifierBodyMass,
                                                                       HKQuantityTypeIdentifierHeight,
                                                                       HKQuantityTypeIdentifierStepCount,
                                                                       HKQuantityTypeIdentifierDistanceWalkingRunning,
                                                                       @{kHKCategoryTypeKey : HKCategoryTypeIdentifierSleepAnalysis} ],
                                            kHKWritePermissionsKey : @[ /*HKQuantityTypeIdentifierBodyMass,*/
                                                                        /*HKQuantityTypeIdentifierHeight*/ ],
                                            kAppServicesListRequiredKey : @[ @(kSignUpPermissionsTypeLocation),
                                                                             @(kSignUpPermissionsTypeCoremotion),
                                                                             @(kSignUpPermissionsTypeLocalNotifications) ],
                                            kAppServicesDescriptionsKey : permissionsDescriptions,
                                            kAppProfileElementsListKey : @[ @(kAPCUserInfoItemTypeEmail),
                                                                            @(kAPCUserInfoItemTypeDateOfBirth),
                                                                            @(kAPCUserInfoItemTypeHeight),
                                                                            @(kAPCUserInfoItemTypeWeight) ],
                                            kShareMessageKey : NSLocalizedString(@"Check out Share the Journey, a research study app about breast cancer survivorship.  Download it for iPhone at https://appsto.re/i6LF2f6", nil) }];
    
    self.initializationOptions = dictionary;
	self.profileExtender = [[APHProfileExtender alloc] init];
}

- (void)setUpTasksReminder
{	
	APCTaskReminder *dailySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kDailySurveyIdentifier reminderBody:NSLocalizedString(@"Daily Survey", nil)];
	APCTaskReminder *dailyJournalReminder = [[APCTaskReminder alloc]initWithTaskID:kDailyJournalSurveyIdentifier reminderBody:NSLocalizedString(@"Daily Journal", nil)];
	APCTaskReminder *exerciseSurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kExerciseSurveyIdentifier reminderBody:NSLocalizedString(@"Exercise Survey", nil)];
	APCTaskReminder *myThoughtsSurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kMyThoughtsSurveyIdentifier reminderBody:NSLocalizedString(@"My Thoughts Survey", nil)];
	APCTaskReminder *assessFunctioningSurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kBCSPAOFISurveyIdentifier reminderBody:NSLocalizedString(@"Assessment of Functioning", nil)];
	APCTaskReminder *personalHealthSurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kPersonalHealthSurveyIdentifier reminderBody:NSLocalizedString(@"Personal Health Survey", nil)];
	APCTaskReminder *sleepQualitySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kSleepQualitySurveyIdentifier reminderBody:NSLocalizedString(@"Sleep Quality Survey", nil)];
	APCTaskReminder *generalHealthSurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kGeneralHealthSurveyIdentifier reminderBody:NSLocalizedString(@"General Health Survey", nil)];
	APCTaskReminder *weeklySurveyReminder = [[APCTaskReminder alloc]initWithTaskID:kWeeklySurveyIdentifier reminderBody:NSLocalizedString(@"Weekly Survey", nil)];
	
	[self.tasksReminder manageTaskReminder:dailySurveyReminder];
	[self.tasksReminder manageTaskReminder:dailyJournalReminder];
	[self.tasksReminder manageTaskReminder:exerciseSurveyReminder];
	[self.tasksReminder manageTaskReminder:myThoughtsSurveyReminder];
	[self.tasksReminder manageTaskReminder:assessFunctioningSurveyReminder];
	[self.tasksReminder manageTaskReminder:personalHealthSurveyReminder];
	[self.tasksReminder manageTaskReminder:sleepQualitySurveyReminder];
	[self.tasksReminder manageTaskReminder:generalHealthSurveyReminder];
	[self.tasksReminder manageTaskReminder:weeklySurveyReminder];
}

- (NSDictionary *)migrateTasksAndSchedules:(NSDictionary *)currentTaskAndSchedules
{
	NSMutableDictionary *migratedTaskAndSchedules = nil;
	
	if (currentTaskAndSchedules == nil) {
		APCLogError(@"Nothing was loaded from the JSON file. Therefore nothing to migrate.");
	} else {
		migratedTaskAndSchedules = [currentTaskAndSchedules mutableCopy];
		
		NSArray *schedulesToMigrate = @[ @{ kMigrationTaskIdKey: @"9-PHQ8GAD7-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e",
                                            kMigrationOffsetByDaysKey: @(1),
                                            kMigrationGracePeriodInDaysKey: @(5),
                                            kMigrationRecurringKindKey: @(APHMigrationRecurringKindMonthly) },
                                         @{ kMigrationTaskIdKey: @"c-Weekly-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e",
                                            kMigrationOffsetByDaysKey: @(5),
                                            kMigrationGracePeriodInDaysKey: @(5),
                                            kMigrationRecurringKindKey: @(APHMigrationRecurringKindWeekly) },
                                         @{ kMigrationTaskIdKey: @"e-PAOFI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e",
                                            kMigrationOffsetByDaysKey: @(2),
                                            kMigrationGracePeriodInDaysKey: @(5),
                                            kMigrationRecurringKindKey: @(APHMigrationRecurringKindMonthly) },
                                         @{ kMigrationTaskIdKey: @"a-PSQI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e",
                                            kMigrationOffsetByDaysKey: @(3),
                                            kMigrationGracePeriodInDaysKey: @(5),
                                            kMigrationRecurringKindKey: @(APHMigrationRecurringKindMonthly) },
                                         @{ kMigrationTaskIdKey: @"b-SF36-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e",
                                            kMigrationOffsetByDaysKey: @(4),
                                            kMigrationGracePeriodInDaysKey: @(5),
                                            kMigrationRecurringKindKey: @(APHMigrationRecurringKindQuarterly) } ];
		
		NSArray *schedules = migratedTaskAndSchedules[kJsonSchedulesKey];
		NSMutableArray *migratedSchedules = [NSMutableArray new];
		NSDate *launchDate = [NSDate date];
		
		for (NSDictionary *schedule in schedules) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kMigrationTaskIdKey, schedule[kJsonScheduleTaskIDKey]];
			NSArray *matchedSchedule = [schedulesToMigrate filteredArrayUsingPredicate:predicate];
			
			if (matchedSchedule.count > 0) {
				NSDictionary *taskInfo = [matchedSchedule firstObject];
				
				NSMutableDictionary *updatedSchedule = [schedule mutableCopy];
				
				NSDate *offsetDate = [launchDate dateByAddingDays:[taskInfo[kMigrationOffsetByDaysKey] integerValue]];
				
				NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday;
				
				NSDateComponents *componentForGracePeriodStartOn = [[NSCalendar currentCalendar] components:units
																								   fromDate:offsetDate];
				
				NSString *dayOfMonth = [NSString stringWithFormat:@"%ld", componentForGracePeriodStartOn.day];
				NSString *dayOfWeek = nil;
				
				if ([taskInfo[kMigrationRecurringKindKey] integerValue] == APHMigrationRecurringKindWeekly) {
					dayOfWeek = [NSString stringWithFormat:@"%ld", componentForGracePeriodStartOn.weekday];
					dayOfMonth = @"*";
				} else {
					dayOfWeek = @"*";
				}
				
				NSString *months = nil;
				
				switch ([taskInfo[kMigrationRecurringKindKey] integerValue]) {
					case APHMigrationRecurringKindMonthly:
						months = @"1/1";
						break;
					case APHMigrationRecurringKindQuarterly:
						months = @"1/3";
						break;
					default:
						months = @"*";
						break;
				}
				
				updatedSchedule[kJsonScheduleStringKey] = [NSString stringWithFormat:@"0 5 %@ %@ %@", dayOfMonth, months, dayOfWeek];
				
				[migratedSchedules addObject:updatedSchedule];
			} else {
				[migratedSchedules addObject:schedule];
			}
		}
		
		migratedTaskAndSchedules[kJsonSchedulesKey] = migratedSchedules;
	}
	
	return migratedTaskAndSchedules;
}

- (NSDictionary *)tasksAndSchedulesWillBeLoaded
{
	NSError *jsonError = nil;
	NSString *resource = [[NSBundle mainBundle] pathForResource:@"APHTasksAndSchedules" ofType:@"json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:resource];
	NSDictionary *tasksAndScheduledFromJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
	
	NSDictionary *migratedSchedules = [self migrateTasksAndSchedules:tasksAndScheduledFromJSON];
	
	return migratedSchedules;
}

- (void)performMigrationAfterDataSubstrateFrom:(NSInteger)__unused previousVersion currentVersion:(NSInteger)__unused currentVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSError *migrationError = nil;
	
	if (self.doesPersisteStoreExist == NO) {
		APCLogEvent(@"This application is being launched for the first time. We know this because there is no persistent store.");
	} else if ( [defaults objectForKey:@"previousVersion"] == nil) {
		APCLogEvent(@"The entire data model version %d", kTheEntireDataModelOfTheApp);
		
		NSError *jsonError = nil;
		NSString *resource = [[NSBundle mainBundle] pathForResource:@"APHTasksAndSchedules" ofType:@"json"];
		NSData *jsonData = [NSData dataWithContentsOfFile:resource];
		NSDictionary *tasksAndScheduledFromJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
		
		NSDictionary *migratedSchedules = [self migrateTasksAndSchedules:tasksAndScheduledFromJSON];
		
		[APCSchedule updateSchedulesFromJSON:migratedSchedules[kJsonSchedulesKey]
								   inContext:self.dataSubstrate.persistentContext];
	}
	
	[defaults setObject:majorVersion forKey:@"shortVersionString"];
	[defaults setObject:minorVersion forKey:@"version"];
	
	if (!migrationError) {
		[defaults setObject:@(currentVersion) forKey:@"previousVersion"];
	}
}

- (id<APCProfileViewControllerDelegate>)profileExtenderDelegate
{
	return self.profileExtender;
}

- (void)setUpAppAppearance
{
	[APCAppearanceInfo setAppearanceDictionary : @{ kPrimaryAppColorKey : [UIColor colorWithRed:0.937 green:0.004 blue:0.553 alpha:1.000],
                                                    @"3-APHMoodSurvey-7259AC18-D711-47A6-ADBD-6CFCECDED1DF" : [UIColor colorWithRed:0.937 green:0.004 blue:0.553 alpha:1.000],
                                                    @"6-APHDailyJournal-80F09109-265A-49C6-9C5D-765E49AAF5D9" : [UIColor colorWithRed:0.937 green:0.004 blue:0.553 alpha:1.000],
                                                    @"4-APHExerciseSurvey-7259AC18-D711-47A6-ADBD-6CFCECDED1DF" : [UIColor colorWithRed:0.937 green:0.004 blue:0.553 alpha:1.000],
                                                    @"8-Feedback-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"7-MyThoughts-14ffde40-1551-4b48-aae2-8fef38d61b61" : [UIColor lightGrayColor],
                                                    @"2-BCPTSymptomsSurvey-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"e-PAOFI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"9-PHQ8GAD7-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"a-PSQI-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"b-SF36-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"c-Weekly-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor],
                                                    @"5-parqquiz-1E174061-5B02-11E4-8ED6-0800200C9A77" : [UIColor lightGrayColor],
                                                    @"1-BackgroundSurvey-394848ce-ca4f-4abe-b97e-fedbfd7ffb8e" : [UIColor lightGrayColor] }];
	
	[[UINavigationBar appearance] setTintColor:[UIColor appPrimaryColor]];
	[[UINavigationBar appearance] setTitleTextAttributes : @{ NSForegroundColorAttributeName : [UIColor appSecondaryColor2],
                                                              NSFontAttributeName : [UIFont appNavBarTitleFont] }];
	
	[[UIView appearance] setTintColor:[UIColor appPrimaryColor]];
	
	self.dataSubstrate.parameters.bypassServer = YES;
}

- (void)showOnBoarding
{
	[super showOnBoarding];
	[self showStudyOverview];
}


- (void)showStudyOverview
{
	APCStudyOverviewViewController *studyController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyOverviewVC"];
	[self setUpRootViewController:studyController];
}

- (BOOL)isVideoShown
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoShownKey];
}

- (NSArray *)offsetForTaskSchedules
{
	return @[];
}

- (NSArray *)allSetTextBlocks
{
	NSArray *allSetBlockOfText = nil;
	
	NSString *activitiesAdditionalText = NSLocalizedString(@"You will be able to log, as often as you like, your mood, energy, sleep, thinking and excercise, and an activity of your choice.", @"You will be able to log, as often as you like, your mood, energy, sleep, thinking and excercise, and an activity of your choice.");
	allSetBlockOfText = @[@{kAllSetActivitiesTextAdditional: activitiesAdditionalText}];
	
	return allSetBlockOfText;
}

#pragma mark - Datasubstrate Delegate Methods

- (void)setUpCollectors
{
	APCCoreLocationTracker * locationTracker = [[APCCoreLocationTracker alloc] initWithIdentifier: @"locationTracker"
																		   deferredUpdatesTimeout: 60.0 * 60.0
																			andHomeLocationStatus: APCPassiveLocationTrackingHomeLocationUnavailable];
	
	if (locationTracker != nil) {
		[self.passiveDataCollector addTracker: locationTracker];
	}
}

#pragma mark - APCOnboardingDelegate Methods

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)__unused onboarding
{
	APCScene *scene = [APCScene new];
	scene.name = @"APHInclusionCriteriaViewController";
	scene.storyboardName = @"APHOnboarding";
	scene.bundle = [NSBundle mainBundle];
	
	return scene;
}

#pragma mark - Consent

- (ORKTaskViewController *)consentViewController
{
	APCConsentTask *task = [[APCConsentTask alloc] initWithIdentifier:@"Consent"
												   propertiesFileName:kConsentPropertiesFileName];
	ORKTaskViewController *consentVC = [[ORKTaskViewController alloc] initWithTask:task
																	   taskRunUUID:[NSUUID UUID]];
	
	return consentVC;
}

@end
