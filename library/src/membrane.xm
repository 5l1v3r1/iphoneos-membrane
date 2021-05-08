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

#import "membrane.h"

#import <AppSupport/CPDistributedMessagingCenter.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NSTask.h"
#import "mediaremote.h"

%hook SpringBoard

SBRingerControl *ringerControl;
BOOL hideIndicator = YES;
static SpringBoard *__strong sharedInstance;

-(id)init {
    id original = %orig;
    sharedInstance = original;
    return original;
}

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    ringerControl = (SBRingerControl *)[[%c(SBMainWorkspace) sharedInstance] ringerControl];
    CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.membrane"];
    [messagingCenter runServerOnCurrentThread];
    [messagingCenter registerForMessageName:@"recieveCommand" target:self selector:@selector(recieveCommand:withUserInfo:)];
}

%new

+(id)sharedInstance {
    return sharedInstance;
}

%new
-(NSDictionary *)recieveCommand:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    NSMutableArray *args = [userInfo objectForKey:@"args"];
    int args_count = [args count];
    if ([args[0] isEqual:@"state"]) {
	if ([(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] isUILocked]) return [NSDictionary dictionaryWithObject:@"locked" forKey:@"returnStatus"];
	return [NSDictionary dictionaryWithObject:@"unlocked" forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"player"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: player [next|prev|pause|play|info]" forKey:@"returnStatus"];
	else {
    	    if ([args[1] isEqual:@"info"]) {
	    	MPMediaItem *song = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
            	NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
            	NSString *album = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
            	NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
            	NSString *result = [NSString stringWithFormat:@"Title: %@\nAlbum: %@\nArtist: %@", title, album, artist];
	    	return [NSDictionary dictionaryWithObject:result forKey:@"returnStatus"];
	    } else if ([args[1] isEqual:@"play"]) {
	    	MRMediaRemoteSendCommand(kMRPlay, nil);
	    } else if ([args[1] isEqual:@"pause"]) {
	    	MRMediaRemoteSendCommand(kMRPause, nil);
	    } else if ([args[1] isEqual:@"next"]) {
	    	MRMediaRemoteSendCommand(kMRNextTrack, nil);
	    } else if ([args[1] isEqual:@"prev"]) {
	    	MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
	    } else {
	        return [NSDictionary dictionaryWithObject:@"Usage: player [next|prev|pause|play|info]" forKey:@"returnStatus"];
	    }
	}
    } else if ([args[0] isEqual:@"location"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: location [on|off|info]" forKey:@"returnStatus"];
	else {
    	    if ([args[1] isEqual:@"on"]) {
	    	[%c(CLLocationManager) setLocationServicesEnabled:true];
	    } else if ([args[1] isEqual:@"off"]) {
	    	[%c(CLLocationManager) setLocationServicesEnabled:false];
	    } else {
	    	return [NSDictionary dictionaryWithObject:@"Usage: location [on|off]" forKey:@"returnStatus"];
	    }
	}
    } else if ([args[0] isEqual:@"lock"]) {
    	[[%c(SpringBoard) sharedInstance] _simulateLockButtonPress];
    } else if ([args[0] isEqual:@"wake"]) {
    	[[%c(SpringBoard) sharedInstance] _simulateLockButtonPress];
    } else if ([args[0] isEqual:@"mute"]) {
        if (![ringerControl isRingerMuted]) {
            [[%c(VolumeControl) sharedVolumeControl] toggleMute];
	    [ringerControl setRingerMuted:![ringerControl isRingerMuted]];
        }
    } else if ([args[0] isEqual:@"unmute"]) {
        if ([ringerControl isRingerMuted]) {
            [[%c(VolumeControl) sharedVolumeControl] toggleMute];
            [ringerControl setRingerMuted:![ringerControl isRingerMuted]];
        }
    } else if ([args[0] isEqual:@"home"]) {
        if ([[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleHomeButtonSinglePressUp)]) {
            [[%c(SBUIController) sharedInstance] handleHomeButtonSinglePressUp];
        } else if ([[%c(SBUIController) sharedInstance] respondsToSelector:@selector(clickedMenuButton)]) {
            [[%c(SBUIController) sharedInstance] clickedMenuButton];
        }
    } else if ([args[0] isEqual:@"dhome"]) {
        if ([[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleHomeButtonDoublePressDown)]) {
            [[%c(SBUIController) sharedInstance] handleHomeButtonDoublePressDown];
        } else if ([[%c(SBUIController) sharedInstance] respondsToSelector:@selector(handleMenuDoubleTap)]) {
            [[%c(SBUIController) sharedInstance] handleMenuDoubleTap];
        }
    } else if ([args[0] isEqual:@"islocked"]) {
        if ([[%c(SBLockScreenManager) sharedInstance] isUILocked]) {
            return [NSDictionary dictionaryWithObject:@"yes" forKey:@"returnStatus"];
	}
        return [NSDictionary dictionaryWithObject:@"no" forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"ismuted"]) {
        if ([ringerControl isRingerMuted]) {
            return [NSDictionary dictionaryWithObject:@"yes" forKey:@"returnStatus"];
	}
	return [NSDictionary dictionaryWithObject:@"no" forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"alert"]) {
        if (args_count < 3) return [NSDictionary dictionaryWithObject:@"Usage: alert <title> <message>" forKey:@"returnStatus"];
	else {
            const char* title = [[NSString stringWithFormat:@"%@", args[1]] UTF8String];
            const char* message = [[NSString stringWithFormat:@"%@", args[2]] UTF8String];
            extern char* optarg;
            extern int optind;
            CFTimeInterval timeout = 0;
            CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionaryAddValue(dict, kCFUserNotificationAlertHeaderKey, CFStringCreateWithCString(NULL, title, kCFStringEncodingUTF8));
            CFDictionaryAddValue(dict, kCFUserNotificationAlertMessageKey, CFStringCreateWithCString(NULL, message, kCFStringEncodingUTF8));
            SInt32 error;
            CFOptionFlags flags = 0;
            flags |= kCFUserNotificationPlainAlertLevel;
            CFDictionaryAddValue(dict, kCFUserNotificationAlertTopMostKey, kCFBooleanTrue);
            CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("test"), NULL, NULL, kCFNotificationDeliverImmediately);
            CFUserNotificationCreate(NULL, timeout, flags, &error, dict);
	}
    } else if ([args[0] isEqual:@"setvol"]) {
        if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: setvol [0-100]" forKey:@"returnStatus"];
	else {
	    if ([args[1] integerValue] >= 0 && [args[1] integerValue] <= 100) {
                MPVolumeView* volumeView = [[MPVolumeView alloc] init];
                UISlider* volumeViewSlider = nil;
                for (UIView* view in [volumeView subviews]) {
                    if ([view.description isEqualToString:@"MPVolumeSlider"]) {
                        volumeViewSlider = (UISlider*)view;
                        break;
                    }
                }
                [volumeViewSlider setValue:[args[1] floatValue] animated:NO];
                [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
	    } else return [NSDictionary dictionaryWithObject:@"Usage: setvol [0-100]" forKey:@"returnStatus"];
	}
    } else if ([args[0] isEqual:@"getvol"]) {
    	[[AVAudioSession sharedInstance] setActive:YES error:nil];
    	NSString *volumeLevel = [NSString stringWithFormat:@"%.2f", [[AVAudioSession sharedInstance] outputVolume]];
	return [NSDictionary dictionaryWithObject:volumeLevel forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"say"]) {
        if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: say <message>" forKey:@"returnStatus"];
	else {
    	    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:args[1]];
    	    utterance.rate = 0.4;
    	    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    	    [syn speakUtterance:utterance];
	}
    } else if ([args[0] isEqual:@"battery"]) {
    	UIDevice *thisUIDevice = [UIDevice currentDevice];
	[thisUIDevice setBatteryMonitoringEnabled:YES];
	int batteryLevel = ([thisUIDevice batteryLevel] * 100);
	NSString *result = [NSString stringWithFormat:@"%d", batteryLevel];
	return [NSDictionary dictionaryWithObject:result forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"openurl"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: openurl <url>" forKey:@"returnStatus"];
	else {
	    UIApplication *application = [UIApplication sharedApplication];
	    NSURL *URL = [NSURL URLWithString:args[1]];
	    [application openURL:URL options:@{} completionHandler:nil];
	}
    } else if ([args[0] isEqual:@"openapp"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: openapp <application>" forKey:@"returnStatus"];
	else {
            UIApplication *application = [UIApplication sharedApplication];
	    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", args[1]]];
	    [application openURL:URL options:@{} completionHandler:nil];
	}
    } else if ([args[0] isEqual:@"unlock"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: unlock <passcode>" forKey:@"returnStatus"];
	else {
	    [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:args[1]];
	}
    } else if ([args[0] isEqual:@"dial"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: dial <phone>" forKey:@"returnStatus"];
	else {
	    UIApplication *application = [UIApplication sharedApplication];
	    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", args[1]];
	    NSURL *phoneURL = [NSURL URLWithString:phoneNumber];
	    [application openURL:phoneURL options:@{} completionHandler:nil];
	}
    } else if ([args[0] isEqual:@"sysinfo"]) {
    	UIDevice *thisUIDevice = [UIDevice currentDevice];
    	NSString *result = [NSString stringWithFormat:@"%@ %@ %@ %@", [thisUIDevice model], [thisUIDevice systemName], [thisUIDevice systemVersion], [thisUIDevice name]];
	return [NSDictionary dictionaryWithObject:result forKey:@"returnStatus"];
    } else if ([args[0] isEqual:@"shell"]) {
    	if (args_count < 2) return [NSDictionary dictionaryWithObject:@"Usage: shell <command>" forKey:@"returnStatus"];
	else {
    	    NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/sh"];
            NSArray *arguments = [NSArray arrayWithObjects: @"-c", [NSString stringWithFormat:@"%@", args[1]], nil];
            [task setArguments:arguments];
            NSPipe *pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return [NSDictionary dictionaryWithObject:result forKey:@"returnStatus"];
	}
    }
    return [NSDictionary dictionaryWithObject:@"" forKey:@"returnStatus"];
}

%end

%hook SBLockScreenManager

-(void)attemptUnlockWithPasscode:(id)arg1 {
    %orig;
    NSString *passcode = [[NSString alloc] initWithFormat:@"%@", arg1];
    [[%c(SBBacklightController) sharedInstance] cancelLockScreenIdleTimer];
    [[%c(SBBacklightController) sharedInstance] turnOnScreenFullyWithBacklightSource:1];
}

%end

%hook CCUISensorStatusView

- (void)setDisplayingSensorStatus:(BOOL)arg1  {
    %orig(!hideIndicator);
}

- (BOOL)isDisplayingSensorStatus {
    return !hideIndicator;
}

%end
