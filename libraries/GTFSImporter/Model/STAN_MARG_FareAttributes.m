//
//  FareAttributes.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_FareAttributes.h"
#import "STAN_MARG_CSVParser.h"
#import "FMDatabase.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_FareAttributes ()
{

}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_FareAttributes

- (void) dealloc {
    [_currencyType release];
    [_fareId release];
    [_paymentMethod release];
    [_price release];
    [_transferDuration release];
    [_transfers release];
    [_db release];
    [super dealloc];
}

- (id)initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
		_db = [fmdb retain];
	}
	return self;
}

- (void)addFareAttributesObject:(STAN_MARG_FareAttributes *)value {
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into fare_attributes(fare_id,price,currency_type,payment_method,transfers,transfer_duration) values(?, ?, ?, ?, ?, ?)",
                        value.fareId,
                        value.price,
                        value.currencyType,
                        value.paymentMethod,
                        value.transfers,
                        value.transferDuration];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)cleanupAndCreate
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    //Drop table if it exists
    NSString *drop = @"DROP TABLE IF EXISTS fare_attributes";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'fare_attributes' ('fare_id' varchar(11) NOT NULL, 'price' FLOAT DEFAULT 0.0, 'currency_type' varchar(255) DEFAULT NULL, 'payment_method' INT(2), 'transfers' INT(11), 'transfer_duration' INT(11), PRIMARY KEY ('fare_id'))";
    
    [_db executeUpdate:create];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_FareAttributes *fareAttributesRecord = [[[STAN_MARG_FareAttributes alloc] init] autorelease];
    fareAttributesRecord.fareId = aRecord[@"fare_id"];
    fareAttributesRecord.price = aRecord[@"price"];
    fareAttributesRecord.currencyType = aRecord[@"currency_type"];
    fareAttributesRecord.paymentMethod = aRecord[@"payment_type"];
    fareAttributesRecord.transfers = aRecord[@"transfers"];
    fareAttributesRecord.transferDuration = aRecord[@"transfer_duration"];
    
    [self addFareAttributesObject:fareAttributesRecord];
}


@end
