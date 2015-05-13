//
//  PKY_RCTViewManager.m
//  PKYStepper
//
//  Created by HUANG,Shaojun on 5/6/15.
//  Copyright (c) 2015 yohei okada. All rights reserved.
//

#import "PKY_RCTViewManager.h"
#import "PKYStepper.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
#import "UIView+React.h"

@implementation PKYStepperManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    PKYStepper *stepper = [[PKYStepper alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    stepper.valueChangedCallback = ^(PKYStepper *stepper, float newValue){
        [self.bridge.eventDispatcher sendInputEventWithName:@"topChange" body:@{@"target":stepper.reactTag,@"newIndex":@((stepper.value-stepper.minimum)/stepper.stepInterval), @"newValue":@(stepper.value)}];
    };
    stepper.incrementCallback = stepper.valueChangedCallback;
    stepper.decrementCallback = stepper.valueChangedCallback;
    return stepper;
}

RCT_EXPORT_VIEW_PROPERTY(value, float);
RCT_EXPORT_VIEW_PROPERTY(stepInterval, float);
RCT_EXPORT_VIEW_PROPERTY(minimum, float);
RCT_EXPORT_VIEW_PROPERTY(maximum, float);
RCT_EXPORT_VIEW_PROPERTY(buttonWidth, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(hidesDecrementWhenMinimum, BOOL);
RCT_EXPORT_VIEW_PROPERTY(hidesIncrementWhenMaximum, BOOL);

RCT_EXPORT_VIEW_PROPERTY(borderColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(labelTextColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(buttonTextColor, UIColor);
RCT_EXPORT_VIEW_PROPERTY(buttonDisabledTextColor, UIColor);

RCT_REMAP_VIEW_PROPERTY(labelText, countLabel.text, NSString)

RCT_CUSTOM_VIEW_PROPERTY(labelFontSize, CGFloat, PKYStepper)
{
    [view setLabelFont:[RCTConvert UIFont:view.countLabel.font withSize:json ?: @(defaultView.countLabel.font.pointSize)]];
}

RCT_CUSTOM_VIEW_PROPERTY(buttonFontSize, CGFloat, PKYStepper)
{
    [view setButtonFont:[RCTConvert UIFont:view.countLabel.font withSize:json ?: @(defaultView.countLabel.font.pointSize)]];
}

RCT_CUSTOM_VIEW_PROPERTY(labelFontName, CGFloat, PKYStepper)
{
    NSString *fontName = [json stringValue];
    [view setLabelFont:[UIFont fontWithName:fontName size:defaultView.countLabel.font.pointSize]];
}

RCT_CUSTOM_VIEW_PROPERTY(buttonFontName, CGFloat, PKYStepper)
{
    NSString *fontName = [json stringValue];
    [view setButtonFont:[UIFont fontWithName:fontName size:defaultView.countLabel.font.pointSize]];
}

RCT_CUSTOM_VIEW_PROPERTY(width, CGFloat, PKYStepper)
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, [RCTConvert CGFloat:json], view.frame.size.height);
}
RCT_CUSTOM_VIEW_PROPERTY(height, CGFloat, PKYStepper)
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [RCTConvert CGFloat:json]);
}

RCT_EXPORT_VIEW_PROPERTY(borderWidth, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(cornerRadius, CGFloat);

@end
