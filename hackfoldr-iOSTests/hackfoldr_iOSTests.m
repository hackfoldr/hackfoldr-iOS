//
//  hackfoldr_iOSTests.m
//  hackfoldr-iOSTests
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HackfoldrClient.h"
#import "HackfoldrField.h"
#import "OHHTTPStubs.h"

@interface hackfoldr_iOSTests : XCTestCase

@end

@implementation hackfoldr_iOSTests

- (void)setUp
{
    [super setUp];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSLog(@"hook on :%@", request);
        NSString *csvDataString = OHPathForFileInBundle(@"kaunsim.csv",nil);
        NSData *csvData = [NSData dataWithContentsOfFile:csvDataString];

        return [OHHTTPStubsResponse responseWithData:csvData statusCode:200 headers:nil];
    }];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    [super tearDown];
}

- (void)testHackField
{
    NSString *nameURL = @"http://www.g0v.tw";
    NSString *name = @"Name ";
    NSString *actions = @"{target}";
    HackfoldrField *field = [[HackfoldrField alloc] initWithFieldArray:@[nameURL, name, actions]];

    XCTAssertTrue([field.urlString isEqualToString:nameURL], @"");
    XCTAssertTrue([field.name isEqualToString:name], @"");
    XCTAssertTrue([field.actions isEqualToString:actions], @"");
    XCTAssertFalse(field.isSubItem, @"");

    NSString *subItemURL = @" http://www.g0v.tw";

    HackfoldrField *subField = [[HackfoldrField alloc] initWithFieldArray:@[subItemURL, name, actions]];
    NSString *subString = [subItemURL substringWithRange:NSMakeRange(1, subItemURL.length-1)];
    XCTAssertTrue([subField.urlString isEqualToString:subString], @"");
    XCTAssertTrue([subField.name isEqualToString:name], @"");
    XCTAssertTrue([subField.actions isEqualToString:actions], @"");
    XCTAssertTrue(subField.isSubItem, @"isSubItem must be YES");
}

@end
