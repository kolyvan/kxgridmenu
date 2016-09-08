//
//  KxGridMenu.h
//  https://github.com/kolyvan/kxgridmenu
//
//  Created by Kolyvan on 22.04.15.
//  Copyright (c) 2015 Konstantin Bukreev. All rights reserved.
//

/*
 Copyright (c) 2015 Konstantin Bukreev All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KxGridMenuStyle) {
    
    KxGridMenuStyleAutomatic,
    KxGridMenuStyleFullscreen,
    KxGridMenuStylePopoverSystem,
    KxGridMenuStylePopoverCustom,
};

@class KxGridMenuItem;

typedef void(^KxGridMenuItemAction)(KxGridMenuItem * __nonnull item);


@interface KxGridMenuItem :NSObject
@property (readonly, nonatomic, strong, nonnull)  NSString *title;
@property (readonly, nonatomic, strong, nullable) UIImage *image;
@property (readonly, nonatomic, copy, nonnull) KxGridMenuItemAction action;
@property (readonly, nonatomic) NSUInteger tag;

+ (nullable instancetype) gridMenuItemWithTitle:(nonnull NSString *)title
                                          image:(nullable UIImage *)image
                                         action:(nonnull KxGridMenuItemAction)action;

- (nullable instancetype) initWithTitle:(nonnull NSString *)title
                                  image:(nullable UIImage *)image
                                 action:(nonnull KxGridMenuItemAction)action;

@end


@interface KxGridMenu : UIViewController

@property (readwrite, nonatomic, strong, nonnull) NSArray *items;
@property (readwrite, nonatomic, strong, nullable) NSString *headline;
@property (readwrite, nonatomic) UIBlurEffectStyle blurEffectStyle;
@property (readwrite, nonatomic, strong, nullable) UIColor *foreColor;
@property (readwrite, nonatomic, strong, nullable) UIFont *itemFont;
@property (readwrite, nonatomic, strong, nullable) UIFont *headlineFont;
@property (readwrite, nonatomic) BOOL panGestureEnabled; // only for iphone
@property (readwrite, nonatomic) BOOL pageControlOn;
@property (readwrite, nonatomic, copy, nullable) void(^didDisappearBlock)();

+ (nullable instancetype) gridMenuWithItems:(nonnull NSArray *)items;

- (nullable instancetype) initWithItems:(nonnull NSArray *)items;

- (void) presentFromViewController:(nonnull UIViewController *)controller;

- (void) presentFromViewController:(nonnull UIViewController *)controller
                             style:(KxGridMenuStyle)style
                     barButtonItem:(nullable UIBarButtonItem *)barButtonItem
                          animated:(BOOL)animated
                        completion:(nullable void (^)(void))completion __attribute__((deprecated));

- (void) presentFromViewController:(nonnull UIViewController *)controller
                             style:(KxGridMenuStyle)style
                              from:(nullable id)from
                          animated:(BOOL)animated
                        completion:(nullable void (^)(void))completion;

@end
