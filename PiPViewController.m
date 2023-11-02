#import "PiPViewController.h"
#include <RemoteLog.h>

@implementation PiPViewController

- (instancetype)initWithControlsViewController:(PGPictureInPictureControlsViewController *)controlsViewController {
    self = [super init];
    if (self) {
        self.controlsViewController = controlsViewController;

        MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPlayingChanged) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

        NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/14PiP.bundle"];

        self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.exitButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"xmark" ofType:@"png"]] forState:UIControlStateNormal];
        self.exitButton.alpha = 0.7;
        self.exitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.exitButton addTarget:controlsViewController action:@selector(_cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.returnToFullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.returnToFullscreenButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"pip.exit" ofType:@"png"]] forState:UIControlStateNormal];
        self.returnToFullscreenButton.alpha = 0.7;
        self.returnToFullscreenButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.returnToFullscreenButton addTarget:controlsViewController action:@selector(_stopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.leftSeekButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftSeekButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"gobackward.15" ofType:@"png"]] forState:UIControlStateNormal];
        self.leftSeekButton.alpha = 0.95;
        self.leftSeekButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.leftSeekButton addTarget:self action:@selector(goBack15:) forControlEvents:UIControlEventTouchUpInside];

        self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playPauseButton.alpha = 0.95;
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying){
            if (!isPlaying) {
                [self.playPauseButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"play.fill" ofType:@"png"]] forState:UIControlStateNormal];
            } else {
                [self.playPauseButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"pause.fill" ofType:@"png"]] forState:UIControlStateNormal];
            }
        });
        self.playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.playPauseButton addTarget:controlsViewController action:@selector(_actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.rightSeekButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightSeekButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"goforward.15" ofType:@"png"]] forState:UIControlStateNormal];
        self.rightSeekButton.alpha = 0.95;
        self.rightSeekButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightSeekButton addTarget:self action:@selector(goForward15:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view = containerView;

    //Oh god this is awful. I literally copied how the properties were on iOS 14's PGGradientView's CAGradientLayer. There is most defintely a better way to do this, but hey this works. All the random decimals cause me physical pain
    self.gradientView = [[UIView alloc] init];
    CAGradientLayer *layer = [CAGradientLayer layer];
    CGColorRef color = UIColor.blackColor.CGColor;
    layer.colors = @[(__bridge id)CGColorCreateCopyWithAlpha(color, 0.00196), (__bridge id)CGColorCreateCopyWithAlpha(color, .00719), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.0221), (__bridge id)CGColorCreateCopyWithAlpha(color, .0364), (__bridge id)CGColorCreateCopyWithAlpha(color, .0574), (__bridge id)CGColorCreateCopyWithAlpha(color, .0866), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.125), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.173), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.229), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.353), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.411), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.459), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.476), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.489), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.497), (__bridge id)CGColorCreateCopyWithAlpha(color, 0.5)];
    layer.locations = @[@0, @0.125, @0.25, @0.3125, @0.375, @0.4375, @0.5, @0.5625, @0.625, @0.75, @0.8125, @0.875, @0.90625, @0.9735, @0.96875, @1];
    layer.startPoint = CGPointMake(0.5, 0);
    layer.endPoint = CGPointMake(0.5, 1);
    layer.type = @"axial";
    [self.gradientView.layer addSublayer:layer];
    [self.view addSubview:self.gradientView];
    self.gradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.gradientView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.gradientView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.gradientView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.gradientView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    UIVisualEffectView *exitBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    exitBlurView.translatesAutoresizingMaskIntoConstraints = NO;
    exitBlurView.layer.continuousCorners = YES;
    exitBlurView.layer.cornerRadius = 6;
    exitBlurView.clipsToBounds = YES;

    [self.view addSubview:exitBlurView];
    [self.view addSubview:self.exitButton];

    // ratio = 1.28
    [self.exitButton.widthAnchor constraintEqualToConstant:28.16].active = YES;
    [self.exitButton.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.exitButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5].active = YES;
    [self.exitButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:5].active = YES;

    [exitBlurView.widthAnchor constraintEqualToAnchor:self.exitButton.widthAnchor].active = YES;
    [exitBlurView.heightAnchor constraintEqualToAnchor:self.exitButton.heightAnchor].active = YES;
    [exitBlurView.leadingAnchor constraintEqualToAnchor:self.exitButton.leadingAnchor].active = YES;
    [exitBlurView.topAnchor constraintEqualToAnchor:self.exitButton.topAnchor].active = YES;

    UIVisualEffectView *returnToFullscreenBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    returnToFullscreenBlurView.translatesAutoresizingMaskIntoConstraints = NO;
    returnToFullscreenBlurView.frame = self.returnToFullscreenButton.frame;
    returnToFullscreenBlurView.layer.continuousCorners = YES;
    returnToFullscreenBlurView.layer.cornerRadius = 6;
    returnToFullscreenBlurView.clipsToBounds = YES;

    [self.view addSubview:returnToFullscreenBlurView];
    [self.view addSubview:self.returnToFullscreenButton];

    // ratio = 1.28
    [self.returnToFullscreenButton.widthAnchor constraintEqualToConstant:28.16].active = YES;
    [self.returnToFullscreenButton.heightAnchor constraintEqualToConstant:22].active = YES;
    [self.returnToFullscreenButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-5].active = YES;
    [self.returnToFullscreenButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:5].active = YES;

    [returnToFullscreenBlurView.widthAnchor constraintEqualToAnchor:self.returnToFullscreenButton.widthAnchor].active = YES;
    [returnToFullscreenBlurView.heightAnchor constraintEqualToAnchor:self.returnToFullscreenButton.heightAnchor].active = YES;
    [returnToFullscreenBlurView.leadingAnchor constraintEqualToAnchor:self.returnToFullscreenButton.leadingAnchor].active = YES;
    [returnToFullscreenBlurView.topAnchor constraintEqualToAnchor:self.returnToFullscreenButton.topAnchor].active = YES;

    self.transportControlsView = [[UIView alloc] init];
    self.transportControlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.transportControlsView];

    [self.transportControlsView addSubview:self.leftSeekButton];
    [self.transportControlsView addSubview:self.playPauseButton];
    [self.transportControlsView addSubview:self.rightSeekButton];

    [self.transportControlsView.widthAnchor constraintEqualToConstant:144].active = YES;
    [self.transportControlsView.heightAnchor constraintEqualToConstant:48].active = YES;
    [self.transportControlsView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.transportControlsView.topAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-61].active = YES;

    [self.leftSeekButton.widthAnchor constraintEqualToConstant:48].active = YES;
    [self.leftSeekButton.heightAnchor constraintEqualToConstant:48].active = YES;
    [self.leftSeekButton.leadingAnchor constraintEqualToAnchor:self.transportControlsView.leadingAnchor].active = YES;

    [self.playPauseButton.widthAnchor constraintEqualToConstant:48].active = YES;
    [self.playPauseButton.heightAnchor constraintEqualToConstant:48].active = YES;
    [self.playPauseButton.leadingAnchor constraintEqualToAnchor:self.leftSeekButton.trailingAnchor].active = YES;

    [self.rightSeekButton.widthAnchor constraintEqualToConstant:48].active = YES;
    [self.rightSeekButton.heightAnchor constraintEqualToConstant:48].active = YES;
    [self.rightSeekButton.leadingAnchor constraintEqualToAnchor:self.playPauseButton.trailingAnchor].active = YES;

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.gradientView.layer.sublayers[0].frame = self.gradientView.bounds;
}

- (void)goBack15:(UIButton *)sender {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *info = (__bridge NSDictionary*)information;
        CGFloat duration = [info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration] floatValue];
        PGPlaybackProgressIndicator *progressIndicator = [self.controlsViewController valueForKey:@"_playbackProgressIndicator"];
        CGFloat progressPercentage = [[progressIndicator valueForKey:@"_currentProgress"] floatValue];
        CGFloat currentVideoTime = duration * progressPercentage;
        MRMediaRemoteSetElapsedTime(currentVideoTime - 15);
    });
}

- (void)goForward15:(UIButton *)sender {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *info = (__bridge NSDictionary*)information;
        CGFloat duration = [info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration] floatValue];
        PGPlaybackProgressIndicator *progressIndicator = [self.controlsViewController valueForKey:@"_playbackProgressIndicator"];
        CGFloat progressPercentage = [[progressIndicator valueForKey:@"_currentProgress"] floatValue];
        CGFloat currentVideoTime = duration * progressPercentage;
        MRMediaRemoteSetElapsedTime(currentVideoTime + 15);
    });
}

- (void)isPlayingChanged {
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/14PiP.bundle"];

    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying){
        if (!isPlaying) {
            [self.playPauseButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"play.fill" ofType:@"png"]] forState:UIControlStateNormal];
        } else {
            [self.playPauseButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"pause.fill" ofType:@"png"]] forState:UIControlStateNormal];
        }
    });
}

@end