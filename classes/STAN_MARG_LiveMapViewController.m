//
//  LiveMapViewController.m
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_LiveMapViewController.h"
#import "STAN_MARG_StopViewController.h"
#import "STAN_MARG_RealtimeBuses.h"
#import "STAN_MARG_MRealtimeBus.h"
#import "STAN_MARG_MRoutePolyline.h"
#import "STAN_MARG_MStop.h"
#import <CoreLocation/CoreLocation.h>
#import "STAN_MARG_secrets.h"
#import "STAN_MARG_Util.h"
#import "GCDiscreetNotificationView.h"

#define STANFORD_LATITUDE                   37.432233
#define STANFORD_LONGITUDE                  -122.171183
#define STANFORD_ZOOM_LEVEL                 14
#define STOP_ZOOM_LEVEL                     15

#define BUS_REFRESH_INTERVAL_IN_SECONDS     5

@interface STAN_MARG_LiveMapViewController ()

@end

@implementation STAN_MARG_LiveMapViewController

- (void) dealloc {
    [_stanfordButton release];
    [_HUD release];
    [_stopToZoomTo release];
    [_buses release];
    [_stopMarkers release];
    [_busMarkers release];
    [_timer release];
    [_routePolyline release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
    self.busMarkers = [[[NSMutableDictionary alloc] init] autorelease];
    self.buses = [[[STAN_MARG_RealtimeBuses alloc] initWithURL:MARGUERITE_REALTIME_XML_FEED
                            andSuccessCallback:^(NSArray *busesArray) {
                                if ([busesArray count] > 0) {
                                    for (STAN_MARG_MRealtimeBus *bus in busesArray) {
                                        [self updateMarkerWithBus:bus];
                                    }
                                    [self hideHUD];
                                    _noBusesRunning = NO;
                                    _busLoadError = NO;
                                } else {
                                    if (!_noBusesRunning) {
                                        [self showHUDWithMessage:@"No buses are reporting locations." withActivity:NO];
                                    }
                                    _noBusesRunning = YES;
                                    _busLoadError = NO;
                                }
                                self.timer = [NSTimer timerWithTimeInterval:BUS_REFRESH_INTERVAL_IN_SECONDS target:self selector:@selector(refreshBuses:) userInfo:nil repeats:NO];
                                [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                            }
                            andFailureCallback:^(NSError *error) {
                                self.timer = [NSTimer timerWithTimeInterval:BUS_REFRESH_INTERVAL_IN_SECONDS target:self selector:@selector(refreshBuses:) userInfo:nil repeats:NO];
                                [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                                if (!_busLoadError) {
                                    [self showHUDWithMessage:@"Could not connect to bus server." withActivity:NO];
                                }
                                _noBusesRunning = NO;
                                _busLoadError = YES;
                            }] autorelease];
    
    [_mapView setCamera:[GMSCameraPosition cameraWithLatitude:STANFORD_LATITUDE longitude:STANFORD_LONGITUDE zoom:STANFORD_ZOOM_LEVEL]];
    _mapView.delegate = self;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.zoomGestures = YES;
    _mapView.settings.myLocationButton = YES;
    
    // Manually insert the "Zoom to Stanford" button
    [_mapView addSubview:_stanfordButton];
    
    [self loadStops];
    
    if (_stopToZoomTo != nil) {
        [self zoomToStop:_stopToZoomTo];
        self.stopToZoomTo = nil;
    }
    
    [self showHUDWithMessage:@"Loading buses..." withActivity:YES];
    [self refreshBuses:nil];
    
    self.routePolyline = nil;
}

- (void) loadStops
{
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"STAN_MARG_Stop" ofType:@"png"];
    UIImage *stopIcon = [UIImage imageWithContentsOfFile:imageFilePath];
    
    NSArray *allStops = [STAN_MARG_MStop getAllStops];
    self.stopMarkers = [[[NSMutableDictionary alloc] init] autorelease];
    for (STAN_MARG_MStop *stop in allStops) {
        GMSMarker *marker = [[[GMSMarker alloc] init] autorelease];
        marker.position = [stop.location coordinate];
        marker.icon = stopIcon;
        marker.title = stop.stopName;
        marker.snippet = @"Tap here to view next shuttles.";
        marker.map = _mapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.userData = stop;
        marker.zIndex = 0;
        [_stopMarkers setObject:marker forKey:stop.stopId];
    }
}

- (void) refreshBuses:(NSTimer *)timer
{
    [_buses update];
}

- (void) showHUDWithMessage:(NSString *)message withActivity:(BOOL)activity
{
    if (self.HUD == nil) {
        self.HUD = [[[GCDiscreetNotificationView alloc] initWithText:message showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:self.view] autorelease];
    }
    
    // Setup HUD
    [self.HUD setTextLabel:message];
    [self.HUD setShowActivity:activity animated:YES];
    
    // Show the HUD
    [self.HUD show:YES];
}

- (void) hideHUD
{
    [self.HUD hide:YES];
    self.HUD = nil;
}

- (void) updateMarkerWithBus:(STAN_MARG_MRealtimeBus *)bus
{
    GMSMarker *marker = _busMarkers[bus.vehicleId];
    if (marker == nil) {
        marker = [[[GMSMarker alloc] init] autorelease];
    }
    marker.position = [bus.location coordinate];
    marker.icon = [self getImageForRouteId:bus.route.routeId];
    marker.title = bus.route.routeShortName;
    marker.snippet = bus.route.routeLongName;
    marker.map = _mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.userData = bus;
    marker.zIndex = 3;
    _busMarkers[bus.vehicleId] = marker;
}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // Clear route polyline if one is being displayed
    if (_routePolyline != nil) {
        _routePolyline.map = nil;
        self.routePolyline = nil;
    }
}


- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    if (marker.userData != nil && [marker.userData isKindOfClass:[STAN_MARG_MStop class]]) {
        STAN_MARG_MStop *stop = (STAN_MARG_MStop *) marker.userData;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"STAN_MARG_MainStoryboard_iPhone" bundle:nil];
        STAN_MARG_StopViewController *stopViewController = (STAN_MARG_StopViewController *) [storyboard instantiateViewControllerWithIdentifier:@"StopView"];
        stopViewController.stop = stop;
        [self.navigationController pushViewController:stopViewController animated:YES];
    }
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    // Clear route polyline if one is being displayed
    if (_routePolyline != nil) {
        _routePolyline.map = nil;
        self.routePolyline = nil;
    }
    
    if (marker.userData != nil && [marker.userData isKindOfClass:[STAN_MARG_MRealtimeBus class]]) {
        STAN_MARG_MRoute *route = ((STAN_MARG_MRealtimeBus *)marker.userData).route;
        self.routePolyline = [[[STAN_MARG_MRoutePolyline alloc] initWithRoute:route] autorelease];
        if (_routePolyline != nil) {
            _routePolyline.map = _mapView;
        }
    }

    // Map should then continue with its default selection behavior
    return NO;
}

/*
 Get the image to show as a marker on the map for the given gtfs
 route_id. Returns nil if route is not recognized.
 */
- (UIImage *) getImageForRouteId:(NSString *)route_id
{
    NSString *imageFileName = nil;
    switch ([route_id integerValue]) {
        case 2:
            //Y
            imageFileName = @"STAN_MARG_Y";
            break;
        case 3:
            //X
            imageFileName = @"STAN_MARG_X";
            break;
        case 4:
            //C
            imageFileName = @"STAN_MARG_C";
            break;
        case 8:
            //SLAC
            imageFileName = @"STAN_MARG_SLAC";
            break;
        case 9:
            //N
            imageFileName = @"STAN_MARG_N";
            break;
        case 15:
            //V
            imageFileName = @"STAN_MARG_V";
            break;
        case 18:
            //SE
            imageFileName = @"STAN_MARG_SE";
            break;
        case 20:
            //P
            imageFileName = @"STAN_MARG_P";
            break;
        case 22:
            //MC
            imageFileName = @"STAN_MARG_MC";
            break;
        case 28:
            //1050A
            imageFileName = @"STAN_MARG_1050A";
            break;
        case 33:
            //S
            imageFileName = @"STAN_MARG_S";
            break;
        case 36:
            //AWE
            imageFileName = @"STAN_MARG_AE";
            break;
        case 38:
            //RP
            imageFileName = @"STAN_MARG_RP";
            break;
        case 43:
            //O
            imageFileName = @"STAN_MARG_O";
            break;
        case 44:
            //Y-lim
            imageFileName = @"STAN_MARG_Y-LIM";
            break;
        case 45:
            //X-lim
            imageFileName = @"STAN_MARG_X-LIM";
            break;
        case 46:
            //C-lim
            imageFileName = @"STAN_MARG_C";
            break;
        case 48:
            //MC-direct
            imageFileName = @"STAN_MARG_MC-DIR";
            break;
        case 50:
            //MC-holiday
            imageFileName = @"STAN_MARG_MC-HOL";
            break;
        case 51:
            //Line x express
            imageFileName = @"STAN_MARG_X-EXP";
            break;
        case 52:
            //line y express
            imageFileName = @"STAN_MARG_Y-EXP";
            break;
        case 53:
            //BOH
            imageFileName = @"STAN_MARG_BOH";
            break;
        case 54:
            //TECH
            imageFileName = @"STAN_MARG_TECH";
            break;
        case 55:
            //East Bay Express
            imageFileName = @"STAN_MARG_EB-EX";
            break;
        case 56:
            //OCA
            imageFileName = @"STAN_MARG_OCA";
            break;
        case 57:
            //H
            imageFileName = @"STAN_MARG_H";
            break;
        default:
            imageFileName = nil;
    }
    
    if (imageFileName == nil) {
        return nil;
    }
    
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:imageFilePath];
}

- (IBAction)zoomToCampus:(id)sender {
    [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:STANFORD_LATITUDE
                                                                  longitude:STANFORD_LONGITUDE
                                                                       zoom:STANFORD_ZOOM_LEVEL]];
}

- (void)zoomToStop:(STAN_MARG_MStop *)stop {
    GMSMarker *marker = [_stopMarkers objectForKey:stop.stopId];
    if (marker == nil) {
        return;
    }
    _mapView.selectedMarker = marker;
    [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:marker.position.latitude
                                                                  longitude:marker.position.longitude
                                                                       zoom:STOP_ZOOM_LEVEL]];
}

@end
