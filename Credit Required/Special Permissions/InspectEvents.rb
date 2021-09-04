
#==============================================================================
# Inspect Events
# ---
# Authors: Jaiden Alemni, KK20
# https://github.com/JaidenAlemni/rmxp-scripts
#
# [Special Permissions]
# KK20 was a collaborator on this script. Please be sure to credit them 
# alongside Jaiden when using this script in your projects.
#==============================================================================
# v2.1 - September 2021
# - Fixed some bugs and made available via Github.
# v2.0 - March 2019
# - Added the capability to configure the inspect direction
# - KK20 fixed all that logic 'cuz it was bad
# v1.0 September 2018
# - Initial release
#==============================================================================
# Checks if an event is flagged for "inspection" and displays an
# animation above the player indicating it can be interacted with. 
#
# [Compatibility]
# This script aliases methods in the following classes:
# * Game_Character
# * Game_Event
# * Game_Map
# * Sprite_Character
# It may not be compatible with other scripts that have heavily
# modified these classes
#
# [How to Use]
# Create a comment with the text \inspect_event in the page of 
# an event that you want to have display an animaton over the player when
# they are facing it. Then, set the animation ID below. 
#
# [Multiple Directions]
# You can also set specific directions that will trigger the animation.
# Assuming the player is 0, imagine the directions like this:
#    8
# 4  0  6
#    2
# 
# For example, \inspect_event[4,6] will only display the animation when
# the player is facing the event from the left and right.
# Use \inspect_event[0] to only display when the player is on top of the event.
#
# Specifying no direction will show the animation when the player faces
# the event from any direction.
#==============================================================================
module InspectEvent
    #--------------------------------------------------------------------------
    # Animation ID 
    #--------------------------------------------------------------------------
    # Set this value to the ID in your animation database that you want
    # to display to indicate that an event can be inspected
    EVENT_ANIMATION_ID = 120
    #--------------------------------------------------------------------------
  end
  #==============================================================================
  # END CONFIGURATION / DOCUMENTATION
  #==============================================================================
  
  #==============================================================================
  # ** Game_Character
  #==============================================================================
  class Game_Character
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    # inspect_event - flags an event for interation
    # inspect_dir_flags - Array of directions for inspection
    #   0 = Center (animation displays when player is on the event)
    #   4 = Left
    #   8 = Above
    #   6 = Right
    #   2 = Below
    # animation_loop_id - id for a looped animation
    #--------------------------------------------------------------------------
    attr_accessor    :inspect_event
    attr_accessor    :inspect_dir_flags
    attr_accessor    :animation_loop_id
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    alias inspect_event_initialize initialize 
    def initialize
      inspect_event_initialize
      # Flag to determine if an event can be inspected
      @inspect_event = false
      # Array of directions
      @inspect_dir_flags = []
      # ID for looped animations
      @animation_loop_id = 0
    end
  end
  
  #==============================================================================
  # ** Game_Event
  #==============================================================================
  class Game_Event
    alias inspect_event_refresh refresh
    def refresh
      prev_page = @page
      # Call original
      inspect_event_refresh
      return if prev_page == @page
      # Initialize flags
      @inspect_event = false
      # Initialize direction array
      @inspect_dir_flags = []
      # Check each list item for a comment
      return if @list.nil?
      @list.each do |cmd|
        # Check if it's a comment
        if cmd.code == 108
          # Set comment
          comment = cmd.parameters[0]
          comment_check = comment.scan(/^\\inspect_event/).flatten[0]
          # Check if the comment contains the string "\inspect_event"
          if comment_check == "\\inspect_event"
            # Flag it
            @inspect_event = true
            # Set directional array
            @inspect_dir_flags = comment.scan(/(\d)+/).flatten
            # Convert to ints
            @inspect_dir_flags.map!{|c| c.to_i}
            break
          end
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Check if player is adjacent to and facing an event
    # directions = an array containing the different directions to register
    # the animation by returning true:
    #    8
    # 4  0  6
    #    2
    #--------------------------------------------------------------------------
    def player_facing?(directions = @inspect_dir_flags)
      # Exit if we're not checking directions
      return false if directions.nil?
      # Initialize variable
      check = false
      # Test each direction
      case $game_player.direction
      when 2 # Facing down
        if directions.include?(8) || directions == [] # Player is above event
          check = (self.y == $game_player.y + 1 && self.x == $game_player.x)
        else
          check = false
        end
      when 4 # Facing left
        if directions.include?(6) || directions == [] # Player is right of event
          check = (self.x == $game_player.x - 1 && self.y == $game_player.y)
        else
          check = false
        end
      when 6 # Facing right
        if directions.include?(4) || directions == [] # Player is left of event
          check = (self.x == $game_player.x + 1 && self.y == $game_player.y)
        else
          check = false
        end
      when 8 # Facing up
        if directions.include?(2) || directions == [] # Player is below event
          check = (self.y == $game_player.y - 1 && self.x == $game_player.x)
        else
          check = false
        end
      end
      # Check for 0 (player on event)
      if directions.include?(0)
        check = (self.y == $game_player.y && self.x == $game_player.x)
      end
      return check
    end
  end 
  #==============================================================================
  # ** Game_Map
  #==============================================================================
  class Game_Map
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    alias inspect_event_map_update update
    def update
      # Call original
      inspect_event_map_update
      # Call animation method
      inspect_event_anim
    end
    #--------------------------------------------------------------------------
    # * Inspect Event Animation
    #--------------------------------------------------------------------------
    def inspect_event_anim
      if $game_player.moving?
        $game_player.animation_loop_id = 0
        return
      end
      
      @events.values.each do |event|
        next unless event.inspect_event
        next if (event.x - $game_player.x).abs + (event.y - $game_player.y).abs > 1
        if event.player_facing?
          $game_player.animation_loop_id = InspectEvent::EVENT_ANIMATION_ID
          return
        end
      end
      $game_player.animation_loop_id = 0
  
    end
  end 
  
  #==============================================================================
  # ** Sprite_Character
  #==============================================================================
  class Sprite_Character
    #--------------------------------------------------------------------------
    # * Frame Update
    #--------------------------------------------------------------------------
    alias inspect_event_character_update update
    def update
      # Call original
      inspect_event_character_update
      # Set loop animation (not if message windows are showing)
      if $game_temp.message_window_showing == true
        loop_animation(nil)
      elsif @character.animation_loop_id != 0
        anim = $data_animations[@character.animation_loop_id]
        loop_animation(anim)
      else
        loop_animation(nil)
      end
    end
  end