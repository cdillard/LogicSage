//
//  Header.h
//  LogicSage
//
//  Created by Chris Dillard on 7/31/23.
//

@protocol Plugin <NSObject>

- (void) runLogicSage:(NSString*)path;

@end
