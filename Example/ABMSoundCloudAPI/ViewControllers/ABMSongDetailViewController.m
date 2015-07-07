//
//  ABMSongDetailViewController.m
//  ABMSoundCloudAPI
//
//  Created by Andres Brun Moreno on 14/03/15.
//  Copyright (c) 2015 Andres Brun Moreno. All rights reserved.
//

#import "ABMSongDetailViewController.h"
#import "ABMSoundCloudAPISingleton.h"

#import <UIAlertView+Blocks.h>
#import <SVProgressHUD.h>

@interface ABMSongDetailViewController ()

@property (nonatomic, readonly) NSString* songID;

@property (weak, nonatomic) IBOutlet UITextView *resultTextField;

-(void)didTap_navigationBar_repostSongButton;

-(void)attemptRepostSong;

@end

@implementation ABMSongDetailViewController

#pragma mark - UIViewController
-(void)viewDidLoad {
	[super viewDidLoad];

	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTap_navigationBar_repostSongButton)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] requestSongById:self.songID withSuccess:^(NSDictionary *songDict) {
        [weakSelf.resultTextField setText:songDict.descriptionInStringsFileFormat];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }];
}

#pragma mark - UIBarButtonItem actions
-(void)didTap_navigationBar_repostSongButton
{
	__weak typeof(self) weakSelf = self;
	[[[UIAlertView alloc]initWithTitle:@"Repost track"
							   message:@"Are you sure you'd like to repost this track to your SoundCloud wall?"
					  cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"]
					  otherButtonItems:[RIButtonItem itemWithLabel:@"Repost" action:^{

		[weakSelf attemptRepostSong];

	}], nil]show];
}

#pragma mark - Repost Song
-(void)attemptRepostSong
{
	NSString* songID = self.songID;
	if (songID.length == 0)
	{
		NSAssert(false, @"Should have a song id");
		return;
	}

	[SVProgressHUD showWithStatus:@"Reposting" maskType:SVProgressHUDMaskTypeBlack];

	[[[ABMSoundCloudAPISingleton sharedManager] soundCloudPort] repostSongToUserWallWithId:songID withSuccess:^(NSDictionary *songDict) {

		[SVProgressHUD showSuccessWithStatus:@"Reposted"];

	} failure:^(NSError *error) {

		[SVProgressHUD showErrorWithStatus:nil];

		[[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];

	}];
}

#pragma mark - songID
-(NSString *)songID
{
	id songID = [self.songDictionary[@"id"] copy];
	NSString* songID_string = nil;
	if ([songID isKindOfClass:[NSString class]])
	{
		songID_string = songID;
	}
	else
	{
		if ([songID isKindOfClass:[NSNumber class]])
		{
			songID_string = [(NSNumber*)songID stringValue];
		}
	}

	return songID_string;
}

@end
