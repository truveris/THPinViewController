//
//  THPinView.m
//  THPinViewControllerExample
//
//  Created by Thomas Heß on 21.4.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THPinView.h"
#import "THPinInputCirclesView.h"
#import "THPinNumPadView.h"
#import "THPinNumButton.h"

@interface THPinView () <THPinNumPadViewDelegate>

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) THPinInputCirclesView *inputCirclesView;
@property (nonatomic, strong) THPinNumPadView *numPadView;
@property (nonatomic, strong) UIButton *bottomButton;

@property (nonatomic, assign) CGFloat paddingBetweenPromptLabelAndInputCircles;
@property (nonatomic, assign) CGFloat paddingBetweenInputCirclesAndMessageLabel;
@property (nonatomic, assign) CGFloat paddingBetweenMessageLabelAndNumPad;
@property (nonatomic, assign) CGFloat paddingBetweenNumPadAndBottomButton;

@property (nonatomic, strong) NSMutableString *input;

@end

@implementation THPinView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithDelegate:nil];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<THPinViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        _delegate = delegate;
        _input = [NSMutableString string];

        _promptLabel = [[UILabel alloc] init];
        _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.adjustsFontSizeToFitWidth = YES;
        _promptLabel.minimumScaleFactor = 0.5;
        _promptLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0f : 20.0f];
        [_promptLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel
                                                      forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_promptLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[promptLabel]|" options:0 metrics:nil
                                                                       views:@{ @"promptLabel" : _promptLabel }]];
        
        _inputCirclesView = [[THPinInputCirclesView alloc] initWithPinLength:[_delegate pinLengthForPinView:self]];
        _inputCirclesView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_inputCirclesView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_inputCirclesView attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f constant:0.0f]];

        _messageLabel = [[UILabel alloc] init];
        _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 18.0f : 14.0f];
        [_messageLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel
                                                      forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_messageLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messageLabel]|" options:0 metrics:nil
                                                                       views:@{ @"messageLabel" : _messageLabel }]];


        _numPadView = [[THPinNumPadView alloc] initWithDelegate:self];
        _numPadView.translatesAutoresizingMaskIntoConstraints = NO;
        _numPadView.backgroundColor = self.backgroundColor;
        [self addSubview:_numPadView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_numPadView attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f constant:0.0f]];
        
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _bottomButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_bottomButton setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel
                                                       forAxis:UILayoutConstraintAxisHorizontal];
        [self updateBottomButton];
        [self addSubview:_bottomButton];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // place button right of zero number button
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self attribute:NSLayoutAttributeRight
                                                            multiplier:1.0f constant:-[THPinNumButton diameter] / 2.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0f constant:-[THPinNumButton diameter] / 2.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0
                                                            multiplier:0.0f constant:[THPinNumButton diameter]]];
        } else {
            // place button beneath the num pad on the right
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self attribute:NSLayoutAttributeRight
                                                            multiplier:1.0f constant:0.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomButton attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                toItem:self attribute:NSLayoutAttributeWidth
                                                            multiplier:0.4f constant:0.0f]];
        }

        //Message label gets fixed height so the other views don't jump when it's missing
        NSMutableString *vFormat = [NSMutableString stringWithString:@"V:|-(minMargin@99,>=0)-[promptLabel]-(paddingBetweenPromptLabelAndInputCircles@98,>=minMargin@99,>=0)-[inputCirclesView]-(paddingBetweenInputCirclesAndMessageLabel@97,>=medMargin@98,>=minMargin@99,>=0)-[messageLabel(20)]-(>=paddingBetweenMessageLabelAndNumPad@96,>=medMargin@97,>=minMargin@99,>=0)-[numPadView]"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _paddingBetweenPromptLabelAndInputCircles = 42.0f;
            _paddingBetweenInputCirclesAndMessageLabel = 32.0f;
            _paddingBetweenMessageLabelAndNumPad = 32.0;
                [vFormat appendString:@"|"];
        } else {
            [vFormat appendString:@"-(paddingBetweenNumPadAndBottomButton@98,minMargin@99,>=0)-[bottomButton]"];
            BOOL isFourInchScreen = (fabs(CGRectGetHeight([[UIScreen mainScreen] bounds]) - 568.0f) < DBL_EPSILON);
            if (isFourInchScreen) {
                _paddingBetweenPromptLabelAndInputCircles = 22.5f;
                _paddingBetweenInputCirclesAndMessageLabel = 31.5f;
                _paddingBetweenMessageLabelAndNumPad = 31.5f;
                _paddingBetweenNumPadAndBottomButton = 10.0f;
            } else {
                _paddingBetweenPromptLabelAndInputCircles = 10.0f;
                _paddingBetweenInputCirclesAndMessageLabel = 10.0f;
                _paddingBetweenMessageLabelAndNumPad = 10.0f;
                _paddingBetweenNumPadAndBottomButton = -12.5f;
            }

            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomButton]-(>=0,minMargin@99)-|" options:0 metrics:@{@"minMargin" : @(5)} views:NSDictionaryOfVariableBindings(_bottomButton)]];
        }
        
        NSDictionary *metrics = @{ @"paddingBetweenPromptLabelAndInputCircles" : @(_paddingBetweenPromptLabelAndInputCircles),
                                   @"paddingBetweenInputCirclesAndMessageLabel" : @(_paddingBetweenInputCirclesAndMessageLabel),
                                   @"paddingBetweenMessageLabelAndNumPad" :
                                       @(_paddingBetweenMessageLabelAndNumPad),
                                   @"paddingBetweenNumPadAndBottomButton" : @(_paddingBetweenNumPadAndBottomButton),
                                   @"medMargin" : @(10),
                                   @"minMargin" : @(5)};
        NSDictionary *views = @{ @"promptLabel" : _promptLabel,
                                 @"inputCirclesView" : _inputCirclesView,
                                 @"messageLabel" : _messageLabel,
                                 @"numPadView" : _numPadView,
                                 @"bottomButton" : _bottomButton};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:0 metrics:metrics views:views]];

        //Show initial message, if any
        self.messageLabel.text = [self.delegate messageStringForPinView:self];
    }
    return self;
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.numPadView.backgroundColor = self.backgroundColor;
}

- (NSString *)promptTitle
{
    return self.promptLabel.text;
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    self.promptLabel.text = promptTitle;
}

- (UIColor *)promptColor
{
    return self.promptLabel.textColor;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    self.promptLabel.textColor = promptColor;
    self.messageLabel.textColor = promptColor;
}

- (void)setPromptFont:(UIFont *)promptFont {
    self.promptLabel.font = [UIFont fontWithDescriptor:promptFont.fontDescriptor size:self.promptLabel.font.pointSize];
    self.messageLabel.font = [UIFont fontWithDescriptor:promptFont.fontDescriptor size:self.messageLabel.font.pointSize];
}

- (BOOL)hideLetters
{
    return self.numPadView.hideLetters;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    self.numPadView.hideLetters = hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel
{
    if (self.disableCancel == disableCancel) {
        return;
    }
    _disableCancel = disableCancel;
    [self updateBottomButton];
}

#pragma mark - Public

- (void)updateBottomButton
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"THPinViewController"
                                                                                ofType:@"bundle"]];
    if ([self.input length] == 0) {
        self.bottomButton.hidden = self.disableCancel;
        [self.bottomButton setTitle:NSLocalizedStringFromTableInBundle(@"cancel_button_title", @"THPinViewController",
                                                                       bundle, nil)
                           forState:UIControlStateNormal];
        [self.bottomButton removeTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.bottomButton.hidden = NO;
        [self.bottomButton setTitle:NSLocalizedStringFromTableInBundle(@"delete_button_title", @"THPinViewController",
                                                                       bundle, nil)
                           forState:UIControlStateNormal];
        [self.bottomButton removeTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - User Interaction

- (void)cancel:(id)sender
{
    [self.delegate cancelButtonTappedInPinView:self];
}

- (void)delete:(id)sender
{
    if ([self.input length] < 2) {
        [self resetInput];
    } else {
        [self.input deleteCharactersInRange:NSMakeRange([self.input length] - 1, 1)];
        [self.inputCirclesView unfillCircleAtPosition:[self.input length]];
    }
}

#pragma mark - THPinNumPadViewDelegate

- (void)pinNumPadView:(THPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number
{
    NSUInteger pinLength = [self.delegate pinLengthForPinView:self];
    
    if ([self.input length] >= pinLength) {
        return;
    }
    
    [self.input appendString:[NSString stringWithFormat:@"%lu", (unsigned long)number]];
    [self.inputCirclesView fillCircleAtPosition:[self.input length] - 1];
    
    [self updateBottomButton];
    
    if ([self.input length] < pinLength) {
        return;
    }
    
    if ([self.delegate pinView:self isPinValid:self.input])
    {
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.delegate correctPinWasEnteredInPinView:self];
        });
        
    } else {
        
        [self.inputCirclesView shakeWithCompletion:^{
            [self resetInput];
            [self.delegate incorrectPinWasEnteredInPinView:self];

            self.messageLabel.text = [self.delegate messageStringForPinView:self];
        }];
    }
}

#pragma mark - Util

- (void)resetInput
{
    self.input = [NSMutableString string];
    [self.inputCirclesView unfillAllCircles];
    [self updateBottomButton];
}

@end
