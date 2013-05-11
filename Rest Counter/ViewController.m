//
//  Rest_CounterViewController.m
//  Rest Counter
//
//  Created by Nathaniel Symer on 8/18/11.
//  Copyright 2011 Nathaniel Symer. All rights reserved.
//

#import "ViewController.h"

dispatch_source_t createDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block);
BOOL timerIsValid(dispatch_source_t aTimer);

dispatch_source_t createDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_source_set_cancel_handler(timer, ^{
            dispatch_release(timer);
        });
    }
    return timer;
}

BOOL timerIsValid(dispatch_source_t aTimer) {
    if (aTimer != nil) {
        if (dispatch_source_testcancel(aTimer) == 0) {
            return YES;
        }
    }
    return NO;
}

@implementation ViewController

- (void)loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    UIButton *mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mainButton.frame = self.view.bounds;
    mainButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [mainButton setTitle:@"Tap anywhere to count a beat" forState:UIControlStateNormal];
    [mainButton addTarget:self action:@selector(countRestButtonWasTapped) forControlEvents:UIControlEventTouchDown];
    [mainButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [mainButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainButton];
    [self.view sendSubviewToBack:mainButton];

    UILabel *autocountLabel = [[UILabel alloc]initWithFrame:iPad?CGRectMake(13, 932, 79, 21):CGRectMake(10, 407+(self.view.bounds.size.height-480), 79, 21)];
    autocountLabel.text = @"Autocount";
    autocountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    autocountLabel.textColor = [UIColor whiteColor];
    autocountLabel.backgroundColor = [UIColor clearColor];
    autocountLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:autocountLabel];
    [self.view bringSubviewToFront:autocountLabel];
    [autocountLabel release];
    
    UILabel *beatsBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(33, 0, 88, 22)];
    beatsBarLabel.text = @"Beats/Bar";
    beatsBarLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    beatsBarLabel.textColor = [UIColor whiteColor];
    beatsBarLabel.backgroundColor = [UIColor clearColor];
    beatsBarLabel.font = [UIFont boldSystemFontOfSize:iPad?26:17];
    [self.view addSubview:beatsBarLabel];
    [self.view bringSubviewToFront:beatsBarLabel];
    [beatsBarLabel release];

    self.autocount = [[[UISwitch alloc]initWithFrame:CGRectMake(10, 436+(self.view.bounds.size.height-480), 79, 27)]autorelease];
    _autocount.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [_autocount setOn:[[NSUserDefaults standardUserDefaults]boolForKey:@"shouldAutocount"]];
    [_autocount addTarget:self action:@selector(autocountToggled) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_autocount];
    [self.view bringSubviewToFront:_autocount];
    
    UILabel *barNumberLabel = [[UILabel alloc]initWithFrame:iPad?CGRectMake(301, 6, 114, 32):CGRectMake(140, 13, 39, 21)];
    barNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    barNumberLabel.textColor = [UIColor whiteColor];
    barNumberLabel.backgroundColor = [UIColor clearColor];
    barNumberLabel.font = [UIFont boldSystemFontOfSize:iPad?24:17];
    barNumberLabel.text = iPad?@"Measure:":@"Bar:";
    [self.view addSubview:barNumberLabel];
    [self.view bringSubviewToFront:barNumberLabel];
    [barNumberLabel release];
    
    UILabel *beatNumberLabel = [[UILabel alloc]initWithFrame:iPad?CGRectMake(301, 46, 73, 36):CGRectMake(192, 48, 52, 21)];
    beatNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    beatNumberLabel.textColor = [UIColor whiteColor];
    beatNumberLabel.backgroundColor = [UIColor clearColor];
    beatNumberLabel.text = @"Beat:";
    beatsBarLabel.font = [UIFont boldSystemFontOfSize:iPad?25:17];
    [self.view addSubview:beatNumberLabel];
    [self.view bringSubviewToFront:beatNumberLabel];
    [beatNumberLabel release];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    resetButton.frame = iPad?CGRectMake(301, 165, 125, 37):CGRectMake(158, 81, 87, 37);
    resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:iPad?28:23];
    [resetButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"resetbutton" ofType:@"png"]] forState:UIControlStateNormal];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetIt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    [self.view bringSubviewToFront:resetButton];
    
    UIImage *textFieldBG = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"textfieldbg" ofType:@"png"]];

    self.beatsPerMeasure = [[[UITextField alloc]initWithFrame:iPad?CGRectMake(38, 73, 60, 60):CGRectMake(18, 26, 42, 42)]autorelease];
    [_beatsPerMeasure addTarget:self action:@selector(updateSegementedControlTitles) forControlEvents:UIControlEventEditingChanged];
    _beatsPerMeasure.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _beatsPerMeasure.background = textFieldBG;
    _beatsPerMeasure.textAlignment = UITextAlignmentCenter;
    _beatsPerMeasure.clearsOnBeginEditing = YES;
    _beatsPerMeasure.keyboardAppearance = UIKeyboardAppearanceAlert;
    _beatsPerMeasure.keyboardType = UIKeyboardTypeDecimalPad;
    _beatsPerMeasure.borderStyle = UITextBorderStyleNone;
    _beatsPerMeasure.minimumFontSize = 10;
    _beatsPerMeasure.adjustsFontSizeToFitWidth = YES;
    _beatsPerMeasure.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _beatsPerMeasure.text = @"4";
    _beatsPerMeasure.font = [UIFont boldSystemFontOfSize:iPad?38:21];
    [self.view addSubview:_beatsPerMeasure];
    [self.view bringSubviewToFront:_beatsPerMeasure];
    
    self.beatsPerMeasure2 = [[[UITextField alloc]initWithFrame:iPad?CGRectMake(139, 73, 60, 60):CGRectMake(82, 26, 42, 42)]autorelease];
    [_beatsPerMeasure2 addTarget:self action:@selector(updateSegementedControlTitles) forControlEvents:UIControlEventEditingChanged];
    _beatsPerMeasure2.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _beatsPerMeasure2.background = textFieldBG;
    _beatsPerMeasure2.textAlignment = UITextAlignmentCenter;
    _beatsPerMeasure2.clearsOnBeginEditing = YES;
    _beatsPerMeasure2.keyboardAppearance = UIKeyboardAppearanceAlert;
    _beatsPerMeasure2.keyboardType = UIKeyboardTypeDecimalPad;
    _beatsPerMeasure2.borderStyle = UITextBorderStyleNone;
    _beatsPerMeasure2.minimumFontSize = 10;
    _beatsPerMeasure2.adjustsFontSizeToFitWidth = YES;
    _beatsPerMeasure2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _beatsPerMeasure2.font = [UIFont boldSystemFontOfSize:iPad?38:21];
    [self.view addSubview:_beatsPerMeasure2];
    [self.view bringSubviewToFront:_beatsPerMeasure2];
    
    self.measures = [[[UILabel alloc]initWithFrame:iPad?CGRectMake(456, 4, 292, 36):CGRectMake(184, 6, 116, 36)]autorelease];
    _measures.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _measures.textColor = [UIColor colorWithRed:0.0f green:174.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    _measures.font = [UIFont boldSystemFontOfSize:35];
    _measures.textAlignment = UITextAlignmentLeft;
    _measures.backgroundColor = [UIColor clearColor];
    _measures.text = @"1";
    [self.view addSubview:_measures];
    [self.view bringSubviewToFront:_measures];

    self.beatInMeasure = [[[UILabel alloc]initWithFrame:iPad?CGRectMake(456, 45, 292, 37):CGRectMake(242, 43, 66, 31)]autorelease];
    _beatInMeasure.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _beatInMeasure.textColor = [UIColor colorWithRed:0.0f green:174.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    _beatInMeasure.font = [UIFont boldSystemFontOfSize:30];
    _beatInMeasure.textAlignment = UITextAlignmentLeft;
    _beatInMeasure.backgroundColor = [UIColor clearColor];
    _beatInMeasure.text = @"1";
    [self.view addSubview:_beatInMeasure];
    [self.view bringSubviewToFront:_beatInMeasure];
    
    [_beatsPerMeasure setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"self.beatsPerMeasure.text"]];
    [_beatsPerMeasure2 setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"self.beatsPerMeasure2.text"]];
    
    if (_beatsPerMeasure.text.length == 0) {
        [_beatsPerMeasure setText:@"4"];
    }
    
    if (_beatsPerMeasure2.text.length == 0) {
        [_beatsPerMeasure2 setText:@"3"];
    }
    
    UIImage *divider = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"divider" ofType:@"png"]];
    
    self.sc = [[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:_beatsPerMeasure.text, _beatsPerMeasure.text, nil]]autorelease];
    _sc.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _sc.segmentedControlStyle = UISegmentedControlStyleBordered;
    _sc.frame = iPad?CGRectMake(20, 161, 204, 44):CGRectMake(10, 84, 134, 32);
    [_sc setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"segmentedcontrolimage" ofType:@"png"]]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_sc setDividerImage:divider forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_sc setDividerImage:divider forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    _sc.selectedSegmentIndex = 0;
    [_sc addTarget:self action:@selector(scSwitched) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_sc];
    [self.view bringSubviewToFront:_sc];
    
    [self scSwitched];
}

- (void)updateTitles {
    [_sc setTitle:_beatsPerMeasure.text forSegmentAtIndex:0];
    [_sc setTitle:_beatsPerMeasure2.text forSegmentAtIndex:1];
}

- (void)updateCurrentBPM {
    currentBPM = (_sc.selectedSegmentIndex == 0)?_beatsPerMeasure.text.intValue:_beatsPerMeasure2.text.intValue;
    
    if (currentBPM == 0) {
        currentBPM = 1;
    }
}

- (void)scSwitched {
    [self resetIt];
    [self updateTitles];
    [self updateCurrentBPM];
}

- (void)resetIt {
    [_measures setText:@"1"];
    [_beatInMeasure setText:@""];
    tapped = NO;
    
    if (timerIsValid(timer)) {
        dispatch_source_cancel(timer);
    }
}

- (void)countBeat {
    int beatInMeasureV = _beatInMeasure.text.intValue;
    int finalValueY = beatInMeasureV+1;
    
    if (finalValueY > currentBPM) {
        [_beatInMeasure setText:@"1"];
        [_measures setText:[NSString stringWithFormat:@"%d",(_measures.text.intValue+(beatInMeasureV/currentBPM))]];
    } else {
        [_beatInMeasure setText:[NSString stringWithFormat:@"%d",finalValueY]];
    }
}

- (void)countRestButtonWasTapped {
    if (_autocount.on) {
        if (!tapped) {
            firstTime = CACurrentMediaTime();
            tapped = YES;
            [self countBeat];
        } else if (tapped && !timerIsValid(timer)) {
            double timeInterval = CACurrentMediaTime()-firstTime;
            firstTime = 0;
            timer = createDispatchTimer(timeInterval*NSEC_PER_SEC, 0, dispatch_get_main_queue(), ^{
                [self countBeat];
            });
            dispatch_resume(timer);
        }
    } else {
        [self countBeat];
    }
}

- (void)updateSegementedControlTitles {
    if ([_beatsPerMeasure isFirstResponder]) {
        [_beatsPerMeasure resignFirstResponder];
        [[NSUserDefaults standardUserDefaults]setObject:_beatsPerMeasure.text forKey:@"self.beatsPerMeasure.text"];
    }
    
    if ([_beatsPerMeasure2 isFirstResponder]) {
        [_beatsPerMeasure2 resignFirstResponder];
        [[NSUserDefaults standardUserDefaults]setObject:_beatsPerMeasure2.text forKey:@"self.beatsPerMeasure2.text"];
    }
    
    [self updateTitles];
    [self updateCurrentBPM];
}

- (void)autocountToggled {
    [[NSUserDefaults standardUserDefaults]setBool:_autocount.on forKey:@"shouldAutocount"];
    [self resetIt];
}

- (void)dealloc {
    [self setBeatsPerMeasure2:nil];
    [self setBeatsPerMeasure:nil];
    [self setAutocount:nil];
    [self setSc:nil];
    [self setMeasures:nil];
    [self setBeatInMeasure:nil];
    [super dealloc];
}

@end
