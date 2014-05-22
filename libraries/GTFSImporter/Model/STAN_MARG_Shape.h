//
//  Shape.h
//
//  Created by Kevin Conley on 6/25/2013.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface STAN_MARG_Shape : NSObject

@property (nonatomic, retain) NSString * shapeId;
@property (nonatomic, retain) NSString * shapePtLat;
@property (nonatomic, retain) NSString * shapePtLon;
@property (nonatomic, retain) NSString * shapePtSequence;
@property (nonatomic, retain) NSString * shapeDistTraveled;


- (void)addShape:(STAN_MARG_Shape *)shape;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
