//
//  Agency.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface STAN_MARG_Agency : NSObject

@property (nonatomic, retain) NSString * agencyId;
@property (nonatomic, retain) NSString * agencyName;
@property (nonatomic, retain) NSString * agencyUrl;
@property (nonatomic, retain) NSString * agencyTimezone;
@property (nonatomic, retain) NSString * agencyLang;
@property (nonatomic, retain) NSString * agencyPhone;


- (void)addAgency:(STAN_MARG_Agency *)agency;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
