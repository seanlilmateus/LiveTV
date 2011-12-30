#
#  LTPlayerView.rb
#  LiveTV
#
#  Created by Mateus Armando on 30.12.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class LTPlayerView < NSView	
  def self.layerClass
      AVPlayerLayer.class
  end
	
	def awakeFromNib
		self.wantsLayer = true
		color = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1)
    self.layer.backgroundColor = color
    CGColorRelease(color)
	end

  def initWithURL url
		asset = AVURLAsset.URLAssetWithURL url, options:nil
		hander_block = -> do
			@status = asset.statusOfValueForKey("tracks", error:nil)
			#The completion block goes here.
			Dispatch::Queue.main.async do
				error = nil          
				if (@status == AVKeyValueStatusLoaded)
					player_item = AVPlayerItem.playerItemWithAsset(asset)            
					player = AVPlayer.playerWithPlayerItem player_item
					self.player = player
					player.play 
				else
					# You should deal with the error appropriately.
					NSLog("The asset's tracks were not loaded:#{error[0].localizedDescription}")
				end
			end
		end
		asset.loadValuesAsynchronouslyForKeys ["tracks"], completionHandler:hander_block
	end

    
  def player
    self.layer.respond_to?(:player) ? self.layer.player : nil
  end
  
  def start_playingURL(contentURL)
    new_asset = AVURLAsset.URLAssetWithURL contentURL, options:nil
		new_player_item = AVPlayerItem.playerItemWithAsset new_asset
		player.pause
		player.replaceCurrentItemWithPlayerItem new_player_item
		player.play
  end
  
  def player=(player)
    av_player_layer = AVPlayerLayer.playerLayerWithPlayer player
		color = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1)
    av_player_layer.backgroundColor = color
    CGColorRelease(color)
    av_player_layer.videoGravity = AVLayerVideoGravityResize
		# AVLayerVideoGravityResize or AVLayerVideoGravityResizeAspectFill AVLayerVideoGravityResizeAspect
    self.layer = av_player_layer
  end
end

