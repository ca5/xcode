//
//  AudioQueueSoundPlayer.h
//  soundTest2
//
//  Created by Ca5 on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define AUDIO_BUFFER_NUM 3

@interface AudioQueueSoundPlayer : NSObject
{
    AudioFileID                     _audioFileId;
    AudioStreamBasicDescription     _audioBasicDesc;
    AudioQueueRef                   _audioQueue;
    AudioQueueBufferRef             _audioBuffer[AUDIO_BUFFER_NUM];
    AudioStreamPacketDescription*   _audioPacketDesc;
    
    UInt32                          _packetSizeToRead;
    UInt32                          _startPacketNumber;
    UInt64                          _maxPacketNumber;
    UInt32                          _playStatus;
    
    NSString* _fileName;
    NSString* _fileType;
}


- (void)makeAudioQueue;
- (void)play;
- (void)stop;

- (id)initWithFileName:(NSString*)fileName
                  type:(NSString*)fileType;
- (void)setFileName:(NSString*)fileName
               type:(NSString*)fileType;
- (void)dealloc;

@end
