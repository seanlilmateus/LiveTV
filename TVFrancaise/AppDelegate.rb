#
#  AppDelegate.rb
#  TVFrancaise
#
#  Created by Matt Aimonetti on 11/27/11.
#  Copyright 2011
#

class AppDelegate
  attr_accessor :window
  attr_accessor :outline
  attr_accessor :play_view
  attr_accessor :split_view

  LAST_CHANNEL_KEY = "org.mattetti.livetv-lastchannel"
  
  def applicationDidFinishLaunching(notification)
    # full screen mode for Lion only
		# remove fullscreen Leopard button
		window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary   
		NSNotificationCenter.defaultCenter.addObserver( self, 
																					selector: 'will_enter_fullscreen:',
																							name: NSWindowWillEnterFullScreenNotification,
																						object: window)
		NSNotificationCenter.defaultCenter.addObserver( self, 
																					selector: 'will_exit_fullscreen:',
																							name: NSWindowWillExitFullScreenNotification,
																						object: window)
  end
  
  def awakeFromNib
		channel_plist_path = NSBundle.mainBundle.pathForResource "channelList", ofType:"plist"
		@data = NSArray.arrayWithContentsOfFile channel_plist_path
    outline.expandItem(@data[0])
    # Starting channel
    defaults = NSUserDefaults.standardUserDefaults
    last_channel = defaults.objectForKey(LAST_CHANNEL_KEY)
    puts last_channel.inspect
    stream_channel(last_channel || "NRJ Pure")
  end
  
	def sourceList source_list, shouldSelectItem:item		
		return false if item.kind_of?(Hash)
		true
	end
	
	def sourceList source_list, numberOfChildrenOfItem:item
    item.nil? ? @data.size  : item[:child].count
	end
	
	def sourceList source_list, child:index, ofItem:item
    return nil if @data.nil?
    return @data[index] if item.nil?
    return item[:child][index].keys.first
	end
	
	def sourceList source_list, objectValueForItem:item
		item.kind_of?(Hash) ? NSLocalizedString(item[:group], value:nil) : item
	end
	
	def sourceList source_list, selectionIndexesForProposedSelection:selected_indexes
		item = outline.itemAtRow(selected_indexes.firstIndex)
    stream_channel(item)
		selected_indexes
	end
	
	def sourceList source_list, isItemExpandable:item
		item.kind_of?(Hash)
	end
	
	def sourceList source_list, itemHasBadge:item
		item.kind_of?(Hash)
	end
	
	def sourceList source_list, badgeValueForItem:item
		item[:child].count
	end
	
	def sourceList source_list, itemHasIcon:item
		not item.kind_of?(Hash)
	end
	
	def sourceList source_list, iconForItem:item
		NSImage.imageNamed "NSSlideshowTemplate"
	end
	
	# selection changed
	def sourceListSelectionDidChange notification		
		selected_indexes = outline.selectedRowIndexes
		if(selected_indexes.count > 1)
			# NSLog("multiple selected")
		elsif(selected_indexes.count == 1)
			row = selected_indexes.firstIndex
			identifier = outline.itemAtRow(row)
			view = selected_row_spinner(row)
			outline.addSubview view
			remove = MATimer.scheduledTimerWithTimeInterval 1.0, repeats:false, block: -> time {
				view.stopAnimation nil; view.removeFromSuperview
			}
			NSRunLoop.currentRunLoop.addTimer(remove, forMode:NSDefaultRunLoopMode)  
		else
			# NSLog("none selected")
		end
	end

	def selected_row_spinner row
		cell_frame =  outline.frameOfCellAtColumn(0, row:row)
		cell_frame.origin.x -= 40
		indicator = NSProgressIndicator.alloc.initWithFrame(cell_frame)
		indicator.indeterminate = true
		indicator.style = NSProgressIndicatorSpinningStyle
		indicator.controlSize = NSSmallControlSize
		indicator.usesThreadedAnimation = true
		indicator.displayedWhenStopped = false
		indicator.sizeToFit
		indicator.startAnimation nil
		indicator
	end
	
  def stream_channel(item)
    unless @last_item == item
      channel = @data.each do |cat| 
        match = cat[:child].detect{|(name, url)| name.keys.first == item}
        break match if match
      end
      return unless channel && channel.respond_to?(:values)
      @selected_channel = channel.keys.first
      value = channel.values.first
			
      url = NSURL.URLWithString(value)
			if @play_view.player
				@play_view.start_playingURL(url)
			else
				# puts "Changing channel"
				@play_view.initWithURL(url)
			end
    end
		@last_item = item
  end
						
  def will_enter_fullscreen(notification)
    # about to enter Lion's FS mode, collapsing the channel list panel
    @channel_panel_old_size = [split_view.subviews[0].frame[0].x, 
		                          split_view.subviews[0].frame[0].y, 
				                      330, #split_view.subviews[0].frame[1].width
				                      split_view.subviews[0].frame[1].height]
    split_view.subviews[0].frame = [0, 0, 0, split_view.subviews[0].frame[1].height]    
  end
    
  def will_exit_fullscreen(notification)
    # resizing the channel panel
    split_view.subviews[0].frame = @channel_panel_old_size if @channel_panel_old_size
  end
		
  
  def save_last_channel
    defaults = NSUserDefaults.standardUserDefaults
    defaults.setObject(@selected_channel, forKey: LAST_CHANNEL_KEY)
    defaults.synchronize
  end
	
  def windowWillClose(sender); save_last_channel; exit(1); end
  
  def applicationWillTerminate(notification)
    save_last_channel
  end
  
	# NSSplitterView delegate method => size configuration
	def splitView splitView, constrainMaxCoordinate:proposed_max, ofSubviewAt:divider_index
		300.0
	end	
end

