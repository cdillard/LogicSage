//
//  MacPlugin.m
//  LogicSage
//
//  Created by Chris Dillard on 7/31/23.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MacPlugin.h"

@implementation MacPlugin

- (void) runLogicSage:(NSString*)path {

    NSTask *task = [NSTask new];

    [task setLaunchPath:@"/bin/zsh"];

    [task setArguments:@[@"-c", path]];
    NSPipe *output = [NSPipe new];

    [task setStandardOutput:output];

    [task launch];
    
    NSData * outputText = [[output fileHandleForReading] readDataToEndOfFile];

    NSString *outputTextText = [[NSString alloc] initWithData:outputText encoding:NSUTF8StringEncoding];

    NSLog(@"output = %@", outputTextText);
}

@end
