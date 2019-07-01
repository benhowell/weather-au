# weather-au
Terminal utilitity for weather forecasts and observations for Australia using live BOM data. Totally WIP, most likely broken and not intended for general use.

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
* show single line station (location) forecast and current temperature
```
--station=[station]
```



### Example single line station output.
Hardcoded for the moment, format string is WIP

e.g
```
bash weather-au --station="Hobart" --state=TAS
```
Format: precis [probability_of_precipitation precipitation_range] air_temperature_maximum / temp

where *precis*, *probability_of_precipitation*, *precipitation_range* and *air_temperature_maximum* are todays forecast values
and *temp* is the current temperature observation
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
