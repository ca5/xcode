//
//  ViewController.h
//  soundTest2
//
//  Created by Ca5 on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioQueueSoundPlayer.h"

#define AUDIO_BUFFER_NUM 3

@interface ViewController : UIViewController
{
    AudioQueueSoundPlayer* _AQSoundPlayer;
}

// Action
- (IBAction)playSound:(id)sender;
- (IBAction)stopSound:(id)sender;

- (void)dealloc;

@end
