#import <UIKit/UIKit.h>
#import "MediaRemote.h"

@interface CALayer (iOS12)
@property (assign) BOOL continuousCorners;
@end

@interface PGPlaybackProgressIndicator : UIView
@end

@interface PGPictureInPictureControlsViewController : UIViewController
@property (nonatomic) BOOL didAdded;
- (void)_stopButtonTapped:(UIButton *)arg1;
- (void)_actionButtonTapped:(UIButton *)arg1;
- (void)_cancelButtonTapped:(UIButton *)arg1;
@end

@interface PiPViewController : UIViewController
@property (strong, nonatomic) UIView *gradientView;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *leftSeekButton;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UIButton *rightSeekButton;
@property (strong, nonatomic) UIView *transportControlsView;
@property (strong, nonatomic) UIButton *returnToFullscreenButton;
@property (strong, nonatomic) PGPictureInPictureControlsViewController *controlsViewController;
- (instancetype)initWithControlsViewController:(PGPictureInPictureControlsViewController *)controlsViewController;
@end