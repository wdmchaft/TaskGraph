//
//  NSString+NMKit_Extenstion.h
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//
//  Different useful categories on NSString

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMKitDefines.h"

@interface NSString (NMKit_Extenstion)

    //Hash-calculation block
/*
 Generate raw NSData hash for NSString
 */
-	(NSData*)	MD5;
-	(NSData*)	SHA1;
-	(NSData*)	HMAC_MD5:	(NSString*)hmacKey;
-	(NSData*)	HMAC_SHA1:	(NSString*)hmacKey;

/*
 Generate and reinterpret like Base64 hash for NSString
 */
-   (NSString*) MD5_x64;
-   (NSString*) SHA1_x64;
-   (NSString*) HMAC_MD5_x64:(NSString*)hmacKey;
-   (NSString*) HMAC_SHA1_x64:(NSString*)hmacKey;

/*
 Generate and reinterpret like hexadecimal hash for NSString
 */
-   (NSString*) MD5_HEX;
-   (NSString*) SHA1_HEX;
-   (NSString*) HMAC_MD5_HEX:(NSString*)hmacKey;
-   (NSString*) HMAC_SHA1_HEX:(NSString*)hmacKey;


/*
 Generate suffixed names for NSString by checking UIControlState
 */
-   (NSString*) statedImageName:(UIControlState)state;  //In default device checked for add suffix
-   (NSString*) statedImageName:(UIControlState)state
                 andDeviceCheck:(BOOL)deviceCheck;
-   (NSString*) deviced;

/*
 Generate GET URL request string with params in dictionary
 */

-   (NSString*) preparedGetURLWithParams:(NSDictionary*)params;

@end
