//
//  HEMWaveform.m
//  Sense
//
//  Created by Delisa Mason on 7/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMWaveform.h"
#import "HEMEventBubbleView.h"

@interface HEMWaveform ()
@property (nonatomic, readwrite) CGFloat minValue;
@property (nonatomic, readwrite) CGFloat maxValue;
@property (nonatomic, readwrite) NSArray *values;
@end

NSArray *validatedWaveformValues(NSArray *values) {
    if (![values isKindOfClass:[NSArray class]])
        return 0;
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:values.count];
    for (id value in values) {
        if ([value isKindOfClass:[NSNumber class]]) {
            [numbers addObject:value];
        }
    }
    return numbers;
}

@implementation HEMWaveform

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSString *const HEMWaveformMaxKey = @"max";
    NSString *const HEMWaveformMinKey = @"min";
    NSString *const HEMWaveformValuesKey = @"amplitudes";
    if (self = [super init]) {
        _maxValue = [dict[HEMWaveformMaxKey] floatValue];
        _minValue = [dict[HEMWaveformMinKey] floatValue];
        _values = validatedWaveformValues(dict[HEMWaveformValuesKey]);
    }
    return self;
}

- (UIImage *)waveformImageWithColor:(UIColor *)barColor {
    CGFloat const HEMWaveformBarSpace = 1.f;
    CGFloat const HEMWaveformBarWidth = 1.f;
    CGFloat x = 0;
    CGFloat width = HEMWaveformBarWidth * self.values.count + ((self.values.count - 1) * HEMWaveformBarSpace);
    CGFloat height = HEMEventBubbleWaveformHeight;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, barColor.CGColor);
    CGFloat diff = self.maxValue - self.minValue;
    for (NSNumber *value in self.values) {
        if (x + HEMWaveformBarWidth > width)
            break;
        CGFloat barHeight = height * (([value doubleValue] - self.minValue) / diff);
        CGFloat y = height - barHeight;
        CGContextFillRect(ctx, CGRectMake(x, y, HEMWaveformBarWidth, barHeight));
        x += HEMWaveformBarSpace + HEMWaveformBarWidth;
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (HEMWaveform *)faketrogram {
    return [[HEMWaveform alloc] initWithDictionary:@{
        @"amplitudes" : @[
            @(0.5024932585150947),
            @(0.500552078178026),
            @(0.499506022595712),
            @(0.4985494829410881),
            @(0.49648243485532734),
            @(0.5005761055924773),
            @(0.49936524127942944),
            @(0.500151897447681),
            @(0.5009045838230876),
            @(0.500027928417085),
            @(0.4986671689408937),
            @(0.5012700352733491),
            @(0.49957886432630444),
            @(0.4999840507679935),
            @(0.5011800360355981),
            @(0.5010697377752934),
            @(0.49862857318032383),
            @(0.4998023607072787),
            @(0.5008787267348346),
            @(0.5027959141795991),
            @(0.5006493270666891),
            @(0.5012091727278352),
            @(0.49967397284184106),
            @(0.49771667066202985),
            @(0.5019048285160669),
            @(0.49987050742585193),
            @(0.5000687681172229),
            @(0.498996199525859),
            @(0.4987496768727022),
            @(0.49910932860223417),
            @(0.4967986922458286),
            @(0.4994601771842301),
            @(0.5041130376617293),
            @(0.49757782258599054),
            @(0.4994490610528316),
            @(0.5027361563427956),
            @(0.4985104729147518),
            @(0.5003471892343927),
            @(0.5000410123108738),
            @(0.5000604828018947),
            @(0.5009847442488865),
            @(0.5001352577727305),
            @(0.5007336991944464),
            @(0.4978853458732501),
            @(0.49945886534263645),
            @(0.5014321857987486),
            @(0.4993774275973911),
            @(0.49869627111098347),
            @(0.49925722148083995),
            @(0.5041946480177107),
            @(0.5010114643908194),
            @(0.501381576330953),
            @(0.4974906886864571),
            @(0.49971087701719813),
            @(0.5007310755112592),
            @(0.5000805401694182),
            @(0.49990067978250496),
            @(0.49889332352720234),
            @(0.49851333825296945),
            @(0.5012951673965109),
            @(0.5028776971463165),
            @(0.5004140586335195),
            @(0.5013878593617435),
            @(0.49779230868654556),
            @(0.49628023863917564),
            @(0.5030268673443686),
            @(0.4988635309141686),
            @(0.4970378616816318),
            @(0.5012625094452595),
            @(0.5016964183134192),
            @(0.501740365006805),
            @(0.500762939453125),
            @(0.4960653382728542),
            @(0.5020543094134439),
            @(0.5026664906497454),
            @(0.49860364819004527),
            @(0.49944629928105555),
            @(0.4994254479041466),
            @(0.5002543246584241),
            @(0.5001610112945418),
            @(0.5031871536738193),
            @(0.4955334210287931),
            @(0.5013604832990137),
            @(0.4973304714013009),
            @(0.502291925352623),
            @(0.500556566057162),
            @(0.5000299307016226),
            @(0.4978351851933682),
            @(0.49924841833330386),
            @(0.4988902510561015),
            @(0.500238444470712),
            @(0.5001388135538921),
            @(0.5019167386568509),
            @(0.4982416834766509),
            @(0.49828345527476314),
            @(0.5002803198352659),
            @(0.4988426104929652),
            @(0.5007008341103117),
            @(0.5014745099512161),
            @(0.4997853758108562),
            @(0.5002409300653103),
            @(0.49527308951675625),
            @(0.5043194455798395),
            @(0.4986014732947716),
            @(0.5002061662630798),
            @(0.49863575378694147),
            @(0.5019140459293694),
            @(0.4994820297034078),
            @(0.5023880695325756),
            @(0.49947364082163814),
            @(0.5022220525266897),
            @(0.5009023744056668),
            @(0.500815344072575),
            @(0.4974661434397978),
            @(0.500279146082261),
            @(0.498567399935485),
            @(0.4952085331014918),
            @(0.5068253737229568),
            @(0.4985847300533795),
            @(0.5003756009615384),
            @(0.4986499078672936),
            @(0.5027648787692661),
            @(0.5006920309627757),
            @(0.4982777936426223),
            @(0.49901649854841273),
            @(0.49816041834214153),
            @(0.49732363601615526),
            @(0.49874422237344457),
            @(0.5042860971856441),
            @(0.49962722985453195),
            @(0.5006711450637196),
            @(0.4984915547780861),
            @(0.49630495649657097),
            @(0.49924613987158867),
            @(0.5016615854668941),
            @(0.5031058885393099),
            @(0.500721547398632),
            @(0.4958400467402255),
            @(0.5019090402180253),
            @(0.5028374788448282),
            @(0.5019976240477411),
            @(0.49752728216248937),
            @(0.4991366010985223),
            @(0.49834379998806916),
            @(0.5051682761351987),
            @(0.4971208874456483),
            @(0.5016728742090286),
            @(0.5036968041329363),
            @(0.4956198644853825),
            @(0.4998934301315929),
            @(0.49743034397315117),
            @(0.5055601715502156),
            @(0.49904566976279696),
            @(0.5003157050361461),
            @(0.49736982664910917),
            @(0.4975964990676259),
            @(0.5016794334169966),
            @(0.5000604137576004),
            @(0.5010612798492293),
            @(0.4974380424119768),
            @(0.499538093670461),
            @(0.5004187191233915),
            @(0.5018230800714968),
            @(0.5000188490923714),
            @(0.4991135057820454)
        ],
        @"min" : @(0.4952085331014918),
        @"max" : @(0.5068253737229568)
    }];
}

@end
