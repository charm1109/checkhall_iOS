//
//  Defines.h
//  checkhall
//
//  Created by pc on 2017. 12. 3..
//  Copyright © 2017년 pc. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

#define MAIN_COLOR  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]
#define SAVE_LOG_FILE_DIR           @"log"

#endif /* Defines_h */

#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog( s, ... )
#endif
