//
//  TVHChannelTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHChannelTests.h"
#import "TVHTestHelper.h"
#import "TVHChannel.h"
#import "TVHEpg.h"
#import "TVHEpgStore.h"
#import "TVHChannelEpg.h"

@interface TVHChannel (MyPrivateMethodsUsedForTesting) 
@property (nonatomic, strong) NSMutableArray *channelEpgDataByDay;
@end

@interface TVHEpgStore (MyPrivateMethodsUsedForTesting)
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHChannelTests 

- (TVHChannel*)channel {
    TVHChannel *channel = [[TVHChannel alloc] init];
    
    return channel;
}

- (TVHEpg*)epg {
    TVHEpg *epg = [[TVHEpg alloc] init];
    [epg updateValuesFromDictionary:@{
        @"channelid":@27,
        @"id":@442521,
        @"title":@"Jornal das 8",
        @"description":@"Episodio 1.\n",
        @"duration":@6120,
        @"start":@1361563200,
        @"end":@1361569320 }];
    return epg;
}

- (void)didLoadEpgChannel{}

- (void)testDuplicateEpg {
    
    TVHChannel *channel = [self channel];
    TVHEpg *epg = [self epg];
    
    [channel addEpg:epg];
    TVHChannelEpg *chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"epg not inserted");
    
    [channel addEpg:epg];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"programs == %d should be 1", [chepg.programs count]);

    [channel addEpg:epg];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"programs == %d should be 1", [chepg.programs count]);
}

- (void)testDuplicateEpgFromFetchMorePrograms {
    NSData *data = [TVHTestHelper loadFixture:@"Log.oneChannelEpg"];
    TVHEpgStore *store = [[TVHEpgStore alloc ] init];
    [store fetchedData:data];
    
    TVHChannel *channel = [self channel];
    TVHEpg *epg = [self epg];
    
    [channel setDelegate:self];
    [channel addEpg:epg];
    TVHChannelEpg *chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"epg not inserted");
    
    [channel didLoadEpg:store];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 4), @"programs == %d should be 4", [chepg.programs count]);
    
    [channel didLoadEpg:store];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 4), @"programs == %d should be 4", [chepg.programs count]);
}

@end