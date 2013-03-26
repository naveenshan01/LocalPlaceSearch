//
//  ViewController.m
//  LocalPlaceSearch
//
//  Created by Naveen Shan on 1/21/13.
//  Copyright (c) 2013 Naveen Shan. All rights reserved.
//

#import "ViewController.h"

#import "GoogleLocationService.h"

@interface ViewController ()

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *options;

@end

@implementation ViewController

@synthesize options = _options;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(initView)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)initView    {
    [self showSearchBar];
    [self showTableView];
    
//    [self fetchPlaceResult];
}

- (void)refreshView {
    [self.tableView reloadData];
}

- (void)showTableView   {
    //tableview for display filters
    CGRect  tableViewFrame = CGRectMake(0, 44, self.view.frame.size.width, (self.view.frame.size.height - 44));
    
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    self.tableView.opaque = YES;
    self.tableView.bounces = NO;
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.tableView setDataSource:(id)self];
	[self.tableView setDelegate:(id)self];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setFrame:tableViewFrame];
    
    [self.view addSubview:self.tableView];
}

- (void) showSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentSizeForViewInPopover.width, 44.0)];
    
    [self.searchBar setBackgroundColor:[UIColor clearColor]];
    self.searchBar.barStyle = UIBarStyleBlack;
    self.searchBar.delegate = (id)self;
    self.searchBar.placeholder = @"Search Places";
    
    [self.view addSubview:self.searchBar];
}

#pragma mark -

- (void)fetchPlaceResult {
    [GoogleLocationService placeAutoCompleteRequestForString:self.searchBar.text completionHandler:^(NSDictionary *results, NSError *error)  {
        if (error) {
            NSLog(@"Error Occured on placeAutoCompleteRequestForString : %@",[error description]);
            return;
        }
        
        NSLog(@"Results : %@",results);
        id resultArray = [results objectForKey:@"predictions"];
        if ([resultArray isKindOfClass:[NSDictionary class]]) {
            resultArray = [NSArray arrayWithObjects:resultArray, nil];
        }
        self.options = resultArray;
        [self refreshView];
    }];
}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar   {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar {
    [searchbar resignFirstResponder];
    if ([searchbar.text length] != 0) {
        [self fetchPlaceResult];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Clear the current result when the user clear the query
    if ([searchText length] == 0) {
        self.options = nil;
        [self refreshView];
    } else {
        [self fetchPlaceResult];
    }
}

#pragma mark - UITableView Data Sources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableview {
    // Return the number of sections.
	int icount = 1;
    return icount;
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int icount = 1;
    icount = [self.options count];
    return icount;
}

- (CGFloat) tableView: (UITableView *) tableview heightForRowAtIndexPath: (NSIndexPath *) indexPath	{
	//	Return the height of cells in tableView
    CGFloat height = 34.0;
	return height;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell =nil;
    
    @try    {
        static NSString *CellIdentifier = @"PlaceCell";
        
        cell = [tableview dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Configure the cell...
        if (indexPath.row < [self.options count]) {
            NSDictionary *option = [self.options objectAtIndex:indexPath.row];
            cell.textLabel.text = [option objectForKey:@"description"];
        }
       
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception for cellForAtIndexPath in SearchFilterViewController : %@",[exception description]);
    }
    @finally    {
        return cell;
    }
    
    return cell;
}

@end
