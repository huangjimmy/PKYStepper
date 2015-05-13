//
//  PKYStepper.m
//  PKYStepper
//
//  Created by Okada Yohei on 1/11/15.
//  Copyright (c) 2015 yohei okada. All rights reserved.
//

// action control: UIControlEventApplicationReserved for increment/decrement?
// delegate: if there are multiple PKYSteppers in one viewcontroller, it will be a hassle to identify each PKYSteppers
// block: watch out for retain cycle

// check visibility of buttons when
// 1. right before displaying for the first time
// 2. value changed

#import "PKYStepper.h"

static const float kButtonWidth = 44.0f;

@implementation PKYStepper

#pragma mark initialization

- (instancetype)init{
    if (self = [super initWithFrame:CGRectZero])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _value = 0.0f;
    _stepInterval = 1.0f;
    _minimum = 0.0f;
    _maximum = 100.0f;
    _hidesDecrementWhenMinimum = NO;
    _hidesIncrementWhenMaximum = NO;
    _buttonWidth = kButtonWidth;
    
    self.clipsToBounds = YES;
    [self setBorderWidth:1.0f];
    [self setCornerRadius:3.0];
    
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.layer.borderWidth = 1.0f;
    [self addSubview:self.countLabel];
    
    self.incrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.incrementButton setTitle:@"+" forState:UIControlStateNormal];
    [self.incrementButton addTarget:self action:@selector(incrementButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.incrementButton];
    
    self.decrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.decrementButton setTitle:@"-" forState:UIControlStateNormal];
    [self.decrementButton addTarget:self action:@selector(decrementButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.decrementButton];
    
    UIColor *defaultColor = [UIColor colorWithRed:(79/255.0) green:(161/255.0) blue:(210/255.0) alpha:1.0];
    [self setBorderColor:defaultColor];
    [self setLabelTextColor:defaultColor];
    [self setButtonTextColor:defaultColor forState:UIControlStateNormal];
    
    [self setLabelFont:[UIFont fontWithName:@"Avernir-Roman" size:14.0f]];
    [self setButtonFont:[UIFont fontWithName:@"Avenir-Black" size:24.0f]];
    
    self.valuePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.valuePicker.dataSource = self;
    self.valuePicker.delegate = self;
    self.valuePickerContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.valuePickerContainer.backgroundColor = [UIColor clearColor];
    self.valuePickerWrapper = [[UIView alloc] initWithFrame:CGRectZero];
    [self.valuePickerContainer addSubview:self.valuePickerWrapper];
    [self.valuePickerWrapper addSubview:self.valuePicker];
    self.valuePickerWrapper.clipsToBounds = YES;
    
    
    self.countLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countLabelTapped:)];
    self.countLabelTapGestureRecognizer.enabled = YES;
    self.countLabel.userInteractionEnabled = YES;
    [self.countLabel addGestureRecognizer:self.countLabelTapGestureRecognizer];
    
    self.pickerViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countLabelTapped:)];
    self.valuePickerContainer.userInteractionEnabled = YES;
    [self.valuePickerContainer addGestureRecognizer:self.pickerViewTapGestureRecognizer];
    
    self.valuePicker.backgroundColor = self.countLabel.backgroundColor == [UIColor clearColor]?[UIColor whiteColor]:self.countLabel.backgroundColor;
    self.valuePicker.layer.borderColor = defaultColor.CGColor;
    self.valuePicker.layer.borderWidth = 1.0;
    self.valuePicker.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.valuePicker.layer.shadowOpacity = 1.0;
    self.valuePicker.layer.shadowColor = [UIColor grayColor].CGColor;
    self.pickerValue = self.value;
    
}



- (IBAction)countLabelTapped:(id)sender{
    NSLog(@"countLabelTapped:");
    
    __weak typeof(self) myself = self;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if(sender == self.countLabelTapGestureRecognizer){
        [self.valuePickerContainer removeFromSuperview];
        
        CGPoint point = self.countLabel.frame.origin;
        point = [keyWindow convertPoint:point fromView:self];
#define PICKER_H 162
        self.valuePicker.frame = CGRectMake(0, -PICKER_H/2+13, self.countLabel.frame.size.width, PICKER_H);
        self.valuePickerWrapper.frame = CGRectMake(point.x, point.y+self.countLabel.frame.size.height, self.countLabel.frame.size.width, 0);
        
        [keyWindow addSubview:self.valuePickerContainer];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.valuePickerWrapper.frame = CGRectMake(point.x, point.y+myself.countLabel.frame.size.height, myself.countLabel.frame.size.width, PICKER_H/2+13);
            
        }];
        
        self.valuePickerContainer.frame = keyWindow.frame;
        float row = (self.value - self.minimum)/self.stepInterval;
        [self.valuePicker selectRow:row inComponent:0 animated:NO];
        self.pickerValue = self.value;
        
        if (self.showHidePickerCallback) {
            self.showHidePickerCallback(self, NO);
        }
        
    }
    else if (sender == self.pickerViewTapGestureRecognizer){
        CGPoint point = [self.pickerViewTapGestureRecognizer locationInView:self.valuePickerContainer];
        UIView *tappedView = [self.valuePickerContainer hitTest:point withEvent:nil];
        if (tappedView == self.valuePicker) {
            
        }
        else{
            if (self.pickerValue != self.value) {
                self.value = self.pickerValue;
            }
            
            point = self.countLabel.frame.origin;
            point = [keyWindow convertPoint:point fromView:self];
            
            [UIView animateWithDuration:0.2 animations:^{
                myself.valuePickerWrapper.frame = CGRectMake(point.x, point.y+myself.countLabel.frame.size.height, myself.countLabel.frame.size.width, 0);
            } completion:^(BOOL finished) {
                [myself.valuePickerContainer removeFromSuperview];
                if (myself.showHidePickerCallback) {
                    myself.showHidePickerCallback(myself, YES);
                }
            }];
            
            
        }
    }
}


#pragma mark render
- (void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.countLabel.frame = CGRectMake(self.buttonWidth, 0, width - (self.buttonWidth * 2), height);
    self.incrementButton.frame = CGRectMake(width - self.buttonWidth, 0, self.buttonWidth, height);
    self.decrementButton.frame = CGRectMake(0, 0, self.buttonWidth, height);
    
    self.incrementButton.hidden = (self.hidesIncrementWhenMaximum && [self isMaximum]);
    self.decrementButton.hidden = (self.hidesDecrementWhenMinimum && [self isMinimum]);
}

- (void)setup
{
    if (self.valueChangedCallback)
    {
        self.valueChangedCallback(self, self.value);
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        // if CGSizeZero, return ideal size
        CGSize labelSize = [self.countLabel sizeThatFits:size];
        return CGSizeMake(labelSize.width + (self.buttonWidth * 2), labelSize.height);
    }
    return size;
}


#pragma mark view customization
- (void)setBorderColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    self.countLabel.layer.borderColor = color.CGColor;
    self.valuePicker.layer.borderColor = color.CGColor;
    self.valuePicker.layer.shadowColor = color.CGColor;
}

- (void)setBorderWidth:(CGFloat)width
{
    self.layer.borderWidth = width;
}

- (void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

- (void)setLabelTextColor:(UIColor *)color
{
    self.countLabel.textColor = color;
}

- (void)setLabelFont:(UIFont *)font
{
    self.countLabel.font = font;
}

- (void)setButtonTextColor:(UIColor *)color
{
    [self.incrementButton setTitleColor:color forState:UIControlStateNormal];
    [self.decrementButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)setButtonDisabledTextColor:(UIColor *)color{
    [self.incrementButton setTitleColor:color forState:UIControlStateDisabled];
    [self.decrementButton setTitleColor:color forState:UIControlStateDisabled];
}

- (void)setButtonTextColor:(UIColor *)color forState:(UIControlState)state
{
    [self.incrementButton setTitleColor:color forState:state];
    [self.decrementButton setTitleColor:color forState:state];
}

- (void)setButtonFont:(UIFont *)font
{
    self.incrementButton.titleLabel.font = font;
    self.decrementButton.titleLabel.font = font;
}


#pragma mark setter
- (void)setValue:(float)value
{
    _value = value;
    if (self.hidesDecrementWhenMinimum)
    {
        self.decrementButton.hidden = [self isMinimum];
    }
    [self.decrementButton setEnabled:![self isMinimum]];
    
    if (self.hidesIncrementWhenMaximum)
    {
        self.incrementButton.hidden = [self isMaximum];
    }
    [self.incrementButton setEnabled:![self isMaximum]];
    
    if (self.valueChangedCallback)
    {
        self.valueChangedCallback(self, _value);
    }
}



#pragma mark event handler
- (void)incrementButtonTapped:(id)sender
{
    if (self.value < self.maximum)
    {
        self.value += self.stepInterval;
        if (self.incrementCallback)
        {
            self.incrementCallback(self, self.value);
        }
    }
}

- (void)decrementButtonTapped:(id)sender
{
    if (self.value > self.minimum)
    {
        self.value -= self.stepInterval;
        if (self.decrementCallback)
        {
            self.decrementCallback(self, self.value);
        }
    }
}


#pragma mark private helpers
- (BOOL)isMinimum
{
    return self.value == self.minimum;
}

- (BOOL)isMaximum
{
    return self.value == self.maximum;
}

#pragma picker view

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return (self.maximum - self.minimum+self.stepInterval)/self.stepInterval;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 20;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    float precisionNum = ceil(1/self.stepInterval);
    int precision = log10(precisionNum);
    NSString *format = [NSString stringWithFormat:@"%%.%df", precision];
    
    return [NSString stringWithFormat:format,(self.minimum+row*self.stepInterval)];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    CGFloat value = self.minimum+row*self.stepInterval;
    self.pickerValue = value;

    if (self.pickerValue != self.value) {
        self.value = self.pickerValue;
    }
    
}

@end
