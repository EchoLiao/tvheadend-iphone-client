//
//  tvhclientChannelListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelStoreViewController.h"
#import "TVHChannelStoreProgramsViewController.h"
#import "TVHChannel.h"

@interface TVHChannelStoreViewController ()
@property (strong, nonatomic) TVHChannelStore *channelList;
@end

@implementation TVHChannelStoreViewController
@synthesize channelList = _channelList;
@synthesize filterTagId = _filterTagId;

- (NSInteger) filterTagId {
    if(!_filterTagId) {
        return 0;
    }
    return _filterTagId;
}

- (TVHChannelStore*) channelList {
    if ( _channelList == nil) {
        _channelList = [TVHChannelStore sharedInstance];
    }
    return _channelList;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.channelList setDelegate:self];
    [self.channelList setFilterTag: self.filterTagId];
    [self.channelList fetchChannelList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channelList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    
    // Configure the cell...
    TVHChannel *ch = [self.channelList objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    TVHEpg *currentPlayingProgram = [ch currentPlayingProgram];
    
    UILabel *channelNameLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *currentProgramLabel = (UILabel *)[cell viewWithTag:101];
	UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    UILabel *currentTimeProgramLabel = (UILabel *)[cell viewWithTag:103];
    UIProgressView *currentTimeProgress = (UIProgressView*)[cell viewWithTag:104];
	currentProgramLabel.text = nil;
    currentTimeProgramLabel.text = nil;
    currentTimeProgress.hidden = true;
    
    channelNameLabel.text = ch.name;
    [channelImage setImageWithURL:[NSURL URLWithString:ch.imageUrl] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    if(currentPlayingProgram) {
        currentProgramLabel.text = currentPlayingProgram.title;
        currentTimeProgramLabel.text = [NSString stringWithFormat:@"%@ | %@", [dateFormatter stringFromDate:currentPlayingProgram.start], [dateFormatter stringFromDate:currentPlayingProgram.end]];
        currentTimeProgress.hidden = false;
        currentTimeProgress.progress = [currentPlayingProgram progress];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Show Channel Programs" sender:self]; 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel Programs"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHChannel *channel = [self.channelList objectAtIndex:path.row];
        
        TVHChannelStoreProgramsViewController *channelPrograms = segue.destinationViewController;
        [channelPrograms setChannel:channel];
        
        [segue.destinationViewController setTitle:channel.name];
    }
}

- (void)didLoadChannels {
    [self.tableView reloadData];
}

- (void)didErrorLoading {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Error connecting to server - this should redirect you to settings app"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

@end