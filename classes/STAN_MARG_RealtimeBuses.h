//
//  RealtimeBuses.h
//  marguerite
//
//  Created by Kevin Conley on 7/16/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TBXML.h"

typedef void (^RealtimeBusesSuccessCallback)(NSArray *);
typedef void (^RealtimeBusesFailureCallback)(NSError *);

@interface STAN_MARG_RealtimeBuses : NSObject {

}

@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSMutableArray *buses;
@property(nonatomic, retain) NSMutableDictionary *vehicleIdsToFareboxIds;
@property(nonatomic, copy) RealtimeBusesSuccessCallback successCallback;
@property(nonatomic, copy) RealtimeBusesFailureCallback failureCallback;

- (id) initWithURL: (NSString *)url andSuccessCallback:(RealtimeBusesSuccessCallback)success andFailureCallback:(RealtimeBusesFailureCallback)failure;
- (void) update;

@end
