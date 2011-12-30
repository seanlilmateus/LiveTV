#
#  BackgroundView.rb
#  LiveTV
#
#  Created by Mateus Armando on 26.12.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
module Kernel # Localization Extensions
  private
  def NSLocalizedString(key, value:value)
		value = key if value.nil?
    NSBundle.mainBundle.localizedStringForKey(key, value:value, table:nil)
  end
end

class MATimer < NSTimer # Timer Extenstion
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


class NSEvent # NSEvent Extensions
	def self.cmdKey
		(GetCurrentKeyModifiers() & cmdKey) != 0
	end

	def self.shiftKey
		(GetCurrentKeyModifiers() & (shiftKey | rightShiftKey)) != 0
	end

	def self.optionKey
		(GetCurrentKeyModifiers() & (optionKey | rightOptionKey)) != 0
	end

	def self.controlKey
		(GetCurrentKeyModifiers() & (controlKey | rightControlKey)) != 0
	end

	def cmdKey
		self.modifierFlags & NSCommandKeyMask != 0
	end

	def shiftKey
		self.modifierFlags & NSShiftKeyMask != 0
	end

	def optionKey
		self.modifierFlags & NSAlternateKeyMask != 0
	end

	def controlKey
		self.modifierFlags & NSControlKeyMask != 0
	end
end

