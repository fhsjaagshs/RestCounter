//
//  objc_msgSendCircumvention.m
//  Rest Counter
//
//  Created by Nathaniel Symer on 12/24/12.
//
//

#import "objc_msgSendCircumvention.h"
#include <objc/message.h>

// #define CurrentIMP __CurrentIMP(__PRETTY_FUNCTION__, _cmd)
/*static inline IMP __CurrentIMP(const char *info, SEL _cmd) {
    IMP imp = NULL;
    if (info[0] == '-' || info[0] == '+') {
        NSString *tmp = [NSString stringWithCString:info+2 encoding:NSUTF8StringEncoding];
        NSRange r = [tmp rangeOfString:@" "];
        NSString *className = [tmp substringToIndex:r.location];
        Class thisClass = NSClassFromString(className);
        if (thisClass != nil) {
            Method m = NULL;
            if (info[0] == '+') {
                m = class_getClassMethod(thisClass, _cmd);
            } else {
                m = class_getInstanceMethod(thisClass, _cmd);
            }
            if (m != NULL) {
                imp = method_getImplementation(m);
            }
        }
    }
    return imp;
}*/

static inline IMP getIMP(Class theClass, SEL _cmd) {
    IMP imp = nil;
    if (theClass) {
        Method m = class_getInstanceMethod(theClass, _cmd);
        if (m) {
            imp = method_getImplementation(m);
        }
    }
    return imp;
}

double callMSCDouble(id obj, SEL aSelector, Class class) {
    IMP imp = getIMP(class, aSelector);
    return ((double(*)(id,SEL))imp)(obj,aSelector);
}

int callMSCInt(id obj, SEL aSelector, Class class) {
    IMP imp = getIMP(class, aSelector);
    return ((int(*)(id,SEL))imp)(obj,aSelector);
}

id callMSC(id obj, SEL aSelector, Class class) {
    IMP imp = getIMP(class, aSelector);
    return imp(obj, aSelector);
}

id callMSCWithArg(id obj, SEL aSelector, Class class, id arg) {
    IMP imp = getIMP(class, aSelector);
    return imp(obj, aSelector, arg);
}


