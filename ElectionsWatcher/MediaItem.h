//
//  MediaItem.h
//  ElectionsWatcher
//
//  Created by xfire on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChecklistItem, PollingPlace;

@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * serverUrl;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * synchronized;
@property (nonatomic, retain) NSNumber * serverRecordId;
@property (nonatomic, retain) ChecklistItem *checklistItem;
@property (nonatomic, retain) PollingPlace *pollingPlace;

- (NSString *) amazonS3FilePath;
- (BOOL) isReadyToSync;

@end
