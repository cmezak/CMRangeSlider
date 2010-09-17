//
//  AppDelegate_iPhone.h
//  RangeSlider
//
//  Created by Charlie Mezak on 9/16/10.
//  Copyright 2010 Natural Guides, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RangeSlider;
@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	RangeSlider *slider;
	UILabel *reportLabel;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

