//
//  MRoute.h
//  marguerite
//
//  Created by Kevin Conley on 7/20/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STAN_MARG_MRoute : NSObject

@property (nonatomic, retain) NSString * routeId;
@property (nonatomic, retain) NSString * routeShortName;
@property (nonatomic, retain) NSString * routeLongName;
@property (nonatomic, retain) NSURL * routeUrl;
@property (nonatomic, retain) UIColor * routeColor;
@property (nonatomic, retain) UIColor * routeTextColor;

- (id) initWithRouteIdString:(NSString *) route_id;
- (void) setColorUsingHexString:(NSString *) hexString;
- (void) setTextColorUsingHexString:(NSString *) hexString;

@end
