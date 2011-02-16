//
//  RangeSlider.h
//  RangeSlider
//
//  Created by Charlie Mezak on 9/16/10.
//  Copyright 2010 Natural Guides, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RangeSlider : UIControl {

	CGFloat min, max; //the min and max of the range	
	CGFloat minimumRangeLength; //the minimum allowed range size
	
	UIImageView *minSlider, *maxSlider, *backgroundImageView, *trackImageView, *inRangeTrackImageView; // the sliders representing the min and max, and a background view;
	UIView *trackingSlider; // a variable to keep track of which slider we are tracking (if either)
}

@property (nonatomic) CGFloat min, max, minimumRangeLength;
- (void)setMinThumbImage:(UIImage *)image;
- (void)setMaxThumbImage:(UIImage *)image;
- (void)setTrackImage:(UIImage *)image;
- (void)setInRangeTrackImage:(UIImage *)image;
@end
