//
//  ViewController.m
//  soundTest2
//
//  Created by Ca5 on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define AUDIO_BUFFER_SECONDS 0.03

@interface ViewController (private)

@end




@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _AQSoundPlayer = [ [ AudioQueueSoundPlayer alloc ] initWithFileName:@"amen001" type:@"wav"]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)playSound:(id)sender
{
    [_AQSoundPlayer play];
}

- (IBAction)stopSound:(id)sender
{
    [_AQSoundPlayer stop];
}    

- (void)dealloc
{
    [_AQSoundPlayer release];
    [super dealloc];
}

@end
