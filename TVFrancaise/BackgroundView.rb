#
#  BackgroundView.rb
#  LiveTV
#
#  Created by Mateus Armando on 26.12.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class NSTimer
	def self.scheduledTimerWithTimeInterval interval, repeats: repeat_flag, block: block
		self.scheduledTimerWithTimeInterval interval, 
																target: self, 
															selector: 'executeBlockFromTimer:', 
															userInfo: block, 
															 repeats: repeat_flag
	end
	def self.timerWithTimeInterval interval, repeats: repeat_flag, block: block
		self.timerWithTimeInterval interval, 
											 target: self, 
										 selector: 'executeBlockFromTimer:', 
										 userInfo: block, 
											repeats: repeat_flag
	end
	def self.executeBlockFromTimer aTimer
		blck = aTimer.userInfo
		time = aTimer.timeInterval
		blck[time] if blck
	end
end

class BackgroundView < QTMovieView	
	def updateTrackingAreas
		super	
		rectMouseOver = NSInsetRect(self.bounds, 0, 2)
		if (@trackingMouseOverArea == nil || !NSEqualRects(rectMouseOver, @rectMouseOver))
			# remove old tracking area if we have one to remove
			if (@trackingMouseOverArea)
				self.removeTrackingArea @trackingMouseOverArea
				@trackingMouseOverArea = nil;
			end
			# Allocate and add new tracking area
			opts = NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingAssumeInside
			@trackingMouseOverArea = NSTrackingArea.alloc.initWithRect rectMouseOver, options:opts, owner:self, userInfo:nil
			self.addTrackingArea @trackingMouseOverArea
			@rectMouseOver = rectMouseOver
		end
	end
	
	def mouseEntered the_event
		super the_event
		hide_cursor
	end
	
	def hide_cursor
		if mouse_inside? 
			@remove_cursor = NSTimer.scheduledTimerWithTimeInterval 2.0, repeats:false, block: -> time do
				NSCursor.hiddenUntilMouseMoves = true
			end
			loop = NSRunLoop.currentRunLoop.addTimer(@remove_cursor, forMode:NSDefaultRunLoopMode)  
		end
	end
	
	def mouseMoved the_event
		super the_event
		hide_cursor
	end
	
	def mouse_inside?
		window_point = self.window.mouseLocationOutsideOfEventStream
		local_Point = self.convertPoint window_point, fromView:nil
		(self.mouse local_Point, inRect:self.visibleRect) ? true : false
	end
	
	def mouseExited the_event
		super the_event
		@remove_cursor.invalidate if @remove_cursor
	end

	def awakeFromNib
		self.window.setAcceptsMouseMovedEvents true
		NSLog("awakeFromNib")
		hide_cursor	
	end
	
end
