#!/bin/bash
#
# Modified to run locally on a TrueNAS Scale installation.
# Original found at https://github.com/brezlord/iDRAC7_fan_control
# A simple script to control fan speeds on Dell generation 12 PowerEdge servers. 
# If the inlet temperature is above 35deg C enable iDRAC dynamic control and exit program.
# If inlet temp is below 35deg C set fan control to manual and set fan speed to predetermined value.
# The tower servers T320, T420 & T620 inlet temperature sensor is after the HDDs so temperature will
# be higher than the ambient temperature.

# Starting fan speed in percent
START=20

# If START is a float, this will convert to int
START=${START%.*}

# Round START down to nearest multiple of 5
START=$(($START/5*5))

# Fan speed in %
SPEED[0]="00"
SPEED[5]="05"
SPEED[10]="0a"
SPEED[15]="0f"
SPEED[20]="14"
SPEED[25]="19"
SPEED[30]="1e"
SPEED[35]="23"
SPEED[40]="28"
SPEED[45]="2d"
SPEED[50]="32"
SPEED[55]="37"
SPEED[60]="3c"
SPEED[65]="41"
SPEED[70]="46"
SPEED[75]="4b"
SPEED[80]="50"
SPEED[85]="55"
SPEED[90]="5a"
SPEED[95]="5f"
SPEED[100]="64"
TEMP_THRESHOLD="35" # iDRAC dynamic control enable thershold
TEMP_SENSOR="04h"   # Inlet Temp
#TEMP_SENSOR="01h"  # Exhaust Temp
#TEMP_SENSOR="0Eh"  # CPU 1 Temp
#TEMP_SENSOR="0Fh"  # CPU 2 Temp

# Get system date & time.
DATE=$(date +%d-%m-%Y\ %H:%M:%S)
echo "Date $DATE"

# Get temperature from iDARC.
T=$(ipmitool sdr type temperature | grep $TEMP_SENSOR | cut -d"|" -f5 | cut -d" " -f2)
echo "--> Current Inlet Temp: $T"

# If ambient temperature is above 35deg C enable dynamic control and exit, if below set manual control.
if [[ $T > $TEMP_THRESHOLD ]]
then
  echo "--> Temperature is above 35deg C"
  echo "--> Enabled dynamic fan control"
  ipmitool raw 0x30 0x30 0x01 0x01
  exit 1
else
  echo "--> Temperature is below 35deg C"
  echo "--> Disabled dynamic fan control"
  ipmitool raw 0x30 0x30 0x01 0x00
fi

# Set fan speed dependant on ambient temperature if inlet temperaturte is below 35deg C.
# If inlet temperature between 0 and 19deg C then set fans to START%.
if [ "$T" -ge 0 ] && [ "$T" -le 19 ]
then
  echo "--> Setting fan speed to $((16#${SPEED[$START]}))%"
  ipmitool raw 0x30 0x30 0x02 0xff 0x${SPEED[$START]}

# If inlet temperature between 20 and 24deg C then set fans to START+5%
elif [ "$T" -ge 20 ] && [ "$T" -le 24 ]
then
  echo "--> Setting fan speed to $((16#${SPEED[$START+5]}))%"
  ipmitool raw 0x30 0x30 0x02 0xff 0x${SPEED[$START+5]}

# If inlet temperature between 25 and 29deg C then set fans to START+10%
elif [ "$T" -ge 25 ] && [ "$T" -le 29 ]
then
  echo "--> Setting fan speed to $((16#${SPEED[$START+10]}))%"
  ipmitool raw 0x30 0x30 0x02 0xff 0x${SPEED[$START+10]}

# If inlet temperature between 30 and 35deg C then set fans to START+15%
elif [ "$T" -ge 30 ] && [ "$T" -le 34 ]
then
  echo "--> Setting fan speed to $((16#${SPEED[$START+15]}))%"
  ipmitool raw 0x30 0x30 0x02 0xff 0x${SPEED[$START+15]}
fi
