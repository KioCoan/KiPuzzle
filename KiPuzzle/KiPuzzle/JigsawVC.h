//
//  JigsawVC.h
//  Kids
//
//  Created by Caio Coan on 3/2/15.
//  Copyright (c) 2015 Encripta. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
   jigsawKidMode,
   jigSawAdultMode
} jigsawMode;

#import <UIKit/UIKit.h>

@interface JigsawVC : UIViewController
@property int mode;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property(strong,nonatomic)NSString* currentImage;
@property(strong,nonatomic)NSString* numberHorizontal;
@property(strong,nonatomic)NSString* numberVertical;

-(void)fixCloseButton;
@end
