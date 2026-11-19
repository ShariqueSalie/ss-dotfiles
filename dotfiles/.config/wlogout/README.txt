Select Logout Command depending on your setup:

Use for Display Manager e.g., sddm (DEFAULT)
sleep 1; hyprctl dispatch "hl.dsp.exit()"

Use for text based login
sleep 1; loginctl terminate-user $USER

