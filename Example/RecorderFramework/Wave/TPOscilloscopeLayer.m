//
//  TPOscilloscopeLayer.m
//  Audio Manager Demo
//
//  Created by Michael Tyson on 27/07/2011.
//  Copyright (c) 2012 A Tasty Pixel. All rights reserved.
//

#import "TPOscilloscopeLayer.h"
#import <Accelerate/Accelerate.h>
#include <libkern/OSAtomic.h>

#define kBufferLength 2048 // In frames; higher values mean oscilloscope spans more time
#define kMaxConversionSize 4096
#define kSkipFrames 16     // Frames to skip - higher value means faster render time, but rougher display

@interface TPOscilloscopeLayer () {
    id           _timer;
//    AudioBufferList *_conversionBuffer;
}
//@property (nonatomic, strong) AEFloatConverter *floatConverter;

@end

@implementation TPOscilloscopeLayer

- (id)init {
    if ( !(self = [super init]) ) return nil;
    
    self.contentsScale = [[UIScreen mainScreen] scale];
    self.lineColor = [UIColor colorWithRed:85.0f/255.0f green:95.0f/255.0f blue:115.0f/255.0f alpha:1];
    _renderVals = [[NSMutableArray alloc] init];

    return self;
}

//- (id)initWithAudioController:(AEAudioController*)audioController {

//
//    if(audioController) {
//        self.floatConverter = [[AEFloatConverter alloc] initWithSourceFormat:audioController.audioDescription];
//        _conversionBuffer = AEAllocateAndInitAudioBufferList(_floatConverter.floatingPointAudioDescription, kMaxConversionSize);
//        
//        // Disable animating view refreshes
//        self.actions = @{@"contents": [NSNull null]};
//    }
//
//    return self;
//}

- (void)start {
    if ( _timer ) return;
    
    if ( NSClassFromString(@"CADisplayLink") ) {
        _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        ((CADisplayLink*)_timer).frameInterval = 2;
        [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    }
}

- (void)stop {
    if ([_renderVals count] * 0.5 < _scrollView.frame.size.width - 42) {
    }
    else {
        [_scrollView setContentOffset:CGPointMake([_renderVals count] * 0.5 - _scrollView.frame.size.width / 2, 0) animated:YES];
    }
    if ( !_timer ) return;
    [_timer invalidate];
    _timer = nil;
    [self setNeedsDisplay];
}

//-(AEAudioControllerAudioCallback)receiverCallback {
//    return &audioCallback;
//}
//
//-(void)dealloc {
//    [self stop];
//    if ( _conversionBuffer ) {
//        AEFreeAudioBufferList(_conversionBuffer);
//    }
//}
//
#pragma mark - Rendering

-(void)drawInContext:(CGContextRef)ctx {
    CGContextSetShouldAntialias(ctx, false);
    
    // Render ring buffer as path
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [_lineColor CGColor]);
    CGContextBeginPath(ctx);
    
    for (int a = ([_renderVals count] < _scrollView.frame.size.width * 2 || _timer == nil) ? 0 : [_renderVals count] - _scrollView.frame.size.width * 2; a < [_renderVals count]; a++) {
        float heigth = [[_renderVals objectAtIndex:a] floatValue] * 100;
        CGContextMoveToPoint(ctx, a * 0.5, (self.frame.size.height - heigth) / 2);
        CGContextAddLineToPoint(ctx, a * 0.5, (self.frame.size.height - heigth) / 2 + heigth);
    }
    
    if (_scrollView != nil && _cursor != nil) {
        if ([_renderVals count] * 0.5 < _scrollView.frame.size.width - 42) {
            _cursor.frame = CGRectMake([_renderVals count] * 0.5 -2, _cursor.frame.origin.y, _cursor.frame.size.width, _cursor.frame.size.height);
        }
        else {
            _cursor.frame = CGRectMake(_scrollView.frame.size.width - 42, _cursor.frame.origin.y, _cursor.frame.size.width, _cursor.frame.size.height);
            _scrollView.contentOffset = CGPointMake([_renderVals count] * 0.5 - _scrollView.frame.size.width + 40, 0);
        }
        
        if (_timer == nil) {
            self.cursor.frame = CGRectMake(self.scrollView.frame.size.width / 2 - 4, self.cursor.frame.origin.y, self.cursor.frame.size.width, self.cursor.frame.size.height);
        }
    }
    
    CGContextStrokePath(ctx);
}

#pragma mark - Callback
//
//static void audioCallback(__unsafe_unretained TPOscilloscopeLayer *THIS,
//                          __unsafe_unretained AEAudioController *audioController,
//                          void *source,
//                          const AudioTimeStamp *time,
//                          UInt32 frames,
//                          AudioBufferList *audio) {
//    // Convert audio
//    AEFloatConverterToFloatBufferList(THIS->_floatConverter, audio, THIS->_conversionBuffer, frames);
//    
//    // Get a pointer to the audio buffer that we can advance
//    float *audioPtr = THIS->_conversionBuffer->mBuffers[0].mData;
//    float *initialAudioPtr = audio->mBuffers[0].mData;
//    
//    float max = 0.0f;
//    for (int i = 0; i < frames-1; i++) {
//        if (audioPtr[i] > max )
//            max = audioPtr[i];
//    }
//
//    THIS->_renderVals = [THIS->_renderVals arrayByAddingObject:[NSString stringWithFormat:@"%f", max]];
//}
//
//+ (float)maxVal:(AudioBufferList*)list audioDescription:(AudioStreamBasicDescription)desc frames:(UInt32)frames {
//    
//    AEFloatConverter* conv = [[AEFloatConverter alloc] initWithSourceFormat:desc];
//    AudioBufferList* cb = AEAllocateAndInitAudioBufferList(conv.floatingPointAudioDescription, frames);
//    
//    // Convert audio
//    AEFloatConverterToFloatBufferList(conv, list, cb, frames);
//    
//    // Get a pointer to the audio buffer that we can advance
//    float *audioPtr = cb->mBuffers[0].mData;
//    
//    float *initialAudioPtr = list->mBuffers[0].mData;
//    
//    float max = 0.0f;
//    for (int i = 0; i < frames-1; i++) {
//        if (audioPtr[i] > max )
//            max = audioPtr[i];
//    }
//    
//    return max;
//}

+ (NSData *) getRenderData:(AVURLAsset *)songAsset {
    
    NSError * error = nil;
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    
    UInt32 sampleRate,channelCount;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc ) {
            
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //    NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",fmtDesc->mChannelsPerFrame, fmtDesc->mBytesPerPacket,fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    SInt16 normalizeMax = 0;
    
    NSMutableData * fullSongData = [[NSMutableData alloc] init];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50;
    
    while (reader.status == AVAssetReaderStatusReading){
        
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
//            NSAutoreleasePool *wader = [[NSAutoreleasePool alloc] init];
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = length / bytesPerSample;
            for (int i = 0; i < sampleCount ; i ++) {
                
                SInt16 left = *samples++;
                totalLeft  += left;
                
                SInt16 right;
                if (channelCount==2) {
                    right = *samples++;
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    
                    SInt16 fix = abs(left);
                    if (fix > normalizeMax) {
                        normalizeMax = fix;
                    }
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    
                    if (channelCount==2) {
                        right = totalRight / sampleTally;
                        
                        SInt16 fix = abs(right);
                        if (fix > normalizeMax) {
                            normalizeMax = fix;
                        }
                        
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                }
            }
            
//            [wader drain];
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    
    NSData * finalData = nil;
    
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        // Something went wrong. return nil
        
        return nil;
    }
    
    return finalData;
}


@end
