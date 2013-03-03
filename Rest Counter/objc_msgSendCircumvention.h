//
//  objc_msgSendCircumvention.h
//  Rest Counter
//
//  Created by Nathaniel Symer on 12/24/12.
//
//

#import <Foundation/Foundation.h>

double callMSCDouble(id obj, SEL aSelector, Class class);
int callMSCInt(id obj, SEL aSelector, Class class);
id callMSC(id obj, SEL aSelector, Class class);
id callMSCWithArg(id obj, SEL aSelector, Class class, id arg);

