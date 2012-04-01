//
//  NSString+NMKit_Extenstion.m
//  NMKit
//
//  Created by Vladimir Konev on 12/3/11.
//  Copyright (c) 2011 Novilab Mobile. All rights reserved.
//

#import "NSString+NMKit_Extenstion.h"
#import "Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

NSString*   _deviceSuffix(void);
NSString*   _stateSuffix(UIControlState controlState);

NSString*   _deviceSuffix(void){
    if (IS_PAD())
        return @"_pad";
    else
        return @"";
}

NSString*   _stateSuffix(UIControlState controlState){
    NSString*   suffix;
    switch (controlState) {
        case UIControlStateHighlighted:
            suffix  =   @"_h";
            break;
            
        case UIControlStateDisabled:
            suffix  =   @"_d";
            break;
            
        case UIControlStateSelected:
            suffix  =   @"_s";
            break;
            
        case UIControlStateNormal:
        default:
            suffix  =   @"";
            break;
    }
    
    return suffix;
}

@implementation NSString (NMKit_Extenstion)

//HASH_CALCUALTION

    //Get raw hash of NSString with MD5 algorithm
-	(NSData*)	MD5{
	const char*		data	=	[self	UTF8String];
	unsigned char	hashingBuffer[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(data, strlen(data), hashingBuffer);
	
	return	[NSData	dataWithBytes:hashingBuffer length:CC_MD5_DIGEST_LENGTH];
}
    //Get raw hash of NSString with SHA1 algorithm
-	(NSData*)	SHA1{
	const char*		data	=	[self	UTF8String];
	unsigned char	hashingBuffer[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data, strlen(data), hashingBuffer);
	
	return	[NSData	dataWithBytes:hashingBuffer length:CC_SHA1_DIGEST_LENGTH];
}

    //Get raw hash of NSString with MD5 algorithm and HMAC postprocessing
-	(NSData*)	HMAC_MD5:	(NSString*)hmacKey{
	const char*		data	=	[self	UTF8String];
	const char*		hashKey	=	[hmacKey	UTF8String];
	unsigned char	hashingBuffer[CC_MD5_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgMD5, hashKey, strlen(hashKey), data, strlen(data), hashingBuffer);
	
	return	[NSData dataWithBytes:hashingBuffer length:CC_MD5_DIGEST_LENGTH];
}

    //Get raw hash of NSString with SHA1 algorithm and HMAC postprocessing
-	(NSData*)	HMAC_SHA1:	(NSString *)hmacKey{
	const char*		data	=	[self	UTF8String];
	const char*		hashKey	=	[hmacKey	UTF8String];
	unsigned char	hashingBuffer[CC_SHA1_DIGEST_LENGTH];
    
	CCHmac(kCCHmacAlgSHA1, hashKey, strlen(hashKey), data, strlen(data), hashingBuffer);
    
	return	[NSData	dataWithBytes:hashingBuffer length:CC_SHA1_DIGEST_LENGTH];
}

    //Get hash of NSString with MD5 algorithm and return Base64 interpretation
-   (NSString*) MD5_x64{
    return [Base64  encode:[self    MD5]];
}

    //Get hash of NSString with SHA1 algorithm and return Base64 interpretation
-   (NSString*) SHA1_x64{
    return [Base64  encode:[self    SHA1]];
}

    //Get hash of NSString with MD5 algorithm, HMAC postprocessing and return Base64 interpretation
-   (NSString*) HMAC_MD5_x64:(NSString *)hmacKey{
    return [Base64  encode:[self    HMAC_MD5:hmacKey]];
}

    //Get hash of NSString with SHA1 algorithm, HMAC postprocessing and return Base64 interpretation
-   (NSString*) HMAC_SHA1_x64:(NSString *)hmacKey{
    return [Base64  encode:[self    HMAC_SHA1:hmacKey]];
}

    //Get hash of NSString with MD5 algorithm and return hexadecimal interpretation
-   (NSString*) MD5_HEX{
    const char*		data	=	[self	UTF8String];
	unsigned char	hashingBuffer[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(data, strlen(data), hashingBuffer);
    
    NSMutableString*    result  =   [[NSMutableString   alloc]  initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i   < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02X", hashingBuffer[i]];
    
    return result;
}
    //Get hash of NSString with SHA1 algorithm and return hexadecimal interpretation
-   (NSString*) SHA1_HEX{
    const char*		data	=	[self	UTF8String];
	unsigned char	hashingBuffer[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data, strlen(data), hashingBuffer);
    
    NSMutableString*    result  =   [[NSMutableString   alloc]  initWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for (int i = 0; i   < CC_SHA1_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02X", hashingBuffer[i]];
    
    return result;
}

    //Get hash of NSString with MD5 algorithm, HMAC postprocessing and return hexadecimal interpretation
-   (NSString*) HMAC_MD5_HEX:(NSString *)hmacKey{
    const char*		data	=	[self	UTF8String];
	const char*		hashKey	=	[hmacKey	UTF8String];
	unsigned char	hashingBuffer[CC_MD5_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgMD5, hashKey, strlen(hashKey), data, strlen(data), hashingBuffer);
    
    NSMutableString*    result  =   [[NSMutableString   alloc]  initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i   < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02X", hashingBuffer[i]];
    
    return result;
}

    //Get hash of NSString with SHA1 algorithm, HMAC postprocessing and return hexadecimal interpretation
-   (NSString*) HMAC_SHA1_HEX:(NSString *)hmacKey{
    const char*		data	=	[self	UTF8String];
	const char*		hashKey	=	[hmacKey	UTF8String];
	unsigned char	hashingBuffer[CC_SHA1_DIGEST_LENGTH];
    
	CCHmac(kCCHmacAlgSHA1, hashKey, strlen(hashKey), data, strlen(data), hashingBuffer);
    
    NSMutableString*    result  =   [[NSMutableString   alloc]  initWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for (int i = 0; i   < CC_SHA1_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02X", hashingBuffer[i]];
    
    return result;
}


    //ImageNames processing
-   (NSString*) statedImageName:(UIControlState)state{
    return [self    statedImageName:state andDeviceCheck:YES];
}

-   (NSString*) statedImageName:(UIControlState)state andDeviceCheck:(BOOL)deviceCheck{
    NSString*   suffix  =   _stateSuffix(state);
    
    if (deviceCheck)
        suffix  =   [suffix stringByAppendingString:_deviceSuffix()];
    
    NSString*   result;
    if ([self   hasSuffix:@".png"]){
        NSUInteger  index   =   [self   length] -   4;
        NSString*   source  =   [self   substringToIndex:index];
        result              =   [source stringByAppendingFormat:@"%@.png", suffix];
    }else
        result  =   [self    stringByAppendingString:suffix];
    
    return result;
}

-   (NSString*) deviced{
    return [self    statedImageName:UIControlStateNormal
                     andDeviceCheck:YES];
}


    //GET URL request prepared
-   (NSString*) preparedGetURLWithParams:(NSDictionary *)params{
    NSMutableArray*	paramComponents	=	[[NSMutableArray	alloc] init];
	for (NSString * key in [params keyEnumerator]) {
        id value    =   [params objectForKey:key];
        if (![value isKindOfClass:[NSString class]] &&
            ![value isKindOfClass:[NSNumber class]])
            continue;
        
		NSString*	ParsedKey	=	(__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) key, NULL, (CFStringRef) @":;,.&%$#@!?[]{}+", kCFStringEncodingUTF8);
		NSString*	ParsedValue	=	(__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[[params objectForKey:key]    description], NULL, (CFStringRef) @":;,.&%$#@!?[]{}+", kCFStringEncodingUTF8);
		[paramComponents addObject:[NSString stringWithFormat:@"%@=%@", ParsedKey, ParsedValue]];
	}
	
	return	[self	stringByAppendingFormat:@"?%@",[paramComponents	componentsJoinedByString:@"&"]];;
}



@end
