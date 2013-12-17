//
//  RangeSlider.m
//  RangeSlider
//
//  Created by Charlie Mezak on 9/16/10.
//  Copyright 2010 Natural Guides, LLC. All rights reserved.
//

#import "RangeSlider.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDER_HEIGHT 30

@interface RangeSlider ()

- (void)calculateMinMax;

@end

@implementation RangeSlider
{
    float _maxLength;
    float _leftMargin;
}

@synthesize min, max, minimumRangeLength;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.clipsToBounds = NO;
		
        // default values
		min = 0.0;
		max = 1.0;
		minimumRangeLength = 0.0;
        
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.frame.size.height)];
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];

		
	}
    return self;
}

- (void)setMinThumbImage:(UIImage *)minImage maxThunbImage:(UIImage *)maxImage trackImage:(UIImage *)trackImage inRangeTrackImage:(UIImage *)inRangeTrackImage
{
    minSlider = [[UIImageView alloc] initWithImage:minImage];
    CGRect minSliderFrame = minSlider.frame;
    minSliderFrame.origin.x = 0;
    minSliderFrame.origin.y = (self.bounds.size.height - minSliderFrame.size.height) / 2;
    minSlider.frame = minSliderFrame;
    [self addSubview:minSlider];
	
	maxSlider = [[UIImageView alloc] initWithImage:maxImage];
    CGRect maxSliderFrame = maxSlider.frame;
    maxSliderFrame.origin.x = self.bounds.size.width - maxSliderFrame.size.width/2;
    maxSliderFrame.origin.y = (self.bounds.size.height - maxSliderFrame.size.height) / 2;
    maxSlider.frame = maxSliderFrame;
    [self addSubview:maxSlider];

    trackImageView = [[UIImageView alloc] initWithImage:trackImage];
    CGRect trackFrame = trackImageView.frame;
    trackFrame.origin.x = minSlider.bounds.size.width / 2;
    trackFrame.origin.y = (self.bounds.size.height - trackFrame.size.height) / 2;
    trackFrame.size.width = self.bounds.size.width - minSlider.bounds.size.width/2 - maxSlider.bounds.size.width/2;
    trackImageView.frame = trackFrame;
    [self addSubview:trackImageView];
    
    inRangeTrackImageView = [[UIImageView alloc] initWithImage:inRangeTrackImage];
    CGRect inRangeTrackFrame = inRangeTrackImageView.frame;
    inRangeTrackFrame.origin.y = (self.bounds.size.height - inRangeTrackFrame.size.height) / 2;
    inRangeTrackImageView.frame = inRangeTrackFrame;
    [self addSubview:inRangeTrackImageView];
    
    [self bringSubviewToFront:minSlider];
    [self bringSubviewToFront:maxSlider];
    
    _maxLength = trackImageView.frame.size.width;
    _leftMargin = trackImageView.frame.origin.x;
    
    [self updateThumbViews];
	[self updateTrackImageViews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	
	if (CGRectContainsPoint(minSlider.frame, [touch locationInView:self])) { //if touch is beginning on min slider
		trackingSlider = minSlider;
	} else if (CGRectContainsPoint(maxSlider.frame, [touch locationInView:self])) { //if touch is beginning on max slider
		trackingSlider = maxSlider;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	
	float deltaX = [touch locationInView:self].x - [touch previousLocationInView:self].x;
	
	if (trackingSlider == minSlider) {
		
		float newX = MAX(
						 _leftMargin,
						 MIN(
							 minSlider.center.x + deltaX,
							 _leftMargin + (1-minimumRangeLength) * _maxLength
                             ));
		
        minSlider.center = CGPointMake(newX, minSlider.center.y);
		
        maxSlider.center = CGPointMake(MAX(maxSlider.center.x, minSlider.center.x + minimumRangeLength * _maxLength), maxSlider.center.y);
		
	} else if (trackingSlider == maxSlider) {
		
        float newX = MAX(_leftMargin + minimumRangeLength*_maxLength, MIN(self.frame.size.width-maxSlider.frame.size.width/2, maxSlider.center.x+deltaX));
        
        maxSlider.center = CGPointMake(newX, maxSlider.center.y);
        
        minSlider.center = CGPointMake(MIN(minSlider.center.x, maxSlider.center.x-minimumRangeLength*_maxLength), minSlider.center.y);
	}
    
    NSLog(@"%f", minSlider.center.x);
	
	[self calculateMinMax];
	[self updateTrackImageViews];
}

- (void)updateTrackImageViews {

	inRangeTrackImageView.frame = CGRectMake(minSlider.center.x,
											 inRangeTrackImageView.frame.origin.y,
											 maxSlider.center.x-minSlider.center.x,
											 inRangeTrackImageView.frame.size.height);

}

- (void)setMin:(CGFloat)newMin {
	min = MIN(1.0,MAX(0,newMin)); //value must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
}

- (void)setMax:(CGFloat)newMax {
	max = MIN(1.0,MAX(0,newMax)); //value must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
}

- (void)calculateMinMax {
	float newMax = MIN(1, (maxSlider.center.x - _leftMargin) / _maxLength);
    float newMin = MAX(0, (minSlider.center.x - _leftMargin) / _maxLength);
	
	if (newMin != min || newMax != max) {

		min = newMin;
		max = newMax;
		[self sendActionsForControlEvents:UIControlEventValueChanged];

	}

}

- (void)setMinimumRangeLength:(CGFloat)length {
	minimumRangeLength = MIN(1.0,MAX(length,0.0)); //length must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
}

- (void)updateThumbViews {
	
    maxSlider.center = CGPointMake(_leftMargin + max*_maxLength, maxSlider.center.y);
    minSlider.center = CGPointMake(MIN(
                                       _leftMargin + min*_maxLength,
                                       maxSlider.center.x - minimumRangeLength*_maxLength
                                       ), minSlider.center.y);
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	trackingSlider = nil; //we are no longer tracking either slider
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
	[backgroundImageView release];
	[minSlider release];
	[maxSlider release];
    [super dealloc];
}


@end
