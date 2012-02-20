//
//  WatcherPollingPlaceController.h
//  ElectionsWatcher
//
//  Created by xfire on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatcherSaveAttributeDelegate.h"
#import "WatcherPollingPlaceControllerDelegate.h"
#import "WatcherChecklistScreenCellDelegate.h"

@class PollingPlace;

@interface WatcherPollingPlaceController : UITableViewController <WatcherSaveAttributeDelegate, WatcherChecklistScreenCellDelegate>

@property (nonatomic, assign) id <WatcherPollingPlaceControllerDelegate> pollingPlaceControllerDelegate;
@property (nonatomic, assign) PollingPlace *pollingPlace;
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic) BOOL isCancelling;
@property (nonatomic, assign) UIResponder *latestActiveResponder;

@end
