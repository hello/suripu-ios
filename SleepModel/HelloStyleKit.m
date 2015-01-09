//
//  HelloStyleKit.m
//  Sleep Sense
//
//  Created by Delisa Mason on 1/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "HelloStyleKit.h"


@implementation HelloStyleKit

#pragma mark Cache

static UIColor* _darkBlueColor = nil;
static UIColor* _mediumBlueColor = nil;
static UIColor* _currentConditionsBackgroundColor = nil;
static UIColor* _highSleepScoreColor = nil;
static UIColor* _poorSleepScoreColor = nil;
static UIColor* _averageSleepScoreColor = nil;
static UIColor* _lightBlueColor = nil;
static UIColor* _lightestBlueColor = nil;
static UIColor* _warningSensorColor = nil;
static UIColor* _idealSensorColor = nil;
static UIColor* _alertSensorColor = nil;
static UIColor* _lightSleepColor = nil;
static UIColor* _intermediateSleepColor = nil;
static UIColor* _deepSleepColor = nil;
static UIColor* _awakeSleepColor = nil;
static UIColor* _sleepQuestionBgColor = nil;
static UIColor* _onboardingGrayColor = nil;
static UIColor* _green = nil;
static UIColor* _backViewBackgroundColor = nil;
static UIColor* _backViewNavTitleColor = nil;
static UIColor* _backViewTextColor = nil;
static UIColor* _senseBlueColor = nil;
static UIColor* _backViewTintColor = nil;
static UIColor* _timelineSectionBorderColor = nil;
static UIColor* _timelineGradientDarkColor = nil;
static UIColor* _backViewDetailTextColor = nil;
static UIColor* _barButtonEnabledColor = nil;
static UIColor* _barButtonDisabledColor = nil;
static UIColor* _actionViewTitleTextColor = nil;
static UIColor* _actionViewCancelButtonTextColor = nil;
static UIColor* _buttonDividerColor = nil;
static UIColor* _questionAnswerSelectedBgColor = nil;
static UIColor* _questionAnswerSelectedTextColor = nil;
static UIColor* _tabBarUnselectedColor = nil;
static UIColor* _deviceAlertMessageColor = nil;
static UIColor* _settingsSeparatorColor = nil;

static PCGradient* _blueBackgroundGradient = nil;

static NSShadow* _onboardingButtonContainerShadow = nil;
static NSShadow* _actionViewShadow = nil;

static UIImage* _alarmEnabledIcon = nil;
static UIImage* _chevronIconLeft = nil;
static UIImage* _alarmNoteIcon = nil;
static UIImage* _questionIcon = nil;
static UIImage* _bluetoothLogoImage = nil;
static UIImage* _wifiLogoImage = nil;
static UIImage* _humidityIcon = nil;
static UIImage* _particleIcon = nil;
static UIImage* _temperatureIcon = nil;
static UIImage* _lightEventIcon = nil;
static UIImage* _noiseEventIcon = nil;
static UIImage* _sleepEventIcon = nil;
static UIImage* _wakeupEventIcon = nil;
static UIImage* _chevronIconRight = nil;
static UIImage* _motionEventIcon = nil;
static UIImage* _alarmsIcon = nil;
static UIImage* _sleepInsightsIcon = nil;
static UIImage* _humidityDarkIcon = nil;
static UIImage* _particleDarkIcon = nil;
static UIImage* _temperatureDarkIcon = nil;
static UIImage* _sense = nil;
static UIImage* _wifiIcon = nil;
static UIImage* _lockIcon = nil;
static UIImage* _backIcon = nil;
static UIImage* _senseGlow = nil;
static UIImage* _sensePlacement = nil;
static UIImage* _shakePill = nil;
static UIImage* _smartAlarm = nil;
static UIImage* _check = nil;
static UIImage* _sensorHumidity = nil;
static UIImage* _sensorHumidityBlue = nil;
static UIImage* _sensorLight = nil;
static UIImage* _sensorLightBlue = nil;
static UIImage* _sensorParticulates = nil;
static UIImage* _sensorParticulatesBlue = nil;
static UIImage* _sensorSound = nil;
static UIImage* _sensorSoundBlue = nil;
static UIImage* _sensorTemperatureBlue = nil;
static UIImage* _sensorTemperature = nil;
static UIImage* _moon = nil;
static UIImage* _alarmBarIcon = nil;
static UIImage* _senseBarIcon = nil;
static UIImage* _settingsBarIcon = nil;
static UIImage* _trendsBarIcon = nil;
static UIImage* _sensorsBarIcon = nil;
static UIImage* _alarmSmartIcon = nil;
static UIImage* _alarmSoundIcon = nil;
static UIImage* _alarmRepeatIcon = nil;
static UIImage* _senseIcon = nil;
static UIImage* _pillIcon = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _darkBlueColor = [UIColor colorWithRed: 0.314 green: 0.325 blue: 0.529 alpha: 1];
    _mediumBlueColor = [UIColor colorWithRed: 0.184 green: 0.514 blue: 0.639 alpha: 1];
    _currentConditionsBackgroundColor = [UIColor colorWithRed: 0.902 green: 0.91 blue: 0.906 alpha: 1];
    _highSleepScoreColor = [UIColor colorWithRed: 0.252 green: 0.84 blue: 0.664 alpha: 1];
    _poorSleepScoreColor = [UIColor colorWithRed: 0.8 green: 0.339 blue: 0.32 alpha: 1];
    _averageSleepScoreColor = [UIColor colorWithRed: 0.947 green: 0.901 blue: 0.5 alpha: 1];
    _lightBlueColor = [UIColor colorWithRed: 0.733 green: 0.851 blue: 0.929 alpha: 1];
    _lightestBlueColor = [UIColor colorWithRed: 0.918 green: 0.945 blue: 0.949 alpha: 1];
    _warningSensorColor = [UIColor colorWithRed: 1 green: 0.604 blue: 0 alpha: 1];
    _idealSensorColor = [UIColor colorWithRed: 0.255 green: 0.843 blue: 0.675 alpha: 1];
    _alertSensorColor = [UIColor colorWithRed: 1 green: 0 blue: 0 alpha: 1];
    _lightSleepColor = [UIColor colorWithRed: 0 green: 0.612 blue: 1 alpha: 1];
    _intermediateSleepColor = [UIColor colorWithRed: 0.027 green: 0.49 blue: 0.969 alpha: 1];
    _deepSleepColor = [UIColor colorWithRed: 0 green: 0.333 blue: 0.847 alpha: 1];
    _awakeSleepColor = [UIColor colorWithRed: 0.32 green: 0.356 blue: 0.8 alpha: 0];
    _sleepQuestionBgColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.9];
    _onboardingGrayColor = [UIColor colorWithRed: 0.29 green: 0.29 blue: 0.29 alpha: 1];
    _green = [UIColor colorWithRed: 0.455 green: 0.792 blue: 0.459 alpha: 1];
    _backViewBackgroundColor = [UIColor colorWithRed: 0.96 green: 0.96 blue: 0.96 alpha: 1];
    _backViewNavTitleColor = [UIColor colorWithRed: 0.286 green: 0.286 blue: 0.286 alpha: 1];
    _backViewTextColor = [UIColor colorWithRed: 0.478 green: 0.478 blue: 0.478 alpha: 1];
    _senseBlueColor = [UIColor colorWithRed: 0 green: 0.604 blue: 1 alpha: 1];
    _backViewTintColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    _timelineSectionBorderColor = [UIColor colorWithRed: 0.9 green: 0.91 blue: 0.91 alpha: 1];
    _timelineGradientDarkColor = [UIColor colorWithRed: 0.96 green: 0.96 blue: 0.97 alpha: 1];
    _backViewDetailTextColor = [UIColor colorWithRed: 0.631 green: 0.631 blue: 0.631 alpha: 1];
    _barButtonEnabledColor = [UIColor colorWithRed: 0 green: 0.612 blue: 1 alpha: 1];
    _barButtonDisabledColor = [UIColor colorWithRed: 0.547 green: 0.547 blue: 0.547 alpha: 1];
    _actionViewTitleTextColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _actionViewCancelButtonTextColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _buttonDividerColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 0.2];
    _questionAnswerSelectedBgColor = [UIColor colorWithRed: 0.961 green: 0.984 blue: 1 alpha: 1];
    _questionAnswerSelectedTextColor = [UIColor colorWithRed: 0.804 green: 0.91 blue: 1 alpha: 1];
    _tabBarUnselectedColor = [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.75 alpha: 1];
    _deviceAlertMessageColor = [UIColor colorWithRed: 0.302 green: 0.302 blue: 0.302 alpha: 1];
    _settingsSeparatorColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.039];

    // Gradients Initialization
    CGFloat blueBackgroundGradientLocations[] = {0, 1};
    _blueBackgroundGradient = [PCGradient gradientWithColors: @[HelloStyleKit.darkBlueColor, HelloStyleKit.mediumBlueColor] locations: blueBackgroundGradientLocations];

    // Shadows Initialization
    _onboardingButtonContainerShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 5];
    _actionViewShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 5];

}

#pragma mark Colors

+ (UIColor*)darkBlueColor { return _darkBlueColor; }
+ (UIColor*)mediumBlueColor { return _mediumBlueColor; }
+ (UIColor*)currentConditionsBackgroundColor { return _currentConditionsBackgroundColor; }
+ (UIColor*)highSleepScoreColor { return _highSleepScoreColor; }
+ (UIColor*)poorSleepScoreColor { return _poorSleepScoreColor; }
+ (UIColor*)averageSleepScoreColor { return _averageSleepScoreColor; }
+ (UIColor*)lightBlueColor { return _lightBlueColor; }
+ (UIColor*)lightestBlueColor { return _lightestBlueColor; }
+ (UIColor*)warningSensorColor { return _warningSensorColor; }
+ (UIColor*)idealSensorColor { return _idealSensorColor; }
+ (UIColor*)alertSensorColor { return _alertSensorColor; }
+ (UIColor*)lightSleepColor { return _lightSleepColor; }
+ (UIColor*)intermediateSleepColor { return _intermediateSleepColor; }
+ (UIColor*)deepSleepColor { return _deepSleepColor; }
+ (UIColor*)awakeSleepColor { return _awakeSleepColor; }
+ (UIColor*)sleepQuestionBgColor { return _sleepQuestionBgColor; }
+ (UIColor*)onboardingGrayColor { return _onboardingGrayColor; }
+ (UIColor*)green { return _green; }
+ (UIColor*)backViewBackgroundColor { return _backViewBackgroundColor; }
+ (UIColor*)backViewNavTitleColor { return _backViewNavTitleColor; }
+ (UIColor*)backViewTextColor { return _backViewTextColor; }
+ (UIColor*)senseBlueColor { return _senseBlueColor; }
+ (UIColor*)backViewTintColor { return _backViewTintColor; }
+ (UIColor*)timelineSectionBorderColor { return _timelineSectionBorderColor; }
+ (UIColor*)timelineGradientDarkColor { return _timelineGradientDarkColor; }
+ (UIColor*)backViewDetailTextColor { return _backViewDetailTextColor; }
+ (UIColor*)barButtonEnabledColor { return _barButtonEnabledColor; }
+ (UIColor*)barButtonDisabledColor { return _barButtonDisabledColor; }
+ (UIColor*)actionViewTitleTextColor { return _actionViewTitleTextColor; }
+ (UIColor*)actionViewCancelButtonTextColor { return _actionViewCancelButtonTextColor; }
+ (UIColor*)buttonDividerColor { return _buttonDividerColor; }
+ (UIColor*)questionAnswerSelectedBgColor { return _questionAnswerSelectedBgColor; }
+ (UIColor*)questionAnswerSelectedTextColor { return _questionAnswerSelectedTextColor; }
+ (UIColor*)tabBarUnselectedColor { return _tabBarUnselectedColor; }
+ (UIColor*)deviceAlertMessageColor { return _deviceAlertMessageColor; }
+ (UIColor*)settingsSeparatorColor { return _settingsSeparatorColor; }

#pragma mark Gradients

+ (PCGradient*)blueBackgroundGradient { return _blueBackgroundGradient; }

#pragma mark Shadows

+ (NSShadow*)onboardingButtonContainerShadow { return _onboardingButtonContainerShadow; }
+ (NSShadow*)actionViewShadow { return _actionViewShadow; }

#pragma mark Images

+ (UIImage*)alarmEnabledIcon { return _alarmEnabledIcon ?: (_alarmEnabledIcon = [UIImage imageNamed: @"alarmEnabledIcon"]); }
+ (UIImage*)chevronIconLeft { return _chevronIconLeft ?: (_chevronIconLeft = [UIImage imageNamed: @"chevronIconLeft"]); }
+ (UIImage*)alarmNoteIcon { return _alarmNoteIcon ?: (_alarmNoteIcon = [UIImage imageNamed: @"alarmNoteIcon"]); }
+ (UIImage*)questionIcon { return _questionIcon ?: (_questionIcon = [UIImage imageNamed: @"questionIcon"]); }
+ (UIImage*)bluetoothLogoImage { return _bluetoothLogoImage ?: (_bluetoothLogoImage = [UIImage imageNamed: @"bluetoothLogoImage"]); }
+ (UIImage*)wifiLogoImage { return _wifiLogoImage ?: (_wifiLogoImage = [UIImage imageNamed: @"wifiLogoImage"]); }
+ (UIImage*)humidityIcon { return _humidityIcon ?: (_humidityIcon = [UIImage imageNamed: @"humidityIcon"]); }
+ (UIImage*)particleIcon { return _particleIcon ?: (_particleIcon = [UIImage imageNamed: @"particleIcon"]); }
+ (UIImage*)temperatureIcon { return _temperatureIcon ?: (_temperatureIcon = [UIImage imageNamed: @"temperatureIcon"]); }
+ (UIImage*)lightEventIcon { return _lightEventIcon ?: (_lightEventIcon = [UIImage imageNamed: @"lightEventIcon"]); }
+ (UIImage*)noiseEventIcon { return _noiseEventIcon ?: (_noiseEventIcon = [UIImage imageNamed: @"noiseEventIcon"]); }
+ (UIImage*)sleepEventIcon { return _sleepEventIcon ?: (_sleepEventIcon = [UIImage imageNamed: @"sleepEventIcon"]); }
+ (UIImage*)wakeupEventIcon { return _wakeupEventIcon ?: (_wakeupEventIcon = [UIImage imageNamed: @"wakeupEventIcon"]); }
+ (UIImage*)chevronIconRight { return _chevronIconRight ?: (_chevronIconRight = [UIImage imageNamed: @"chevronIconRight"]); }
+ (UIImage*)motionEventIcon { return _motionEventIcon ?: (_motionEventIcon = [UIImage imageNamed: @"motionEventIcon"]); }
+ (UIImage*)alarmsIcon { return _alarmsIcon ?: (_alarmsIcon = [UIImage imageNamed: @"alarmsIcon"]); }
+ (UIImage*)sleepInsightsIcon { return _sleepInsightsIcon ?: (_sleepInsightsIcon = [UIImage imageNamed: @"sleepInsightsIcon"]); }
+ (UIImage*)humidityDarkIcon { return _humidityDarkIcon ?: (_humidityDarkIcon = [UIImage imageNamed: @"humidityDarkIcon"]); }
+ (UIImage*)particleDarkIcon { return _particleDarkIcon ?: (_particleDarkIcon = [UIImage imageNamed: @"particleDarkIcon"]); }
+ (UIImage*)temperatureDarkIcon { return _temperatureDarkIcon ?: (_temperatureDarkIcon = [UIImage imageNamed: @"temperatureDarkIcon"]); }
+ (UIImage*)sense { return _sense ?: (_sense = [UIImage imageNamed: @"sense"]); }
+ (UIImage*)wifiIcon { return _wifiIcon ?: (_wifiIcon = [UIImage imageNamed: @"wifiIcon"]); }
+ (UIImage*)lockIcon { return _lockIcon ?: (_lockIcon = [UIImage imageNamed: @"lockIcon"]); }
+ (UIImage*)backIcon { return _backIcon ?: (_backIcon = [UIImage imageNamed: @"backIcon"]); }
+ (UIImage*)senseGlow { return _senseGlow ?: (_senseGlow = [UIImage imageNamed: @"senseGlow"]); }
+ (UIImage*)sensePlacement { return _sensePlacement ?: (_sensePlacement = [UIImage imageNamed: @"sensePlacement"]); }
+ (UIImage*)shakePill { return _shakePill ?: (_shakePill = [UIImage imageNamed: @"shakePill"]); }
+ (UIImage*)smartAlarm { return _smartAlarm ?: (_smartAlarm = [UIImage imageNamed: @"smartAlarm"]); }
+ (UIImage*)check { return _check ?: (_check = [UIImage imageNamed: @"check"]); }
+ (UIImage*)sensorHumidity { return _sensorHumidity ?: (_sensorHumidity = [UIImage imageNamed: @"sensorHumidity"]); }
+ (UIImage*)sensorHumidityBlue { return _sensorHumidityBlue ?: (_sensorHumidityBlue = [UIImage imageNamed: @"sensorHumidityBlue"]); }
+ (UIImage*)sensorLight { return _sensorLight ?: (_sensorLight = [UIImage imageNamed: @"sensorLight"]); }
+ (UIImage*)sensorLightBlue { return _sensorLightBlue ?: (_sensorLightBlue = [UIImage imageNamed: @"sensorLightBlue"]); }
+ (UIImage*)sensorParticulates { return _sensorParticulates ?: (_sensorParticulates = [UIImage imageNamed: @"sensorParticulates"]); }
+ (UIImage*)sensorParticulatesBlue { return _sensorParticulatesBlue ?: (_sensorParticulatesBlue = [UIImage imageNamed: @"sensorParticulatesBlue"]); }
+ (UIImage*)sensorSound { return _sensorSound ?: (_sensorSound = [UIImage imageNamed: @"sensorSound"]); }
+ (UIImage*)sensorSoundBlue { return _sensorSoundBlue ?: (_sensorSoundBlue = [UIImage imageNamed: @"sensorSoundBlue"]); }
+ (UIImage*)sensorTemperatureBlue { return _sensorTemperatureBlue ?: (_sensorTemperatureBlue = [UIImage imageNamed: @"sensorTemperatureBlue"]); }
+ (UIImage*)sensorTemperature { return _sensorTemperature ?: (_sensorTemperature = [UIImage imageNamed: @"sensorTemperature"]); }
+ (UIImage*)moon { return _moon ?: (_moon = [UIImage imageNamed: @"moon"]); }
+ (UIImage*)alarmBarIcon { return _alarmBarIcon ?: (_alarmBarIcon = [UIImage imageNamed: @"alarmBarIcon"]); }
+ (UIImage*)senseBarIcon { return _senseBarIcon ?: (_senseBarIcon = [UIImage imageNamed: @"senseBarIcon"]); }
+ (UIImage*)settingsBarIcon { return _settingsBarIcon ?: (_settingsBarIcon = [UIImage imageNamed: @"settingsBarIcon"]); }
+ (UIImage*)trendsBarIcon { return _trendsBarIcon ?: (_trendsBarIcon = [UIImage imageNamed: @"trendsBarIcon"]); }
+ (UIImage*)sensorsBarIcon { return _sensorsBarIcon ?: (_sensorsBarIcon = [UIImage imageNamed: @"sensorsBarIcon"]); }
+ (UIImage*)alarmSmartIcon { return _alarmSmartIcon ?: (_alarmSmartIcon = [UIImage imageNamed: @"alarmSmartIcon"]); }
+ (UIImage*)alarmSoundIcon { return _alarmSoundIcon ?: (_alarmSoundIcon = [UIImage imageNamed: @"alarmSoundIcon"]); }
+ (UIImage*)alarmRepeatIcon { return _alarmRepeatIcon ?: (_alarmRepeatIcon = [UIImage imageNamed: @"alarmRepeatIcon"]); }
+ (UIImage*)senseIcon { return _senseIcon ?: (_senseIcon = [UIImage imageNamed: @"senseIcon"]); }
+ (UIImage*)pillIcon { return _pillIcon ?: (_pillIcon = [UIImage imageNamed: @"pillIcon"]); }

#pragma mark Drawing Methods

+ (void)drawSleepScoreGraphWithSleepScoreLabelText: (NSString*)sleepScoreLabelText sleepScore: (CGFloat)sleepScore
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* sleepScoreNoValueColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.059];
    UIColor* sleepScoreValueColor = [UIColor colorWithRed: 0.41 green: 0.41 blue: 0.41 alpha: 1];
    UIColor* sleepScoreLabelTextColor = [UIColor colorWithRed: 0.602 green: 0.602 blue: 0.602 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore > 0 ? (sleepScore < 45 ? HelloStyleKit.alertSensorColor : (sleepScore < 80 ? HelloStyleKit.warningSensorColor : HelloStyleKit.highSleepScoreColor)) : sleepScoreNoValueColor;
    CGFloat graphPercentageAngle = sleepScore > 0 ? (sleepScore < 100 ? 360 - sleepScore * 0.01 * 360 : 0.01) : 0.01;
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (NSInteger)round(sleepScore)] : @"100") : @"";
    NSString* localizedSleepScoreDescriptionLabel = sleepScore > 0 ? sleepScoreLabelText : @"";

    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 1);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-153, 0, 153, 153);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];

    [sleepScoreColor setStroke];
    pieOvalPath.lineWidth = 2.5;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(0, 36, 155, 98);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-UltraLight" size: 75], NSForegroundColorAttributeName: sleepScoreValueColor, NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    CGFloat sleepScoreLabelTextHeight = [sleepScoreText boundingRectWithSize: CGSizeMake(sleepScoreLabelRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreLabelFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreLabelRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(sleepScoreLabelRect), CGRectGetMinY(sleepScoreLabelRect) + (CGRectGetHeight(sleepScoreLabelRect) - sleepScoreLabelTextHeight) / 2, CGRectGetWidth(sleepScoreLabelRect), sleepScoreLabelTextHeight) withAttributes: sleepScoreLabelFontAttributes];
    CGContextRestoreGState(context);


    //// sleep score text label Drawing
    CGRect sleepScoreTextLabelRect = CGRectMake(0, 30, 155, 10);
    NSMutableParagraphStyle* sleepScoreTextLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreTextLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreTextLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Avenir-Heavy" size: 9], NSForegroundColorAttributeName: sleepScoreLabelTextColor, NSParagraphStyleAttributeName: sleepScoreTextLabelStyle};

    CGFloat sleepScoreTextLabelTextHeight = [localizedSleepScoreDescriptionLabel boundingRectWithSize: CGSizeMake(sleepScoreTextLabelRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreTextLabelFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreTextLabelRect);
    [localizedSleepScoreDescriptionLabel drawInRect: CGRectMake(CGRectGetMinX(sleepScoreTextLabelRect), CGRectGetMinY(sleepScoreTextLabelRect) + (CGRectGetHeight(sleepScoreTextLabelRect) - sleepScoreTextLabelTextHeight) / 2, CGRectGetWidth(sleepScoreTextLabelRect), sleepScoreTextLabelTextHeight) withAttributes: sleepScoreTextLabelFontAttributes];
    CGContextRestoreGState(context);
}

@end



@interface PCGradient ()
{
    CGGradientRef _CGGradient;
}
@end

@implementation PCGradient

- (instancetype)initWithColors: (NSArray*)colors locations: (const CGFloat*)locations
{
    self = super.init;
    if (self)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSMutableArray* cgColors = NSMutableArray.array;
        for (UIColor* color in colors)
            [cgColors addObject: (id)color.CGColor];

        _CGGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

+ (instancetype)gradientWithColors: (NSArray*)colors locations: (const CGFloat*)locations
{
    return [self.alloc initWithColors: colors locations: locations];
}

+ (instancetype)gradientWithStartingColor: (UIColor*)startingColor endingColor: (UIColor*)endingColor
{
    CGFloat locations[] = {0, 1};
    return [self.alloc initWithColors: @[startingColor, endingColor] locations: locations];
}

- (void)dealloc
{
    CGGradientRelease(_CGGradient);
}

@end



@implementation NSShadow (PaintCodeAdditions)

- (instancetype)initWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    self = super.init;
    if (self)
    {
        self.shadowColor = color;
        self.shadowOffset = offset;
        self.shadowBlurRadius = blurRadius;
    }
    return self;
}

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    return [self.alloc initWithColor: color offset: offset blurRadius: blurRadius];
}

- (void)set
{
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
}

@end
