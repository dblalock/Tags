//
//  DemoViewController.m
//  Tags
//
//  Created by DB on 4/4/16.
//  Copyright © 2016 D Blalock. All rights reserved.
//

#import "DemoViewController.h"

//#import "GraphView.h"
#import "DBPebbleMonitor.h"
#import "DropboxUploader.h"
#import "MiscUtils.h"

//#import "BEMSimpleLineGraphView.h"
#import "Tags-Swift.h"

//#import <Charts/Charts.h>
//#import "Charts.h"
//#import "Charts/Charts.h"

// magical *pair* of lines of code to get it importing the swift lib
#include "Charts-Swift.h"
@import Charts;

static const NSUInteger kHistoryLen = 512;

//===============================================================
//===============================================================
@interface DemoViewController () <ChartViewDelegate>
//<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
//===============================================================
//===============================================================

//--------------------------------
// Non-View properties
//--------------------------------

@property (nonatomic) BOOL recording;
@property (strong, nonatomic) NSMutableArray* accelHistoryX;
@property (strong, nonatomic) NSMutableArray* accelHistoryY;
@property (strong, nonatomic) NSMutableArray* accelHistoryZ;
@property (strong, nonatomic) NSMutableArray* instanceStartIdxs;
@property (strong, nonatomic) NSMutableArray* instanceEndIdxs;

//--------------------------------
// View properties
//--------------------------------

@property (weak, nonatomic) IBOutlet UITextField *userIdText;
@property (weak, nonatomic) IBOutlet UITextField *actionNameText;
@property (weak, nonatomic) IBOutlet UITextField *actionCountText;
//@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *dataGraph;
@property (weak, nonatomic) IBOutlet LineChartView *dataGraph;

@end

//===============================================================
//===============================================================
@implementation DemoViewController
//===============================================================
//===============================================================


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	// state flags
	_recording = NO;
	
	// pebble
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notifiedPebbleData:)
												 name:kNotificationPebbleData
											   object:nil];
	// plot
	_accelHistoryX = [NSMutableArray array];
	_accelHistoryY = [NSMutableArray array];
	_accelHistoryZ = [NSMutableArray array];
	_dataGraph.delegate = self;
	_dataGraph.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:1.f];
	
	
	ChartYAxis *leftAxis = _dataGraph.leftAxis;
	leftAxis.labelTextColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
	leftAxis.axisMaxValue = 2.0;
	leftAxis.axisMinValue = -2.0;
	leftAxis.drawGridLinesEnabled = YES;
	leftAxis.drawZeroLineEnabled = NO;
	leftAxis.granularityEnabled = YES;
	
	_dataGraph.drawGridBackgroundEnabled = NO;
	_dataGraph.rightAxis.enabled = NO;
//	_dataGraph.descriptionText = @"Behold, acceleration values";
	_dataGraph.descriptionText = @"";
	_dataGraph.noDataTextDescription = @"Ze chart, she needs ze datas!";
	
	[_dataGraph animateWithXAxisDuration:1.0];
	
	
	// instances of repeating pattern
	_instanceStartIdxs = [NSMutableArray array];
	_instanceEndIdxs = [NSMutableArray array];
	
	
	[self updatePlot];
//	[_dataGraph reloa
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

//===============================================================
#pragma mark Pebble
//===============================================================

-(void) notifiedPebbleData:(NSNotification*)notification {
	if ([notification name] != kNotificationPebbleData) return;
//	if (! _recording) return;
	
	int x, y, z;
	timestamp_t t;
	extractPebbleData(notification.userInfo, &x, &y, &z, &t);
	
//	NSLog(@"received pebble data %d, %d, %d", x, y, z);
	
//	[self logAccelX:x Y:y Z:z timeStamp:t];
	[self plotAccelX:x Y:y Z:z];
}

//===============================================================
#pragma mark Plotting
//===============================================================

// -------------------------- BEMSimpleLineGraphDelegate

//- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
//	return [_accelHistory count];
//}
//- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
//	return …; // The value of the point on the Y-Axis for the index.
//}

void addDummyDataForStartEndIdxs(NSArray* startIdxs, NSArray* endIdxs,
								 NSUInteger dataLength, NSMutableArray *dataSets) {
	
//	NSAssert([startIdxs count] == [endIdxs count],
//			 @"must have same number of start and end idxs!");
	
	NSMutableArray* dummyData = [NSMutableArray arrayWithCapacity:dataLength];
	for (int i = 0; i < dataLength; i++) {
		dummyData[i] = @(0.0);
	}
	for (int i = 0; i < [startIdxs count]; i++) {
		int start = [startIdxs[i] intValue];
		int end = [endIdxs[i] intValue];
		for (int j = start; j < end; j++) {
			dummyData[j] = @(2.0);
		}
	}
	
	// create an array of ChartDataEntries
	for (int d = 0; d < 2; d++) {
		NSMutableArray *vals = [[NSMutableArray alloc] init];
		for (int i = 0; i < [dummyData count]; i++) {
			//		for (int i = 0; i < 100; i++) {
			double val = [dummyData[i] doubleValue];
			if (d == 1) {
				val = -val; // flip it below x axis
			}
			//			double val = (double) (arc4random_uniform(i)) + i / 100;
			[vals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
		}
		NSString* label = d == 0 ? @"Instances" : @"";
		LineChartDataSet* dataset = [[LineChartDataSet alloc] initWithYVals:vals label:label];
		UIColor* color = [UIColor grayColor];
		[dataset setColor:color];
		dataset.fillAlpha = .5f;
		dataset.fillColor = color;
		dataset.drawFilledEnabled = YES;
		dataset.drawCirclesEnabled = NO;
		dataset.drawSteppedEnabled = YES;
		[dataSets addObject:dataset];
	}
}

- (void)updatePlot {
//	LineChartDataSet* x = [[LineChartDataSet alloc] initWithYVals:_accelHistoryX label:@"X accel"];
//	LineChartDataSet* y = [[LineChartDataSet alloc] initWithYVals:_accelHistoryY label:@"Y accel"];
//	LineChartDataSet* z = [[LineChartDataSet alloc] initWithYVals:_accelHistoryZ label:@"Z accel"];
	
	NSMutableArray *xVals = [[NSMutableArray alloc] init];
	
	NSUInteger count = [_accelHistoryX count];
//	NSUInteger count = 100;
	for (int i = 0; i < count; i++) {
		[xVals addObject:[@(i) stringValue]];
	}
	
	NSMutableArray *dataSets = [[NSMutableArray alloc] init];
//	[dataSets addObject:x];
//	[dataSets addObject:y];
//	[dataSets addObject:z];
	
	NSArray* colors = @[
		[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f],
		[UIColor colorWithRed:120/255.f green:180/255.f blue:51/255.f alpha:1.f],
		[UIColor colorWithRed:229/255.f green:181/255.f blue:51/255.f alpha:1.f],
	];
	NSArray* histories = @[_accelHistoryX, _accelHistoryY, _accelHistoryZ];
	NSArray* names = @[@"x", @"y", @"z"];
	for (int j = 0; j < 3; j++) {
		// create a dataset object from each of x, y, z, acceleration
		NSArray* ar = histories[j];
		NSMutableArray *vals = [[NSMutableArray alloc] init];
		for (int i = 0; i < [ar count]; i++) {
			double val = [ar[i] doubleValue];
//			double val = (double) (arc4random_uniform(i)) + i / 100;
			[vals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
		}
		LineChartDataSet* dataset = [[LineChartDataSet alloc] initWithYVals:vals label:names[j]];
		
		UIColor* color = colors[j];
		[dataset setColor:color];
		dataset.circleRadius = .5f;
		dataset.circleHoleColor = color;
		dataset.lineWidth = 3.0f;
		[dataset setCircleColor:color];
		
		[dataSets addObject:dataset];
	}
	
	// plot boundaries of pattern instances
	// TODO remove after debug
	if (count > 100) {
		NSArray* fakeStarts = @[@(20), @(70)];
		NSArray* fakeEnds = @[@(50), @(90)];
		addDummyDataForStartEndIdxs(fakeStarts, fakeEnds, count, dataSets);
	}
	
	// 1 fake dataset works
//	NSMutableArray *yVals = [[NSMutableArray alloc] init];
//	for (int i = 0; i < 100; i++) {
//		double val = (double) (arc4random_uniform(i)) + i / 100;
//		[yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
//	}
	
//	LineChartDataSet* yDataset = [[LineChartDataSet alloc] initWithYVals:yVals label:@"random"];
//	[yDataset setAxisDependency:AxisDependencyLeft];
//	[dataSets addObject:yDataset];
	
	LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
	_dataGraph.data = data;
}

- (void)plotAccelX:(int8_t)x Y:(int8_t)y Z:(int8_t)z {
	
	// TODO modify the ChartDataSet objects directly
	
	NSArray* histories = @[_accelHistoryX, _accelHistoryY, _accelHistoryZ];
	NSArray* vals = @[@(convertPebbleAccelToGs(x)),
					  @(convertPebbleAccelToGs(y)),
					  @(convertPebbleAccelToGs(z))];
	for (int i = 0; i < [histories count]; i++) {
		NSMutableArray* ar = histories[i];
		[ar addObject:vals[i]];
		if ([ar count] > kHistoryLen) {
			[ar removeObjectAtIndex:0];
		}
	}

	[self updatePlot];
}

@end
