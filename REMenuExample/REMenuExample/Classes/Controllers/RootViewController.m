//
//  RootViewController.m
//  REMenuExample
//
//  Created by Roman Efimov on 2/20/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "RootViewController.h"
#import "REMenu.h"

@interface RootViewController ()
  @property (strong, readwrite, nonatomic) REMenu *leftMenu;
  @property (strong, readwrite, nonatomic) REMenu *rightMenu;
@end
@implementation RootViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Home";
  self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleLeftMenu)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleRightMenu)];
  
  UIImageView *imageView     = [[UIImageView alloc] initWithFrame:self.view.bounds];
  imageView.image            = [UIImage imageNamed:@"Balloon"];
  imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  imageView.contentMode      = UIViewContentModeScaleAspectFill;
  [self.view addSubview:imageView];
  
  self.leftMenu = ({
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainMenu"];
    REMenu *leftMenu                 = [[REMenu alloc] initWithViewController:viewController menuHeight:5*44]; // 3 items, 44 pixels height each
    
    [leftMenu setClosePreparationBlock:^{
      NSLog(@"Menu will close");
    }];
    
    [leftMenu setCloseCompletionHandler:^{
      NSLog(@"Menu did close");
    }];
    leftMenu;
  });
  
  self.rightMenu = ({
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"TestMenu"];
    REMenu *rightMenu                = [[REMenu alloc] initWithViewController:viewController menuHeight:3*44]; // 3 lines, 44 pixels height each
    
    [rightMenu setClosePreparationBlock:^{
      NSLog(@"Menu will close");
    }];
    
    [rightMenu setCloseCompletionHandler:^{
      NSLog(@"Menu did close");
    }];
    rightMenu;
  });
}

- (void)toggleLeftMenu
{
  if (self.leftMenu.isOpen) {
    return [self.leftMenu close];
  }

  if (self.rightMenu.isOpen) {
    [self.rightMenu close];
  }

  [self.leftMenu showFromNavigationController:self.navigationController];
}

- (void)toggleRightMenu
{
  if (self.rightMenu.isOpen) {
    return [self.rightMenu close];
  }
  
  if (self.leftMenu.isOpen) {
    [self.leftMenu close];
  }
  [self.rightMenu showFromNavigationController:self.navigationController];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  // [self.menu setNeedsLayout]; needed?
}

@end
