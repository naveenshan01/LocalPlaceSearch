//
//  GoogleLocationService.h
//  LocalPlaceSearch
//
//  Created by Naveen Shan on 1/21/13.
//  Copyright (c) 2013 Naveen Shan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGOOGLE_API_KEY @"AIzaSyAJoUeeelxE-DbBAoBrtnn3pZKIax2RwfA"

@interface GoogleLocationService : NSObject

#pragma mark -

+ (NSString *)getEncodedURLAsUTF8:(NSString *)urlString;
+ (NSString *)getDecodedURLAsUTF8:(NSString *)encodedUrlString;

#pragma mark -

+ (void)placeAutoCompleteRequestForString:(NSString *)string completionHandler:(void (^)(NSDictionary*, NSError*)) handler;

@end
