//
//  MStopTime.h
//  marguerite
//
//  Created by Kevin Conley on 7/24/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STAN_MARG_MStopTime : NSObject

@property (nonatomic, retain) NSDate * departureTime;
@property (nonatomic, retain) NSString * routeLongName;
@property (nonatomic, retain) UIColor * routeColor;
@property (nonatomic, retain) UIColor * routeTextColor;
@property (nonatomic, retain) NSString * tripId;

@end
