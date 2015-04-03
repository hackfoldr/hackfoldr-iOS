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
        if ([request.URL.absoluteString rangeOfString:@"ethercalc.org"].location != NSNotFound) {
            return YES;
        }
        return NO;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSLog(@"hook hackfoldr:%@", request);
        NSString *jsonCSVDataString = OHPathForFileInBundle(@"sample.csv.json", nil);
        NSData *csvData = [NSData dataWithContentsOfFile:jsonCSVDataString];

        return [OHHTTPStubsResponse responseWithData:csvData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
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
    XCTAssertTrue(field.isSubItem, @"");

    NSString *subItemURL = @" http://www.g0v.tw";
    HackfoldrField *subField = [[HackfoldrField alloc] initWithFieldArray:@[subItemURL, name, actions]];
    NSString *subString = [subItemURL substringWithRange:NSMakeRange(1, subItemURL.length-1)];
    XCTAssertTrue([subField.urlString isEqualToString:subString], @"");
    XCTAssertTrue([subField.name isEqualToString:name], @"");
    XCTAssertTrue([subField.actions isEqualToString:actions], @"");
    XCTAssertTrue(subField.isSubItem, @"isSubItem must be YES");

    NSString *commentURL = @"# yooo";
    HackfoldrField *commentField = [[HackfoldrField alloc] initWithFieldArray:@[@"", commentURL, actions]];
    XCTAssertTrue(commentField.isCommentLine);
}

- (void)testHackfoldrClient
{
    XCTestExpectation *openHackfoldrExpectation = [self expectationWithDescription:@"open Hackfoldr"];

    [[[HackfoldrClient sharedClient] taskCompletionPagaDataAtPath:@"testHackFoldr"].task continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        NSLog(@"task %@ %@", task.error, task.result);

        [openHackfoldrExpectation fulfill];;
        return nil;
    }];

    [self waitForExpectationsWithTimeout:1000 handler:nil];
}

@end
