//
//  CHCSVParserResponseSerializer.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "CHCSVParserResponseSerializer.h"

#import "CHCSVParser.h"
#import "HackfolerField.h"

@interface CHCSVParserResponseSerializer () <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray *_fields;
@property (nonatomic, strong) HackfolerField *_oneField;
@property (nonatomic, strong) NSError *_parserError;

@end

@implementation CHCSVParserResponseSerializer

+ (instancetype)serializer {
    CHCSVParserResponseSerializer *serializer = [[self alloc] init];

    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/csv", nil];

    return self;
}

- (NSArray *)fields
{
    return self._fields;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:response data:data error:error]) {
        if (!error) {
            return nil;
        }
    }

    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    CHCSVParser *csvParser = [[CHCSVParser alloc] initWithCSVString:stringData];
    csvParser.delegate = self;
    csvParser.recognizesBackslashesAsEscapes = self.recognizesBackslashesAsEscapes;
    csvParser.sanitizesFields = self.sanitizesFields;
    csvParser.recognizesComments = self.recognizesComments;

    [csvParser parse];

    if (self._parserError) {
        *error = self._parserError;
        return nil;
    }

    return [NSArray arrayWithArray:self._fields];
}

#pragma mark - CHCSVParserDelegate

- (void)parserDidBeginDocument:(CHCSVParser *)parser
{
    self._fields = [NSMutableArray array];
}

- (void)parserDidEndDocument:(CHCSVParser *)parser
{
    self._oneField = nil;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber
{
    self._oneField = [[HackfolerField alloc] init];
    self._oneField.index = recordNumber;
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber
{
    if (![self._oneField isEmpty]) {
        [self._fields addObject:self._oneField];
    }

    self._oneField = nil;
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex
{
    NSLog(@"field:%@, at %ld", field, (long)fieldIndex);
    self._oneField.index = fieldIndex;
    switch (fieldIndex) {
        case 0:
            self._oneField.urlString = field;
            break;
        case 1:
            self._oneField.name = field;
            break;
        case 2:
            self._oneField.actions = field;
            break;
        default:
            break;
    }
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error
{
    NSLog(@"parser error:%@", error);
    self._parserError = error;
}

@end
