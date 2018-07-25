#!/usr/bin/env bash

# install macosvpn https://github.com/halo/macosvpn
sudo bash -c "curl -L https://github.com/halo/macosvpn/releases/download/0.1.0/macosvpn > /usr/local/bin/macosvpn"
sudo chmod +x /usr/local/bin/macosvpn

echo "Hide.me Password:"
read hmp
hmu="seansh7"
hmss="hide.io"
declare -A hmservers=(
  [Montreal]="ca.hide.me"
  [Bucharest]="ro.hide.me"
  [Roosendaal]="nl.hide.me"
  [Istanbul]="tr.hide.me"
  [Washington, D.C.]="us-2.hide.me"
  [San Jose, CA]="us-3.hide.me"
  [Queretaro]="mx.hide.me"
)

# loop though servers and write the config
for server in "${!hmservers[@]}"; do
  echo $server ---
  sudo macosvpn create -ceups "$server" "${hmservers[$server]}" "$hmu" "$hmp" "$hmss"
done

# Preferences > Network > "Show VPN status in menu bar"
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/vpn.menu"
killall SystemUIServer -HUP
