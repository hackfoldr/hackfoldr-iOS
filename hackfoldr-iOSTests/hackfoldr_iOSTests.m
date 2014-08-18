//
//  hackfoldr_iOSTests.m
//  hackfoldr-iOSTests
//
//  Created by Superbil on 2014/6/21.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HackfolerField.h"

@interface hackfoldr_iOSTests : XCTestCase

@end

@implementation hackfoldr_iOSTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHackField
{
    NSString *nameURL = @"http://www.g0v.tw";
    NSString *name = @"Name ";
    NSString *actions = @"{target}";
    HackfolerField *field = [[HackfolerField alloc] initWithFieldArray:@[nameURL, name, actions]];

    XCTAssertTrue([field.urlString isEqualToString:nameURL], @"");
    XCTAssertTrue([field.name isEqualToString:name], @"");
    XCTAssertTrue([field.actions isEqualToString:actions], @"");
    XCTAssertFalse(field.isSubItem, @"");

    NSString *subItemURL = @" http://www.g0v.tw";

    HackfolerField *subField = [[HackfolerField alloc] initWithFieldArray:@[subItemURL, name, actions]];
    NSString *subString = [subItemURL substringWithRange:NSMakeRange(1, subItemURL.length-1)];
    XCTAssertTrue([subField.urlString isEqualToString:subString], @"");
    XCTAssertTrue([subField.name isEqualToString:name], @"");
    XCTAssertTrue([subField.actions isEqualToString:actions], @"");
    XCTAssertTrue(subField.isSubItem, @"isSubItem must be YES");
}

@end
