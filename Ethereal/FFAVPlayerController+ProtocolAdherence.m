//
//  FFAVPlayerController+ProtocolAdherence.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "FFAVPlayerController+ProtocolAdherence.h"

@implementation FFAVPlayerController (ProtocolAdherence)

- (void)play {
    [self play:0];
}

- (id)currentItem {
    return nil;
}

@end
