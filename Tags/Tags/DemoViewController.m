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
#import "DBMicrosoftBandMonitor.h"
#import "DBDataLogger.h"
#import "DBSensorMonitor.h"
//#import "DBLoggingManager.h" // just for DATALOGGING_PERIOD_MS
#import "DropboxUploader.h"
#import "FileUtils.h"
#import "MiscUtils.h"
#import "CppWrapper.h"

// magical *pair* of lines of code to get it importing the swift lib
#include "Charts-Swift.h"
@import Charts;

const NSUInteger kHistoryLen = 512;
const int kUpdatePlotEvery = 20; // once/second at 20Hz sampling

NSString* kRecordBtnTextOff = @"Start Recording";
NSString* kRecordBtnTextOn = @"Stop Recording";
//NSString* kDeleteBtnTextOff = @"Start Recording";
//NSString* kDeleteBtnTextOn = @"Stop Recording";
NSString *const kLogSubdir = @"recordings/";

//===============================================================
// Logging setup funcs
//===============================================================

NSDictionary* allSignalsNamesToDefaultVals() {
	NSMutableDictionary* dict = [pebbleDefaultValuesDict() mutableCopy];
	[dict addEntriesFromDictionary:defaultsDictMotion()];
	return dict;
}


//===============================================================
//===============================================================
@interface DemoViewController () <ChartViewDelegate, UITextFieldDelegate>
//<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
//===============================================================
//===============================================================

//--------------------------------
// Non-View properties
//--------------------------------

@property (atomic) int numSamplesSeen;
@property (nonatomic) BOOL recording;

@property (strong, nonatomic) NSMutableArray* accelHistoryX;
@property (strong, nonatomic) NSMutableArray* accelHistoryY;
@property (strong, nonatomic) NSMutableArray* accelHistoryZ;
@property (strong, nonatomic) NSMutableArray* timestampHistory;

@property (strong, nonatomic) NSMutableArray* instanceStartIdxs;
@property (strong, nonatomic) NSMutableArray* instanceEndIdxs;
@property (strong, nonatomic) CppWrapper* cpp;
@property (strong, nonatomic) DBSensorMonitor* sensorMonitor;
@property (strong, nonatomic) DBDataLogger* logger;

//--------------------------------
// View properties
//--------------------------------

@property (weak, nonatomic) IBOutlet UITextField* userIdText;
@property (weak, nonatomic) IBOutlet UITextField* actionNameText;
@property (weak, nonatomic) IBOutlet UITextField* exampleNumText;
@property (weak, nonatomic) IBOutlet LineChartView* dataGraph;
@property (weak, nonatomic) IBOutlet UIButton* learnBtn;
@property (weak, nonatomic) IBOutlet UIButton* deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton* recordBtn;
@property (weak, nonatomic) IBOutlet UIStepper* exampleNumStepr;

@end

//===============================================================
//===============================================================
@implementation DemoViewController
//===============================================================
//===============================================================






// TODO get MSBand stuff logged (and plotted?); also get DBLoggingManager to use it






- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// state flags
	_recording = NO;
	_numSamplesSeen = 0;

	// pebble and msband
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notifiedPebbleData:)
												 name:kNotificationPebbleData
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notifiedMSBandData:)
												 name:kNotificationMSBandData
											   object:nil];
	// cpp code
	_cpp = [[CppWrapper alloc] init];

	// plot
	_accelHistoryX = [NSMutableArray array];
	_accelHistoryY = [NSMutableArray array];
	_accelHistoryZ = [NSMutableArray array];
	_timestampHistory = [NSMutableArray array];
//	_histories = @[_accelHistoryX, _accelHistoryY, _accelHistoryZ,
//				   _timestampHistory];

	_dataGraph.delegate = self;
	_dataGraph.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:1.f];

	ChartYAxis *leftAxis = _dataGraph.leftAxis;
	leftAxis.labelTextColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
	leftAxis.axisMaxValue = 2.0;
	leftAxis.axisMinValue = -2.0;
	leftAxis.drawGridLinesEnabled = YES;
	leftAxis.drawZeroLineEnabled = NO;
	leftAxis.granularityEnabled = YES;
	NSNumberFormatter* fmtr = [[NSNumberFormatter alloc] init];
	[fmtr setNegativeFormat:@"0.##g"];
	[fmtr setPositiveFormat:@"0.##g"];
	leftAxis.valueFormatter = fmtr;

	// TODO formatting x axis seems to require a ChartDefaultXAxisValueFormatter
	// object or something; below yields a warning and crashes at runtime
//	ChartXAxis *xAxis = _dataGraph.xAxis;
//	NSNumberFormatter* xfmtr = [[NSNumberFormatter alloc] init];
//	[xfmtr setNegativeFormat:@"0g"];
//	[xfmtr setPositiveFormat:@"0g"];
//	_dataGraph.xAxis.valueFormatter = xfmtr;
//	xAxis.valueFormatter = xfmtr;

	NSDictionary* defaultsDict = allSignalsNamesToDefaultVals();
	_logger = [[DBDataLogger alloc] initWithSignalDefaultsDict:defaultsDict
										   samplePeriod:50]; // 50ms = 20Hz

//	_logger = [[DBDataLogger alloc] initWithSignalNames:[defaultsDict allKeys]
//										  defaultValues:[defaultsDict allValues]
//										   samplePeriod:50 // 50ms = 20Hz
//											   dataType:@"recording"];
	_logger.logSubdir = kLogSubdir;
	_logger.omitDuplicates = NO; // write every line even if same as previous
	_sensorMonitor = [[DBSensorMonitor alloc] initWithDataReceivedHandler:^
		void(NSDictionary *data, timestamp_t timestamp, NSString *type) {
			dispatch_async(dispatch_get_main_queue(), ^{	//main thread
//				NSLog(@"received data from sensor monitor");
				if([type isEqualToString:@"motion"]) {
//					NSLog(@"...and it was motion data");
					[_logger logData:data withTimeStamp:timestamp];
				}
			});
		}
	];

	_dataGraph.drawGridBackgroundEnabled = NO;
	_dataGraph.rightAxis.enabled = NO;
//	_dataGraph.descriptionText = @"Behold, acceleration values";
	_dataGraph.descriptionText = @"";
	_dataGraph.noDataTextDescription = @"Ze chart, she needs ze datas!";

	[_dataGraph animateWithXAxisDuration:1.0];


	// instances of repeating pattern
	_instanceStartIdxs = [NSMutableArray array];
	_instanceEndIdxs = [NSMutableArray array];

	// data logger for acceleration data
//	_logger = [[DBDataLogger alloc] initWithSignalNames:[pebbleDefaultValuesDict() allKeys]
//															defaultValues:[pebbleDefaultValuesDict() allValues]
//															samplePeriod:DATALOGGING_PERIOD_MS
//																dataType:@"PebbleAccel"];

	// ensure these get created so that phone will try to connect to watches
	[DBPebbleMonitor sharedInstance];
	[[DBMicrosoftBandMonitor sharedInstance] tryStartAccelerometerUpdates];

	[self updatePlot:YES]; // yes = force update
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

//===============================================================
#pragma mark - Pebble
//===============================================================

-(void) logPebbleAccelX:(double)x Y:(double)y Z:(double)z
	timeStamp:(timestamp_t)sampleTime {
	// NSDictionary* kvPairs = @{kKeyPebbleX: @(convertPebbleAccelToGs(x)),
	// 						  kKeyPebbleY: @(convertPebbleAccelToGs(y)),
	// 						  kKeyPebbleZ: @(convertPebbleAccelToGs(z))};
	NSDictionary* kvPairs = @{kKeyPebbleX: @(x),
							  kKeyPebbleY: @(y),
							  kKeyPebbleZ: @(z)};
	[_logger logData:kvPairs withTimeStamp:sampleTime];
}

-(void) notifiedPebbleData:(NSNotification*)notification {
	if ([notification name] != kNotificationPebbleData) return;
	if (! _recording) return;

	int x, y, z;
	timestamp_t t;
	extractPebbleData(notification.userInfo, &x, &y, &z, &t);

	[_cpp pushX:x Y:y Z:z];

	double xd = convertPebbleAccelToGs(x);
	double yd = convertPebbleAccelToGs(x);
	double zd = convertPebbleAccelToGs(x);

//	NSLog(@"received pebble data %d, %d, %d", x, y, z);

	[self logPebbleAccelX:xd Y:yd Z:zd timeStamp:t];
//	[self storeAccelX:xd Y:yd Z:zd time:t]; // TODO uncomment after msband test
	[self updatePlot:NO]; // no = don't force update
}

//===============================================================
#pragma mark - MS Band
//===============================================================

-(void) logMSBandAccelX:(double)x Y:(double)y Z:(double)z timeStamp:(timestamp_t)sampleTime {
	//Logs pebble data
	NSDictionary* kvPairs = @{kKeyMSBandX: @(x),
							  kKeyMSBandY: @(y),
							  kKeyMSBandZ: @(z)};
	//	NSDictionary* kvPairs = @{kKeyPebbleX: @(x),
	//							  kKeyPebbleY: @(y),
	//							  kKeyPebbleZ: @(z)};
	[_logger logData:kvPairs withTimeStamp:sampleTime];
}

-(void) notifiedMSBandData:(NSNotification*)notification {
	if ([notification name] != kNotificationMSBandData) return;
	if (! _recording) return;

	double x, y, z;
	timestamp_t t;
	extractMSBandData(notification.userInfo, &x, &y, &z, &t);

	NSLog(@"received ms band data %.3f, %.3f, %.3f, %lld", x, y, z, t);

	[self logMSBandAccelX:x Y:y Z:z timeStamp:t];
	[self storeAccelX:x Y:y Z:z time:t];
	[self updatePlot:NO]; // no = don't force update
}

//===============================================================
#pragma mark - Plotting
//===============================================================

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
//		[dataset setColor:[UIColor blackColor]];
		dataset.fillAlpha = .5f;
		dataset.fillColor = color;
		dataset.drawFilledEnabled = YES;
		dataset.drawCirclesEnabled = NO;
		dataset.drawSteppedEnabled = YES;
//		dataset.lineWidth = 1;
		[dataSets addObject:dataset];
	}
}

- (void)updatePlot:(BOOL)force {

	assert(_numSamplesSeen == [_accelHistoryX count] || _numSamplesSeen > kHistoryLen);
	BOOL shouldUpdate = force || (_numSamplesSeen % kUpdatePlotEvery == 0);
	if (!shouldUpdate) {
		return;
	}

//	LineChartDataSet* x = [[LineChartDataSet alloc] initWithYVals:_accelHistoryX label:@"X accel"];
//	LineChartDataSet* y = [[LineChartDataSet alloc] initWithYVals:_accelHistoryY label:@"Y accel"];
//	LineChartDataSet* z = [[LineChartDataSet alloc] initWithYVals:_accelHistoryZ label:@"Z accel"];

	NSMutableArray *xVals = [[NSMutableArray alloc] init];

	NSUInteger count = [_accelHistoryX count];
//	NSUInteger count = 100;
	for (int i = 0; i < count; i++) {
		long samplesToEnd = count - i - 1;
		float msToEnd = -(samplesToEnd / (float) kPebbleAccelHz);
//		NSString* lbl = [NSString stringWithFormat:@"%@s",
//						 [@(msToEnd) stringValue]];
		// TODO uncomment above
		NSString* lbl = [NSString stringWithFormat:@"%d", i];
		[xVals addObject:lbl];
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
	// TODO remove "if" after debug
	if (count > 100) {
		addDummyDataForStartEndIdxs(_instanceStartIdxs, _instanceEndIdxs, count, dataSets);
	}

	LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
	_dataGraph.data = data;
}

//-(void)

//- (void)storeAccelX:(int8_t)x Y:(int8_t)y Z:(int8_t)z time:(timestamp_t)time {

- (void)storeAccelX:(double)x Y:(double)y Z:(double)z time:(timestamp_t)time {
	// TODO modify the ChartDataSet objects directly

	_numSamplesSeen++;
	NSArray* histories = @[_accelHistoryX, _accelHistoryY, _accelHistoryZ,
						   _timestampHistory];
	NSArray* vals = @[@(x), @(y), @(z), @(time)];
	for (int i = 0; i < [histories count]; i++) {
		NSMutableArray* ar = histories[i];
		[ar addObject:vals[i]];
		if ([ar count] > kHistoryLen) {
			[ar removeObjectAtIndex:0];
		}
	}
}

//===============================================================
#pragma mark - Logging
//===============================================================

-(NSString*) generateLogFileName {
	return [NSString stringWithFormat:@"%@_%@_%@",
						  [_userIdText text],
						  [_actionNameText text],
						  [_exampleNumText text]];

//	return [kLogSubdir stringByAppendingPathComponent:dirName];
}

- (NSString*)generateFileName {
	NSString* fileName = [NSString stringWithFormat:@"%@_%@_%@.csv",
						  [_userIdText text],
						  [_actionNameText text],
						  [_exampleNumText text]];
//						  currentTimeStr()];
	return [FileUtils getFullFileName:fileName];
}

- (void)saveCurrentRecording {
	NSString* fileName = [self generateFileName];
	NSMutableString* outStr = [NSMutableString string];
	for (int i = 0; i < [_accelHistoryX count]; i++) {
		NSString* line = [NSString stringWithFormat:@"%lld,%@,%@,%@\n",
						  (timestamp_t)[_timestampHistory[i] longLongValue],
						  _accelHistoryX[i],
						  _accelHistoryY[i],
						  _accelHistoryZ[i]];
//		NSLog(@"line: %@", line);
		[outStr appendString:line];
	}
	[FileUtils writeString:outStr toFile:fileName];
	NSString* dbPath = [kLogSubdir stringByAppendingPathComponent:[fileName lastPathComponent]];
	[[DropboxUploader sharedUploader] addFileToUpload:fileName toPath:dbPath];
	[[DropboxUploader sharedUploader] tryUploadingFiles];
}

//===============================================================
#pragma mark - UI
//===============================================================

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)clearHistory {
	_numSamplesSeen = 0;
	[_accelHistoryX removeAllObjects];
	[_accelHistoryY removeAllObjects];
	[_accelHistoryZ removeAllObjects];
	[_timestampHistory removeAllObjects];
	[_instanceStartIdxs removeAllObjects];
	[_instanceEndIdxs removeAllObjects];
//	[_logger endLog];
}

//- (IBAction)switchChanged:(id)sender {
//	if ([sender isOn] && !_recording) {
//		_recording = YES;
//		[_saveBtn setEnabled:NO];
//		[self clearHistory];
//		[_cpp clearHistory];
//	} else if (![sender isOn] && _recording) {
//		_recording = NO;
//		[_saveBtn setEnabled:NO];
//		int count = (int)[_accelHistoryX count];
//		dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//			// Add code here to do background processing
//			[_cpp updateStartIdxs:_instanceStartIdxs endIdxs:_instanceEndIdxs
//					   historyLen:count Lmin:.15 Lmax:.3];
//			dispatch_async( dispatch_get_main_queue(), ^{
//				// Add code here to update the UI/send notifications based on the
//				// results of the background processing
//				[self updatePlot:NO];
//			});
//		});
//	}
//}


void setButtonTitle(UIButton* btn, NSString *const title) {
	[btn setTitle: title forState: UIControlStateNormal];
//	[btn setTitle: title forState: UIControlStateApplication];
//	[btn setTitle: title forState: UIControlStateHighlighted];
//	[btn setTitle: title forState: UIControlStateReserved];
//	[btn setTitle: title forState: UIControlStateSelected];
//	[btn setTitle: title forState: UIControlStateDisabled];
}

-(void) learnPattern {
	int count = (int)[_accelHistoryX count];
	if (count < 100) {
		NSLog(@"ignoring recording: too short");
		return;
	}
	if (count > kHistoryLen) {
		count = kHistoryLen;
	}

	dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Add code here to do background processing
		[_cpp updateStartIdxs:_instanceStartIdxs endIdxs:_instanceEndIdxs
				   historyLen:count Lmin:.15 Lmax:.3];

		dispatch_async( dispatch_get_main_queue(), ^{
			// Add code here to update the UI/send notifications based on the
			// results of the background processing
			[self updatePlot:YES]; // YES = force update
		});
	});
}

-(void) stopRecording:(BOOL)save {
	_recording = NO;

	[_learnBtn setEnabled:YES];
	setButtonTitle(_recordBtn, kRecordBtnTextOff);

	if (save) {
		[_logger endLog]; // saves file immediately
	} else {
		[_logger cancelLog];
	}
}
-(void) startRecording {
	_recording = YES;

	[_deleteBtn setEnabled:YES];
	[_learnBtn setEnabled:NO];
	setButtonTitle(_recordBtn, kRecordBtnTextOn);

	[self clearHistory];
	[_cpp clearHistory];

	_logger.logName = [self generateLogFileName];
	[_logger startLog];
}


- (IBAction)recordingBtnPressed:(id)sender {
	if (_recording) {
		[_deleteBtn setEnabled:YES];
		[self stopRecording:YES];
	} else {
		[self startRecording];
	}
}

- (IBAction)learnBtnPressed:(id)sender {
	[sender setEnabled:NO];
	[self learnPattern];
}

- (IBAction)deleteBtnPressed:(id)sender {
	[sender setEnabled:NO];
	NSLog(@"delete btn pressed");
	if (_recording) {
		NSLog(@"delete btn stopping recording");
		[self stopRecording:NO];
	} else {
		NSLog(@"delete btn not stopping recording cuz already stopped");
		[_logger deleteLog];
	}
}

-(IBAction)motionNumberChanged:(id)sender {
	int num = round([_exampleNumStepr value]);
	NSString* valueStr = [NSString stringWithFormat:@"%d", num];
	[_exampleNumText setText:valueStr];
}

@end
