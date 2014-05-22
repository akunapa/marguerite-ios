//
//  FirstViewController.m
//  marguerite
//
//  Created by Kevin Conley on 6/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_NextShuttleViewController.h"
#import "STAN_MARG_StopViewController.h"
#import "STAN_MARG_MStop.h"
#import "STAN_MARG_MUtil.h"

#define FEET_IN_MILES 5280

#define NEARBY_STOPS_SECTION_INDEX      0
#define NEARBY_STOPS_SECTION_HEADER     @"Nearby Stops"

#define FAVORITE_STOPS_SECTION_INDEX    1
#define FAVORITE_STOPS_SECTION_HEADER   @"Favorite Stops"

#define ALL_STOPS_SECTION_INDEX         2
#define ALL_STOPS_SECTION_HEADER        @"All Stops"

#define STOPS_NUMBER_OF_SECTIONS        3

@interface STAN_MARG_NextShuttleViewController ()
@end

@implementation STAN_MARG_NextShuttleViewController

- (void) dealloc {
    [_CLController release];
    [_closestStops release];
    [_favoriteStops release];
    [_allStops release];
    [_searchResults release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UITableViewHeaderFooterView appearance] setTintColor:[STAN_MARG_MUtil colorFromHexString:@"8C1515"]];
    
    self.CLController = [[[STAN_MARG_CoreLocationController alloc] init] autorelease];
	_CLController.delegate = self;

    // Initialize the "pull down to refresh" control
    UIRefreshControl *refresh = [[[UIRefreshControl alloc] init] autorelease];
    refresh.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Pull to Refresh"] autorelease];
    [refresh addTarget:self
                action:@selector(refreshView:)
                forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self loadAndSortAllStops];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.favoriteStops = [STAN_MARG_MStop getFavoriteStops];
    [self updateLocation];
    [self.tableView reloadData];
}

#pragma mark - Table Refresh

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Refreshing data..."] autorelease];

    [self loadAndSortAllStops];
    [self.tableView reloadData];
    
    [self updateLocation];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                    [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[[NSAttributedString alloc] initWithString:lastUpdated] autorelease];
    [refresh endRefreshing];
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return STOPS_NUMBER_OF_SECTIONS;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // If the user is searching, return the number of results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
    }
        
    // Number of rows is the number of stops in the region for the specified section.
    switch (section) {
        case NEARBY_STOPS_SECTION_INDEX:
            return [_closestStops count];
        case FAVORITE_STOPS_SECTION_INDEX:
            return [_favoriteStops count];
        case ALL_STOPS_SECTION_INDEX:
            return [_allStops count];
        default:
            return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // If this is a search, don't display any section headers
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    switch (section) {
        case NEARBY_STOPS_SECTION_INDEX:
            return NEARBY_STOPS_SECTION_HEADER;
        case FAVORITE_STOPS_SECTION_INDEX:
            return FAVORITE_STOPS_SECTION_HEADER;
        case ALL_STOPS_SECTION_INDEX:
            return ALL_STOPS_SECTION_HEADER;
        default:
            return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    UITableViewCell *cell;
    STAN_MARG_MStop *stop;
    
    // If this is a search, only show search results (no nearby stops or favorites)
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cellIdentifier = @"AllStopCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
             cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        stop = [_searchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.text = stop.stopName;
        
        return cell;
    }
    
    switch (indexPath.section) {
        case NEARBY_STOPS_SECTION_INDEX: {
            cellIdentifier = @"NearbyStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [_closestStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            
            int distanceInFeet = stop.milesAway * FEET_IN_MILES;
            NSString *distanceString;
            if (stop.milesAway < 1.0) {
                distanceString = [[[NSString alloc] initWithFormat:@"%d feet", distanceInFeet] autorelease];
            } else {
                distanceString = [[[NSString alloc] initWithFormat:@"%.2f miles", stop.milesAway] autorelease];
            }
            cell.detailTextLabel.text = distanceString;
            return cell;
        }
        case FAVORITE_STOPS_SECTION_INDEX: {
            cellIdentifier = @"FavoriteStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [_favoriteStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            return cell;
        }
        case ALL_STOPS_SECTION_INDEX: {
            cellIdentifier = @"AllStopCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            stop = [_allStops objectAtIndex:indexPath.row];
            
            cell.textLabel.text = stop.stopName;
            
            return cell;
        }
    }
    return nil;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"SelectedNearbyStopSegue"]) {
		STAN_MARG_StopViewController *stopViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        stopViewController.stop = [_closestStops objectAtIndex:indexPath.row];
        stopViewController.isFavoriteStop = [stopViewController.stop isFavoriteStop];
	} else if ([segue.identifier isEqualToString:@"SelectedFavoriteStopSegue"] || [segue.identifier isEqualToString:@"SelectedAllStopSegue"]) {
        STAN_MARG_StopViewController *stopViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = nil;
        
        // Make sure to access the right tableView based on whether the user is searching or not
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            stopViewController.stop = [_searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
            if ([segue.identifier isEqualToString:@"SelectedFavoriteStopSegue"]) {
                stopViewController.stop = [_favoriteStops objectAtIndex:indexPath.row];
            } else if ([segue.identifier isEqualToString:@"SelectedAllStopSegue"]) {
                stopViewController.stop = [_allStops objectAtIndex:indexPath.row];
            }
        }
        stopViewController.isFavoriteStop = [stopViewController.stop isFavoriteStop];
    }
}

#pragma mark - Searching

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"stopName contains[cd] %@ OR stopId == %@",
                                    searchText, searchText];
    
    self.searchResults = [_allStops filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - GPS Location

-(void)updateLocation {
    _CLController.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [_CLController.locMgr startUpdatingLocation];
}

- (void)locationUpdate:(CLLocation *)location {
    self.closestStops = [STAN_MARG_MStop getClosestStops:3 withLocation:location];

    [[_CLController locMgr] stopUpdatingLocation];
    
    [self.tableView reloadData];
}

- (void)locationError:(NSError *)error {
	NSLog(@"locationError: %@", error);
//    UIAlertView *errorAlert = [[[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
//    [errorAlert show];
}

#pragma mark - private methods

- (void)loadAndSortAllStops
{
    self.allStops = [STAN_MARG_MStop getAllStops];
    
    // Sort the stops alphabetically by name
    self.allStops = [_allStops sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        STAN_MARG_MStop *firstStop = (STAN_MARG_MStop *) a;
        STAN_MARG_MStop *secondStop = (STAN_MARG_MStop *) b;
        
        return [firstStop.stopName caseInsensitiveCompare:secondStop.stopName];
    }];
}
@end
