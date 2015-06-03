//
//  JigsawVC.h
//  Kids
//
//  Created by Caio Coan on 3/2/15.
//  Copyright (c) 2015 Encripta. All rights reserved.
//

typedef enum : NSUInteger {
   jigsawKidMode,
   jigSawAdultMode
} jigsawMode;

#import <UIKit/UIKit.h>

@interface JigsawVC : UIViewController
@property int mode;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

-(void)fixCloseButton;
@end
