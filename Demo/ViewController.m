//
//  ViewController.m
//  Demo
//
//  Created by Kolyvan on 22.04.15.
//  Copyright (c) 2015 Konstantin Bukreev. All rights reserved.
//

#import "ViewController.h"
#import "KxGridMenu.h"

@interface ViewController()
@end

@implementation ViewController

- (id) init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void) loadView
{
    const CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = ({
        UIView *v = [[UIImageView alloc] initWithFrame:frame];
        v.backgroundColor = [UIColor whiteColor];
        v.opaque = YES;
        v;
    });
    
    UIImageView *backView = ({
        UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        v.frame = self.view.bounds;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        v.contentMode = UIViewContentModeScaleAspectFill;
        v;
    });
    
    [self.view addSubview:backView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(actionMenu:)];
}

- (void) actionMenu:(id)sender
{
    KxGridMenuItemAction action = ^(KxGridMenuItem *item) {
        NSLog(@"tapped: %@", item.title);
    };
    
    NSArray *items = @[
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Digg"
                                                       image:[UIImage imageNamed:@"digg"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Google"
                                                       image:[UIImage imageNamed:@"google"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Pinterest"
                                                       image:[UIImage imageNamed:@"pinterest"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Reddit"
                                                       image:[UIImage imageNamed:@"reddit"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Tumbrl"
                                                       image:[UIImage imageNamed:@"tumbrl"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Twitter"
                                                       image:[UIImage imageNamed:@"twitter"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Vimeo"
                                                       image:[UIImage imageNamed:@"vimeo"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"VK.com"
                                                       image:[UIImage imageNamed:@"vk"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Youtube"
                                                       image:[UIImage imageNamed:@"youtube"]
                                                      action:action],
                       
#if 0
                       [KxGridMenuItem gridMenuItemWithTitle:@"Twitter #"
                                                       image:[UIImage imageNamed:@"twitter"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Vimeo #"
                                                       image:[UIImage imageNamed:@"vimeo"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"VK.com #"
                                                       image:[UIImage imageNamed:@"vk"]
                                                      action:action],
                       
                       [KxGridMenuItem gridMenuItemWithTitle:@"Youtube #"
                                                       image:[UIImage imageNamed:@"youtube"]
                                                      action:action],
#endif
                       ];
    
    KxGridMenu *gridMenu = [KxGridMenu new];
    gridMenu.items = items;
    gridMenu.headline = @"The preferred network service.\nPlease select.";
    gridMenu.itemFont = [UIFont systemFontOfSize:15.f weight:UIFontWeightLight];
    gridMenu.foreColor = [UIColor colorWithWhite:0.15 alpha:1];
    //gridMenu.foreColor = [UIColor colorWithWhite:0.85 alpha:1];
    //gridMenu.blurEffectStyle = UIBlurEffectStyleDark;
    gridMenu.panGestureEnabled = YES;
    
    [gridMenu presentFromViewController:self
                                  style:KxGridMenuStyleAutomatic
                          barButtonItem:sender
                               animated:YES
                             completion:nil];
}

@end
