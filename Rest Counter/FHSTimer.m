//
//  FHSTimer.m
//  Rest Counter
//
//  Created by Nathaniel Symer on 11/6/13.
//
//

#import "FHSTimer.h"
#include <objc/message.h>

dispatch_source_t createDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block);

dispatch_source_t createDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_event_handler(timer, block);
        dispatch_source_set_cancel_handler(timer, ^{
            dispatch_release(timer);
        });
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), interval, leeway);
    }
    return timer;
}

@interface FHSTimer ()

@end

@implementation FHSTimer

- (instancetype)shared {
    static FHSTimer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class]alloc]init];
    });
    return shared;
}

- (void)addTarget:(id)target withSelector:(SEL)selector andTimeInterval:(float)timeInterval {
    createDispatchTimer(timeInterval*NSEC_PER_SEC, 0, dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            IMP imp = nil;
            
            Method m = class_getInstanceMethod([target class], selector);
            if (m) {
                imp = method_getImplementation(m);
            }
            imp(target,selector);
        });
    });
}

@end
