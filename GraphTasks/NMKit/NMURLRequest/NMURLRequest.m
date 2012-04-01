//
//  NMURLRequest.m
//  CustomRequest
//
//  Created by Николай Сычев on 08.06.11.
//  Copyright 2011 СКИБ. All rights reserved.
//

#import "NMURLRequest.h"
#import "NSString+NMKit_Extenstion.h"
#import "JSON.h"
#import "NMJSONResponse.h"


@interface NMURLRequest (InternalMethods)

-   (NSMutableURLRequest*)  preparePostRequest;
-   (NSMutableURLRequest*)  prepareGetRequest;
-   (NSString*) getRandomBoundary;

-   (NSError*)  prepareErrorWithDomain:(NSString*)errorDomain
                          andErrorCode:(NSInteger)errorCode
                            andMessage:(NSString*)errorMessage;

    //PARSERS

-   (NSString*) parseResponseAsStringWithError:(NSError**)error;

-   (id)        parseResponseWithSBJSON:(NSError**)error;

-   (id)        parseResponseWithSBJSONStd:(NSError**)error;

-   (id)        parseResponseWithNSJSONSerializator:(NSError**)error;

@end

@implementation NMURLRequest

@synthesize url             =   _url,
            httpMethod      =   _httpMethod,
            params          =   _params,
            delegate        =   _delegate,
            parsingEngine   =   _parsingEngine;


#pragma mark    -   Life Cycle

-   (void)  dealloc{
    [_connection    cancel];
}

+   (NMURLRequest*) requestWithDelegate:(id<NMURLRequestDelegate>)delegate 
                                 andUrl:(NSString *)url 
                              andParams:(NSDictionary *)params 
                          andHttpMethod:(NSString *)method 
                       andParsingEngine:(NSString *)parsingEngine{
    @autoreleasepool {
        NMURLRequest*   request =   [[NMURLRequest  alloc]  initWithDelegate:delegate
                                                                      andUrl:url
                                                                   andParams:params
                                                               andHttpMethod:method
                                                            andParsingEngine:parsingEngine];
        
        [request        start];
        
        return request;
    }
}

+   (NMURLRequest*) requestWithDelegate:(id<NMURLRequestDelegate>)delegate
                                 andUrl:(NSString *)url
                              andParams:(NSDictionary *)params
                          andHttpMethod:(NSString *)method{
    return [NMURLRequest    requestWithDelegate:delegate
                                         andUrl:url
                                      andParams:params
                                  andHttpMethod:method
                               andParsingEngine:kNMURLRequestParsingEngineRawData];
}

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString *)url
                           andParams:(NSDictionary *)params
                       andHttpMethod:(NSString *)method
                    andParsingEngine:(NSString *)parsingEngine{
    self    =   [super  init];
    
    if (self){
        [self   setUrl:url];
        [self   setDelegate:delegate];
        [self   setParams:params];
        [self   setHttpMethod:method];
        [self   setParsingEngine:parsingEngine];
    }
    
    return self;    
}

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString *)url
                           andParams:(NSDictionary *)params
                       andHttpMethod:(NSString *)method{
    
    return [self    initWithDelegate:delegate
                              andUrl:url
                           andParams:params
                       andHttpMethod:method
                    andParsingEngine:kNMURLRequestParsingEngineRawData];
}

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString *)url
                           andParams:(NSDictionary *)params{
    return [self    initWithDelegate:delegate
                              andUrl:url
                           andParams:params
                       andHttpMethod:kNMURLRequestHttpMethodGet];
}


-   (NMURLRequest*) init{
    return [self    initWithDelegate:nil
                              andUrl:nil
                           andParams:nil];
}

-   (void)  start{
    [self   cancel];
    
    NSMutableURLRequest*    request;
    
    if ([_httpMethod    isEqualToString:kNMURLRequestHttpMethodPost])
        request =   [self   preparePostRequest];
    else
        request =   [self   prepareGetRequest];
    
    [NSURLConnection    connectionWithRequest:request
                                     delegate:self];
}

-   (void)  cancel{
    [_connection    cancel];
    _connection =   nil;
    
    _data       =   nil;
}

#pragma mark    -   Internal Methods

-   (NSMutableURLRequest*)  prepareGetRequest{
    NSMutableURLRequest*    request =   [[NSMutableURLRequest   alloc]  init];
    [request    setHTTPMethod:kNMURLRequestHttpMethodGet];
    
    NSString*   effectiveUrl    =   [_url preparedGetURLWithParams:_params];
    NSLog(@"NMURLRequest. Effective executed url: %@",effectiveUrl);
    [request    setURL:[NSURL   URLWithString:effectiveUrl]];
    
    return request;
}

-   (NSMutableURLRequest*)  preparePostRequest{
    NSMutableURLRequest*    request =   [[NSMutableURLRequest   alloc]  init];
    
    [request    setURL:[NSURL URLWithString:_url]];
    [request    setHTTPMethod:kNMURLRequestHttpMethodPost];
    
    NSString*   boundary    =   [NSString   stringWithFormat:@"--------------------%@", [self   getRandomBoundary]];
    NSLog(@"NMURLRequest. Boundary: %@", boundary);
    
    [request    setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
      forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData*  httpBody=   [[NSMutableData alloc]  init];
    
    for (NSString*  paramName in [[_params  allKeys]    objectEnumerator]){
        id  value   =   [_params    objectForKey:paramName];
        NSData* representation;
        if ([value  isKindOfClass:[NSString class]] ||  [value  isKindOfClass:[NSNumber class]])
            representation  =   [[value  description]   dataUsingEncoding:NSUTF8StringEncoding];
        else if ([value isKindOfClass:[NSData class]])
            representation  =   value;
        else if ([value isKindOfClass:[UIImage class]])
            representation  =   UIImagePNGRepresentation(value);
        else
            continue;
        
        [httpBody   appendData:[[NSString   stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody   appendData:[[NSString   stringWithFormat:@"Content-Disposition: form-data; name\"%@\"\r\n\r\n", paramName]  dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody   appendData:representation];
        [httpBody   appendData:[[NSString   stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [request    setHTTPBody:httpBody];    
    
    return request;
}


-   (NSString*) getRandomBoundary{
    srand(time(NULL));
    
    NSString*   randomString    =   [NSString   stringWithFormat:@"%i", arc4random()];
    
    return [randomString    MD5_HEX];
}

-   (void)  setHttpMethod:(NSString *)httpMethod{
    if ([httpMethod isEqualToString:kNMURLRequestHttpMethodPost])
        _httpMethod =   kNMURLRequestHttpMethodPost;
    else
        _httpMethod =   kNMURLRequestHttpMethodGet;
}

-   (NSError*)  prepareErrorWithDomain:(NSString *)errorDomain
                          andErrorCode:(NSInteger)errorCode
                            andMessage:(NSString *)errorMessage{
    NSLog(@"NMURLRequest. Should prepare error with:\n\tDOMAIN: %@\n\tMESSAGE: %@\n\tCODE: %d", errorDomain, errorMessage, errorCode);
    
    NSError*    error   =   [[NSError   alloc]  initWithDomain:errorDomain
                                                          code:errorCode
                                                      userInfo:[NSDictionary    dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
    
    return error;
}

#pragma mark    -   NMURLRequestParserEngines

-   (NSString*) parseResponseAsStringWithError:(NSError **)error{
    NSLog(@"NMURLRequest. Try to parse response as NSString");
    
    NSString*   result  =   [[NSString  alloc]  initWithData:_data
                                                    encoding:NSUTF8StringEncoding];
    
    
    return result;
}

-   (id)    parseResponseWithSBJSON:(NSError **)error{
    NSLog(@"NMURLRequest. Try to parse response with SBJSON interpretator");
    
    SBJsonParser*   parser  =   [[SBJsonParser  alloc]  init];
    
    NSString*       jsonString  =   [self   parseResponseAsStringWithError:error];
    
    if (*error   !=  nil)
        NSLog(@"NMURLRequest. SBJSON parser failed on try to convert NSData to String representation");
    else{
        id response =   [parser objectWithString:jsonString
                                           error:error];
        if (*error   !=  nil)
            NSLog(@"NMURLRequest, SBJSON parser failed to convert NSString to JSON representation");
        else
            return response;
    }
    
    return nil;    
}

-   (id)    parseResponseWithSBJSONStd:(NSError **)error{
    NSLog(@"NMURLRequest Try to parse response with SBJSON standard interpretator");
    
    NSDictionary*   jsonResponse    =   [self   parseResponseWithSBJSON:error];
    
    if (*error  !=  nil)
        NSLog(@"NMURLRequest. SBJSON parser failed on try to convert NSData to JSON representation");
    else{
        if (![jsonResponse   isKindOfClass:[NSDictionary class]]){
            NSLog(@"Not std structure of JSON response");
            *error  =   [self   prepareErrorWithDomain:kNMURLRequestErrorDomain
                                          andErrorCode:kNMURLRequestErrorDefaultCode
                                            andMessage:kNMURLRequestErrorParsingWrongFormat];
        }
        
        if ([[jsonResponse   objectForKey:kNMJSONResponseStateKey]  isEqualToString:kNMJSONResponseStateSuccess]){
            NMJSONResponse* response    =   [[NMJSONResponse    alloc]  init];
            [response   setData:[jsonResponse   objectForKey:kNMJSONResponseDataKey]];
            [response   setRequestType:[jsonResponse    objectForKey:kNMJSONResponseRequestTypeKey]];
            
            return response;
        }else if ([[jsonResponse    objectForKey:kNMJSONResponseStateKey]   isEqualToString:kNMJSONResponseStateFailed]){
            NSInteger   errorCode   =   [[[jsonResponse objectForKey:kNMJSONResponseErrorKey]   objectForKey:kNMJSONResponseErrorCodeKey]  integerValue];
            NSString*   errorMessage=   [[jsonResponse  objectForKey:kNMJSONResponseErrorKey]   objectForKey:kNMJSONResponseErrorDescriptionKey];
            
            *error  =   [self   prepareErrorWithDomain:kNMURLRequestErrorDomain
                                          andErrorCode:errorCode
                                            andMessage:errorMessage];
        }else
            *error  =   [self   prepareErrorWithDomain:kNMURLRequestErrorDomain
                                          andErrorCode:kNMURLRequestErrorDefaultCode
                                            andMessage:kNMURLRequestErrorParsingWrongFormat];
    }
    
    return nil;
}

-   (id)    parseResponseWithNSJSONSerializator:(NSError *)error{
    NSLog(@"NMURLRequest. Try to parse response with NSJSONSerializator");
    
    BOOL    isValid =   [NSJSONSerialization    isValidJSONObject:_data];
    NSLog(@"NMURLRequest. NSJSON parsing is valid: %@", isValid ?   @"YES"  :   @"NO");
    
    id  response    =   [NSJSONSerialization    JSONObjectWithData:_data
                                                           options:NSJSONReadingAllowFragments
                                                             error:&error];
    
    if (error   !=  nil)
        return response;
        
    
    return nil;
}

#pragma mark    -   NSURLConnection Protocol

-   (void)  connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (_data   ==  nil)
        _data   =   [[NSMutableData alloc]  init];
    
    [_data  appendData:data];
}

-   (void)  connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([_delegate  respondsToSelector:@selector(urlRequest:didFailWithError:)])
        [_delegate  urlRequest:self didFailWithError:error];
}

-   (void)  connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError*    error   =   nil;
    
    if ([_delegate  respondsToSelector:@selector(urlRequest:didReceiveResponse:)]){
        if (_parsingEngine  ==  nil ||  ![_parsingEngine    isKindOfClass:[NSString class]]){
            error   =   [self   prepareErrorWithDomain:kNMURLRequestErrorDomain 
                                          andErrorCode:kNMURLRequestErrorDefaultCode
                                            andMessage:kNMUrlRequestErrorParsingUknownEngine];
            [self   connection:connection
              didFailWithError:error];
            return;
        }
        
        id  response    =   nil;
        if ([_parsingEngine isEqualToString:kNMURLRequestParsingEngineRawData])
            response    =   _data;
        else if ([_parsingEngine    isEqualToString:kNMUrlRequestParsingEngineString])
            response    =   [self   parseResponseAsStringWithError:&error];
        else if ([_parsingEngine    isEqualToString:kNMURLRequestParsingEngineSBJSON])
            response    =   [self   parseResponseWithSBJSON:&error];
        else if ([_parsingEngine    isEqualToString:kNMURLRequestParsingEngineSBJSONStd])
            response    =   [self   parseResponseWithSBJSONStd:&error];
        else if ([_parsingEngine    isEqualToString:kNMURLRequestParsingEngineNSJSON])
            response    =   [self   parseResponseWithNSJSONSerializator:&error];
        else
            error       =   [self   prepareErrorWithDomain:kNMURLRequestErrorDomain
                                              andErrorCode:kNMURLRequestErrorDefaultCode
                                                andMessage:kNMUrlRequestErrorParsingUknownEngine];

        
        if (error   !=  nil)
            [self   connection:connection
              didFailWithError:error];
        else
            [_delegate  urlRequest:self
                didReceiveResponse:response];
    }
}

@end
