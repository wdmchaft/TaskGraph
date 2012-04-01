//
//  NMJSONResponse.h
//  iCurrency_Lite
//
//  Created by Mephi Skib on 03.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNMJSONResponseRequestTypeKey       @"RequestType"

#define kNMJSONResponseStateKey             @"State"
#define kNMJSONResponseStateSuccess         @"Success"
#define kNMJSONResponseStateFailed          @"Failed"

#define kNMJSONResponseDataKey              @"Data"

#define kNMJSONResponseErrorKey             @"Error"
#define kNMJSONResponseErrorCodeKey         @"Code"
#define kNMJSONResponseErrorDescriptionKey  @"Description"

@interface NMJSONResponse : NSObject{
    NSString*   _requestType;
    id          _data;
}
@property(nonatomic,    copy)   NSString*   requestType;
@property(nonatomic,    strong) id          data;

@end
