//
//  DBSettingsViewController.m
//  Tags
//
//  Created by DB on 2/5/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBSettingsViewController.h"

#import "DBPebbleMonitor.h"
#import "DropboxUploader.h"
#import "MiscUtils.h"

@interface DBSettingsViewController ()
@property(weak, nonatomic) IBOutlet UILabel* pebbleLbl;
@property(weak, nonatomic) IBOutlet UILabel* filesLbl;
@property(weak, nonatomic) IBOutlet UILabel* idLbl;
@end

@implementation DBSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//	[[DBPebbleMonitor sharedInstance] startWatchApp];
	
	_pebbleLbl.text = [[DBPebbleMonitor sharedInstance] connectedPebbleName];
	_filesLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)
					  [[DropboxUploader sharedUploader] numberOfFilesToUpload]];
	_idLbl.text = getUniqueDeviceIdentifierAsString();

	[_pebbleLbl sizeToFit];
	[_filesLbl sizeToFit];
	[_idLbl sizeToFit];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
