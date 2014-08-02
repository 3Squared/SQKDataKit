//
//  Bundle.h
//  SQKDataKit
//
//  Created by Luke Stringer on 01/12/2013.
//  Copyright (c) 2013 3Squared. All rights reserved.
//

#ifndef SDCAlertView_Bundle_h
#define SDCAlertView_Bundle_h


static BOOL isRunningFromTestBundle(void)
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return ([[injectBundle pathExtension] isEqualToString:@"octest"]
            || [[injectBundle pathExtension] isEqualToString:@"xctest"]);
}

static BOOL isRunningFromProductionBundle(void)
{
    return !isRunningFromTestBundle();
}


#endif
