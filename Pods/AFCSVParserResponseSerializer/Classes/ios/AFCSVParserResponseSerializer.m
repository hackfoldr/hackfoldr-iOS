//
//  AFCSVParserResponseSerializer.m
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "AFCSVParserResponseSerializer.h"

#import "CHCSVParser.h"

@interface AFCSVParserResponseSerializer () <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray *_fields;
@property (nonatomic, strong) NSMutableArray *_oneLine;
@property (nonatomic, strong) NSError *_parserError;

@end

@implementation AFCSVParserResponseSerializer

+ (instancetype)serializer {
    AFCSVParserResponseSerializer *serializer = [[self alloc] init];

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

    NSStringEncoding usedEncoding = self.usedEncoding ? self.usedEncoding : [NSString defaultCStringEncoding];
    unichar usedDelimiter = self.usedDelimiter ? self.usedDelimiter : ',';

    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    CHCSVParser *csvParser = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&usedEncoding delimiter:usedDelimiter];
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
    self._oneLine = nil;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber
{
    self._oneLine = [NSMutableArray array];
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber
{
    [self._fields addObject:self._oneLine];
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex
{
    [self._oneLine addObject:field];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error
{
    self._parserError = error;
}

@end
