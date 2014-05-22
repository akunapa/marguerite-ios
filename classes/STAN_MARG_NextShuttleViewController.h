//
//  NextBusViewController.h
//  marguerite
//
//  Created by Kevin Conley on 6/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAN_MARG_CoreLocationController.h"

@interface STAN_MARG_NextShuttleViewController : UITableViewController <STAN_MARG_CoreLocationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate> {

}

@property(nonatomic, retain) STAN_MARG_CoreLocationController *CLController;
@property(nonatomic, retain) NSArray *closestStops;
@property(nonatomic, retain) NSArray *favoriteStops;
@property(nonatomic, retain) NSArray *allStops;
@property(nonatomic, retain) NSArray *searchResults;

@end
