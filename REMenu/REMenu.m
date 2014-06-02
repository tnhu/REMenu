//
// REMenu.m
// REMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REMenu.h"

@interface REMenu ()
  @property (strong, readwrite, nonatomic) UIView              *backgroundView;
  @property (strong, readwrite, nonatomic) UIView              *tabbarBackgroundView;
  @property (strong, readwrite, nonatomic) UIViewController    *topViewController;
  @property (strong, readwrite, nonatomic) UIView              *menuView;
  @property (strong, readwrite, nonatomic) UIView              *menuWrapperView;
  @property (strong, readwrite, nonatomic) UIView              *containerView;
  @property (strong, readwrite, nonatomic) UIButton            *backgroundButton;
  @property (assign, readwrite, nonatomic) BOOL                isOpen;
  @property (assign, readwrite, nonatomic) BOOL                isAnimating;
  @property (weak,   readwrite, nonatomic) UINavigationBar     *navigationBar;

  @property (strong, nonatomic) UIViewController               *viewController;
  @property (nonatomic) NSInteger                               height;
@end
@implementation REMenu

- (id)initWithViewController:(UIViewController*)viewController menuHeight:(NSInteger)height
{
  self                = [self init];
  self.viewController = viewController;
  self.height         = height;
  return self;
}

- (id)init
{
  self = [super init];
  if (self) {
    _animationDuration          = 0.3;
    _bounce                     = NO;
    _bounceAnimationDuration    = 0.2;
    _appearsBehindNavigationBar = YES;
  }
  return self;
}

+ (UIViewController*)topViewController:(UIViewController*)viewController
{
  return [REMenu topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
  if ([rootViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)rootViewController;
    return [REMenu topViewControllerWithRootViewController:tabBarController.selectedViewController];
  } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController* navigationController = (UINavigationController*)rootViewController;
    return [REMenu topViewControllerWithRootViewController:navigationController.visibleViewController];
  } else if (rootViewController.presentedViewController) {
    UIViewController* presentedViewController = rootViewController.presentedViewController;
    return [REMenu topViewControllerWithRootViewController:presentedViewController];
  } else {
    return rootViewController;
  }
}

- (void)selectorCloseMenu:(NSNotification*)notification
{
  void (^completion)(void) = notification.object;
  
  [self closeWithCompletion:completion];
}

- (void)showFromRect:(CGRect)rect inView:(UIView*)view
{
  if (self.isAnimating) {
    return;
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectorCloseMenu:) name:kCloseSlidedownMenuWithCompletion object:nil];
  
  self.isOpen      = YES;
  self.isAnimating = YES;
  
  self.containerView = ({
    UIView *view                         = [[UIView alloc] init];
    view.clipsToBounds                   = YES;
    view.autoresizingMask                = UIViewAutoresizingFlexibleWidth;

    self.backgroundView                  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor  = [UIColor colorWithWhite:0.000 alpha:0.600];
    self.backgroundView.alpha            = 0;
    
    [view addSubview:self.backgroundView];
    
    view;
  });
  
  self.tabbarBackgroundView = ({
    UIButton *view          = [[UIButton alloc] initWithFrame:self.topViewController.tabBarController.tabBar.bounds];
    view.backgroundColor    = [UIColor colorWithWhite:0.000 alpha:0.600];
    view.alpha              = 0;
    [view addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    view.accessibilityLabel = NSLocalizedString(@"Menu background", nil);
    view.accessibilityHint  = NSLocalizedString(@"Tap to close", nil);
    
    [self.topViewController.tabBarController.tabBar addSubview:view];  // the trick is to add this view on top of tabbar    
    view;
  });
  
  self.menuWrapperView = ({
    UIView *view                  = [[UIView alloc] init];
    view.autoresizingMask         = UIViewAutoresizingFlexibleWidth;
    view.layer.shouldRasterize    = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    view;
  });
    
  self.backgroundButton = ({
    UIButton *button          = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask   = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.accessibilityLabel = NSLocalizedString(@"Menu background", nil);
    button.accessibilityHint  = NSLocalizedString(@"Tap to close", nil);
    [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    button;
  });
    
  CGFloat navigationBarOffset = self.appearsBehindNavigationBar && self.navigationBar ? 64 : 0;
  NSInteger statusBarHeight   = 40;
  
  self.menuView = ({
    UIView *view                  = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.height + navigationBarOffset + statusBarHeight)];
    view.backgroundColor          = [UIColor clearColor];
    view.layer.masksToBounds      = YES;
    view.layer.shouldRasterize    = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    view.autoresizingMask         = UIViewAutoresizingFlexibleWidth;
    view;
  });
  
  self.menuWrapperView.frame = CGRectMake(0, -self.height - navigationBarOffset, rect.size.width, self.height + navigationBarOffset);
  self.containerView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
  self.backgroundButton.frame = self.containerView.bounds;
  
  self.viewController.view.frame =  CGRectMake(0, navigationBarOffset + statusBarHeight, rect.size.width, self.height);
  [self.menuView addSubview:self.viewController.view];
  
  [self.menuWrapperView addSubview:self.menuView];
  [self.containerView   addSubview:self.backgroundButton];
  [self.containerView   addSubview:self.menuWrapperView];
  [view addSubview:self.containerView];
  
  // Animate appearance
  if (self.bounce) {
    self.isAnimating = YES;
    if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
      [UIView animateWithDuration:self.animationDuration+self.bounceAnimationDuration
                            delay:0.0
           usingSpringWithDamping:0.6
            initialSpringVelocity:4.0
                          options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         self.backgroundView.alpha       = 1.0;
                         self.tabbarBackgroundView.alpha = 1.0;
                         CGRect frame                    = self.menuView.frame;
                         frame.origin.y                  = -statusBarHeight;
                         self.menuWrapperView.frame      = frame;
                       } completion:^(BOOL finished) {
                         self.isAnimating = NO;
                       }];
    } else {
      [UIView animateWithDuration:self.animationDuration
                            delay:0.0
                          options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         self.backgroundView.alpha       = 1.0;
                         self.tabbarBackgroundView.alpha = 1.0;
                         CGRect frame                    = self.menuView.frame;
                         frame.origin.y                  = -statusBarHeight;
                         self.menuWrapperView.frame      = frame;
       } completion:^(BOOL finished) {
           self.isAnimating = NO;
       }];
    }
  } else {
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.backgroundView.alpha       = 1.0;
                       self.tabbarBackgroundView.alpha = 1.0;
                       CGRect frame                    = self.menuView.frame;
                       frame.origin.y                  = -statusBarHeight;
                       self.menuWrapperView.frame      = frame;
      } completion:^(BOOL finished) {
        self.isAnimating = NO;
      }];
  }
}

- (void)showInView:(UIView*)view
{
  [self showFromRect:view.bounds inView:view];
}

- (void)showFromNavigationController:(UINavigationController*)navigationController
{
  if (self.isAnimating) {
    return;
  }
  
  self.navigationBar     = navigationController.navigationBar;
  self.topViewController = [REMenu topViewController:[navigationController.viewControllers lastObject]];
  
  [self showFromRect:CGRectMake(0, 0, navigationController.navigationBar.frame.size.width, navigationController.view.frame.size.height) inView:navigationController.view];

  if (self.appearsBehindNavigationBar) {
    [navigationController.view bringSubviewToFront:navigationController.navigationBar];
  }
}

- (void)closeWithCompletion:(void(^)(void))completion
{
  if (self.isAnimating) {
    return;
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  self.isAnimating = YES;
  
  CGFloat navigationBarOffset = self.appearsBehindNavigationBar && self.navigationBar ? 64 : 0;
  
  void (^closeMenu)(void) = ^{
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                       CGRect frame                    = self.menuView.frame;
                       frame.origin.y                  = -self.height - navigationBarOffset;
                       self.menuWrapperView.frame      = frame;
                       self.backgroundView.alpha       = 0;
                       self.tabbarBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
      self.isOpen      = NO;
      self.isAnimating = NO;

      [self.menuView              removeFromSuperview];
      [self.menuWrapperView       removeFromSuperview];
      [self.backgroundButton      removeFromSuperview];
      [self.backgroundView        removeFromSuperview];
      [self.containerView         removeFromSuperview];
      [self.tabbarBackgroundView  removeFromSuperview];
      
      if (completion) {
        completion();
      }
      
      if (self.closeCompletionHandler) {
        self.closeCompletionHandler();
      }
    }];
  };
  
  if (self.closePreparationBlock) {
    self.closePreparationBlock();
  }
  
  if (self.bounce) {
    [UIView animateWithDuration:self.bounceAnimationDuration animations:^{
      CGRect frame               = self.menuView.frame;
      frame.origin.y             = -20.0;
      self.menuWrapperView.frame = frame;
    } completion:^(BOOL finished) {
      closeMenu();
    }];
  } else {
    closeMenu();
  }
}

- (void)close
{
  [self closeWithCompletion:nil];
}

- (void)setNeedsLayout
{
  [UIView animateWithDuration:0.35 animations:^{
    [self.containerView layoutSubviews];
  }];
}

@end