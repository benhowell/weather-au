# weather-au
Terminal utilitity for weather forecasts and observations for Australia using live BOM data. Totally WIP, most likely broken and not intended for general use. This purpose of this script is to give me a basic tmux status line weather report (although it does contain much more functionality in various states of completion and/or disrepair).


BOM OBS data is updated every 10 minutes. This script is currently run as a cron every 3 minutes and writes result to file. The file is read by tmux every minute.


## Usage

```
bash weather-au [options]
```

## Options

* set state (required)
```
--state=[NSW,TAS,NT,QLD,SA,VIC,WA]
```
* pretty print (adds header and some whitespace where needed, probably to be removed, applies to lists and forecasts but not observations)
```
--pretty
```
* list stations
```
--stations
```
* list forecast districts

```
--forecast-districts
```
* list forecast locations
```
--forecast-locations
```
* show synoptic forecast
```
--forecast-synoptic
```
* show district forecast
```
--forecast-district=[district]
```
* show location forecast
```
--forecast-location=[location]
```
* show single line station (location) forecast, current *apparent* temperature and current *actual* temperature
```
--station=[station] --forecast-location=[location]
```



### Example single line station output.
Hardcoded for the moment, format string is WIP

e.g
```
bash weather-au --station="Hobart" --forecast-location="Hobart" --state=TAS
```
Format: precis [probability_of_precipitation precipitation_range] air_temperature_maximum | apparent_temp / temp

where *precis*, *probability_of_precipitation*, *precipitation_range* and *air_temperature_maximum* are todays forecast values, and *apparent_temp* and *temp* are the current apparent temperature and temperature observations respectively
![Alt text](tmux-weather-au.png?raw=true "Example tmux status line")


### Other examples.
* List all stations

```
bash weather-au --stations --state=TAS
```
* list all forecast districts
```
bash weather-au --forecast-districts --state=TAS
```
* list all forecast locations
```
bash weather-au --forecast-locations --state=TAS
```
* show synoptic forecast
```
bash weather-au --forecast-synoptic --state=TAS
```
* show district forecast
```
bash weather-au --forecast-district="South East" --state=TAS --pretty
```
* show location forecast
```
bash weather-au --forecast-location="Hobart" --state=TAS --pretty
```
* combining options
```
bash weather-au --forecast-locations --forecast-synoptic --forecast-district="South East" --forecast-location="Hobart" --state=TAS --pretty
```
