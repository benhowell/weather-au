#!/bin/bash

# symbols
DEGREES_CELCIUS=$'\xe2\x84\x83'
DEGREES=$'\xc2\xb0'

# files
NSW_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDN60920.xml
NSW_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDN11020.xml

TAS_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDT60920.xml
TAS_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDT16000.xml

NT_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDD60920.xml
NT_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDD10207.xml

QLD_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ60920.xml
QLD_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ10606.xml

SA_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDS60920.xml
SA_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDS11055.xml

VIC_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDV60920.xml
VIC_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDV10750.xml

WA_OBS=ftp://ftp.bom.gov.au/anon/gen/fwo/IDW60920.xml
WA_FCAST=ftp://ftp.bom.gov.au/anon/gen/fwo/IDW13010.xml


# cached files
# if file cached: use it
# else curl it to cache: use it
function get_file() {
    CACHE="$1_C"
    RES="${!CACHE}"
    if [ ${RES:+1} ]; then
        echo "$RES"
    else
        RES="$(curl -s ${!1})"
        echo "$RES"
    fi
}


# pretty print header
function print_header() {
    rl="$(echo -n $1 | wc -c)"
    ll="$(echo -n $2 | wc -c)"
    sl="$(echo -n $3 | wc -c)"

    printf %"s" "+";
    for i in $(seq 1 $(($ll + $rl + $sl + 4))); do printf %"s" "-"; done;
    printf %"s\n" "+"
    printf %"s\n" "| $1 $3 $2 |"
    printf %"s" "+";
    for i in $(seq 1 $(($ll + $rl + $sl + 4))); do printf %"s" "-"; done;
    printf %"s\n" "+"
}


#TODO: allow format param to show details for each station
# stations
function list_stations() {
    DATA="$(echo $1 | xpath -q -e '//station/@description')"
    if [ $2 ]; then
        print_header "Stations"
    fi
    for i in "$DATA"
    do
        #strip leading text and double quotes
        echo "$i" | sed -e 's/\sdescription=//g' -e 's/\"//g'
    done
    if [ $2 ]; then
        printf %"s\n"
    fi
}


#TODO: allow format param to show details for each district
# forecast districts
function list_forecast_districts() {
    DATA="$(echo $1 | xpath -q -e '//area[@type='"'public-district'"']/@description')"
    if [ $2 ]; then
        print_header "Forecast districts"
    fi
    for i in "$DATA"
    do
        #strip leading text and double quotes
        echo "$i" | sed -e 's/\sdescription=//g' -e 's/\"//g'
    done
    if [ $2 ]; then
        printf %"s\n"
    fi
}


#TODO: allow format param to show details for each location
# forecast locations
function list_forecast_locations() {
    DATA="$(echo $1 | xpath -q -e '//area[@type='"'location'"']/@description')"
    if [ $2 ]; then
        print_header "Forecast locations"
    fi
    for i in "$DATA"
    do
        #strip leading text and double quotes
        echo "$i" | sed -e 's/\sdescription=//g' -e 's/\"//g'
    done
    if [ $2 ]; then
        printf %"s\n"
    fi
}

#TODO: pass in format????
# synoptic forecast (region)
function forecast_synoptic() {
    DATA="$(echo $1 | xpath -q -e '//area[@aac='"'$2'"']')"
    l="$(echo $DATA | xpath -q -e '//area/@description')"
    #strip leading text and double quotes
    location="$(echo "$l" | sed -e 's/\sdescription=//g' -e 's/\"//g')"
    if [ $3 ]; then
        print_header "Synoptic forecast" "$location" "-"
    fi
    printf %"s\n" "$(echo $DATA | xpath -q -e '//text[@type='"'synoptic_situation'"']/text()')"
    if [ $3 ]; then printf %"s\n"; fi
}


#TODO: pass in index [0..3] (0 today, 1 tomorrow, etc)
#TODO: pass in format????
# district forecast
function forecast_district() {
    DATA="$(echo $1 | xpath -q -e '//area[@description='"'$2'"']/forecast-period[@index='"'0'"']')"
    #strip leading text and double quotes
    location="$(echo "$2" | sed -e 's/\sdescription=//g' -e 's/\"//g')"
    if [ $3 ]; then
        print_header "District forecast" "$location" "-"
    fi
    printf %"s\n" "$(echo $DATA | xpath -q -e '//text[@type='"'forecast'"']/text()')"
    if [ $3 ]; then printf %"s\n"; fi
}


#TODO: pass in index [0..3] (0 today, 1 tomorrow, etc)
#TODO: pass in format
# location forecast
function forecast_location() {
    DATA="$(echo $1 | xpath -q -e '//area[@description='"'$2'"']/forecast-period[@index='"'0'"']')"
    #strip leading text and double quotes
    location="$(echo "$2" | sed -e 's/\sdescription=//g' -e 's/\"//g')"
    precis="$(echo $DATA | xpath -q -e '//text[@type='"'precis'"']/text()')"
    temp="$(echo $DATA | xpath -q -e '//element[@type='"'air_temperature_maximum'"']/text()')"
    if [ $3 ]; then
        print_header "Location forecast" "$location" "-"
    fi
    printf "%s %s%s%s\n" "$precis" "$temp" "$DEGREES" "C"
    if [ $3 ]; then printf %"s\n"; fi
}



for ARG in "$@"
do
    K=$(echo $ARG | cut -f1 -d=)
    V=$(echo $ARG | cut -f2 -d=)
    case "$K" in
        --pretty)              pretty=true;;
        --stations)            stations=true;;
        --state)               state="$V";;

        --forecast-districts)  forecast_districts=true;;
        --forecast-locations)  forecast_locations=true;;
        --forecast-synoptic)   forecast_synoptic=true;;
        --forecast-district)   forecast_district="$V";;
        --forecast-location)   forecast_location="$V";;

        --station)             station="$V";;

        --format)              format="$V";;
        *)
    esac
done



# list stations
if [ "$stations" = true ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_OBS)
    if [ ${pretty:+1} ]; then
        list_stations "$f" "$pretty"
    else
        list_stations "$f"
    fi
fi


# list forecast districts
if [ "$forecast_districts" = true ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_FCAST)
    if [ ${pretty:+1} ]; then
        list_forecast_districts "$f" "$pretty"
    else
        list_forecast_districts "$f"
    fi
fi


# list forecast locations
if [ "$forecast_locations" = true ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_FCAST)
    if [ ${pretty:+1} ]; then
        list_forecast_locations "$f" "$pretty"
    else
        list_forecast_locations "$f"
    fi
fi


# synoptic forecast
if [ "$forecast_synoptic" = true ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_FCAST)
    if [ ${pretty:+1} ]; then
        forecast_synoptic "$f" "$state"_FA001 "$pretty"
    else
        forecast_synoptic "$f" "$state"_FA001
    fi
fi


# district forecast
if [ ${forecast_district:+1} ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_FCAST)
    if [ ${pretty:+1} ]; then
        forecast_district "$f" "$forecast_district" "$pretty"
    else
        forecast_district "$f" "$forecast_district"
    fi
fi


# location forecast
if [ ${forecast_location:+1} ] && [ ${state:+1} ]; then
    f=$(get_file "$state"_FCAST)
    if [ ${pretty:+1} ]; then
        forecast_location "$f" "$forecast_location" "$pretty"
    else
        forecast_location "$f" "$forecast_location"
    fi
fi




#------------
#forecast
#------------

#REGION
#default always
# <area aac="TAS_FA001" description="Tasmania" type="region">
#       <text type="synoptic_situation"> text()

#PUBLIC DISTRICT [index 0 to 3]
#<area aac="TAS_PW011" description="King Island" type="public-district"
#      <text type="forecast"> text
#      <text type="uv_alert"> text

#LOCATION [index 0 to 3]
#<element type="forecast_icon_code">
#    <element type="air_temperature_maximum" units="Celsius"> text
#    <text type="precis"> text










#-state (req)
#-stations (returns all station names)
#-station-name (returns station data)


#flags
#d datetime of reading
#T apparent temperature
#t actual temperature
#temerature delta
#c cloud
#cloud_oktas
#wind gust
#dew point
#p atmospheric pressure
#h humidity
#w wind direction
#s wind speed
#rainfall
#rainfall_24hr
#temp max
#temp min
#wind gust max
#wind gust dir max


#flags
#a
#A
#b
#B
#c
#C
#d
#D
#e
#E
#f
#F
#g
#G
#h
#H
#i
#I
#j
#J
#k
#K
#l
#L
#m
#M
#n
#N
#o
#O
#p
#P
#q
#Q
#r
#R
#s
#S
#t
#T
#u
#U
#v
#V
#w
#W
#x
#X
#y
#Y
#z
#Z




#time="$(echo $STATION_OBS | xpath -q -e 'string(//period/@time-local)')"
#echo $time
#temp_apparent="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'apparent_temp'"']/text()')"
#echo $temp_apparent
#cloud="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'cloud'"']/text()')"
#echo $cloud

#cloud_oktas="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'cloud_oktas'"']/text()')"
#echo $cloud_oktas

#temp_delta="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'delta_t'"']/text()')"
#echo $temp_delta

#wind_gust="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'gust_kmh'"']/text()')"
#echo $wind_gust

#temp_actual="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'air_temperature'"']/text()')"
#echo $temp_actual

#dew_point="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'dew_point'"']/text()')"
#echo $dew_point

#pres="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'pres'"']/text()')"
#echo $pres

#humidity="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'rel-humidity'"']/text()')"
#echo $humidity

#wind_dir="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'wind_dir'"']/text()')"
#echo $wind_dir

#wind_speed="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'wind_spd_kmh'"']/text()')"
#echo $wind_speed

#rainfall="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'rainfall'"']/text()')"
#echo $rainfall

#rainfall_24hr="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'rainfall_24hr'"']/text()')"
#echo $rainfall_24hr

#temp_max="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'maximum_air_temperature'"']/text()')"
#echo $temp_max

#temp_min="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'minimum_air_temperature'"']/text()')"
#echo $temp_min

#wind_gust_max="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'maximum_gust_kmh'"']/text()')"
#echo $wind_gust_max

#wind_gust_dir_max="$(echo $STATION_OBS | xpath -q -e '//element[@type='"'maximum_gust_dir'"']/text()')"
#echo $wind_gust_dir_max





#STATION_OBS="$(echo $OBS | xpath -q -e '//station[@stn-name='"'HOBART AIRPORT'"']')"
#STATION_FCAST_TODAY="$(echo $FCAST | xpath -q -e '//area[@description='"'Hobart'"']/forecast-period[@index='"'0'"']')"
#STATION_FCAST_TOMORROW="$(echo $FCAST | xpath -q -e '//area[@description='"'Hobart'"']/forecast-period[@index='"'1'"']')"
#STATION_FCAST_OVERMORROW="$(echo $FCAST | xpath -q -e '//area[@description='"'Hobart'"']/forecast-period[@index='"'2'"']')"

#temp_max_fcast="$(echo $STATION_FCAST_TODAY | xpath -q -e 'string(//element[@type='"'air_temperature_maximum'"'])')"
#echo $temp_max_fcast
#precis_fcast="$(echo $STATION_FCAST_TODAY | xpath -q -e 'string(//text[@type='"'precis'"'])')"
#echo $precis_fcast

#echo $STATION_FCAST_TODAY
#echo $STATION_FCAST_TOMORROW
#echo $STATION_FCAST_OVERMORROW



#FCAST="$(xpath -q -e '//area[@description='"'Hobart'"']/forecast-period' test-forecast.xml)"
#FCAST="$(xpath -q -e '//area[@description='"'Hobart'"']/forecast-period[@index='"'0'"']' test-forecast.xml)"
#echo $FCAST

#fcast_today="$(echo $FCAST | xpath -q -e '//forecast-period[@index='"'0'"']')"
#echo $fcast_today

#temp_fcast_today="$(echo $FCAST | xpath -q -e '//element[@type='"'air_temperature_maximum'"']/text()')"
#echo $temp_fcast_today
#precis_fcast_today="$(echo $FCAST | xpath -q -e '//text[@type='"'precis'"']/text()')"
#echo $precis_fcast_today
