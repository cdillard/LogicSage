//
//  Header.h
//  LogicSage
//
//  Created by Chris Dillard on 7/31/23.
//
#import "Plugin.h"

@interface MacPlugin : NSObject <Plugin>


- (void) runLogicSage:(NSString*)path;

@end
