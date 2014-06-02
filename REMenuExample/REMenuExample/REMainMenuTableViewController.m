//
//  REMainMenuTableViewController.m
//  REMenuExample
//
//  Created by Tan Nhu on 6/1/14.
//  Copyright (c) 2014 Roman Efimov. All rights reserved.
//

#import "REMainMenuTableViewController.h"
#import "REMenu.h"

@interface REMainMenuTableViewController () <UITableViewDelegate>
@end
@implementation REMainMenuTableViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
  
  // deselect row
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  // hide menu
  [[NSNotificationCenter defaultCenter] postNotificationName:kCloseSlidedownMenuWithCompletion object:^(void) {
    NSLog(@"Do something when menu finishes closing...");
  }];
  
  NSLog(@"Row selected at section: %d, index: %d, tag: %d", indexPath.section, indexPath.row, cell.tag);
}

@end
