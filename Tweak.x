#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <RemoteLog.h>
#import "PiPViewController.h"

BOOL enabled;
PiPViewController *newControlsViewController = nil;

%hook PGPictureInPictureControlsViewController

%property (nonatomic) BOOL didAdded;

- (void)_manageControlsSize {
    %orig;
    PGPlaybackProgressIndicator *progressIndicator = [self valueForKey:@"_playbackProgressIndicator"];
    progressIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    progressIndicator.frame = CGRectMake(8, self.view.frame.size.height - 10, self.view.frame.size.width - 16, 3);
    progressIndicator.subviews[0].layer.cornerRadius = 2;

    UIButton *stopButton = [self valueForKey:@"_stopButton"];
    UIButton *actionButton = [self valueForKey:@"_actionButton"];
    UIButton *cancelButton = [self valueForKey:@"_cancelButton"];
    stopButton.hidden = YES;
    actionButton.hidden = YES;
    cancelButton.hidden = YES;

    if (self.didAdded == 1) return;

    newControlsViewController = [[PiPViewController alloc] initWithControlsViewController:self];
    [self addChildViewController:newControlsViewController];
    [self.view addSubview:newControlsViewController.view];

    UIView *view = newControlsViewController.view;
    [view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [view.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    self.didAdded = 1;
}

- (void)_updateControlsVisibility {
    %orig;
    BOOL hidden = ![[self valueForKey:@"_showsControls"] boolValue];
    [UIView animateWithDuration:0.2 animations: ^{
        //the hidden property can't be animated, so I have to use alpha
        newControlsViewController.view.alpha = !hidden;
    }];
}

%end

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.galacticdev.14pipprefs.plist"];
    enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
}

%ctor {
    loadPrefs();
    if (enabled) %init;
}