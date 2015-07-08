//
//  ViewController.m
//  ZCScrollerBarFollowDemo
//
//  Created by cuibo on 7/8/15.
//  Copyright (c) 2015 cuibo. All rights reserved.
//

#import "ViewController.h"

#import "ZCScrollerBarFollow.h"

NSString * const TableViewCellIdentifier = @"TableViewCellIdentifier";


@interface ViewController ()
<ZCScrollerBarFollowDelegate, UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) NSMutableArray *datasource;
@property(strong, nonatomic) ZCScrollerBarFollow *scrollerFollow;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDatasource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *followView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0, 40)];
    UIView *backgroundView = [[UIView alloc]  initWithFrame:followView.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:backgroundView.bounds];
    label.textColor = [UIColor whiteColor];
    label.tag = 1000;
    [backgroundView addSubview:label];
    
    [followView addSubview:backgroundView];
    
    self.scrollerFollow = [[ZCScrollerBarFollow alloc] initWithDelegate:self tableView:self.tableView followView:followView];
    self.scrollerFollow.autoHide = NO;
    self.scrollerFollow.hideScrollBar = YES;
    self.scrollerFollow.offsetX = 10;
    
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollerFollow show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDatasource
{
    self.datasource = [NSMutableArray new];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSDate *today = [NSDate date];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];
    
    for (NSInteger i = [todayComponents day]; i >= -15; i--)
    {
        [components setYear:[todayComponents year]];
        [components setMonth:[todayComponents month]];
        [components setDay:i];
        [components setHour:arc4random() % 23];
        [components setMinute:arc4random() % 59];
        
        NSDate *date = [calendar dateFromComponents:components];
        [self.datasource addObject:date];
    }
}

#pragma mark - ZCScrollerBarFollowDelegate Methods

- (void)scrollerBarFollow:(ZCScrollerBarFollow *)scrollerFollow followView:(UIView *)followView dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
    
    UILabel *label = (UILabel *)[followView viewWithTag:1000];
    label.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
}

#pragma mark - UITableViewDatasource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    
    NSDate *date = self.datasource[[indexPath row]];
    [[cell textLabel] setText:[date description]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.scrollerFollow scrollViewWillBeginDragging];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollerFollow scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self.scrollerFollow scrollViewDidEndDecelerating];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.scrollerFollow scrollViewDidEndDecelerating];
}


@end
