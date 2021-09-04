
#==============================================================================
# Audio Extras [+Additional Features with XPA]
# ---
# Author: JaidenAlemni
# 
# --------------------------------------------------------------------------- 
# Version 1.3 - Sep 3rd, 2021
#   - Fixed some bugs and made available via Github.
# Version 1.2 - Feb 6th, 2019
#   - Changed the script so it would work in either vanilla RMXP or XPA. 
# Version 1.1 - Feb 5th, 2019
#   - Fixed a typo in the directions
#   - Shortened the "change_bgm/bgs/se_volume" methods to "change_bgm/bgs/se_vol"
#     so they would be friendlier with script calls. 
# Version 1.0 - Feb 4th, 2019
#   - Initial release
# --------------------------------------------------------------------------- 
# This script includes a few small audio features, as well as a special
# functionality to pause and resume an audio track if paired with 
# RPG Maker XP Ace.
#
# Features:
# -> Ability to pause and resume an audio track at any point [RGSS3/XPA ONLY]
# -> Decreasing the volume of BGM/BGS when entering / exiting buildings
# -> Master volume for decreasing and increasing all tracks throughout the game
#
# [[NOTE]]
# The pause/resume audio feature is only available through an audio method
# from RGSS3. Because of this, that feature will only work if you are running 
# RPG Maker VX Ace engine (via KK20's XPA) or an engine that provides access to 
# RGSS3 functions, such as MKXP-Z. 
#
# For more information on RPG Maker XP ACE and using RGSS3 functions in RMXP,
# visit this thread:
# https://forum.chaos-project.com/index.php?topic=12899.0
#
# This script is not intended for use in RPG Maker VX or VXA. 
#
# --------------------------------------------------------------------------- 
# ** Instructions:
# --------------------------------------------------------------------------- 
# [XPA/RGSS3 ONLY]
# -> To "Pause" the BGM at the current position, use the following script call:
#
#    AudioExtras.save_bgm
#
# [XPA/RGSS3 ONLY]
# -> To "Resume" a saved BGM track, use the following script call:
#
#    AudioExtras.resume_bgm
#
# Note that this function does not support MIDI; they will always resume from the beginning.
# --------------------------------------------------------------------------- 
#
# -> To mark a map as "Indoors" and automatically decrease the volume,
#
#    Use the following tag in your maps: [ind]
#
# For example, a map named "[ind]Inside House" will have its volume 
# lowered when you enter it. Note that the "[ind]" is automatically removed
# from the map name to avoid conflict with map name display scripts.
#
# Note that when the player moves from the next map without an [ind] tag,
# the volume will increase back to the original level. 
#
# -> To disable changing the volume level even when a map is marked [ind],
#
#   Set a switch with the same ID set in the configuration below. 
#
# This is useful for cutscenes where you change the audio track, but don't want
# the volume to increase or decrease further when the player changes maps.
#
# ---------------------------------------------------------------------------
# ** Additional Features: 
# ---------------------------------------------------------------------------
# This script also gives access to a master volume control, which can be 
# used to control the overall game volume, such as via events or a menu.
#
# -> The follow values are responsible for the master volume:
#
#    AudioExtras.bgm_volume
#    AudioExtras.bgs_volume
#    AudioExtras.se_volume
#
# -> You can set the master volume to any value (0 to 100):
#
#    AudioExtras.bgm_volume = VALUE
#    AudioExtras.bgs_volume = VALUE
#    AudioExtras.se_volume = VALUE
#
# -> Conversely, if you would like to INCREMENT/DECREMENT the value (-100 to 100):
#
#    AudioExtras.change_bgm_vol = VALUE
#    AudioExtras.change_bgs_vol = VALUE
#    AudioExtras.change_se_vol = VALUE
#
# This is useful when creating volume controls in-game where you want 
# to change the master volume by a set amount. 
#
# For example to set the BGM volume to 80%, you would use:
#
#   AudioExtras.bgm_volume = 80
#
# But if you wanted to DECREASE the SE volume by 20%, you would use:
#
#   AudioExtras.change_se = -20
#
#==============================================================================
module AudioExtras
    # ======================== # BEGIN CONFIGURATION # =========================  
    
      # Switch ID to disable decreasing the game volume when entering a house
      DISABLE_BGM_CHANGE = 14
    
      # Level (as a percentage) to decrease the volume when going indoors.
      # The default value is 20%
      LEVEL_DECREASE = 20
    
    #
    # = Please do not edit below this line unless you know what you are doing. =
    #
    # ======================== # END CONFIGURATION # ===========================
      # Skip these methods if running RGSS1
      unless defined?(Hangup)
        def self.save_bgm
          # Save the currently playing BGM  
          $game_system.bgm_save if !$game_system.playing_bgm.nil?
        end
        
        def self.resume_bgm
          # Resume the saved BGM
          $game_system.bgm_resume
        end
      end
      # End Skip
    
      def self.bgm_volume
        $game_system.bgm_master_vol
      end
    
      def self.bgs_volume
        $game_system.bgs_master_vol
      end
    
      def self.se_volume
        $game_system.se_master_vol
      end
    
      def self.bgm_volume=(value)
        # Set the master BGM volume 
        $game_system.bgm_master_vol = [[value, 0].max, 100].min
        # Set new BGM if playing
        if $game_system.playing_bgm != nil
          $game_system.bgm_play($game_system.playing_bgm)
        end  
      end
      
      def self.bgs_volume=(value)
        # Set the master BGS volume 
        $game_system.bgs_master_vol = [[value, 0].max, 100].min
        # Set new BGS if playing
        if $game_system.playing_bgs != nil
          $game_system.bgs_play($game_system.playing_bgs)
        end  
      end
    
      def self.se_volume=(value)
        # Set the master SE volume 
        $game_system.se_master_vol = [[value, 0].max, 100].min
      end
    
      def self.change_bgm_vol=(value)
        # Increment / Decrement the BGM volume
        $game_system.bgm_master_vol = $game_system.bgm_master_vol + value
        # Ensure the value isn't higher than 100 or lower than 0
        $game_system.bgm_master_vol = [[$game_system.bgm_master_vol, 0].max, 100].min
        # Set new BGM if playing
        if $game_system.playing_bgm != nil
          $game_system.bgm_play($game_system.playing_bgm)
        end      
      end
    
      def self.change_bgs_vol=(value)
        # Increment / Decrement the BGM volume
        $game_system.bgs_master_vol = $game_system.bgs_master_vol + value
        # Ensure the value isn't higher than 100 or lower than 0
        $game_system.bgs_master_vol = [[$game_system.bgs_master_vol, 0].max, 100].min
        # Set new BGS if playing
        if $game_system.playing_bgs != nil
          $game_system.bgs_play($game_system.playing_bgs)
        end  
      end
    
      def self.change_se_vol=(value)
        # Increment / Decrement the BGM volume
        $game_system.se_master_vol = $game_system.se_master_vol + value
        # Ensure the value isn't higher than 100 or lower than 0
        $game_system.se_master_vol = [[$game_system.se_master_vol, 0].max, 100].min
      end
    end
    
    
    #==============================================================================
    # ** Game_System
    #------------------------------------------------------------------------------
    #  This class handles data surrounding the system. Backround music, etc.
    #  is managed here as well. Refer to "$game_system" for the instance of 
    #  this class.
    #==============================================================================
    class Game_System
      #--------------------------------------------------------------------------
      # * Public Instance Variables
      #--------------------------------------------------------------------------
      attr_accessor :bgm_master_vol  # store bgm volume
      attr_accessor :bgs_master_vol  # store sfx volume
      attr_accessor :se_master_vol   # store se volume
      attr_accessor :saved_bgm_vol   # Saves the BGM volume
      attr_accessor :saved_bgs_vol   # Saves the BGS volume
      #--------------------------------------------------------------------------
      # * Object Initialization
      #--------------------------------------------------------------------------
      alias system_options_jaiden_initialize initialize
      def initialize
        system_options_jaiden_initialize
        # Initialize volume settings
        @bgm_master_vol = 100
        @bgs_master_vol = 100
        @se_master_vol = 100
        @saved_bgm_vol = nil
        @saved_bgs_vol = nil
      end
      #==========================================================================
      # The following methods for playing music and sounds have been REWRITTEN
      #--------------------------------------------------------------------------
      # * Play Background Music
      #--------------------------------------------------------------------------
      def bgm_play(bgm)
        @playing_bgm = bgm
        if bgm != nil and bgm.name != ""
          Audio.bgm_play("Audio/BGM/" + bgm.name, bgm.volume * @bgm_master_vol / 100, bgm.pitch)
        else
          Audio.bgm_stop
        end
        Graphics.frame_reset
      end
      #--------------------------------------------------------------------------
      # * Play Background Sound
      #--------------------------------------------------------------------------
      def bgs_play(bgs)
        @playing_bgs = bgs
        if bgs != nil and bgs.name != ""
          Audio.bgs_play("Audio/BGS/" + bgs.name, bgs.volume * @bgs_master_vol / 100, bgs.pitch)
        else
          Audio.bgs_stop
        end
        Graphics.frame_reset
      end
      #--------------------------------------------------------------------------
      # * Play Music Effect
      #--------------------------------------------------------------------------
      def me_play(me)
        if me != nil and me.name != ""
          Audio.me_play("Audio/ME/" + me.name, me.volume * @se_master_vol / 100, me.pitch)
        else
          Audio.me_stop
        end
        Graphics.frame_reset
      end
      #--------------------------------------------------------------------------
      # * Play Sound Effect
      #     se : sound effect to be played
      #--------------------------------------------------------------------------
      def se_play(se)
        if se != nil and se.name != ""
          Audio.se_play("Audio/SE/" + se.name, se.volume * @se_master_vol / 100, se.pitch)
        end
      end
      # Skip these methods if running RGSS1
      unless defined?(Hangup)
        #--------------------------------------------------------------------------
        # * Memorize BGM
        #--------------------------------------------------------------------------
        def bgm_save
          @memorized_bgm = @playing_bgm
          @position = Audio.bgm_pos
        end
        #--------------------------------------------------------------------------
        # * Resume memorized bgm
        #--------------------------------------------------------------------------
        def bgm_resume
          bgm = @memorized_bgm
          @memorized_bgm = nil
          return if @position.nil? || bgm.nil? || bgm.name == ""
          Audio.bgm_play("Audio/BGM/" + bgm.name, bgm.volume * @bgm_master_vol / 100, bgm.pitch, @position)
        end
      end
      # End Skip
    end
    
    
    #==============================================================================
    # ** Game_Map
    #==============================================================================
    class Game_Map
      #--------------------------------------------------------------------------
      # * Public Instance Variables
      #--------------------------------------------------------------------------
      attr_reader    :is_house # Determines if the map is a house
      attr_accessor  :name     # Map name
      #--------------------------------------------------------------------------
      # * Initialize
      #--------------------------------------------------------------------------
      alias jaiden_house_initialize initialize 
      def initialize
        jaiden_house_initialize
        @name = ""
      end
      #--------------------------------------------------------------------------
      # * Setup
      #     map_id : map ID
      #--------------------------------------------------------------------------
      alias jaiden_house_setup setup
      def setup(map_id)    
        jaiden_house_setup(map_id)
        # Store the map name
        @name = get_name(map_id)
        # Determine if it's a house, strip the name if it is.=
        @is_house = !self.name.scan(/\[ind\]/i).first.nil?
        self.name.gsub!(/\[ind\]/i, '')
      end
      #--------------------------------------------------------------------------
      # * Get name
      # Get the map name
      #--------------------------------------------------------------------------  
      def get_name(id = @map_id)
        map_info = load_data("Data/MapInfos.rxdata") 
        return map_info[id].name 
      end
      #--------------------------------------------------------------------------
      # * Automatically Change Background Music and Backround Sound < needs to move to scene_map
      #--------------------------------------------------------------------------
      def setup_house_bgm
        # If the map is indoors
        if @is_house
          # And we didn't already reduce the volume
          if $game_system.saved_bgm_vol.nil? 
            # Save the current volume
            $game_system.saved_bgm_vol = $game_system.bgm_master_vol
            # Decrease the volume
            AudioExtras.change_bgm_vol = -AudioExtras::LEVEL_DECREASE
          end
          if $game_system.saved_bgs_vol.nil?
            # Save the current volume
            $game_system.saved_bgs_vol = $game_system.bgs_master_vol
            # Decrease the volume
            AudioExtras.change_bgs_vol = -AudioExtras::LEVEL_DECREASE
          end
        # If the map is not outdoors
        elsif
          # And there is a saved volume
          unless $game_system.saved_bgm_vol.nil?
            # Set the master volume to the saved volume
            AudioExtras.bgm_volume = $game_system.saved_bgm_vol
            # Clear the saved volume
            $game_system.saved_bgm_vol = nil
          end
          unless $game_system.saved_bgs_vol.nil?
            # Set the master volume to the saved volume
            AudioExtras.bgs_volume = $game_system.saved_bgs_vol
            # Clear the saved volume
            $game_system.saved_bgs_vol = nil
          end
        end
      end
    end
    #==============================================================================
    # ** Scene_Map
    #==============================================================================
    class Scene_Map
      alias jaiden_house_transfer transfer_player
      def transfer_player
        jaiden_house_transfer
        # Check if BGM changing is disabled
        unless $game_switches[AudioExtras::DISABLE_BGM_CHANGE]
          $game_map.setup_house_bgm
        end
      end
    end