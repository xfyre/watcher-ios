//
//  ChecklistItem.h
//  ElectionsWatcher
//
//  Created by xfire on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem, PollingPlace, WatcherProfile;

@interface ChecklistItem : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * screenIndex;
@property (nonatomic, retain) NSNumber * serverRecordId;
@property (nonatomic, retain) NSNumber * synchronized;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * violationFlag;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSSet *mediaItems;
@property (nonatomic, retain) PollingPlace *pollingPlace;
@property (nonatomic, retain) WatcherProfile *watcherProfile;
@end

@interface ChecklistItem (CoreDataGeneratedAccessors)

- (void)addMediaItemsObject:(MediaItem *)value;
- (void)removeMediaItemsObject:(MediaItem *)value;
- (void)addMediaItems:(NSSet *)values;
- (void)removeMediaItems:(NSSet *)values;
@end
