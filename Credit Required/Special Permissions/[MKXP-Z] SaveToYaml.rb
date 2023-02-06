# =====================================================================
# ** RPG Maker Save to YAML Converter
# Converts an RXDATA Save file to YAML
# KK20, Jaiden
# v1.0 - Feb 2023
# ---------------------------------------------------------------------
# This was written for MKXP-Z running Ruby 3.0+ (github.com/mkxp-z/mkxp-z)
# Stability and usage in vanilla RM versions is not guaranteed. 
# You also must have access to the Ruby Standard Library.
#
# [IMPORTANT NOTE]
# You MUST define the Table, Class, Tone and Rect classes below
# in order for this to work!!! It will not run without them.
# 
# It is legally grey to include them here since they're RM's internal classes,
# though there are many user-written examples all over the internet
# and the RPG Maker MV+ internal classes are MIT, so it should not be too
# challenging to find / write them.
#
# [Instructions]
# - Place above Main and below all of your Game_ class definitions.
# - Define the location of the Ruby stdlib within your project folder below.
# - Set the RM mode and convert mode
# - Name the save to convert "Save.rxdata/rvdata/rvdata2" (no number)
# - Ensure you have a Save.yml if you want to convert back
#
# The game will crash once it hits Main because of the class definitions. 
# This is expected, and the save should still convert fine.
#
# =====================================================================
# Uncomment/comment this line to quickly disable/enable the script
#__END__
# Location of your Ruby stdlib in relation to the project root (Windows/Linux)
STDLIB_DIR = "3.0.0"
# RGSS Version : 1 (RMXP) 2 (VX) 3 (VXA)
RGSS_VER = 1
# Convert mode : 1 (RXDATA => YAML) or 2 (YAML => RXDATA) 
MODE = 1
# ---------------------------------------------------------------------
# Load Ruby YAML module
$:.push(File.join(Dir.pwd, STDLIB_DIR)) unless System.is_mac?
require 'yaml'
# ---------------------------------------------------------------------
# ! IMPORTANT !
# Ruby definitions of RM's internal classes are required for 
# saving / loading to YAML. Place / write them below.
#
# Refer to the Great Interwebs for any number of examples of these.
# ---------------------------------------------------------------------
class Table
  # Remember to define _dump and self._load!
end
class Color
end
class Tone
end
class Rect
end
#-----------------------------------------------------------------------------
# * Actual Conversion Starts Here
#-----------------------------------------------------------------------------
EXTENSIONS = ["",".rxdata",".rvdata",".rvdata2"]
if MODE == 1
  p "= Converting Save to YAML ="
  data = []
  fn = "Save" + EXTENSIONS[RGSS_VER]
  begin
    savefile = File.open(fn)
  rescue Errno::ENOENT
    raise "Save file not found! Remember to remove the number from the save you want to convert."
  end
  loop do
    data << Marshal.load(savefile)
    puts "Loaded #{data.last.class}"
  rescue EOFError
    break
  end
  File.write('Save.yml', data.to_yaml)
  p "Done."
elsif MODE == 2
  p "= Converting YAML to Save ="
  begin
    data = YAML.unsafe_load(File.read('Save.yml'))
  rescue Errno::ENOENT
    raise "Save YAML file not found! Try creating one in Mode 1 first."
  end
  fn = "Save_fromYaml" + EXTENSIONS[RGSS_VER]
  file = File.new(fn, 'wb')
  data.each do |subdata|
    puts "Dumping #{subdata.class}..."
    Marshal.dump(subdata, file)
  end
  file.close
  p "Done."
end
p "Save dump/load complete. The game will now self-destruct in 3 seconds."
sleep(3)