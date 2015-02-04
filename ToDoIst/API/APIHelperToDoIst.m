//
//  APIHelper.m
//  ToDoIst
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "APIHelperToDoIst.h"
#import "APIProtocol.h"
@import AppKit;

static NSOperationQueue *operationQueue = nil;

@implementation APIHelperToDoIst

+(NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return operationQueue;
}

+ (NSString *) URLEncodedString_ch: (NSString *)input {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[input UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+(void)getUserWithEmail:(NSString *)email andPassword:(NSString *)password andDelegate: (id)delegate
{
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.todoist.com/API/login?email=%@&password=%@", email, password];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([body isEqualToString:@"\"LOGIN_ERROR\""])
            [delegate finishedCallFor:@"GetUser" withData:nil];
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [delegate finishedCallFor:@"GetUser" withData:dict];
        }
    }];
}

+(void)sendToInboxWithContent:(NSString *)content andApiToken:(NSString *)token andDelegate:(id)delegate
{
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.todoist.com/API/addItem?content=%@&token=%@", [self URLEncodedString_ch:content], token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([body isEqualToString:@"\"ERROR_PROJECT_NOT_FOUND\""] || [body isEqualToString:@"\"ERROR_WRONG_DATE_SYNTAX\""])
            [delegate finishedCallFor:@"SendToInbox" withData:nil];
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [delegate finishedCallFor:@"SendToInbox" withData:dict];
        }
    }];
}

@end
