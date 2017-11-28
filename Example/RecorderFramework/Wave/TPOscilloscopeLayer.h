#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "TheAmazingAudioEngine/TheAmazingAudioEngine.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface TPOscilloscopeLayer : CALayer //<AEAudioReceiver>
//- (id)initWithAudioController:(AEAudioController*)audioController;
- (id)init;

- (void)start;
- (void)stop;
+ (NSData *) getRenderData:(AVURLAsset *)songAsset;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIImageView* cursor;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* renderVals;

//- (AEAudioControllerAudioCallback)receiverCallback;

//+ (float)maxVal:(AudioBufferList*)list audioDescription:(AudioStreamBasicDescription)desc frames:(UInt32)frames;

@end
