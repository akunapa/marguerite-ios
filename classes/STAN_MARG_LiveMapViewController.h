//
//  LiveMapViewController.h
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAN_MARG_RealtimeBuses.h"
#import "STAN_MARG_MRoutePolyline.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GCDiscreetNotificationView.h"
#import "STAN_MARG_MStop.h"

@interface STAN_MARG_LiveMapViewController : UIViewController <GMSMapViewDelegate> {

}

@property (assign, nonatomic) GMSMapView *mapView;
@property (retain, nonatomic) IBOutlet UIButton *stanfordButton;
@property (retain, nonatomic) GCDiscreetNotificationView *HUD;
@property (retain, nonatomic) STAN_MARG_MStop *stopToZoomTo;
@property (retain, nonatomic) STAN_MARG_RealtimeBuses *buses;
@property (retain, nonatomic) NSMutableDictionary *stopMarkers;
@property (retain, nonatomic) NSMutableDictionary *busMarkers;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) STAN_MARG_MRoutePolyline *routePolyline;
@property (assign, nonatomic) BOOL noBusesRunning;
@property (assign, nonatomic) BOOL busLoadError;

- (IBAction)zoomToCampus:(id)sender;
- (void)zoomToStop:(STAN_MARG_MStop *)stop;

@end
