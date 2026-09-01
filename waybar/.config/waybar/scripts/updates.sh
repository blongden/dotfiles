#!/bin/sh
# waybar custom module: count pending apt upgrades.
# Reads the current package lists only (no root). apt-daily.timer refreshes them
# in the background — but only because /etc/apt/apt.conf.d/02periodic sets
# APT::Periodic::Update-Package-Lists "1" (+ a drop-in dropping the unit's
# ConditionACPower so it also runs on battery). See buddy memory/system-
# maintenance.md. Right-click the module to run a real `apt update && full-upgrade`.
#
#  = Debian swirl (nf-linux-debian, needs a Nerd Font).

list=$(apt list --upgradable 2>/dev/null | grep '/')
if [ -z "$list" ]; then
    jq -cn '{text:"", tooltip:"  apt · system up to date", class:"updated"}'
    exit 0
fi

n=$(printf '%s\n' "$list" | grep -c '/')
sec=$(printf '%s\n' "$list" | grep -c -- '-security')
names=$(printf '%s\n' "$list" | awk -F/ '{print $1}' | sort | paste -sd' ' -)

cls="pending"
sfx=""
if [ "$sec" -gt 0 ]; then
    cls="security"
    sfx=" · ${sec} security"
fi

jq -cn --arg n "$n" --arg names "$names" --arg sfx "$sfx" --arg cls "$cls" \
    '{ text: ("  " + $n),
       tooltip: ("  " + $n + " package(s) upgradable" + $sfx + "\n\n" + $names),
       class: $cls }'
