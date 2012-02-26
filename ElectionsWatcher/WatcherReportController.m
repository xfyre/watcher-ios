//
//  WatcherReportController.m
//  ElectionsWatcher
//
//  Created by xfire on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatcherReportController.h"
#import "WatcherReportGraph.h"
#import "AppDelegate.h"
#import "ChecklistItem.h"
#import "PollingPlace.h"
#import "WatcherProfile.h"
#import "Facebook.h"
#import "WatcherTools.h"

@implementation WatcherReportController

@synthesize goodItems, badItems;
@synthesize watcherChecklist;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    
    if ( self ) {
        self.tabBarItem.image = [UIImage imageNamed:@"report"];
        self.tabBarItem.title = @"Отчет";
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
    [goodItems release];
    [badItems release];
    [watcherChecklist release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.watcherChecklist = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"WatcherChecklist" 
                                                                                                        ofType: @"plist"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *checklistItems = [appDelegate.watcherProfile.currentPollingPlace.checklistItems allObjects];
    
    NSPredicate *badPredicate   = [NSPredicate predicateWithFormat: @"SELF.sectionName != NIL && SELF.screenIndex >= 0 && SELF.violationFlag == 1"];
    NSPredicate *goodPredicate  = [NSPredicate predicateWithFormat: @"SELF.sectionName != NIL && SELF.screenIndex >= 0 && SELF.violationFlag == 0"];
    
    self.goodItems = [checklistItems filteredArrayUsingPredicate: goodPredicate];
    self.badItems = [checklistItems filteredArrayUsingPredicate: badPredicate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.navigationItem.title = appDelegate.watcherProfile.currentPollingPlace ?
    appDelegate.watcherProfile.currentPollingPlace.titleString : @"Отчет";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ( section == 1 ) ? 50 : 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if  ( section == 1 ) {
        NSString *summary = nil;
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if ( appDelegate.watcherProfile.currentPollingPlace )
            summary = self.badItems.count ?
                [NSString stringWithFormat: @"Нарушения на %@", appDelegate.watcherProfile.currentPollingPlace.titleString] :
                [NSString stringWithFormat: @"На %@ не отмечено нарушений", appDelegate.watcherProfile.currentPollingPlace.titleString] ;
        else
            summary = @"Информация появится после заполнения раздела «Наблюдение»";
        

        CGRect headerFrame = CGRectMake(10, 0, tableView.bounds.size.width-10, 60);
        UIView *headerView = [[[UIView alloc] initWithFrame: headerFrame] autorelease];
        
        UIButton *linkButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        UIButton *facebookButton = [UIButton buttonWithType: UIButtonTypeCustom];
        UIButton *twitterButton = [UIButton buttonWithType: UIButtonTypeCustom];
        UILabel *summaryLabel = [[[UILabel alloc] initWithFrame: CGRectZero] autorelease];
        
        [linkButton setTitle: @"Ваш отчет на сайте" forState: UIControlStateNormal];
        [linkButton setTitleColor: [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1.000] forState: UIControlStateNormal];
        [linkButton setTitleColor: [UIColor lightTextColor] forState: UIControlStateSelected];
        [facebookButton setImage: [UIImage imageNamed: @"button_facebook"] forState: UIControlStateNormal];
        [twitterButton setImage: [UIImage imageNamed: @"button_twitter"] forState: UIControlStateNormal];
        
        summaryLabel.text = summary;
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1.000];
        summaryLabel.shadowColor = [UIColor colorWithWhite: 1 alpha: 1];
        summaryLabel.shadowOffset = CGSizeMake(0, 1);
        summaryLabel.font = [UIFont boldSystemFontOfSize: 15];
        summaryLabel.numberOfLines = 2;
        summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        linkButton.titleLabel.font = [UIFont boldSystemFontOfSize: 15];
        linkButton.titleLabel.textAlignment = UITextAlignmentLeft;
        
        [headerView addSubview: summaryLabel];
        [headerView addSubview: linkButton];
        [headerView addSubview: facebookButton];
        [headerView addSubview: twitterButton];
        
        
        linkButton.frame = CGRectMake(10, 0, headerFrame.size.width-90, 30);
        twitterButton.frame = CGRectMake(headerFrame.size.width-70, 0, 30, 30);
        facebookButton.frame = CGRectMake(headerFrame.size.width-30, 0, 30, 30);
        
        linkButton.enabled = appDelegate.watcherProfile.userId != nil;
        twitterButton.enabled = ( appDelegate.watcherProfile.twNickname != nil ) && [TWTweetComposeViewController canSendTweet];
        facebookButton.enabled = appDelegate.watcherProfile.fbAccessToken != nil;
        
        [linkButton addTarget: self action: @selector(openWebsite:) forControlEvents: UIControlEventTouchUpInside];
        [twitterButton addTarget: self action: @selector(shareWithTwitter:) forControlEvents: UIControlEventTouchUpInside];
        [facebookButton addTarget: self action: @selector(shareWithFacebook:) forControlEvents: UIControlEventTouchUpInside];
        
        summaryLabel.frame = CGRectMake(10, 30, headerFrame.size.width, 40);
        
        return headerView;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return ( section == 2 && self.badItems.count ) ? 100 : 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ( section == 2 && self.badItems.count ) {
        UIView *footerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 100)] autorelease];
        
        CGRect labelFrame = CGRectMake(15, 10, footerView.bounds.size.width-30, 20);
        UILabel *label1 = [[[UILabel alloc] initWithFrame: labelFrame] autorelease];
        UILabel *label2 = [[[UILabel alloc] initWithFrame: CGRectOffset(labelFrame, 0, 20)] autorelease];
        UILabel *label3 = [[[UILabel alloc] initWithFrame: CGRectOffset(labelFrame, 0, 40)] autorelease];
        UILabel *label4 = [[[UILabel alloc] initWithFrame: CGRectOffset(labelFrame, 0, 60)] autorelease];
        
        NSArray *labels = [NSArray arrayWithObjects: label1, label2, label3, label4, nil];
        for ( UILabel *label in labels ) {
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize: 15];
            label.textColor = [UIColor colorWithRed:0.265 green:0.294 blue:0.367 alpha:1.000];
            label.shadowColor = [UIColor colorWithWhite: 1 alpha: 1];
            label.shadowOffset = CGSizeMake(0, 1);
            [footerView addSubview: label];
        }
        
        label1.text = @"Чтобы подать жалобу по нарушениям:";
        label2.text = @"1. Заполните жалобу.";
        label3.text = @"2. Передайте её председателю.";
        label4.text = @"3. Оставьте один экземпляр у себя.";
        
        return footerView;
    }
        
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ( section) {
        case 0:
            return 1;
        case 1:
            return 0;
        default:
            return self.badItems.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ( indexPath.section == 0 && indexPath.row == 0 ) ? 200 : 50;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 2 ) {
        ChecklistItem *item = [self.badItems objectAtIndex: indexPath.row];
        
        NSDictionary *sectionInfo = [watcherChecklist objectForKey: item.sectionName];
        NSArray *sectionScreens = [sectionInfo objectForKey: @"screens"];
        NSDictionary *screenInfo = [sectionScreens objectAtIndex: [item.screenIndex intValue]];
        NSArray *screenItems = [screenInfo objectForKey: @"items"];
        NSPredicate *itemPredicate = [NSPredicate predicateWithFormat: @"SELF.name LIKE %@", item.name];
    
        cell.textLabel.text = [[[screenItems filteredArrayUsingPredicate: itemPredicate] lastObject] objectForKey: @"violation_text"];
    }
    
    if ( indexPath.section == 0 && indexPath.row == 0 ) {
        CGRect cb = cell.contentView.bounds;
        
        WatcherReportGraph *graph = (WatcherReportGraph *) [cell.contentView viewWithTag: 11];
        graph.superview.frame = CGRectInset(cb,10,40);
        graph.frame = graph.superview.bounds;
        graph.goodCount = self.goodItems.count;
        graph.badCount = self.badItems.count;
        
        [graph setNeedsDisplay];
        
        UILabel *goodCountLabel = (UILabel *) [cell.contentView viewWithTag: 12];
        UILabel *badCountLabel = (UILabel *) [cell.contentView viewWithTag: 13];
        
        
        goodCountLabel.frame = CGRectMake(10, 0, cb.size.width-20, 30);
        goodCountLabel.text = self.goodItems.count ? 
            [WatcherTools countOfConformances: self.goodItems.count] : @"Нет отметок";
        
        badCountLabel.frame = CGRectMake(10, cb.size.height-30, cb.size.width-20, 30);
        badCountLabel.text = self.badItems.count ? 
            [WatcherTools countOfViolations: self.badItems.count] : @"Нет отметок";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = ( indexPath.section == 0 && indexPath.row == 0 ) ? @"GraphCell" : @"ReportCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if ( indexPath.section == 0 && indexPath.row == 0 ) {
            UIView *graphHolder = [[UIView alloc] init];
            WatcherReportGraph *graph = [[WatcherReportGraph alloc] init];
            [graph setTag: 11];
            [graphHolder addSubview: graph];
            [graph release];
            [cell.contentView addSubview: graphHolder];
            [graphHolder release];
            
            UILabel *goodCountLabel = [[UILabel alloc] init];
            goodCountLabel.textColor = [UIColor colorWithRed: 0 green: 0x77/255.0f blue: 0xcb/255.0f alpha: 1];
            goodCountLabel.font = [UIFont boldSystemFontOfSize: 16];
            goodCountLabel.backgroundColor = [UIColor clearColor];
            goodCountLabel.tag = 12;
            goodCountLabel.textAlignment = UITextAlignmentLeft;
            [cell.contentView addSubview: goodCountLabel];
            [goodCountLabel release];
            
            UILabel *badCountLabel = [[UILabel alloc] init];
            badCountLabel.textColor = [UIColor colorWithRed: 0xdf/255.0f green: 0x2a/255.0f blue: 0 alpha: 1];
            badCountLabel.font = [UIFont boldSystemFontOfSize: 16];
            badCountLabel.backgroundColor = [UIColor clearColor];
            badCountLabel.tag = 13;
            badCountLabel.textAlignment = UITextAlignmentRight;
            [cell.contentView addSubview: badCountLabel];
            [badCountLabel release];
            
            graphHolder.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"report_graph_bg"]] autorelease];
        } else {
            cell.textLabel.font = [UIFont boldSystemFontOfSize: 12];
            cell.textLabel.numberOfLines = 3;
        }
    }
    
    cell.textLabel.text = nil;

    return cell;
}

#pragma mark - Report sharing

- (void) openWebsite: (id) sender {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *reportUrlString = [@"http://webnabludatel.org/user/" stringByAppendingString: appDelegate.watcherProfile.userId];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: reportUrlString]];
}

- (void) shareWithTwitter: (id) sender {
    if ( [TWTweetComposeViewController canSendTweet] ) {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSString *reportUrlString = [@"http://webnabludatel.org/user/" stringByAppendingString: appDelegate.watcherProfile.userId];
        
        TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [controller setInitialText: @"Отчет о нарушениях"];
        [controller addURL: [NSURL URLWithString: reportUrlString]];
        [self presentModalViewController: controller animated: YES];
        [controller release];
    } else {
        // FIXME
    }
}

- (void) shareWithFacebook: (id) sender {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ( [appDelegate.facebook isSessionValid] ) {
        NSString *reportUrlString = [@"http://webnabludatel.org/user/" stringByAppendingString: appDelegate.watcherProfile.userId];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"308722072498316", @"app_id",
                                       reportUrlString, @"link",
                                       @"http://webnabludatel.org/assets/logo-c9604203fd303189d1c58c87eff80da7.png", @"picture",
                                       @"Отчет о нарушениях", @"name",
                                       // @"Отчет о нарушениях", @"caption",
                                       @"Отчет о нарушениях на сайте webnabludatel.org", @"description",
                                       @"Отчет о нарушениях на сайте webnabludatel.org",  @"message",
                                       nil];
        
        [appDelegate.facebook dialog: @"feed" andParams: params andDelegate: self];        
    }
}

@end
