//
//  GoogleLocationService.m
//  LocalPlaceSearch
//
//  Created by Naveen Shan on 1/21/13.
//  Copyright (c) 2013 Naveen Shan. All rights reserved.
//

#import "GoogleLocationService.h"

@implementation GoogleLocationService

#pragma mark -

+ (NSString *)getEncodedURLAsUTF8:(NSString *)urlString {
    
    NSString *encodedUrlString = nil;
    
    if (urlString != nil && [NSNull null] != (NSNull *)urlString && [urlString length] > 0) {
        encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return encodedUrlString;
}

+ (NSString *)getDecodedURLAsUTF8:(NSString *)encodedUrlString  {
    
    NSString *decodedUrlString = nil;
    
    if (encodedUrlString != nil && [NSNull null] != (NSNull *)encodedUrlString && [encodedUrlString length] > 0)    {
        decodedUrlString = [encodedUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return decodedUrlString;
}

+ (void)sendRequest:(NSURLRequest *)request
  completionHandler:(void (^)(NSDictionary*, NSError*)) handler {
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setName:@"HTTPRequest queue"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)   {
                               
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       handler(nil,error);
                                   });
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if ([httpResponse statusCode] == 200) { // Sccuess
                                   NSString *mimeType = [response MIMEType];
                                   
                                   if ([mimeType isEqualToString:@"text/json"] ||
                                       [mimeType isEqualToString:@"application/json"]) {
                                       
                                       NSError *parseError = nil;
                                       NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
                                       if (parseError) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               handler(nil,parseError);
                                           });
                                           return;
                                       }
                                       
                                       // RequestLog(@"Response : %@ ",responseDictionary);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           handler(responseDictionary,error);
                                       });
                                       return;
                                       
                                   }
                                   else {
                                       NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                                       [userInfo setValue:[NSString stringWithFormat:@"UnSupported Mime Type : %@",mimeType] forKey:NSLocalizedDescriptionKey];
                                       NSError *mimeTypeError = [NSError errorWithDomain:@"com.googleapi.ios" code:800 userInfo:userInfo];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           handler(nil,mimeTypeError);
                                       });
                                       return;
                                   }
                               }
                               else {
                                   NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                                   [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] forKey:NSLocalizedDescriptionKey];
                                   NSError *mimeTypeError = [NSError errorWithDomain:@"HTTP Error" code:[httpResponse statusCode] userInfo:userInfo];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       handler(nil,mimeTypeError);
                                   });
                                   return;
                               }
                               
                           }];
}

#pragma mark -

+ (void)placeAutoCompleteRequestForString:(NSString *)string completionHandler:(void (^)(NSDictionary*, NSError*)) handler    {
    // URL
    // https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters
    
    // Required Parameter
    //    input — The text string on which to search. The Place service will return candidate matches based on this string and order results based on their perceived relevance.
    //    sensor — Indicates whether or not the Place request came from a device using a location sensor (e.g. a GPS) to determine the location sent in this request. This value must be either true or false.
    //    key — Your application's API key. 
    
    // Optional Parameter
    //    offset — The character position in the input term at which the service uses text for predictions. If no offset is supplied, the service will use the entire term.
//        location — The point around which you wish to retrieve Place information. Must be specified as latitude,longitude.
//        radius — The distance (in meters) within which to return Place results. Note that setting a radius biases results to the indicated area, but may not fully restrict results to the specified area. 
//        language — The language in which to return results. 
//        types — The types of Place results to return. See Place Types below. If no type is specified, all types will be returned.
//        components — A grouping of places to which you would like to restrict your results. Currently, you can use components to filter by country. The country must be passed as a two character, ISO 3166-1 Alpha-2 compatible country code. For example: components=country:fr would restrict your results to places within France.
    
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?";
    NSString *completeURL = [NSString stringWithFormat:@"%@input=%@&sensor=%@&key=%@",baseURL,
                             string,
                             @"true",
                             kGOOGLE_API_KEY];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self class] getEncodedURLAsUTF8:completeURL]]];
    [[self class] sendRequest:request completionHandler:handler];
}


@end
