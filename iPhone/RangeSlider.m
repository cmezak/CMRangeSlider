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
#define CONTROL_WIDTH 20
#define CONTROL_HEIGHT 20

@interface RangeSlider ()

- (void)calculateMinMax;
- (void)setupSliders;

@end

@implementation RangeSlider

@synthesize min, max;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SLIDER_HEIGHT)])) {
		
		min = 0.0;
		max = 1.0;
				
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_HEIGHT)];
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];
		
		subRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, min*frame.size.width, SLIDER_HEIGHT)];
		inRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(min*frame.size.width, 0, (max-min)*frame.size.width, SLIDER_HEIGHT)];
		superRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(max*frame.size.width, 0, frame.size.width-frame.size.width*max, SLIDER_HEIGHT)];
		
		[self addSubview:subRangeTrackImageView];
		[self addSubview:inRangeTrackImageView];
		[self addSubview:superRangeTrackImageView];
		
		[self setupSliders];
				
		[self updateTrackImageViews];
		
	}
    return self;
}

- (void)setupSliders {
	
	minSlider = [[UIImageView alloc] initWithFrame:CGRectMake(min*self.frame.size.width, (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT)];
	minSlider.backgroundColor = [UIColor whiteColor];
	minSlider.contentMode = UIViewContentModeScaleToFill;
	
	maxSlider = [[UIImageView alloc] initWithFrame:CGRectMake(max*(self.frame.size.width-CONTROL_WIDTH), (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT)];
	maxSlider.backgroundColor = [UIColor whiteColor];
	maxSlider.contentMode = UIViewContentModeScaleToFill;
	
	[self addSubview:minSlider];
	[self addSubview:maxSlider];
	
}

- (void)setMinThumbImage:(UIImage *)image {
	minSlider.backgroundColor = [UIColor clearColor];
	minSlider.image = image;	
}

- (void)setMaxThumbImage:(UIImage *)image {
	maxSlider.backgroundColor = [UIColor clearColor];
	maxSlider.image = image;	
}

- (void)setSubRangeTrackImage:(UIImage *)image {
	subRangeTrackImageView.image = image;
	NSLog(@"set subrange image view with stretchable imag with left cap %d", subRangeTrackImageView.image.leftCapWidth);
}

- (void)setInRangeTrackImage:(UIImage *)image {
	inRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];
}

- (void)setSuperRangeTrackImage:(UIImage *)image {
	superRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	
	if (CGRectContainsPoint(minSlider.frame, [touch locationInView:self])) { //if touch is beginning on min slider
		trackingSlider = minSlider;
		NSLog(@"tracking min slider");
	} else if (CGRectContainsPoint(maxSlider.frame, [touch locationInView:self])) { //if touch is beginning on max slider
		trackingSlider = maxSlider;
		NSLog(@"tracking max slider");
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	
	float deltaX = [touch locationInView:self].x - [touch previousLocationInView:self].x;
	
	if (trackingSlider == minSlider) {
		float newX = MAX(0,MIN(minSlider.frame.origin.x+deltaX,self.frame.size.width-CONTROL_WIDTH*2.0));
		minSlider.frame = CGRectMake(newX, minSlider.frame.origin.y, minSlider.frame.size.width, minSlider.frame.size.height);
		maxSlider.frame = CGRectMake(MAX(maxSlider.frame.origin.x,minSlider.frame.origin.x+CONTROL_WIDTH), maxSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	} else if (trackingSlider == maxSlider) {
		float newX = MAX(CONTROL_WIDTH,MIN(maxSlider.frame.origin.x+deltaX,self.frame.size.width-CONTROL_WIDTH));
		maxSlider.frame = CGRectMake(newX, maxSlider.frame.origin.y, maxSlider.frame.size.width, maxSlider.frame.size.height);
		minSlider.frame = CGRectMake(MIN(minSlider.frame.origin.x,maxSlider.frame.origin.x-CONTROL_WIDTH), minSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	}
	
	[self calculateMinMax];
	[self updateTrackImageViews];
}

- (void)updateTrackImageViews {
	subRangeTrackImageView.frame = CGRectMake(CONTROL_WIDTH*0.5,
											  0,
											  MAX(minSlider.frame.origin.x,subRangeTrackImageView.image.size.width),
											  subRangeTrackImageView.frame.size.height);
	
	inRangeTrackImageView.frame = CGRectMake(minSlider.frame.origin.x+0.5*CONTROL_WIDTH,
											 0,
											 maxSlider.frame.origin.x-minSlider.frame.origin.x,
											 inRangeTrackImageView.frame.size.height);
	
	superRangeTrackImageView.frame = CGRectMake(maxSlider.frame.origin.x+0.5*CONTROL_WIDTH,
												0,
												self.frame.size.width-maxSlider.frame.origin.x-CONTROL_WIDTH,
												superRangeTrackImageView.frame.size.height);
}

- (void)calculateMinMax {
	float newMax = (maxSlider.frame.origin.x - CONTROL_WIDTH)/(self.frame.size.width-(2*CONTROL_WIDTH));
	float newMin = minSlider.frame.origin.x/(self.frame.size.width-2.0*CONTROL_WIDTH);
	
	if (newMin != min || newMax != max) {

		min = newMin;
		max = newMax;
		[self sendActionsForControlEvents:UIControlEventValueChanged];

	}

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
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
