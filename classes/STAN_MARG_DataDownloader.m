//
//  DataDownloader.m
//  SNLaunchPad
//
//  Created by Ashok Kunaparaju on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STAN_MARG_DataDownloader.h"

#define HTTP_NOT_MODIFIED_CODE 304

@interface STAN_MARG_DataDownloader()

@property(nonatomic, retain) NSURLConnection* connection;
@property(nonatomic, retain) NSMutableData *activeDownloadDataBuffer;
@property(nonatomic, retain) NSData* downloadedData;
@property(nonatomic, retain) NSURL* urlToDownloadFrom;
@property(nonatomic, assign) BOOL notifiedDelegate;
@property(nonatomic, retain, readonly) NSString * localPath;
@property(nonatomic, retain) NSHTTPURLResponse* httpURLResponse;
@property(nonatomic, assign) NSObject<STAN_MARG_DataDownloadDone>* dataDownloadDelegate;
@property(nonatomic, retain) NSDate * lastModified;

@end

@implementation STAN_MARG_DataDownloader

- (void) dealloc {
    [_connection release];
    [_activeDownloadDataBuffer release];
    [_downloadedData release];
    [_urlToDownloadFrom release];
    [_localPath release];
    [_httpURLResponse release];
    [_lastModified release];
    [super dealloc];
}

- (id) initWithURL:(NSURL*)url localPath:(NSString*)path downloadDelegate:(NSObject<STAN_MARG_DataDownloadDone>*)delegate {
    self = [super init];
    if (self) {
        _urlToDownloadFrom = [url retain];
        _dataDownloadDelegate = delegate;
        _localPath = [path retain];
    }
    return self;
}

- (NSDateFormatter*)dateFormatter {
    static dispatch_once_t onceToken;
	static NSDateFormatter * formatter = nil;
	dispatch_once(&onceToken, ^{
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
		formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	});
    return formatter;
}

- (NSString *) formatDate:(NSDate *)date
{
	return [[self dateFormatter] stringFromDate:date];
}

- (NSDate *) dateFromStr:(NSString *)dateStr
{
	return [[self dateFormatter] dateFromString:dateStr];
}

- (void)startDownload
{
    self.notifiedDelegate = NO;
    self.activeDownloadDataBuffer = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL: _urlToDownloadFrom] autorelease];
    [self setIfModifiedSinceHeaderOnRequest:urlRequest];
    NSURLConnection *conn = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    self.connection = conn;
}

- (void) setIfModifiedSinceHeaderOnRequest:(NSMutableURLRequest*)urlRequest {
    NSFileManager * mgr = [NSFileManager defaultManager];
    NSDictionary * info = [mgr attributesOfItemAtPath:_localPath error:nil];
    NSDate * time = info[NSFileModificationDate];
    /* for testing*/ // time = [self dateFromStr:@"WED, 16 APR 2014 17:12:38 GMT"];
    [urlRequest setValue:[self formatDate:time] forHTTPHeaderField:@"If-Modified-Since"];
    NSLog(@"If-Modified-Since is %@", time);
}

- (void)cancelDownload
{
    self.dataDownloadDelegate = nil;
    [self.connection cancel];
    self.connection = nil;
    self.activeDownloadDataBuffer = nil;
}

- (NSDate *) getFileModifiedDate
{
    return self.lastModified;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.httpURLResponse = (NSHTTPURLResponse*)response;
    if (response) {
        NSDictionary * headers = [self.httpURLResponse allHeaderFields];
        NSString * last_modified = [NSString stringWithFormat:@"%@",
                                    [headers objectForKey:@"Last-Modified"]];
        if (last_modified) {
            NSLog(@"GTFS zip file Last-Modified on server: %@", last_modified);
            self.lastModified = [self dateFromStr:last_modified];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownloadDataBuffer appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownloadDataBuffer = nil;
    // Release the connection now that it's finished
    self.connection = nil;
    NSLog(@"error downloading data: %@",[error localizedDescription]);
    [_dataDownloadDelegate dataDownloadFailed:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloadedData = _activeDownloadDataBuffer;
    self.activeDownloadDataBuffer = nil;
    if (!_dataDownloadDelegate || ![_dataDownloadDelegate isKindOfClass:[NSObject class]]) {
        NSLog(@"delegate is nil or not pointing to correct address!");
    } else  {
        if (!_notifiedDelegate) {
            if ( _httpURLResponse.statusCode == HTTP_NOT_MODIFIED_CODE ) {
                NSLog(@"File was not modified, loading local file.");
                NSData * data = [NSData dataWithContentsOfFile:_localPath options:NSDataReadingMappedIfSafe error:nil];
                [_dataDownloadDelegate cachedDataDownloadDone:data];
            } else {
                NSError * error = nil;
                if ( ! [_downloadedData writeToFile:_localPath options:NSDataWritingAtomic error:&error] ) {
                    NSLog(@"Error while writing data downloaded from server : %@",[error localizedDescription]);
                    [_dataDownloadDelegate dataDownloadFailed:error];
                } else {
                    [_dataDownloadDelegate dataDownloadDone:_downloadedData];
                }
            }
            self.notifiedDelegate = YES;
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
