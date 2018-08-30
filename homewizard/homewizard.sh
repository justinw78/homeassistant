#!/bin/bash
# This file is part of homewizard-web-remote (hwwr)                                                    
# https://github.com/mgafner/homewizard-web-remote                                            
#                                                                                
# hwwr is free software: you can redistribute it and/or modify                 
# it under the terms of the GNU General Public License as published by            
# the Free Software Foundation, either version 3 of the License, or               
# (at your option) any later version.                                             
#                                                                                
# hwwr is distributed in the hope that it will be useful,                      
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   
# GNU General Public License for more details.                                    
#                                                                                
# You should have received a copy of the GNU General Public License               
# along with hwwr.  If not, see <http://www.gnu.org/licenses/>.

# Constants --------------------------------------------------------------------
#
# you may overwrite all this constants in 
#   ~/.homewizard/homewizardrc 

#HOMEWIZARD_IP="192.168.2.35"
#HOMEWIZARD_PW="9609924"
PROFILEDIR="/config/homewizard"
PROFILE="$PROFILEDIR/homewizardrc"
CACHETIME=10                            # how long to cache the values in [s]
SIGINT=2
DEBUG=0

# get all informations from homewizard:
# GET /yourpass/enlist
# GET /yourpass/get-sensors
# GET /yourpass/suntimes
# GET /yourpass/get-status

# Functions --------------------------------------------------------------------

# ------------------------------------------------------------------------------
control_c()
# ------------------------------------------------------------------------------
#
# Description:  run if user hits control-c
#
# Parameter  :  none
#
# Output     :  logging
#
{
if [ $DEBUG -ge 3 ]; then set -x
fi

echo ""
}

# ------------------------------------------------------------------------------
gethumidity()
# ------------------------------------------------------------------------------
#
# Description:  return the humidity of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.thermometers | .[] | select(.name=='\"$1\"') | .hu'`
}


# ------------------------------------------------------------------------------
presetname()
# ------------------------------------------------------------------------------
#
# Description:  return the name of the active preset (0-3)
#
# Parameter  :  none
#
# Output     :  logging
#
{
  case $1 in
  0)
    echo "home"
    ;;
  1)
    echo "away"
    ;;
  2)
    echo "sleep"
    ;;
  3)
    #echo "holiday"
    echo "guest"            # the author is using 'holiday'-mode as 'guest'-mode
    ;;
  esac
}

# ------------------------------------------------------------------------------
getpreset()
# ------------------------------------------------------------------------------
#
# Description:  return the active preset (0-3)
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  preset=`cat $PROFILEDIR/homewizard.json | jq '.preset'`
  echo `presetname $preset`
}

# ------------------------------------------------------------------------------
setpreset()
# ------------------------------------------------------------------------------
#
# Description:  set a preset
#
# Parameter  :  preset, one of [0,1,2,3]
#               0 = home
#               1 = away
#               2 = sleep
#               3 = holiday (or in my personal case: guest)
#
# Output     :  logging
#
{
  case $1 in
  0|home)
    newpreset=0
    ;;
  1|away)
    newpreset=1
    ;;
  2|sleep)
    newpreset=2
    ;;
  3|holiday|guest)           # the author is using 'holiday'-mode as 'guest'-mode
    newpreset=3
    ;;
  esac
  wget -O /dev/null -q http://$HOMEWIZARD_IP/$HOMEWIZARD_PW/preset/$newpreset
  cat $PROFILEDIR/homewizard.json | jq '.preset = '\"$newpreset\"'' > \
    $PROFILEDIR/homewizard.json-$PID
  mv $PROFILEDIR/homewizard.json-$PID $PROFILEDIR/homewizard.json
  echo `presetname $newpreset`
}

# ------------------------------------------------------------------------------
getswitchstate()
# ------------------------------------------------------------------------------
#
# Description:  return the state of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/switches.json | jq 'select(.name=='\"$1\"') | .status' | sed 's/\"//g'`
}
# ------------------------------------------------------------------------------
getrain()
# ------------------------------------------------------------------------------
#
# Description:  return the rain of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.rainmeters | .[] | select(.name=='\"$1\"') | .mm'`
}
# ------------------------------------------------------------------------------
getbattr()
# ------------------------------------------------------------------------------
#
# Description:  return the battery level rain of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.rainmeters | .[] | select(.name=='\"$1\"') | .lowBattery'`
}
# ------------------------------------------------------------------------------
getbattt()
# ------------------------------------------------------------------------------
#
# Description:  return the battery level rain of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.thermometers | .[] | select(.name=='\"$1\"') | .lowBattery'`
}
# ------------------------------------------------------------------------------
getwindspeed()
# ------------------------------------------------------------------------------
#
# Description:  return the wind of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.windmeters | .[] | select(.name=='\"$1\"') | .ws'`
}
# ------------------------------------------------------------------------------
getwindbatt()
# ------------------------------------------------------------------------------
#
# Description:  return the wind of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.windmeters | .[] | select(.name=='\"$1\"') | .lowBattery'`
}
# ------------------------------------------------------------------------------
getwinddir()
# ------------------------------------------------------------------------------
#
# Description:  return the wind of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.windmeters | .[] | select(.name=='\"$1\"') | .dir'`
}
# ------------------------------------------------------------------------------
gettemperature()
# ------------------------------------------------------------------------------
#
# Description:  return the temperature of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.thermometers | .[] | select(.name=='\"$1\"') | .te'`
}
getsensortime()
# ------------------------------------------------------------------------------
#
# Description:  return the battery level rain of a device
#
# Parameter  :  none
#
# Output     :  logging
#
{
  update_cache_check
  echo `cat $PROFILEDIR/homewizard.json | jq '.kakusensors | .[] | select(.name=='\"$1\"') | .timestamp'`
}
# ------------------------------------------------------------------------------
switch2id()
# ------------------------------------------------------------------------------
#
# Description:  converts switch to id
# 
# Parameter  :  <switchname> 
#
# Return     :  <id>
#
{
  ID=`cat $PROFILEDIR/homewizard.json | jq '.switches | .[] | select(.name=='\"$1\"') | .id'`
  if [ -z "$ID" ] ; then
    echo -e "ID of Switch '$1' not found. Exiting..."
    exit 1
  else
    echo $ID
  fi
}


# ------------------------------------------------------------------------------
switch() 
# ------------------------------------------------------------------------------
#
# Description:  switch a switch on or off
# 
# Parameter  :  <switch> <on/off>
#
# Output     :  none
#
{
  SWITCH=`switch2id $1`
  wget -O /dev/null -q http://$HOMEWIZARD_IP/$HOMEWIZARD_PW/sw/$SWITCH/$2 &
  cat $PROFILEDIR/switches.json | jq --arg name $1 --arg state $2 \
    'if .name == $name then .status = $state else . end' \
    > $PROFILEDIR/switches.json-$PID
  mv $PROFILEDIR/switches.json-$PID $PROFILEDIR/switches.json
}

# ------------------------------------------------------------------------------
update_cache_check()
# ------------------------------------------------------------------------------
#
# Description:  writes a json file of all switches of the homewizard
# 
# Parameter  :  none
#
# Output     :  none
#
{
  # if we ask for immediate update or if no cache file exist (i.e. first start)
  # then update immediately
  if [ "$1" == "now" ] || [ ! -f "$PROFILEDIR/homewizard.json" ] ; then
    update_immediate="true"
  else
    update_immediate="false"
  fi

  # if the cache file is older than predefined cache-time we want to update too
  if [ -f "$PROFILEDIR/homewizard.json" ]; then
    lastmodified=$(( $(date +%s) - $(stat -c %Y "$PROFILEDIR/homewizard.json") ))
    if [ "$lastmodified" -gt "$CACHETIME" ]; then
      update="true"
    else
      update="false"
    fi
  fi
  
  # found an old locking file, set to update and remove the file
  if [ -f "$PROFILEDIR/update.lock" ]; then
    lastmodified=$(( $(date +%s) - $(stat -c %Y "$PROFILEDIR/update.lock") ))
    if [ "$lastmodified" -gt "$CACHETIME" ]; then
      update="true"
      rm "$PROFILEDIR/update.lock"
    else
      update="false"
    fi
  fi

  if [ "$update_immediate" == "true" ] || [ "$update" == "true" ]; then
    $0 -x &
  fi
}

# ------------------------------------------------------------------------------
update_cache()
# ------------------------------------------------------------------------------
#
# Description:  writes a json file of all switches of the homewizard
# 
# Parameter  :  none
#
# Output     :  none
#
{
  touch "$PROFILEDIR/update.lock"
  wget -O - -q http://$HOMEWIZARD_IP/$HOMEWIZARD_PW/get-sensors | jq '.response' > /tmp/homewizard.json-$PID
  if [ -f /tmp/homewizard.json-$PID ]; then
    mv /tmp/homewizard.json-$PID $PROFILEDIR/homewizard.json
    cat $PROFILEDIR/homewizard.json | jq '.switches | .[]' > $PROFILEDIR/switches.json
  fi
  if [ -f "$PROFILEDIR/update.lock" ]; then
    rm "$PROFILEDIR/update.lock"
  fi
}

# ------------------------------------------------------------------------------
usage()
# ------------------------------------------------------------------------------
#
# Description:  shows help text
# 
# Parameter  :  none
#
# Output     :  shows help text
#
{
cat << EOF

usage: $(basename $0) -d <switchdevice> -s <on/off>

OPTIONS:
  -a    batterij niveau thermometers
  -b    batterij niveau regenmeter
  -d    <device>
  -g    get status of a sensor/device, needs option -d too
  -h    get humidity of a sensor, needs option -d too
  -k    get kakusensor
  -t    get temperature of a sensor, needs option -d too
  -r    get rain of a sensor, needs option -d too
  -p    needs options: keyword or number: 0,1,2,3 or ?
        0 or home
        1 or away
        2 or sleep
        3 or holiday/guest
        for options 0-3 it sets the preset to 0-3
        for option ? it returns the current set preset
  -u    update all caches
  -v    batterij niveau windmeter
  -w    windspeed
  -z    windhoek

examples:

  switch a device on or off
  $(basename $0) -d Loudspeaker -s on
  $(basename $0) -d Loudspeaker -s off

EOF
return 0
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# trap keyboard interrupt (control-c)
trap control_c $SIGINT

PID=`date +%N`

if [ ! -d "$PROFILEDIR" ]; then
  mkdir -p "$PROFILEDIR"
fi

# load configuration
if [ -f "$PROFILE" ]; then
  . "$PROFILE"
else
  if [ ! -z "$HOMEWIZARD_IP" ] || [ ! -z "$HOMEWIZARD_PW" ]; then
    echo "Error:" 
    echo "'HOMEWIZARD_IP' and 'HOMEWIZARD_PW' have to be set either in the "
    echo "header of $0 or in $PROFILE"
    exit 1
  fi
fi

# When you need an argument that needs a value, you put the ":" right after 
# the argument in the optstring. If your var is just a flag, withou any 
# additional argument, just leave the var, without the ":" following it.
#
# please keep letters in alphabetic order
#
while getopts ":d:ghp:rs:abktuvwxz" OPTION
do
  case $OPTION in
	a)
      GETOPTS_BATTT=1
      ;;
	b)
      GETOPTS_BATTR=1
      ;;
	d)
      GETOPTS_DEVICE="$OPTARG"
      ;;
    g)
      GETOPTS_GETSENSORS=1
      ;;
    h)
      GETOPTS_HUMIDITY=1
      ;;
	k)
      GETOPTS_SENSORTIME=1
      ;;
    p)
      GETOPTS_PRESET="$OPTARG"
      ;;
	r)
	  GETOPTS_RAIN=1
	  ;;
    s)
      GETOPTS_SWITCH="$OPTARG"
      ;;
    t) 
      GETOPTS_TEMPERATURE=1
      ;;
	u)
      update_cache_check
      ;;
	v)
	  GETOPTS_WINDBATT=1
      ;;
	w)
      GETOPTS_WINDSPEED=1
      ;;
	z)
      GETOPTS_WINDDIR=1
      ;;
    x)
      # update immediately without checks
      # using for calling myself to update in background
      update_cache
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      echo -e "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ ! -z $GETOPTS_SWITCH ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -s needs Option -d too"
    exit 1
  else
    switch $GETOPTS_DEVICE $GETOPTS_SWITCH
  fi
fi

if [ ! -z $GETOPTS_PRESET ] ; then
  case $GETOPTS_PRESET in
   home|0)
     setpreset 0
     ;;
   away|1)
     setpreset 1
     ;;
   sleep|2)
     setpreset 2
     ;;
   holiday|guest|3)  # the author is using 'holiday'-mode as 'guest'-mode
     setpreset 3
     ;;
   ?)
     getpreset
     ;;
   *)
     echo -e "Arguments for Option -p are: 0,1,2,3,?"
     exit 1
     ;;
  esac
fi

if [ ! -z $GETOPTS_GETSENSORS ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -g needs Option -d too"
    exit 1
  else
    getswitchstate $GETOPTS_DEVICE $GETOPTS_SWITCH
  fi
fi

if [ ! -z $GETOPTS_HUMIDITY ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -h needs Option -d too"
    exit 1
  else
    gethumidity $GETOPTS_DEVICE 
  fi
fi

if [ ! -z $GETOPTS_TEMPERATURE ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    gettemperature $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_RAIN ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getrain $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_BATTR ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getbattr $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_BATTT ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getbattt $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_WINDSPEED ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getwindspeed $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_WINDBATT ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getwindbatt $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_WINDDIR ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getwinddir $GETOPTS_DEVICE
  fi
fi
if [ ! -z $GETOPTS_SENSORTIME ] ; then
  if [ -z $GETOPTS_DEVICE ] ; then
    echo -e "Option -t needs Option -d too"
    exit 1
  else
    getsensortime $GETOPTS_DEVICE
  fi
fi