//
//  WatcherSOSController.m
//  ElectionsWatcher
//
//  Created by xfire on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatcherSOSController.h"
#import "WatcherChecklistScreenCell.h"
#import "AppDelegate.h"
#import "PollingPlace.h"
#import "WatcherProfile.h"

@implementation WatcherSOSController

static NSString *sosReportSections[] = { @"sos_report" };

@synthesize sosReport;
@synthesize latestActiveResponder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        self.tabBarItem.image = [UIImage imageNamed:@"sos"];
        self.tabBarItem.title = @"S.O.S.";
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc {
    [sosReport release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *defaultPath = [[NSBundle mainBundle] pathForResource: @"WatcherSOS" ofType: @"plist"];
    self.sosReport = [NSDictionary dictionaryWithContentsOfFile: defaultPath];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self.tableView reloadData];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.navigationItem.title = appDelegate.watcherProfile.currentPollingPlace ?
        [NSString stringWithFormat: @"%@ № %@", 
         appDelegate.watcherProfile.currentPollingPlace.type, appDelegate.watcherProfile.currentPollingPlace.number] :
        @"Меня удаляют";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view controller

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.sosReport allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.sosReport objectForKey: sosReportSections[section]];
    return [sectionInfo objectForKey: @"title"];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ( section == [[self.sosReport allKeys] count] - 1 ) {
        UIView *footerView      = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 60)] autorelease];
        UIButton *saveButton    = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        
        saveButton.frame = CGRectInset(footerView.bounds, 10, 10);
        
        [saveButton setTitle: @"Отправить" forState: UIControlStateNormal];
        
        [footerView addSubview: saveButton];
        
        return footerView;
    } else {
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return ( section == [[self.sosReport allKeys] count] - 1 ) ? 60 : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.sosReport objectForKey: sosReportSections[section]];
    return [[sectionInfo objectForKey: @"items"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionInfo = [self.sosReport objectForKey: sosReportSections[indexPath.section]];
    NSDictionary *itemInfo = [[sectionInfo objectForKey: @"items"] objectAtIndex: indexPath.row];
    NSString *itemTitle = [itemInfo objectForKey: @"title"];
    
    int controlType = [[itemInfo objectForKey: @"control"] intValue];
    
    CGSize labelSize = [itemTitle sizeWithFont: [UIFont boldSystemFontOfSize: 13] 
                             constrainedToSize: CGSizeMake(280, 120) 
                                 lineBreakMode: UILineBreakModeWordWrap];
    
    return controlType == INPUT_COMMENT ? 
            labelSize.height + 120 : 
        itemTitle.length ? 
            labelSize.height + 70 : 60;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionInfo = [self.sosReport objectForKey: sosReportSections[indexPath.section]];
    NSDictionary *itemInfo = [[sectionInfo objectForKey: @"items"] objectAtIndex: indexPath.row];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *checklistItems = [[appDelegate.watcherProfile.currentPollingPlace checklistItems] allObjects];
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat: @"SELF.name LIKE %@", [itemInfo objectForKey: @"name"]];
    NSArray *existingItems = [checklistItems filteredArrayUsingPredicate: itemPredicate];
    
    if ( existingItems.count ) {
        [(WatcherChecklistScreenCell *) cell setChecklistItem: [existingItems lastObject]];
    } else {
        ChecklistItem *checklistItem = [NSEntityDescription insertNewObjectForEntityForName: @"ChecklistItem" 
                                                                     inManagedObjectContext: appDelegate.managedObjectContext];
        
        [(WatcherChecklistScreenCell *) cell setChecklistItem: checklistItem];
    }
    
    [cell setNeedsLayout];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [NSString stringWithFormat: @"SosCell_%d_%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellId];
    NSDictionary *sectionInfo = [self.sosReport objectForKey: sosReportSections[indexPath.section]];
    NSDictionary *itemInfo = [[sectionInfo objectForKey: @"items"] objectAtIndex: indexPath.row];
    
    if ( cell == 0 ) {
        cell = [[[WatcherChecklistScreenCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                                  reuseIdentifier: cellId 
                                                     withItemInfo: itemInfo] autorelease];
        [(WatcherChecklistScreenCell *) cell setSaveDelegate: self];
    }
    
    return cell;
}

#pragma mark - Save delegate

-(void)didSaveAttributeItem:(ChecklistItem *)item {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ( ! [appDelegate.watcherProfile.currentPollingPlace.checklistItems containsObject: item] )
        [appDelegate.watcherProfile.currentPollingPlace addChecklistItemsObject: item];
    
    NSError *error = nil;
    [appDelegate.managedObjectContext save: &error];
    if ( error ) 
        NSLog(@"error saving emergency message: %@", error.description);
}

-(BOOL)isCancelling {
    return NO;
}

@end
