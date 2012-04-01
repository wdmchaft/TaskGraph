//
//  NMURLRequest.h
//  CustomRequest
//
//  Created by Николай Сычев on 08.06.11.
//  Copyright 2011 СКИБ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNMURLRequestHttpMethodPost             @"POST"
#define kNMURLRequestHttpMethodGet              @"GET"

#define kNMURLRequestParsingEngineRawData       @"NMURLRequest_parse_response_as_NSData"
#define kNMUrlRequestParsingEngineString        @"NMURLRequest_parse_response_as_NSString"
#define kNMURLRequestParsingEngineSBJSON        @"NMURLRequest_parse_response_with_SBJSON_engine"
#define kNMURLRequestParsingEngineSBJSONStd     @"NMURLRequest_parse_response_with_SBJSON_engine_standard"
#define kNMURLRequestParsingEngineNSJSON        @"NMURLRequest_parse_response_with_NSJSONSerialization"

    //ERROR Constants
#define kNMURLRequestErrorDomain                @"ru.novilab-mobile.nmurlrequest.error"
#define kNMUrlRequestErrorParsingUknownEngine   @"NMURLRequest error uknown engine"
#define kNMURLRequestErrorParsingWrongFormat    @"NMURLRequest error wrong format"
#define kNMURLRequestErrorDefaultCode           -1000


@protocol NMURLRequestDelegate;

// IN GET REQUEST USE NSString+PrepareURL

@interface NMURLRequest : NSObject  <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSString*           _parsingEngine;
    
    NSString*           _method;
    NSString*           _url;
    NSDictionary*       _params;
    
    NSMutableData*      _data;
    NSURLConnection*    _connection;
    
    id<NMURLRequestDelegate>    __unsafe_unretained _delegate;
}

@property(nonatomic, copy)      NSString*       url;
@property(nonatomic, strong)    NSDictionary*   params;
@property(nonatomic,
          strong,   
          setter = setHttpMethod:)      NSString*       httpMethod;
@property(nonatomic, unsafe_unretained) id<NMURLRequestDelegate> delegate;
@property(nonatomic, strong)    NSString*       parsingEngine;


    //CONSTRUCTORS
    //@standard constructors
-   (NMURLRequest*) init;

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString*)url
                           andParams:(NSDictionary*)params;

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString *)url
                           andParams:(NSDictionary *)params
                       andHttpMethod:(NSString*)method;

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString*)url
                           andParams:(NSDictionary*)params
                       andHttpMethod:(NSString*)method
                    andParsingEngine:(NSString*)parsingEngine;

-   (NMURLRequest*) initWithDelegate:(id<NMURLRequestDelegate>)delegate
                              andUrl:(NSString*)url
                           andParams:(NSDictionary*)params
                       andHttpMethod:(NSString*)method
                    andParsingEngine:(NSString*)parsingEngine;

    //@static constructors
+   (NMURLRequest*) requestWithDelegate:(id<NMURLRequestDelegate>)delegate
                                 andUrl:(NSString*)url
                              andParams:(NSDictionary*)params
                          andHttpMethod:(NSString*)method;

+   (NMURLRequest*) requestWithDelegate:(id<NMURLRequestDelegate>)delegate
                                 andUrl:(NSString*)url
                              andParams:(NSDictionary*)params
                          andHttpMethod:(NSString*)method
                       andParsingEngine:(NSString*)parsingEngine;




-   (void)  cancel;
-   (void)  start;

@end

@protocol NMURLRequestDelegate <NSObject>

@optional
-   (void)  urlRequest:(NMURLRequest*)urlRequest    didReceiveResponse:(id)response;

-   (void)  urlRequest:(NMURLRequest*)ulrRequest    didFailWithError:(NSError*)error;
@end



