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
- (void)setupSliders;

@end

@implementation RangeSlider

@synthesize min, max, minimumRangeLength;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SLIDER_HEIGHT)])) {
		
		self.clipsToBounds = NO;
		
			// default values
		min = 0.0;
		max = 1.0;
		minimumRangeLength = 0.0;
				
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_HEIGHT)];
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];
		
		trackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-10, SLIDER_HEIGHT)];
		trackImageView.contentMode = UIViewContentModeScaleToFill;
		
		inRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(min*frame.size.width, 0, (max-min)*frame.size.width, SLIDER_HEIGHT)];
		inRangeTrackImageView.contentMode = UIViewContentModeScaleToFill;

		[self addSubview:trackImageView];
		[self addSubview:inRangeTrackImageView];
		
		[self setupSliders];
				
		[self updateTrackImageViews];
		
	}
    return self;
}

- (void)setupSliders {
	
	minSlider = [[UIImageView alloc] initWithFrame:CGRectMake(min*self.frame.size.width, (SLIDER_HEIGHT-self.frame.size.height)/2.0, self.frame.size.height, self.frame.size.height)];
	minSlider.backgroundColor = [UIColor whiteColor];
	minSlider.contentMode = UIViewContentModeScaleToFill;
	
	maxSlider = [[UIImageView alloc] initWithFrame:CGRectMake(max*(self.frame.size.width-self.frame.size.height), (SLIDER_HEIGHT-self.frame.size.height)/2.0, self.frame.size.height, self.frame.size.height)];
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

- (void)setInRangeTrackImage:(UIImage *)image {
	trackImageView.frame = CGRectMake(inRangeTrackImageView.frame.origin.x,trackImageView.frame.origin.y, inRangeTrackImageView.frame.size.width, trackImageView.frame.size.height);
	inRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];
	
}

- (void)setTrackImage:(UIImage *)image {
	trackImageView.frame = CGRectMake(5, MAX((self.frame.size.height-image.size.height)/2.0,0), self.frame.size.width-10, MIN(self.frame.size.height,image.size.height));
	trackImageView.image = image;
	inRangeTrackImageView.frame = CGRectMake(inRangeTrackImageView.frame.origin.x,trackImageView.frame.origin.y,inRangeTrackImageView.frame.size.width,trackImageView.frame.size.height);
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
						 0,
						 MIN(
							 minSlider.frame.origin.x+deltaX,
							 self.frame.size.width-self.frame.size.height*2.0-minimumRangeLength*(self.frame.size.width-self.frame.size.height*2.0))
						 );
		
		minSlider.frame = CGRectMake(
									 newX, 
									 minSlider.frame.origin.y, 
									 minSlider.frame.size.width, 
									 minSlider.frame.size.height
									 );
		
		maxSlider.frame = CGRectMake(
									 MAX(
										 maxSlider.frame.origin.x,
										 minSlider.frame.origin.x+self.frame.size.height+minimumRangeLength*(self.frame.size.width-self.frame.size.height*2.0)
										 ), 
									 maxSlider.frame.origin.y, 
									 self.frame.size.height, 
									 self.frame.size.height);
		
	} else if (trackingSlider == maxSlider) {
		
		float newX = MAX(
						 self.frame.size.height+minimumRangeLength*(self.frame.size.width-self.frame.size.height*2.0),
						 MIN(
							 maxSlider.frame.origin.x+deltaX,
							 self.frame.size.width-self.frame.size.height)
						 );
		
		maxSlider.frame = CGRectMake(
									 newX, 
									 maxSlider.frame.origin.y, 
									 maxSlider.frame.size.width, 
									 maxSlider.frame.size.height
									 );
		
		minSlider.frame = CGRectMake(
									 MIN(
										 minSlider.frame.origin.x,
										 maxSlider.frame.origin.x-self.frame.size.height-minimumRangeLength*(self.frame.size.width-2.0*self.frame.size.height)
										 ), 
									 minSlider.frame.origin.y, 
									 self.frame.size.height, 
									 self.frame.size.height);
	}
	
	[self calculateMinMax];
	[self updateTrackImageViews];
}

- (void)updateTrackImageViews {

	inRangeTrackImageView.frame = CGRectMake(minSlider.frame.origin.x+0.5*self.frame.size.height,
											 inRangeTrackImageView.frame.origin.y,
											 maxSlider.frame.origin.x-minSlider.frame.origin.x,
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
	float newMax = MIN(1,(maxSlider.frame.origin.x - self.frame.size.height)/(self.frame.size.width-(2*self.frame.size.height)));
	float newMin = MAX(0,minSlider.frame.origin.x/(self.frame.size.width-2.0*self.frame.size.height));
	
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
	
	maxSlider.frame = CGRectMake(max*(self.frame.size.width-2*self.frame.size.height)+self.frame.size.height, 
								 (SLIDER_HEIGHT-self.frame.size.height)/2.0, 
								 self.frame.size.height, 
								 self.frame.size.height);
	
	minSlider.frame = CGRectMake(MIN(
									 min*(self.frame.size.width-2*self.frame.size.height),
									 maxSlider.frame.origin.x-self.frame.size.height-(minimumRangeLength*(self.frame.size.width-self.frame.size.height*2.0))
									 ), 
								 (SLIDER_HEIGHT-self.frame.size.height)/2.0, 
								 self.frame.size.height, 
								 self.frame.size.height);
	
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
