//
//  THPinViewController.h
//  THPinViewController
//
//  Created by Thomas Heß on 11.4.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

@import UIKit;
#import "THPinViewControllerMacros.h"

@class THPinViewController;
@class THPinView;

// when using translucentBackground assign this tag to the view that should be blurred
static const NSInteger THPinViewControllerContentViewTag = 14742;

@protocol THPinViewControllerDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController;
- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin;
- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController;

//Anything extra to do to dismiss the VC (in case normal dismissViewController isn't enough)
- (void)dismissPinViewController;

@optional
- (void)incorrectPinEnteredInPinViewController:(THPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(UIViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:(THPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController;

/**
 * On create, and after every incorrect pin entry, requests a string to show beneath
 * the pin circles
 */
- (NSString *)messageStringForPinViewController:(THPinViewController *)pinViewController;

/**
 * Title to use for nav bar, if present in one
 */
- (NSString *)titleStringForPinViewController:(THPinViewController *)pinViewController;

@end

@interface THPinViewController : UIViewController

@property (nonatomic, weak) id<THPinViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *backgroundColor; // is only used if translucentBackground == NO
@property (nonatomic, assign) BOOL translucentBackground;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, strong) UIFont *promptFont;//size is ignored, just takes the style
@property (nonatomic, assign) BOOL hideLetters; // hides the letters on the number buttons
@property (nonatomic, assign) BOOL disableCancel; // hides the cancel button

- (instancetype)initWithDelegate:(id<THPinViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)correctPinWasEnteredInPinView:(THPinView *)pinView;

@end
