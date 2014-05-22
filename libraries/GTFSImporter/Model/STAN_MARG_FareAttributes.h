//
//  FareAttributes.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface STAN_MARG_FareAttributes : NSObject

@property (nonatomic, retain) NSString * currencyType;
@property (nonatomic, retain) NSString * fareId;
@property (nonatomic, retain) NSNumber * paymentMethod;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * transferDuration;
@property (nonatomic, retain) NSNumber * transfers;

- (void)addFareAttributesObject:(STAN_MARG_FareAttributes *)value;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
