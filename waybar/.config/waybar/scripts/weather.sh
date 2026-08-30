#!/bin/sh
# waybar custom module: current weather from wttr.in (no API key).
# Location is auto-detected from the public IP; override by exporting
# WEATHER_LOCATION (e.g. "Edinburgh" or "EH54") before waybar starts.
# Nerd Font weather glyphs (nf-weather-*) — needs a patched font.

loc=${WEATHER_LOCATION:-}
url="https://wttr.in/${loc}?format=j1"

json=$(curl -sf --max-time 10 "$url") || {
    jq -cn '{text:"", tooltip:"weather: offline", class:"offline"}'
    exit 0
}

cur=$(printf '%s' "$json" | jq -r '.current_condition[0]')
code=$(printf '%s'  "$cur" | jq -r '.weatherCode')
temp=$(printf '%s'  "$cur" | jq -r '.temp_C')
feels=$(printf '%s' "$cur" | jq -r '.FeelsLikeC')
desc=$(printf '%s'  "$cur" | jq -r '.weatherDesc[0].value')
hum=$(printf '%s'   "$cur" | jq -r '.humidity')
wind=$(printf '%s'  "$cur" | jq -r '.windspeedKmph')
wdir=$(printf '%s'  "$cur" | jq -r '.winddir16Point')

area=$(printf '%s' "$json" | jq -r '.nearest_area[0] | (.areaName[0].value) + ", " + (.region[0].value)')
hi=$(printf '%s'   "$json" | jq -r '.weather[0].maxtempC')
lo=$(printf '%s'   "$json" | jq -r '.weather[0].mintempC')

hour=$(date +%-H)
if [ "$hour" -ge 7 ] && [ "$hour" -lt 20 ]; then day=1; else day=0; fi

case "$code" in
    113) [ "$day" = 1 ] && icon="" || icon="" ;;                 # clear
    116) [ "$day" = 1 ] && icon="" || icon="" ;;                 # partly cloudy
    119|122) icon="" ;;                                            # cloudy / overcast
    143|248|260) icon="" ;;                                        # mist / fog
    176|263|266|293|296|353) icon="" ;;                           # light rain / drizzle
    299|302|305|308|356|359) icon="" ;;                           # rain
    179|182|185|281|284|317|320|362|365) icon="" ;;               # sleet / freezing
    311|314) icon="" ;;                                            # freezing rain
    227|230|323|326|329|332|335|338|368|371) icon="" ;;           # snow
    350|374|377) icon="" ;;                                        # ice pellets
    200|386|389|392|395) icon="" ;;                               # thunder
    *) icon="" ;;
esac

cls="ok"
case "$code" in
    200|386|389|392|395) cls="alert" ;;
    230|338|359) cls="alert" ;;
esac

tooltip=$(printf '%s  %s°C  (feels %s°C)\n%s\n today %s–%s°C   humidity %s%%   wind %s km/h %s' \
    "$desc" "$temp" "$feels" "$area" "$lo" "$hi" "$hum" "$wind" "$wdir")

jq -cn --arg text "$icon $temp°C" --arg tt "$tooltip" --arg cls "$cls" \
    '{text: $text, tooltip: $tt, class: $cls}'
