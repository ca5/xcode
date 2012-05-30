//
//  AudioQueueSoundPlayer.m
//  soundTest2
//
//  Created by Ca5 on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AudioQueueSoundPlayer.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define AUDIO_BUFFER_SECONDS 0.03

@interface AudioQueueSoundPlayer(private)
- (void)_audioQueueOutputWithQueue:(AudioQueueRef)audioQueue 
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
@end

static void audioQueueOutputCallback(
                                     void* userData, AudioQueueRef audioQueue, AudioQueueBufferRef audioQueueBuffer)
{
    [(AudioQueueSoundPlayer*)userData 
     _audioQueueOutputWithQueue:audioQueue queueBuffer:audioQueueBuffer];
}

@implementation AudioQueueSoundPlayer

- (id)initWithFileName:(NSString*)fileName
              type:(NSString*)fileType;
{
    
    self = [super init];
    if(self){
        _fileName = fileName;
        _fileType = fileType;
        [self makeAudioQueue];
    }else{
        [self dealloc];
        return nil;
    }
    return self;
}

- (void)setFileName:(NSString*)fileName
             type:(NSString*)fileType
{
    _fileName = fileName;
    _fileType = fileType;
}

- (void)makeAudioQueue
{
    OSStatus status;
    UInt32 size;
    
    // get audio file path
    NSString* path;
    path = [[NSBundle mainBundle] pathForResource:_fileName ofType:_fileType];
    
    // open audio file
    status = AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:path], kAudioFileReadPermission, 0, &_audioFileId );
    
    // get audio file format
    size = sizeof(_audioBasicDesc);
    status = AudioFileGetProperty(_audioFileId, kAudioFilePropertyDataFormat, &size, &_audioBasicDesc);
    
    // make audio queue
    status = AudioQueueNewOutput(&_audioBasicDesc, audioQueueOutputCallback, self, 
                                 CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_audioQueue);
    
    // get max packet size
    UInt32 maxPacketSize;
    size = sizeof(maxPacketSize);
    status = AudioFileGetProperty(_audioFileId, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
    
    // get max packet number (file size)
    size = sizeof( _maxPacketNumber);
    status = AudioFileGetProperty(_audioFileId, kAudioFilePropertyAudioDataPacketCount, &size, & _maxPacketNumber);
    
    // calculate packets per time
    Float64 numPacketsPerTime;
    numPacketsPerTime =_audioBasicDesc.mSampleRate / _audioBasicDesc.mFramesPerPacket;
    
    // calculate packet size
    UInt32 bufferSize;
    bufferSize = numPacketsPerTime * maxPacketSize * AUDIO_BUFFER_SECONDS;
    
    // make audio queue buffer
    for (int i=0; i<AUDIO_BUFFER_NUM; i++){
        status = AudioQueueAllocateBuffer(_audioQueue, bufferSize, &_audioBuffer[i]);
    }
    
    
    // calculate packet size to load into buffer
    _packetSizeToRead = numPacketsPerTime * AUDIO_BUFFER_SECONDS;
    
    // make buffer for packet description
    _audioPacketDesc = malloc(_packetSizeToRead * sizeof(AudioStreamPacketDescription));
    
}

- (void)_audioQueueOutputWithQueue:(AudioQueueRef)audioQueue 
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer
{
    OSStatus    status;
    // read packet data
    UInt32 numBytes;
    UInt32 numPackets = _packetSizeToRead;
    
    status = AudioFileReadPackets( _audioFileId, NO, &numBytes, _audioPacketDesc, 
                                   _startPacketNumber, &numPackets, audioQueueBuffer->mAudioData);
    
    if (numPackets > 0) { // succeed to read packet
        // set audio data byte size to loaded packet data size
        audioQueueBuffer->mAudioDataByteSize = numBytes;
        
        // add buffer into queue
        status = AudioQueueEnqueueBuffer(
                                         audioQueue, audioQueueBuffer, numPackets, _audioPacketDesc);
        
        // move packet point
         _startPacketNumber += numPackets;
        
        
        // loop
        if (_startPacketNumber + numPackets >= _maxPacketNumber) {
            _startPacketNumber = 0;
        }
    }
    
    // update AQStruct _playStatus
    UInt32 valueSize = sizeof( _playStatus);
    status = AudioQueueGetProperty(audioQueue, kAudioQueueProperty_IsRunning, &_playStatus, &valueSize);
}

- (void)play
{
    // put data into queue
    _startPacketNumber = 0;
    
    if(_playStatus == 0){ //if status is not "playing"
        for(int i=0; i<AUDIO_BUFFER_NUM; i++){
            [self _audioQueueOutputWithQueue:_audioQueue queueBuffer:_audioBuffer[i]];
        }
        
        // start audio queue
        OSStatus    status;
        status = AudioQueueStart(_audioQueue, NULL);
    }
}

- (void)stop
{
    // stop audio queue
    OSStatus    status;
    status = AudioQueueStop(_audioQueue, YES);
}

- (void)dealloc
{
    free(_audioPacketDesc);
    [super dealloc];
}

@end

