//
//  TVHPlayStreamHelpController.m
//  TvhClient
//
//  Created by Luis Fernandes on 05/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHPlayStreamHelpController.h"
#import "TVHNativeMoviePlayerViewController.h"
#import "TVHPlayStream.h"
#import "TVHSingletonServer.h"

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate> {
    UIActionSheet *myActionSheet;
    BOOL transcodingEnabled;
}
@property (weak, nonatomic) id<TVHPlayStreamDelegate> streamObject;
@property (weak, nonatomic) UIStoryboard *storyboard;
@property (weak, nonatomic) UIViewController *vc;
@property (weak, nonatomic) UIBarButtonItem *sender;
@property (weak, nonatomic) TVHPlayStream *playStreamModal;
@end

@implementation TVHPlayStreamHelpController

- (id)init {
    self = [super init];
    if (self) {
        TVHServer *server = [TVHSingletonServer sharedServerInstance];
        self.playStreamModal = server.playStream;
    }
    return self;
}

- (void)showTranscodeMenu:(id)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle {
    transcodingEnabled = YES;
    [self showMenu:sender withVC:vc withActionSheet:actionTitle];
}

- (void)showMenu:(id)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle {
    int countOfItems = 0;
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *transcode;
    if ( transcodingEnabled ) {
        transcode = NSLocalizedString(@"Internal Player", nil);
    } else {
        transcode = NSLocalizedString(@"Transcode", nil);
    }

    [self dismissActionSheet];
    myActionSheet = [[UIActionSheet alloc] init];
    [myActionSheet setTitle:actionTitle];
    [myActionSheet setDelegate:self];
    
    if ( [self.playStreamModal isTranscodingCapable] ) {
        [myActionSheet addButtonWithTitle:transcode];
        [myActionSheet setDestructiveButtonIndex:countOfItems];
        countOfItems++;
    }
    
    [myActionSheet addButtonWithTitle:copy];
    countOfItems++;
    NSArray *available = [self.playStreamModal arrayOfAvailablePrograms];
    countOfItems += [available count];
    for( NSString *title in available )  {
        [myActionSheet addButtonWithTitle:title];
    }
    [myActionSheet setCancelButtonIndex:countOfItems];
    [myActionSheet addButtonWithTitle:cancel];
    
    if ( [sender isKindOfClass:[UIBarButtonItem class]] ) {
        [myActionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [myActionSheet showInView:sender];
    }

}

- (void)playStream:(id)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc  {
    self.streamObject = channel;
    self.vc = vc;
    self.sender = sender;
    transcodingEnabled = NO;
    [self showMenu:sender withVC:vc withActionSheet:NSLocalizedString(@"Stream Channel", nil)];
}

- (void)playDvr:(UIBarButtonItem*)sender withDvrItem:(id<TVHPlayStreamDelegate>)dvrItem withVC:(UIViewController*)vc {
    self.streamObject = dvrItem;
    self.vc = vc;
    self.sender = sender;
    transcodingEnabled = NO;
    [self showMenu:sender withVC:vc withActionSheet:NSLocalizedString(@"Play Dvr File", nil)];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *streamUrl, *streamUrlInternal;
    
    streamUrl = [self.streamObject streamUrlWithTranscoding:transcodingEnabled withInternal:NO];
    
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)] ) {
        if ( streamUrl ) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:streamUrl];
        }
    }
    
    // transcode will call this menu again with the transcoding setting turned on
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Transcode", nil)] ) {
        [self dismissActionSheet];
        [self showTranscodeMenu:self.sender withVC:self.vc withActionSheet:NSLocalizedString(@"Playback Transcode Stream", nil)];
    }
    
    [TVHAnalytics sendEventWithCategory:@"uiActions"
                             withAction:@"playTo"
                              withLabel:buttonTitle
                              withValue:[NSNumber numberWithInt:1]];
    
    // internal player
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Internal Player", nil)] ) {
        streamUrlInternal = [self.streamObject streamUrlWithTranscoding:transcodingEnabled withInternal:YES];
        [self streamNativeUrl:streamUrlInternal];
    }
    
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Cancel", nil)] ) {
        return ;
    }
    
    [self.playStreamModal playStreamIn:buttonTitle forObject:self.streamObject withTranscoding:transcodingEnabled];
}

- (void)dismissActionSheet {
    if ( myActionSheet ) {
        [myActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        myActionSheet = nil;
    }
}

- (void)streamNativeUrl:(NSString*)url {
    TVHNativeMoviePlayerViewController *moviePlayer = [[TVHNativeMoviePlayerViewController alloc] init];
    moviePlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.vc presentViewController:moviePlayer animated:YES completion:^{
        [moviePlayer playStream:url];
    }];
    
}

@end
