//
//  KxGridMenu.m
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

#import "KxGridMenu.h"

@interface KxGridMenuCollLayout : UICollectionViewLayout
@property (readwrite, nonatomic) CGFloat lineSpacing;
@property (readwrite, nonatomic) CGFloat interitemSpacing;
@property (readwrite, nonatomic) CGSize itemSize;
@property (readwrite, nonatomic) UIEdgeInsets sectionInset;
@end

//////////

@interface KxGridMenuCell : UICollectionViewCell
@property (readonly, nonatomic, strong) UILabel *titleLabel;
@property (readonly, nonatomic, strong) UIImageView *imageView;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic, strong) UIColor *selectedColor;
@property (readwrite, nonatomic) UIBlurEffectStyle blurEffectStyle;
@end

//////////

@interface KxGridMenuPopoverBackView : UIPopoverBackgroundView
@end

//////////

@interface KxGridMenu() <UICollectionViewDelegate, UICollectionViewDataSource,UIPopoverPresentationControllerDelegate>
@property (readonly, nonatomic, strong) UICollectionView *collView;
@property (readonly, nonatomic, strong) UILabel *headlineLabel;
@end

@implementation KxGridMenu {
    UITapGestureRecognizer  *_tapGesture;
    UIPanGestureRecognizer  *_panGesture;
    UIColor                 *_selectedColor;
    CGRect                  _panFrame;
}

+ (instancetype) gridMenuWithItems:(NSArray *)items
{
    return [[self alloc] initWithItems:items];
}

- (instancetype) initWithItems:(NSArray *)items
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _items = items;
        _blurEffectStyle = UIBlurEffectStyleLight;
    }
    return self;
}

- (void) loadView
{
    const CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = ({
        
        UIView *v = [[UIView alloc] initWithFrame:frame];
        v.backgroundColor = [UIColor clearColor];
        v;
    });
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:_blurEffectStyle];
    UIVisualEffectView *backView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    backView.frame = frame;
    backView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backView];
    
    const CGSize size = frame.size;
    CGFloat Y = 0;
    
    if (_headline) {
        
        _headlineLabel = ({
            
            const CGRect frame = {0, 0, size.width, 40.f};
            UILabel *v = [[UILabel alloc] initWithFrame:frame];
            v.opaque = NO;
            v.numberOfLines = 2;
            v.backgroundColor = [UIColor clearColor];
            v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            v.textAlignment = NSTextAlignmentCenter;
            v.font = self.headlineFont ?: self.defaultHeadlineFont;
            v.textColor = self.foreColor ?: self.defaultColor;
            v.text = _headline;
            v;
        });
        
        [backView.contentView addSubview:_headlineLabel];
        
        Y = CGRectGetMaxY(_headlineLabel.frame);
    }
    
    _collView = ({

        UICollectionViewLayout *layout = [KxGridMenuCollLayout new];
        
        const CGRect frame = {0, Y, size.width, size.height - Y};
        UICollectionView *v = [[UICollectionView alloc] initWithFrame:frame
                                                 collectionViewLayout:layout];
        v.delegate = self;
        v.dataSource = self;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        v.backgroundColor = [UIColor clearColor];
        v.opaque = NO;
        
        v.backgroundView = [[UIView alloc] initWithFrame:frame];
        v.backgroundView.backgroundColor = [UIColor clearColor];
        
        [v registerClass:[KxGridMenuCell class] forCellWithReuseIdentifier:@"Cell"];
        
        v;
    });
    
    [backView.contentView addSubview:_collView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [_collView.backgroundView addGestureRecognizer:_tapGesture];
    
    // force to create gesture recognizer if need
    self.panGestureEnabled = _panGestureEnabled;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return _blurEffectStyle == UIBlurEffectStyleDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    const CGSize contentSize = _collView.contentSize;
    if (contentSize.height) {
        const CGFloat D = _collView.frame.size.height - contentSize.height;
        if (D > 0) {
            _collView.contentInset = UIEdgeInsetsMake(D * .5, 0, 0, 0);
        }
    }
}

- (CGSize) preferredContentSize
{
    CGSize size = [super preferredContentSize];
    if (!size.width) {
        
        const CGFloat hHeadline = _headlineLabel ? _headlineLabel.bounds.size.height : 0;
        
        KxGridMenuCollLayout *layout = (KxGridMenuCollLayout *)_collView.collectionViewLayout;
        
        const BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
        const CGFloat maxWidth  = isLandscape ? 480 : 320;
        const CGFloat maxHeight = isLandscape ? 320 : 480;
        
        const NSUInteger maxCols = (maxWidth - layout.sectionInset.top - layout.sectionInset.bottom) / (layout.itemSize.width + layout.interitemSpacing);
        
        NSUInteger numCols, numRows;
        
        if (_items.count < maxCols) {
            
            numCols = _items.count;
            numRows = 1;
            
        } else {
            
            numCols = maxCols;
            numRows = (_items.count / numCols + ((_items.count % numCols) ? 1 : 0));
            
            if (numRows > 3) {
                numRows = 3;
            }
        }
        
        size.width = layout.sectionInset.left + layout.sectionInset.right + numCols * layout.itemSize.width + (numCols - 1) * layout.interitemSpacing + 20;
        size.height = layout.sectionInset.top + layout.sectionInset.bottom + numRows * layout.itemSize.height + (numRows - 1) * layout.lineSpacing + 20 + hHeadline;

        if (size.width > maxWidth) {
            size.width = maxWidth;
        }
        if (size.height > maxHeight) {
            size.height = maxHeight;
        }
        
        self.preferredContentSize = size;
    }

    return size;
}

#pragma mark - public

- (void) setPanGestureEnabled:(BOOL)panGestureEnabled
{
    _panGestureEnabled = panGestureEnabled;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (self.isViewLoaded) {
            
            if (_panGestureEnabled && !_panGesture) {
                
                _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPan:)];
                [self.view addGestureRecognizer:_panGesture];
                
            } else if (!_panGestureEnabled && _panGesture) {
                
                [self.view removeGestureRecognizer:_panGesture];
                _panGesture = nil;
            }
        }
    }
}

- (void) presentFromViewController:(UIViewController *)controller
{
    return[self presentFromViewController:controller
                                    style:KxGridMenuStyleAutomatic
                            barButtonItem:nil
                                 animated:YES
                               completion:nil];
}

- (void) presentFromViewController:(UIViewController *)controller
                             style:(KxGridMenuStyle)style
                     barButtonItem:(UIBarButtonItem *)barButtonItem
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion
{
    if (style == KxGridMenuStyleAutomatic) {
        
        if (controller.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            style = KxGridMenuStylePopoverCustom;
        } else {
            style = KxGridMenuStyleFullscreen;
        }
    }

    if (style == KxGridMenuStyleFullscreen) {
        
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        //self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
    } else {
    
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.preferredContentSize = CGSizeZero;
        
        UIPopoverPresentationController *popover = self.popoverPresentationController;
        popover.delegate = self;
        popover.sourceView = controller.view;
        popover.backgroundColor = [UIColor clearColor];
        
        if (barButtonItem &&
            controller.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            
            popover.barButtonItem = barButtonItem;
            
        } else {
        
            // at center
            const CGSize size = controller.view.bounds.size;
            popover.sourceRect = (CGRect) { roundf(size.width * 0.5f), roundf(size.height * 0.5f), 1, 1 };
            popover.permittedArrowDirections = 0;
            
            if (style == KxGridMenuStylePopoverCustom) {
                popover.popoverBackgroundViewClass = [KxGridMenuPopoverBackView class];
            }
        }
    }
    
    [controller presentViewController:self animated:animated completion:completion];
}

#pragma mark - private

- (UIColor *) defaultColor
{
    return _blurEffectStyle == UIBlurEffectStyleDark ? [UIColor whiteColor] : [UIColor darkTextColor];
}

- (UIFont *) defaultFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (UIFont *) defaultHeadlineFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (UIColor *) selectedColor
{
    if (!_selectedColor) {
        
        if (_foreColor) {
            
            // complementary color
            
            CGFloat h,s,b,a;
            if ([_foreColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
                
                if (b == 0) {
                    _selectedColor = [UIColor whiteColor];
                } else if (s == 0) {
                    _selectedColor = [UIColor colorWithHue:h saturation:0 brightness:1.f-b alpha:a];
                } else {
                    
                    CGFloat hue = h + 0.5f;
                    if (hue > 1.f) {
                        hue -= 1.f;
                    } else if (hue < 0.f) {
                        hue = -hue;
                    }
                    _selectedColor = [UIColor colorWithHue:hue saturation:s brightness:b alpha:a];
                }
                
            } else {
                // indicator of bad color
                _selectedColor = [UIColor redColor];
            }
            
        } else {
            _selectedColor = _blurEffectStyle == UIBlurEffectStyleDark ? [UIColor darkTextColor] : [UIColor whiteColor];
        }
    }
    
    return _selectedColor;
}

- (void) actionTap:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) actionPan:(UIPanGestureRecognizer *)gesture
{
    UIView *view = self.presentationController.containerView;
    //UIView *view = self.view;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _panFrame = view.frame;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        const CGFloat D = [gesture translationInView:view].y;
        if (D > 0) {
            if (D > 160.f) {
                
                gesture.enabled = NO;
                gesture.enabled = YES;
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                
                CGRect frame = _panFrame;
                frame.origin.y += D;
                view.frame = frame;
            }
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.25 animations:^{
            view.frame = _panFrame;
        }];
    }
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KxGridMenuItem *item = _items[indexPath.row];
    
    KxGridMenuCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                     forIndexPath:indexPath];
    

    cell.foreColor = self.foreColor ?: self.defaultColor;
    cell.selectedColor = self.selectedColor;
    cell.titleLabel.font = self.itemFont ?: self.defaultFont;
    cell.titleLabel.text = item.title;
    cell.imageView.image = item.image;
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    KxGridMenuItem *item = _items[indexPath.row];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^
    {
        [self dismissViewControllerAnimated:YES completion:^{
            item.action(item);
        }];
    });
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

@end

//////////

@implementation KxGridMenuCollLayout {
    NSArray *_layout;
}

- (id) init
{
    if ((self = [super init])) {
        
        _itemSize = (CGSize){80, 120};
        _interitemSpacing = 10;
        _lineSpacing = 10;
        _sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

- (void) prepareLayout
{
    NSMutableArray *layout = [NSMutableArray array];
    
    const CGSize collSize = self.collectionView.bounds.size;
    const UIEdgeInsets contentInset = self.collectionView.contentInset;
    const CGFloat W = collSize.width - _sectionInset.left - _sectionInset.right - contentInset.left - contentInset.right;
    const CGFloat H = collSize.height - _sectionInset.top - _sectionInset.bottom - contentInset.top - contentInset.bottom;

    const CGFloat wCol = _itemSize.width + _interitemSpacing;
    const NSUInteger colNum = wCol < W ? (W / wCol) : 1;
    const CGFloat wD = colNum > 1 ? roundf((W - (colNum * _itemSize.width)) / (colNum - 1)) : 0;

    CGFloat hRow = _itemSize.height + _lineSpacing;
    const NSUInteger rowNum = hRow < H ? (H / hRow) : 1;
    hRow = roundf(H / rowNum);
    
    CGFloat Y = _sectionInset.top;
    
    const NSInteger numSections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < numSections; ++section) {
    
        const NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        const NSUInteger colNum = numItems / rowNum + ((numItems % rowNum) ? 1 : 0);
        
        NSUInteger iCol = 0;
        
        NSMutableArray *layoutSection = [NSMutableArray arrayWithCapacity:numItems];
    
        for (NSInteger item = 0; item < numItems; ++item) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *atts;
            atts = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat X = _sectionInset.left;
            if (iCol) {
                X += (_itemSize.width + wD) * (CGFloat)iCol;
            }
            
            atts.frame = (CGRect){X, Y, _itemSize};
            
            if (++iCol == colNum) {
                iCol = 0;
                Y += hRow;
            }
            
            [layoutSection addObject:atts];
        }
        
        [layout addObject:[layoutSection copy]];
        
        Y += _sectionInset.bottom;
        Y += _sectionInset.top;
    }
    
    _layout = [layout copy];
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSArray *layoutSection in _layout) {
        for (UICollectionViewLayoutAttributes *atts in layoutSection) {
            if (CGRectIntersectsRect(rect, atts.frame)) {
                [result addObject:atts];
            }
        }
    }
    return result;
}

- (CGSize) collectionViewContentSize
{
    CGFloat H = 0;
    CGFloat W = 0;
    
    if (_layout.count) {
        
        for (NSArray *layoutSection in _layout) {
            for (UICollectionViewLayoutAttributes *atts in layoutSection) {
                W  = MAX(W, CGRectGetMaxX(atts.frame));
                H  = MAX(H, CGRectGetMaxY(atts.frame));
            }
        }
        
        if (W) W += _sectionInset.right;
        if (H) H += _sectionInset.bottom;
    }
    
    return (CGSize){W, H};
}

@end

//////////

@implementation KxGridMenuCell {

    UILabel     *_titleLabel;
    UIImageView *_imageView;
}

- (UIImageView *) imageView
{
    if (!_imageView) {
        
        const CGRect bounds = self.imageBounds;
        
        _imageView = ({
            
            UIImageView *v = [[UIImageView alloc] initWithFrame:bounds];
            v.tintColor = _foreColor;
            v.contentMode = UIViewContentModeCenter;
            v.clipsToBounds = YES;
            v.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            
            v.layer.cornerRadius = roundf(bounds.size.height * .5f);
            v.layer.borderColor = [_foreColor colorWithAlphaComponent:0.7].CGColor;
            v.layer.borderWidth = 1.f;// / [UIScreen mainScreen].scale;
            
            v;
        });
        
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *) titleLabel
{
    if (!_titleLabel) {
        
        _titleLabel = ({
            
            const CGRect bounds = self.labelBounds;
            UILabel *v = [[UILabel alloc] initWithFrame:bounds];
            v.adjustsFontSizeToFitWidth = YES;
            v.minimumScaleFactor = 0.5f;
            v.textColor = _foreColor;
            v.numberOfLines = 2;
            v.textAlignment = NSTextAlignmentCenter;
            v.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            v;
        });

        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (CGRect) imageBounds
{
    CGSize size = self.contentView.bounds.size;
    size.height -= [self labelBounds].size.height;
    const CGFloat D = MIN(size.width, size.height);
    return (CGRect) {
        roundf((size.width - D) * 0.5f),
        roundf((size.height - D) * 0.5f),
        D, D
    };
}

- (CGRect) labelBounds
{
    const CGSize size = self.contentView.bounds.size;
    const CGFloat H = 40;
    return (CGRect) { 0, size.height - H, size.width, H };
}

- (void) setHighlighted:(BOOL)value
{
    [super setHighlighted:value];
    [self updateSelection:value];
}

- (void) setSelected:(BOOL)value
{
    [super setSelected:value];
    [self updateSelection:value];
}

- (void) updateSelection:(BOOL)value
{
    if (value) {
        _imageView.backgroundColor = _foreColor;
        _imageView.tintColor = _selectedColor;
    } else {
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.tintColor = _foreColor;
    }
}

@end

//////////

@implementation KxGridMenuItem

+ (instancetype) gridMenuItemWithTitle:(NSString *)title
                                 image:(UIImage *)image
                                action:(KxGridMenuItemAction)action
{
    return [[self alloc] initWithTitle:title image:image action:action];
}

- (instancetype) initWithTitle:(NSString *)title
                         image:(UIImage *)image
                        action:(KxGridMenuItemAction)action
{
    if ((self = [super init])) {
        _title = title;
        _image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _action = action;
    }
    return self;
}

@end

//////////

@implementation KxGridMenuPopoverBackView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // add a mask layer with hole inside as border
        
        const CGRect bounds1 = CGRectInset(self.bounds, -1, -1);
        const CGRect bounds2 = CGRectInset(self.bounds,  0,  0);
        
        UIBezierPath *bpath1 = [UIBezierPath bezierPathWithRoundedRect:bounds1 cornerRadius:12];
        UIBezierPath *bpath2 = [UIBezierPath bezierPathWithRoundedRect:bounds2 cornerRadius:12];
        [bpath2 appendPath:bpath1];
        
        CAShapeLayer *border = [CAShapeLayer layer];
        border.path = bpath2.CGPath;
        border.fillRule =kCAFillRuleEvenOdd;
        border.fillColor = [UIColor colorWithWhite:0.36 alpha:1].CGColor;
        border.opacity = 0.5f;
        
        [self.layer addSublayer:border];
    }
    return self;
}

- (void) layoutSubviews
{
    // forbid shadow
}

+ (UIEdgeInsets) contentViewInsets
{
    return UIEdgeInsetsMake(0,0,0,0);
}

+ (CGFloat)arrowHeight
{
    return 0;
}

+ (CGFloat)arrowBase
{
    return 0;
}

+ (BOOL) wantsDefaultContentAppearance
{
    return NO;
}

@synthesize arrowOffset, arrowDirection;

@end
