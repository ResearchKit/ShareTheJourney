// 
//  APHScoring.m 
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
 
#import "APHScoring.h"

static NSDateFormatter *dateFormatter = nil;

NSString *const kDatasetDateKey  = @"datasetDateKey";
NSString *const kDatasetValueKey = @"datasetValueKey";

@interface APHScoring()

@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) NSMutableArray *correlateDataPoints;
@property (nonatomic) NSUInteger current;
@property (nonatomic) NSUInteger correlatedCurrent;
@property (nonatomic) BOOL hasCorrelateDataPoints;
@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation APHScoring

/*
 * @usage  APHScoring.h should be imported.
 *
 *   There are two ways to get data, Core Data and HealthKit. Each source can
 *   
 *   For Core Data:
 *      APHScoring *scoring = [APHScoring alloc] initWithTaskId:taskId numberOfDays:-5 valueKey:@"value";
 *
 *   For HealthKit:
 *      APHScoring *scoring = [APHScoring alloc] initWithHealthKitQuantityType:[HKQuantityType ...] numberOfDays:-5
 *
 *   NSLog(@"Score Min: %f", [[scoring minimumDataPoint] doubleValue]);
 *   NSLog(@"Score Max: %f", [[scoring maximumDataPoint] doubleValue]);
 *   NSLog(@"Score Avg: %f", [[scoring averageDataPoint] doubleValue]);
 *
 *   NSDictionary *score = nil;
 *   while (score = [scoring nextObject]) {
 *       NSLog(@"Score: %f", [[score valueForKey:@"value"] doubleValue]);
 *   }
 */

- (void)sharedInit
{
    _dataPoints = [NSMutableArray array];
    _correlateDataPoints = [NSMutableArray array];
    _hasCorrelateDataPoints = NO; //(correlateKind != APHDataKindNone);
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if ([HKHealthStore isHealthDataAvailable]) {
        _healthStore = [[HKHealthStore alloc] init];
        
        NSSet *readDataTypes = [self healthKitDataTypesToRead];
        
        [_healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:readDataTypes
                                            completion:^(BOOL success, NSError *error) {
                                                if (!success) {
                                                    NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                                                    
                                                    return;
                                                }
                                            }];
    }
}

/**
 * @brief   Returns an instance of APHScoring.
 *
 * @param   taskId          The ID of the task whoes data needs to be displayed
 *
 * @param   numberOfDays    Number of days that the data is needed. Negative will produce data
 *                          from past and positive will yeild future days.
 *
 * @param   valueKey        The key that is used for storing data
 *
 */
- (instancetype)initWithTask:(NSString *)taskId
                numberOfDays:(NSUInteger)numberOfDays
                    valueKey:(NSString *)valueKey
                     dataKey:(NSString *)dataKey
{
    self = [super init];
    
    if (self) {
        [self sharedInit];
        [self queryTaskId:taskId forDays:numberOfDays valueKey:valueKey dataKey:dataKey];
    }
    
    return self;
}

/**
 * @brief   Returns an instance of APHScoring.
 *
 * @param   quantityType    The HealthKit quantity type
 *
 * @param   numberOfDays    Number of days that the data is needed. Negative will produce data
 *                          from past and positive will yeild future days.
 *
 */
- (instancetype)initWithHealthKitQuantityType:(HKQuantityType *)quantityType numberOfDays:(NSUInteger)numberOfDays
{
    self = [super init];
    
    if (self) {
        [self sharedInit];
        [self statsCollectionQueryForQuantityType:quantityType forDays:numberOfDays];
    }
    
    return self;
}

#pragma mark - Queries
#pragma mark Core Data

- (void)queryTaskId:(NSString *)taskId forDays:(NSUInteger)days valueKey:(NSString *)valueKey dataKey:(NSString *)dataKey
{
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startOn"
                                                                   ascending:YES];
    
    NSFetchRequest *request = [APCScheduledTask request];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
                                                                options:0];
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                               minute:59
                                                               second:59
                                                               ofDate:[NSDate date]
                                                              options:0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(task.taskID == %@) AND (startOn >= %@) AND (startOn <= %@)",
                              taskId, startDate, endDate];
    
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *tasks = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request error:&error];

    for (APCScheduledTask *task in tasks) {
        if ([task.completed boolValue]) {
            NSDictionary *taskResult = [self retrieveResultSummaryFromResults:task.results];
            
            if (taskResult) {
                if (!dataKey) {
                    [self.dataPoints addObject:@{
                                         kDatasetDateKey: task.startOn,
                                         kDatasetValueKey: [taskResult valueForKey:valueKey]
                                        }];
                } else {
                    NSDictionary *nestedData = [taskResult valueForKey:dataKey];
                    
                    if (nestedData) {
                        [self.dataPoints addObject:@{
                                                     kDatasetDateKey: task.startOn,
                                                     kDatasetValueKey: [nestedData valueForKey:valueKey]
                                                     }];
                    }
                }
            }
        }
    }
}

- (NSDictionary *)retrieveResultSummaryFromResults:(NSSet *)results
{
    NSDictionary *result = nil;
    NSArray *scheduledTaskResults = [results allObjects];
    
    // sort the results in a decsending order,
    // in case there are more than one result for a meal time.
    NSSortDescriptor *sortByCreateAtDescending = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                             ascending:NO];
    
    NSArray *sortedScheduleTaskresults = [scheduledTaskResults sortedArrayUsingDescriptors:@[sortByCreateAtDescending]];
    
    // We are iterating throught the results because:
    // a.) There could be more than one result
    // b.) In case the last result is nil, we will pick the next result that has a value.
    NSString *resultSummary = nil;
    
    for (APCResult *result in sortedScheduleTaskresults) {
        resultSummary = [result resultSummary];
        if (resultSummary) {
            break;
        }
    }
    
    if (resultSummary) {
        NSData *resultData = [resultSummary dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        result = [NSJSONSerialization JSONObjectWithData:resultData
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error];
    }
    
    return result;
}

#pragma mark HealthKit

- (void)statsCollectionQueryForQuantityType:(HKQuantityType *)quantityType forDays:(NSInteger)days
{
    NSMutableArray *queryDataset = [NSMutableArray array];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateBySettingHour:0
                                                                 minute:0
                                                                 second:0
                                                                 ofDate:[self dateForSpan:days]
                                                                options:0];
    
    NSLog(@"Week Start/End: %@/%@", startDate, [NSDate date]);
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:[NSDate date] options:HKQueryOptionStrictStartDate];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:predicate
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];
    // set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * __unused query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSDate *endDate = [[NSCalendar currentCalendar] dateBySettingHour:23
                                                                       minute:59
                                                                       second:59
                                                                       ofDate:[NSDate date]
                                                                      options:0];
            NSDate *beginDate = startDate;
            
            [results enumerateStatisticsFromDate:beginDate
                                          toDate:endDate
                                       withBlock:^(HKStatistics *result, BOOL * __unused stop) {
                                           HKQuantity *quantity = result.sumQuantity;
                                           
                                           if (quantity) {
                                               NSDate *date = result.startDate;
                                               double value = [quantity doubleValueForUnit:[HKUnit meterUnit]];
                                               
                                               NSDictionary *dataPoint = @{
                                                                           kDatasetDateKey: [dateFormatter stringFromDate:date],
                                                                           kDatasetValueKey: [NSNumber numberWithDouble:value]
                                                                           };
                                               
                                               [queryDataset addObject:dataPoint];
                                               
                                               NSLog(@"%@: %f", date, value);
                                           }
                                       }];
            [self dataIsAvailableFromHealthKit:queryDataset];
        }
    };
    
    [self.healthStore executeQuery:query];
}

- (void)dataIsAvailableFromHealthKit:(NSArray *)dataset
{
    self.dataPoints = [dataset mutableCopy];
}

/**
 * @brief   Returns an NSDate that is past/future by the value of daySpan.
 *
 * @param   daySpan Number of days relative to current date.
 *                  If negative, date will be number of days in the past;
 *                  otherwise the date will be number of days in the future.
 *
 * @return  Returns the date as NSDate.
 */
- (NSDate *)dateForSpan:(NSInteger)daySpan
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daySpan];
    
    NSDate *spanDate = [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                                     toDate:[NSDate date]
                                                                    options:0];
    return spanDate;
}


- (NSNumber *)minimumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@min.datasetValueKey"];
}

- (NSNumber *)maximumDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@max.datasetValueKey"];
}

- (NSNumber *)averageDataPoint
{
    return [self.dataPoints valueForKeyPath:@"@avg.datasetValueKey"];
}

- (id)nextObject
{
    id nextPoint = nil;
    
    if (self.current < [self.dataPoints count]) {
        nextPoint = [self.dataPoints objectAtIndex:self.current++];
    } else {
        self.current = 0;
        nextPoint = [self.dataPoints objectAtIndex:self.current++];
    }
    
    return nextPoint;
}

- (id)nextCorrelatedObject
{
    id nextCorrelatedPoint = nil;
    
    if (self.correlatedCurrent < [self.correlateDataPoints count]) {
        nextCorrelatedPoint = [self.correlateDataPoints objectAtIndex:self.correlatedCurrent++];
    }
    
    return nextCorrelatedPoint;
}

#pragma mark - Helpers

- (NSSet *)healthKitDataTypesToRead {
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *carbs = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *sugar = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar];
    
    return [NSSet setWithObjects:steps, carbs, sugar, nil];
}

#pragma mark - Graph Datasource

- (NSInteger)lineGraph:(APCLineGraphView *) __unused graphView numberOfPointsInPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if (plotIndex == 0) {
        numberOfPoints = [self.dataPoints count];
    } else {
        numberOfPoints = [self.correlateDataPoints count];
    }
    
    return numberOfPoints;
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *) __unused graphView
{
    NSUInteger numberOfPlots = 1;
    
    if (self.hasCorrelateDataPoints) {
        numberOfPlots = 2;
    }
    return numberOfPlots;
}

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *) __unused graphView
{
    NSLog(@"%f", [[self minimumDataPoint] doubleValue]);
    return [[self minimumDataPoint] doubleValue];
}

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *) __unused graphView
{
        NSLog(@"%f", [[self maximumDataPoint] doubleValue]);
    return [[self maximumDataPoint] doubleValue];
}

- (CGFloat)lineGraph:(APCLineGraphView *) __unused graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger) __unused pointIndex
{
    CGFloat value;
    
    if (plotIndex == 0) {
        NSDictionary *point = [self nextObject];
        value = [[point valueForKey:kDatasetValueKey] doubleValue];
    } else {
        NSDictionary *correlatedPoint = [self nextCorrelatedObject];
        value = [[correlatedPoint valueForKey:kDatasetValueKey] doubleValue];
    }
    
    return value;
}


@end
