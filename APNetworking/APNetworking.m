//
//  APNetworking.m
//  APNetworking
//
//  Created by Aadesh Patel on 1/30/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import "APNetworking.h"

@interface APNetworking()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSURLSessionConfiguration *config;

- (NSMutableURLRequest *)getURLRequest:(HTTPRequest)request
                                   url:(NSURL *)url
                                  data:(NSData *)data
                                  mimeType:(MimeType)mime;
- (NSDictionary *)paramsToDictionary:(id)params;
- (NSString *)requestToString:(HTTPRequest)request;
- (NSString *)mimeTypeToString:(MimeType)mimeType;

@end

@implementation APNetworking

#pragma mark - init

- (instancetype)init
{
    return [self initWithBaseUrl:nil];
}

- (instancetype)initWithBaseUrl:(NSString *)baseUrl
{
    if (![baseUrl hasSuffix:@"/"] && baseUrl)
        [baseUrl stringByAppendingString:@"/"];
    
    return [self initWithBaseUrl:baseUrl andSessionConfiguration:nil];
}

- (instancetype)initWithBaseUrl:(NSString *)baseUrl
        andSessionConfiguration:(NSURLSessionConfiguration *)config
{
    if (self = [super init]) {
        self.baseUrl = baseUrl;
        self.config = config;
    }
    
    return self;
}

#pragma mark - Request

/*
 Completion Block Example:
 
 ^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error)
        //Display Error Here
 
    //Get Response Text
    if (data) {
        NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //Do Whatever With Response Text Here
    }
 }
 */

- (NSURLSessionDataTask *)request:(HTTPRequest)request
         urlext:(NSString *)urlExt
         params:(id)params
           mime:(MimeType)mimeType
completionBlock:(void(^)(NSData *, NSURLResponse *, NSError *))completionBlock
{
    //Check if HTTPRequest is Given
    NSParameterAssert(request);
    
    //Serialize parameters to JSON
    NSData *d = nil;
    
    if (params) {
        NSError *error;
        d = [NSJSONSerialization dataWithJSONObject:[self paramsToDictionary:params] options:0 error:&error];
        
        if (error) {
            d = nil;
            NSLog(@"Error: Unable to Load Parameters");
        }
    }
    
    //Check if URL is Valid
    NSURL *url = [NSURL URLWithString:[_baseUrl stringByAppendingString:urlExt]];
    NSParameterAssert(url);
    
    //Create NSURLSession Using Provided Configurations or Shared Session
    NSURLSession *session;
    if (self.config)
        session = [NSURLSession sessionWithConfiguration:self.config];
    else
        session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *req = [self getURLRequest:request
                                         url:url
                                        data:d
                                    mimeType:mimeType];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req
                                            completionHandler:completionBlock];
    [task resume];
    
    return task;
}

#pragma mark - Create NSURLRequest

- (NSMutableURLRequest *)getURLRequest:(HTTPRequest)request
                             url:(NSURL *)url
                            data:(NSData *)data
                            mimeType:(MimeType)mimeType
{
    //Check if HTTPRequest and URL are Given
    NSParameterAssert(request);
    NSParameterAssert(url);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:[self requestToString:request]];
    
    if (data)
        [req setHTTPBody:data];
    
    if (mimeType)
        [req setValue:[self mimeTypeToString:mimeType] forHTTPHeaderField:@"Content-Type"];
    
    return req;
}

#pragma mark - Convert Parameter Type to NSDictionary

- (NSDictionary *)paramsToDictionary:(id)params {
    //If Already NSDictionary, return it. Otherwise convert to NSDictionary for JSON Serialization
    if ([params isKindOfClass:[NSDictionary class]])
        return (NSDictionary *)params;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    //Format: 'param1=value1&param2=value2...&param(N)=value(N)'
    if ([params isKindOfClass:[NSString class]]) {
        NSArray *array = [params componentsSeparatedByString:@"&"];
        
        for (id param in array) {
            NSArray *p = [param componentsSeparatedByString:@"="];
            [dict setValue:(NSString *)[p objectAtIndex:1] forKey:(NSString *)[p objectAtIndex:0]];
        }
    } else
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"Invalid Format: Parameters (Correct Format: NSString or NSDictionary" userInfo:nil];
    
    return dict;
}

#pragma mark - Singletons/ToStrings

+ (NSDictionary *)requests {
    static NSDictionary *_requests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _requests = @{
                      @(HTTPRequestPost)  : @"POST",
                      @(HTTPRequestGet)   : @"GET",
                      @(HTTPRequestPatch) : @"PATCH",
                      @(HTTPRequestPut)   : @"PUT",
                      @(HTTPRequestDelete): @"DELETE"
                      };
    });
    
    return _requests;
}

- (NSString *)requestToString:(HTTPRequest)request
{
    NSParameterAssert(request);
    
    return [[APNetworking requests] objectForKey:@(request)];
}

+ (NSDictionary *)mimeTypes {
    static NSDictionary *_mimeTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mimeTypes = @{
                       @(MimeTypeJson)           : @"application/json",
                       @(MimeTypeHtml)           : @"text/html",
                       @(MimeTypeFormUrlEncoded) : @"application/x-www-form-urlencoded"
                       };
    });
    
    return _mimeTypes;
}

- (NSString *)mimeTypeToString:(MimeType)mimeType {
    NSParameterAssert(mimeType);
    
    return [[APNetworking mimeTypes] objectForKey:@(mimeType)];
}

@end