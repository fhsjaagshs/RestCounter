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

@synthesize beatInMeasure, beatsPerMeasure, beatsPerMeasure2, sc, autocount, measures;

- (void)loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIButton *mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mainButton.frame = self.view.bounds;
    mainButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [mainButton setTitle:@"Tap anywhere to count a beat" forState:UIControlStateNormal];
    [mainButton addTarget:self action:@selector(countRestButtonWasTapped) forControlEvents:UIControlEventTouchDown];
    [mainButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [mainButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainButton];
    [self.view sendSubviewToBack:mainButton];

    UILabel *autocountLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 407+(self.view.bounds.size.height-480), 79, 21)];
    autocountLabel.text = @"Autocount";
    autocountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    autocountLabel.textColor = [UIColor whiteColor];
    autocountLabel.backgroundColor = [UIColor clearColor];
    autocountLabel.font = [UIFont systemFontOfSize:17];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        autocountLabel.frame = CGRectMake(13, 932, 79, 21);
    }
    
    [self.view addSubview:autocountLabel];
    [self.view bringSubviewToFront:autocountLabel];
    [autocountLabel release];
    
    UILabel *beatsBarLabel = [[UILabel alloc]initWithFrame:CGRectMake(33, 0, 88, 22)];
    beatsBarLabel.text = @"Beats/Bar";
    beatsBarLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    beatsBarLabel.textColor = [UIColor whiteColor];
    beatsBarLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        beatsBarLabel.frame = CGRectMake(43, 11, 168, 44);
        beatsBarLabel.font = [UIFont boldSystemFontOfSize:26];
    } else {
        beatsBarLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    [self.view addSubview:beatsBarLabel];
    [self.view bringSubviewToFront:beatsBarLabel];
    [beatsBarLabel release];
    
    UISwitch *aSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(10, 436+(self.view.bounds.size.height-480), 79, 27)];
    [self setAutocount:aSwitch];
    [aSwitch release];
    self.autocount.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.autocount setOn:[[NSUserDefaults standardUserDefaults]boolForKey:@"shouldAutocount"]];
    [self.autocount addTarget:self action:@selector(autocountToggled) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.autocount];
    [self.view bringSubviewToFront:self.autocount];
    
    UILabel *barNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 13, 39, 21)];
    barNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    barNumberLabel.textColor = [UIColor whiteColor];
    barNumberLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        barNumberLabel.frame = CGRectMake(301, 6, 114, 32);
        barNumberLabel.font = [UIFont boldSystemFontOfSize:24];
        barNumberLabel.text = @"Measure:";
    } else {
        barNumberLabel.text = @"Bar:";
        barNumberLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    [self.view addSubview:barNumberLabel];
    [self.view bringSubviewToFront:barNumberLabel];
    [barNumberLabel release];
    
    UILabel *beatNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(192, 48, 52, 21)];
    beatNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    beatNumberLabel.textColor = [UIColor whiteColor];
    beatNumberLabel.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        beatNumberLabel.frame = CGRectMake(301, 46, 73, 36);
        beatNumberLabel.font = [UIFont boldSystemFontOfSize:25];
    } else {
        beatNumberLabel.font = [UIFont boldSystemFontOfSize:17];
        beatNumberLabel.text = @"Beat:";
    }
    
    [self.view addSubview:beatNumberLabel];
    [self.view bringSubviewToFront:beatNumberLabel];
    [beatNumberLabel release];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    resetButton.frame = CGRectMake(158, 81, 87, 37);
    [resetButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"resetbutton" ofType:@"png"]] forState:UIControlStateNormal];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [resetButton addTarget:self action:@selector(resetIt) forControlEvents:UIControlEventTouchUpInside];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        resetButton.frame = CGRectMake(301, 165, 125, 37);
        resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    } else {
        resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:23];
    }
    
    [self.view addSubview:resetButton];
    [self.view bringSubviewToFront:resetButton];
    
    UITextField *aFirstTextField = [[UITextField alloc]initWithFrame:CGRectMake(18, 26, 42, 42)];
    [self setBeatsPerMeasure:aFirstTextField];
    [aFirstTextField release];
    self.beatsPerMeasure.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.beatsPerMeasure setBackground:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"textfieldbg" ofType:@"png"]]];
    self.beatsPerMeasure.textAlignment = UITextAlignmentCenter;
    self.beatsPerMeasure.clearsOnBeginEditing = YES;
    self.beatsPerMeasure.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.beatsPerMeasure.keyboardType = UIKeyboardTypeDecimalPad;
    [self.beatsPerMeasure addTarget:self action:@selector(updateSegementedControlTitles) forControlEvents:UIControlEventEditingChanged];
    self.beatsPerMeasure.borderStyle = UITextBorderStyleNone;
    self.beatsPerMeasure.minimumFontSize = 10;
    self.beatsPerMeasure.adjustsFontSizeToFitWidth = YES;
    self.beatsPerMeasure.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.beatsPerMeasure.text = @"4";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.beatsPerMeasure.frame = CGRectMake(38, 73, 60, 60);
        self.beatsPerMeasure.font = [UIFont boldSystemFontOfSize:38];
    } else {
        self.beatsPerMeasure.font = [UIFont boldSystemFontOfSize:21];
    }
    
    [self.view addSubview:self.beatsPerMeasure];
    [self.view bringSubviewToFront:self.beatsPerMeasure];
    
    UITextField *aSecondTextField = [[UITextField alloc]initWithFrame:CGRectMake(82, 26, 42, 42)];
    [self setBeatsPerMeasure2:aSecondTextField];
    [aSecondTextField release];
    self.beatsPerMeasure2.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.beatsPerMeasure2 setBackground:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"textfieldbg" ofType:@"png"]]];
    self.beatsPerMeasure2.textAlignment = UITextAlignmentCenter;
    self.beatsPerMeasure2.clearsOnBeginEditing = YES;
    self.beatsPerMeasure2.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.beatsPerMeasure2.keyboardType = UIKeyboardTypeDecimalPad;
    [self.beatsPerMeasure2 addTarget:self action:@selector(updateSegementedControlTitles) forControlEvents:UIControlEventEditingChanged];
    self.beatsPerMeasure2.borderStyle = UITextBorderStyleNone;
    self.beatsPerMeasure2.minimumFontSize = 10;
    self.beatsPerMeasure2.adjustsFontSizeToFitWidth = YES;
    self.beatsPerMeasure2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.beatsPerMeasure2.frame = CGRectMake(139, 73, 60, 60);
        self.beatsPerMeasure2.font = [UIFont boldSystemFontOfSize:38];
    } else {
        self.beatsPerMeasure2.font = [UIFont boldSystemFontOfSize:21];
    }
    
    [self.view addSubview:self.beatsPerMeasure2];
    [self.view bringSubviewToFront:self.beatsPerMeasure2];
    
    UILabel *aMeasures = [[UILabel alloc]initWithFrame:CGRectMake(184, 6, 116, 36)];
    [self setMeasures:aMeasures];
    [aMeasures release];
    self.measures.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.measures.textColor = [UIColor colorWithRed:0.0f green:174.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    self.measures.font = [UIFont boldSystemFontOfSize:35];
    self.measures.textAlignment = UITextAlignmentLeft;
    self.measures.backgroundColor = [UIColor clearColor];
    [self.measures setText:@"1"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.measures.frame = CGRectMake(456, 4, 292, 36);
    }
    
    [self.view addSubview:self.measures];
    [self.view bringSubviewToFront:self.measures];
    
    UILabel *aBeatInMeasure = [[UILabel alloc]initWithFrame:CGRectMake(242, 43, 66, 31)];
    [self setBeatInMeasure:aBeatInMeasure];
    [aBeatInMeasure release];
    self.beatInMeasure.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.beatInMeasure.textColor = [UIColor colorWithRed:0.0f green:174.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    self.beatInMeasure.font = [UIFont boldSystemFontOfSize:30];
    self.beatInMeasure.textAlignment = UITextAlignmentLeft;
    self.beatInMeasure.backgroundColor = [UIColor clearColor];
    [self.beatInMeasure setText:@""];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.beatInMeasure.frame = CGRectMake(456, 45, 292, 37);
    }
    
    [self.view addSubview:self.beatInMeasure];
    [self.view bringSubviewToFront:self.beatInMeasure];
    
    [self.beatsPerMeasure setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"self.beatsPerMeasure.text"]];
    [self.beatsPerMeasure2 setText:[[NSUserDefaults standardUserDefaults]objectForKey:@"self.beatsPerMeasure2.text"]];
    
    if (self.beatsPerMeasure.text.length == 0) {
        [self.beatsPerMeasure setText:@"4"];
    }
    
    if (self.beatsPerMeasure2.text.length == 0) {
        [self.beatsPerMeasure2 setText:@"3"];
    }
    
    UISegmentedControl *aSegmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:self.beatsPerMeasure.text, self.beatsPerMeasure.text, nil]];
    [self setSc:aSegmentedControl];
    [aSegmentedControl release];
    self.sc.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.sc.segmentedControlStyle = UISegmentedControlStyleBordered;
    self.sc.frame = CGRectMake(10, 84, 134, 32);
    [self.sc setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"segmentedcontrolimage" ofType:@"png"]]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.sc setDividerImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"divider" ofType:@"png"]] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.sc setDividerImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"divider" ofType:@"png"]] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.sc.selectedSegmentIndex = 0;
    [self.sc addTarget:self action:@selector(scSwitched) forControlEvents:UIControlEventValueChanged];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.sc.frame = CGRectMake(20, 161, 204, 44);
    }
    
    [self.view addSubview:self.sc];
    [self.view bringSubviewToFront:self.sc];
    
    tapped = NO;
    [self scSwitched];
}

- (void)updateTitles {
    [self.sc setTitle:self.beatsPerMeasure.text forSegmentAtIndex:0];
    [self.sc setTitle:self.beatsPerMeasure2.text forSegmentAtIndex:1];
}

- (void)updateCurrentBPM {
    if (self.sc.selectedSegmentIndex == 0) {
        currentBPM = self.beatsPerMeasure.text.intValue;
    } else if (self.sc.selectedSegmentIndex == 1) {
        currentBPM = self.beatsPerMeasure2.text.intValue;
    }
    
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
    [self.measures setText:@"1"];
    [self.beatInMeasure setText:@""];
    tapped = NO;
    
    if (timerIsValid(timer)) {
        dispatch_source_cancel(timer);
    }
}

- (void)countBeat {
    UILabel *bim = [self beatInMeasure];

    int beatInMeasureV = bim.text.intValue;
    int finalValueY = beatInMeasureV+1;
    
    if (finalValueY > currentBPM) {
        UILabel *mes = [self measures];
        [bim setText:@"1"];
        [mes setText:[NSString stringWithFormat:@"%d",(mes.text.intValue+(beatInMeasureV/currentBPM))]];
    } else {
        [bim setText:[NSString stringWithFormat:@"%d",finalValueY]];
    }
}

- (void)countRestButtonWasTapped {
    if (self.autocount.on) {
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
    if ([self.beatsPerMeasure isFirstResponder]) {
        [self.beatsPerMeasure resignFirstResponder];
        [[NSUserDefaults standardUserDefaults]setObject:self.beatsPerMeasure.text forKey:@"self.beatsPerMeasure.text"];
    }
    
    if ([self.beatsPerMeasure2 isFirstResponder]) {
        [self.beatsPerMeasure2 resignFirstResponder];
        [[NSUserDefaults standardUserDefaults]setObject:self.beatsPerMeasure2.text forKey:@"self.beatsPerMeasure2.text"];
    }
    
    [self updateTitles];
    [self updateCurrentBPM];
}

- (void)autocountToggled {
    [[NSUserDefaults standardUserDefaults]setBool:self.autocount.on forKey:@"shouldAutocount"];
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
