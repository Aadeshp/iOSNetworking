//
//  APNetworking.h
//  APNetworking
//
//  Created by Aadesh Patel on 1/30/15.
//  Copyright (c) 2015 Aadesh Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, HTTPRequest) {
    HTTPRequestPost,
    HTTPRequestGet,
    HTTPRequestPatch,
    HTTPRequestPut,
    HTTPRequestDelete
};

typedef NS_ENUM (NSInteger, MimeType) {
    MimeTypeJson,
    MimeTypeHtml,
    MimeTypeFormUrlEncoded
};

@interface APNetworking : NSObject

- (instancetype)init;
- (instancetype)initWithBaseUrl:(NSString *)baseUrl;
- (void)setBaseUrl:(NSString *)baseUrl;
- (NSURLSessionDataTask *)request:(HTTPRequest)request
         urlext:(NSString *)urlExt
         params:(id)params
           mime:(MimeType)mime
completionBlock:(void(^)(NSData *, NSURLResponse *, NSError *))completionBlock;

@end


