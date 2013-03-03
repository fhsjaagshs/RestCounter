//
//  Rest_CounterViewController.h
//  Rest Counter
//
//  Created by Nathaniel Symer on 8/18/11.
//  Copyright 2011 Nathaniel Symer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    BOOL tapped;
    double firstTime;
    int currentBPM;
    dispatch_source_t timer;
}

@property (nonatomic, retain) UILabel *measures;
@property (nonatomic, retain) UILabel *beatInMeasure;
@property (nonatomic, retain) UITextField *beatsPerMeasure;
@property (nonatomic, retain) UITextField *beatsPerMeasure2;
@property (nonatomic, retain) UISwitch *autocount;
@property (nonatomic, retain) UISegmentedControl *sc;

@end
