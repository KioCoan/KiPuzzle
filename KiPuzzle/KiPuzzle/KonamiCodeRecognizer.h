//
//  KonamiCodeRecognizer.h
//  Kids
//
//  Created by Caio Coan on 6/2/15.
//  Copyright (c) 2015 Encripta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum {
    DirectionUnknown = 0,
    DirectionLeft,
    DirectionRight
} Direction;

@interface KonamiCodeRecognizer : UIGestureRecognizer

@property int count;
@property CGPoint startPoint;
@property Direction lastDirection;

@end
