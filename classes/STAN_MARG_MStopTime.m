//
//  MStopTime.m
//  marguerite
//
//  Created by Kevin Conley on 7/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_MStopTime.h"

@implementation STAN_MARG_MStopTime

- (void) dealloc {
    [_departureTime release];
    [_routeLongName release];
    [_routeColor release];
    [_routeTextColor release];
    [_tripId release];
    [super dealloc];
}

@end
