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
#import "HackfoldrPage.h"
#import "OHHTTPStubs.h"


@interface AnnotatedRequestSerializer : AFHTTPRequestSerializer @end
@implementation AnnotatedRequestSerializer
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError * __autoreleasing *)error {
    NSMutableURLRequest* req = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    [NSURLProtocol setProperty:parameters forKey:@"parameters" inRequest:req];
    [NSURLProtocol setProperty:req.HTTPBody forKey:@"HTTPBody" inRequest:req];
    return req;
}
@end


@interface HackfoldrClient (UnitTest)
- (instancetype)initWithBaseURLForUnitTest:(NSURL *)url;
@end

@implementation HackfoldrClient (UnitTest)

- (instancetype)initWithBaseURLForUnitTest:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AnnotatedRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

@end


@interface hackfoldr_iOSTests : XCTestCase
@end

@implementation hackfoldr_iOSTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testHackfoldrPage
{
    HackfoldrPage *page = [[HackfoldrPage alloc] initWithFieldArray:@[@[@"abcdefg_is_key_length_must_bigger_than_40", @"A1"]]];
    XCTAssertTrue(page.rediredKey!=nil);
    XCTAssertTrue(page.rediredKey.length > 0);

    NSString *comment = @"#A1: if not marked as comment (start with #), better less than 40 characters, or will be parsed as a google spreadsheer id";
    HackfoldrPage *commentPage = [[HackfoldrPage alloc] initWithFieldArray:@[@[comment, @"A1 comment"]]];
    XCTAssertNil(commentPage.rediredKey);
}

- (void)testHackfoldrField
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

    // Hacfoldr 2.0 rule
    NSString *topItemURL = @"< http://hackfoldr.org/";
    HackfoldrField *topField = [[HackfoldrField alloc] initWithFieldArray:@[topItemURL, name, actions]];
    NSString *subStringOfTopField = [topItemURL substringWithRange:NSMakeRange(2, topItemURL.length -2)];
    XCTAssertFalse(topField.isSubItem);
    XCTAssertTrue([topField.urlString isEqualToString:subStringOfTopField]);

    NSString *commentURL = @"# yooo";
    HackfoldrField *commentField = [[HackfoldrField alloc] initWithFieldArray:@[@"", commentURL, actions]];
    XCTAssertTrue(commentField.isCommentLine);

    NSString *notCleanCommentURL = @"\"# not yoo\"";
    HackfoldrField *notCleanCommentField = [[HackfoldrField alloc] initWithFieldArray:@[@"", notCleanCommentURL, actions]];
    XCTAssertTrue(notCleanCommentField.isCommentLine);

    NSString *lableString = @"blue I am red";
    HackfoldrField *labelField = [[HackfoldrField alloc] initWithFieldArray:@[nameURL, @"label", actions, lableString]];
    XCTAssertTrue([labelField.labelString isEqualToString:@"I am red"]);

    NSString *commentLabelString = @"lol:warning";
    HackfoldrField *commentLabelField = [[HackfoldrField alloc] initWithFieldArray:@[nameURL, @"commentLabel", actions, commentLabelString]];
    NSLog(@"%@",commentLabelField.labelString);
    XCTAssertTrue([commentLabelField.labelString isEqualToString:@"lol"]);
}

- (void)testHackfoldrClient
{
    XCTestExpectation *openHackfoldrExpectation = [self expectationWithDescription:@"open Hackfoldr"];

    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString rangeOfString:@"ethercalc.org"].location != NSNotFound;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSLog(@"hook hackfoldr:%@", request);
        NSString *jsonCSVDataString = OHPathForFileInBundle(@"sample.csv.json", nil);
        NSData *csvData = [NSData dataWithContentsOfFile:jsonCSVDataString];

        return [OHHTTPStubsResponse responseWithData:csvData
                                          statusCode:200
                                             headers:@{@"Content-Type":@"text/json"}];
    }];

    HackfoldrClient *client = [[HackfoldrClient alloc] initWithBaseURLForUnitTest:[NSURL URLWithString:@"https://ethercalc.org/"]];
    [[client taskCompletionWithKey:@"testHackFoldr"].task continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error);
        NSLog(@"task %@ %@", task.error, task.result);

        [openHackfoldrExpectation fulfill];;
        return nil;
    }];

    [self waitForExpectationsWithTimeout:1000 handler:^(NSError * _Nullable error) {
        [OHHTTPStubs removeStub:stub];
    }];
}

@end
