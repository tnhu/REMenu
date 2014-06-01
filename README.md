# REMenu

Custom version of [REMenu](https://github.com/romaonthego) focusing on custom UIView. This modification supports:
* Custom menu height
* Scrollable menu content

<img src="https://github.com/tnhu/REMenu/raw/master/Demo.gif" alt="REMenu Screenshot" width="320" height="568" />

## Requirements
* Xcode 5 or higher
* Apple LLVM compiler
* iOS 6.0 or higher
* ARC

## Demo

Build and run the `REMenuExample` project in Xcode to see `REMenu` in action.

## Installation

### Manual Install

All you need to do is drop `REMenu.h` and `REMenu.m` files into your project, and add `#include "REMenu.h"` to the top of classes that will use it.

## Example Usage

Assuming you have a custom UIViewController named MainMenu in your Storyboard. In your UIViewController class

``` objective-c
@interface YOURViewController ()
  @property (strong, readwrite, nonatomic) REMenu *leftMenu;
@end
@implementation YOURViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.leftMenu = ({
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainMenu"];
    REMenu *leftMenu                 = [[REMenu alloc] initWithViewController:viewController menuHeight:5*44]; // 5 rows, 44 pixels each

    leftMenu;
  });
}
```

Which toggleLeftMenu implemented as:

``` objective-c
- (void)toggleLeftMenu
{
  if (self.leftMenu.isOpen) {
    return [self.leftMenu close];
  }

  [self.leftMenu showFromNavigationController:self.navigationController];
}
```

## Customization

You can customize the following properties of `REMenu`:

``` objective-c
@property (assign, readwrite, nonatomic) NSTimeInterval  animationDuration;
@property (assign, readwrite, nonatomic) NSTimeInterval  bounceAnimationDuration;
@property (assign, readwrite, nonatomic) BOOL            appearsBehindNavigationBar;
@property (assign, readwrite, nonatomic) BOOL            bounce;
```

## TODO
* Interaction between the view owns the menu and the menu view itself

## License

REMenu is available under the MIT license.

Copyright © 2013 Roman Efimov.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
