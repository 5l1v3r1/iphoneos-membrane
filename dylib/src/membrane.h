/*
* MIT License
*
* Copyright (c) 2020-2021 EntySec
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#import <Foundation/Foundation.h>
#import "rocketbootstrap.h"
	
@interface SBMediaController : NSObject {
    int _manualVolumeChangeCount;
    float _pendingVolumeChange;
    NSTimer* _volumeCommitTimer;
    BOOL _debounceVolumeRepeat;
    NSDictionary *_nowPlayingInfo;
}

@property (assign, getter=isRingerMuted, nonatomic) BOOL ringerMuted;
+ (id)sharedInstance;
- (void)setRingerMuted:(BOOL)arg1;
- (void)cancelLockScreenIdleTimer;
- (void)turnOnScreenFullyWithBacklightSource:(int)arg1;
- (BOOL)play;
- (BOOL)togglePlayPause;
- (BOOL)isPlaying;
- (BOOL)changeTrack:(int)track;
@end

@interface SpringBoard
+ (id)sharedInstance;
- (void)_simulateLockButtonPress;
@end

@interface SBIcon : NSObject
- (NSString *)nodeIdentifier;
@end


@interface SBApplicationIcon : SBIcon
@end

@interface SBIconController : NSObject
- (id)lastTouchedIcon;
@end

@interface SBUserAgent : NSObject
+ (id)sharedUserAgent;
- (void)lockAndDimDevice;
- (void)handleMenuDoubleTap;
- (void)clickedMenuButton;
- (bool)handleHomeButtonSinglePressUp;
- (bool)handleHomeButtonDoublePressDown;
@end

@interface SBDeviceLockController : NSObject
+ (id)sharedController;
- (void)_clearBlockedState;
- (BOOL)isPasscodeLocked;
@end

@interface CLLocationManager : NSObject
+ (void)setLocationServicesEnabled:(BOOL)arg1;
@end

@interface SBLockScreenManager : NSObject
@property (nonatomic, readonly) BOOL isUILocked;
+ (id)sharedInstance;
- (BOOL)attemptUnlockWithPasscode:(id)passcode;
@end

@interface SBHUDController : NSObject
+ (id)sharedInstance;
- (void)hideHUD;
- (void)showHUD;
@end

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (void)toggleMute;
@end

@interface SBRingerControl : NSObject
- (BOOL)isRingerMuted;
-(void)setRingerMuted:(BOOL)arg1;
@end

@interface SBMainWorkspace : NSObject
+ (SBMainWorkspace *)sharedInstance;
@property (readonly, nonatomic) SBRingerControl *ringerControl;
@end
