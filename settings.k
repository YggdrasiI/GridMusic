########## BASE SETTINGS ####################

VERBOSE = 1 # print some debug messages
OSCPORT = 3335
GLOBALVOL = 80 # ?!

# midi channel of next played note in some areas.
# See area_piano.k and area_channelswitcher.k
MAINCHANNEL = 1

# The variable kstore should be used to share data between areas and the osc looper.
# I.e. to change the area objects.
KSTORE = []

## DEFAULT AREA POSITIONS ####################
# The following settings assume this physical
# position of 11 areas (0-10):
#
# ┏━━━━━┳━━━━━┳━━━━━┓
# ┃  0  ┃     ┃  6  ┃
# ┣━━━━━┫  4  ┣━━━━━┫
# ┃     ┃     ┃     ┃
# ┃  1  ┣━━━━━┫  7  ┃
# ┃     ┃     ┃     ┃
# ┣━━━━━┫  5  ┣━━━━━┫
# ┃     ┃     ┃     ┃
# ┃  2  ┣━━━━━┫  9  ┃
# ┃     ┃     ┃     ┃
# ┣━━━━━┫  6  ┣━━━━━┫
# ┃  3  ┃     ┃ 10  ┃
# ┗━━━━━┻━━━━━┻━━━━━┛

## Array of function handles to settings.
# A setting represent a set of areas and if your
# kinect detect i.e. 11 touchpads, each setting should
# contains 11 areas.
#
# Add your own settings in mysettings.k
#
# See area_setting_switcher.k if you want load an other
# setting on runtime.
#
#SETTINGS = [1=(settingPiano),2=(settingPiano),4=(setting3),5=(setting3),6=(setting3),8=(settingGst),9=(settingGst), 10=(settingHalloween)]
# New, with keys
SETTINGS=[ "settingPiano"=(settingPiano)
,"piano"=(settingPiano)
,"knob"=(settingKnob)
,"1"=(setting1)
,"2"=(setting2)
,"3"=(setting3)
,"4"=(setting4)
,"5"=(setting5)
#,"settingGst"=(settingGst)
#,"settingTest"=(settingTest)
#	,"kinectSet1"=(kinectSet1)
#	,"kinectSet2"=(kinectSet2)
]
########## DEFINITON OF AREA GROUPS #########



################ SETTINGS ####################

# TODO: Base setting example
# OLD
function settingExample(loop){

  # Get default settings for area
  settings = settings_piano()

  # Adapt some values
  settings["notes"] = [0='c',1='e',2='g']
  settings["durations"] = [0=1b,1=2b,3=4b]

  # Create area
  # (Use different settings for each area
  # to be on the save side...)
  piano = new area_piano(settings)

  # Map area ids to areas. I assume here
  # the default frame with '11 rectanles'.
  areas = [ 0=piano, 1=piano, 2=piano, 3=piano,
  4=piano, 5=piano, 6=piano,
  7=piano, 8=piano, 9=piano, 10=piano ]

  # Start main loop if not called externally.
  # This calls blocks
  if(nargs() < 1 || loop != 0){
    task looper(areas, kstore)
  }

  # Otherwise, return areas for external handling.
  return(areas)
}


# C-Major pads
#
#  0,vol          7,vol
#         4,d
#   1,c           8,e
#         5,g,g'
#   2,f           9,a
#         6,b
#  3,switcher    10,vol
#
function settingPiano(loop){

  settings = settings_piano()
  settings["durations"] = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]
  settings["vol_range"] = ["low" = 50, "high" = 128]

  s2 = durarr('co2')
  s3 = durarr('c')
  s4 = durarr('co4')
  s5 = durarr('co5')

  # Same setting for each pad, but different notes
  settings["notes"] = [0=s3[0],1=s4[0],2=s5[0]]
  piano_c = new area_piano(settings)
  settings["notes"] = [1=s3[1],1=s4[1],2=s5[1]]
  piano_d = new area_piano(settings)
  settings["notes"] = [2=s3[2],1=s4[2],2=s5[2]]
  piano_e = new area_piano(settings)
  settings["notes"] = [3=s3[3],1=s4[3],2=s5[3]]
  piano_f = new area_piano(settings)
  settings["notes"] = [4=s2[4],1=s3[4],2=s4[4]]
  piano_g = new area_piano(settings)
  settings["notes"] = [5=s2[5],1=s3[5],2=s4[5]]
  piano_a = new area_piano(settings)
  settings["notes"] = [6=s2[6],1=s3[6],2=s4[6]]
  piano_b = new area_piano(settings)

  #bpm_area = new area_bpm( 30, 190, 20, 1)
  volume_area = new area_volume( 20, 127, 5)

  kstore = []
  switcher = new area_setting_switcher(kstore,SETTINGS)

  #areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher,  4=piano_d, 5=piano_g, 6=piano_b, 7=volume_area, 8=piano_e, 9=piano_a, 10=volume_area ]
  areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=piano_d,  4=piano_d, 5=piano_g, 6=piano_b, 7=volume_area, 8=piano_e, 9=piano_a, 10=volume_area ]

  if(nargs() < 1 || loop != 0){
    task looper(areas, kstore)
  }
  return(areas)
}

# Example for knob area.
# This example defines two areas. The second area is a knob
# and switch between several targets for the first area.
#
function settingKnob(loop){
  # GridMusic Clipboard
  kstore = []

  # Settings for first area 
  setA = settings_piano()
  setB = settings_phrases()


  # Create area targets
  targetA = new area_piano(setA)
  targetB = new area_phrases(setB)
  knob = new area_multimode(kstore)

  areas = [0=knob, 1=targetA, 2=targetB]

  # Start main loop if not called externally.
  # This calls blocks
  if(nargs() < 1 || loop != 0){
    task looper(areas, kstore)
  }

  # Otherwise, return areas for external handling.
  return(areas)
}

# Send OSC commands to gst123 (media player)
# Modify oscplayer.k or gst123.k to
# support other players (which?)
# OLD
function settingGst(loop){

  files=[ 1="filename.mp3",
  2="filename2.mp3"
  ];

  bpm_area = new area_bpm( 30, 190, 20, 1)
  volume_area = new area_volume( 20, 127, 5)

  mp3_1 = new area_gst123([0=files[0],1=files[1]],volume_area )
  mp3_2 = new area_gst123([0=files[0],1=files[1]])
  mp3_4 = new area_gst123([0=files[0],1=files[1]])
  mp3_5 = new area_gst123([0=files[0],1=files[1]])
  mp3_6 = new area_gst123([0=files[0],1=files[1]])
  mp3_8 = new area_gst123([0=files[0],1=files[1]])
  mp3_9 = new area_gst123([0=files[0],1=files[1]])


  files3 = []
  files3[0] = "bachinv1.mid"
  files3[1] = "bachinv2.mid"
  files3[2] = "bachinv3.mid"
  files3[3] = "bachinv4.mid"
  playmidi = new area_playmidi(files3, 1.0)

  kstore = []
  switcher = new area_setting_switcher(kstore,SETTINGS)

  areas = [0=volume_area, 1=mp3_1, 2=mp3_2, 3=switcher, 4=mp3_4, 5=mp3_5, 6=mp3_6, 7=bpm_area, 8=mp3_8, 9=mp3_9, 10=playmidi]

  if(nargs() < 1 || loop != 0){
    task looper(areas, kstore)
  }
  return(areas)
}

# OLD
function settingTest(loop){

  durations = [0=1b,1=4b,2=8b,3=8b,4=8b,5=8b]
  s2 = durarr('co2')
  s3 = durarr('c')
  s4 = durarr('co4')
  s5 = durarr('co5')

  #piano_g = new area_piano([4=s2[4],1=s3[4],2=s4[4]],durations,50,128)
  piano_a = new area_piano([5=s2[5],1=s3[5],2=s4[5]],durations,50,128)
  piano_b = new area_piano([6=s2[6],1=s3[6],2=s4[6]],durations,50,128)
  piano_c = new area_piano([0=s3[0],1=s4[0],2=s5[0]],durations,50,128)
  piano_d = new area_piano([1=s3[1],1=s4[1],2=s5[1]],durations,50,128)
  piano_e = new area_piano([2=s3[2],1=s4[2],2=s5[2]],durations,50,128)
  piano_f = new area_piano([3=s3[3],1=s4[3],2=s5[3]],durations,50,128)

  trumpet_notes = [0='cc4',2='ec4',4='gc4',5='ac4',7='co4c4']
  trumpet = new area_trumpet(trumpet_notes,0,121)
  #trumpet = new area_piano([2=s3[2],1=s4[2],2=s5[2]],durations,50,128)

  #bpm_area = new area_bpm( 30, 190, 20, 1)
  volume_area = new area_volume( 20, 127, 5)

  kstore = []
  switcher = new area_setting_switcher(kstore,SETTINGS)

  #big_area_ids = [0=1,1=2,2=4,3=5,4=6,5=8,6=9]
  #replace_areas = [1=piano_e]
  #knob_area = new area_knob(2,2,kstore, big_area_ids, replace_areas);

  channels = [0=1,1=2,2=3]
  channel_area = new area_channelswitcher(channels,kstore);

  multi_area = new area_multimode(kstore)

  areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher,  4=piano_d, 5=trumpet, 6=piano_b, 7=channel_area, 8=multi_area, 9=piano_a, 10=volume_area ]

  if(nargs() < 1 || loop != 0){
    task looper(areas, kstore)
  }
  return(areas)
}


