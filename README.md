# weather-au
Terminal utilitity for weather forecasts and observations for Australia using live BOM data

## Example tmux status line.
Hardcoded for the moment  (just pass station and state) 

e.g 
```
bash weather-au --station="Hobart" --state=TAS
```
Format: precis [probability_of_precipitation precipitation_range] air_temperature_maximum / temp

where *precis*, *probability_of_precipitation*, *precipitation_range* and *air_temperature_maximum* are todays forecast values
and *temp* is the current temperature observation
![Alt text](tmux-weather-au.png?raw=true "Example tmux status line")
