local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

-- my buttons
-- if they change: pacmd list-sources | grep -e 'index:' -e device.string -e 'name:'

local do_stereo = "xrandr --output DisplayPort-0 --off --output DVI-1 --gamma 1.15:1.15:1.15 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-0 --off --output HDMI-0 --off; pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo; pacmd set-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo 65536"
--local do_stereo = "echo 'stereo'"
local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo; pacmd set-sink-volume alsa_output.pci-0000_01_00.1.hdmi-stereo 23000"
--local do_hdmi = "echo 'hdmi'"

local do_zen = "zenity --progress --title='Vent..' --pulsate --auto-close --auto-kill"
local do_twice = do_hdmi .. " | " .. do_zen .. "; sleep 8; " .. do_stereo .. " | " .. do_zen .. "; sleep 8; " .. do_hdmi  

-- new PC button
local twice_line = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff90">TW</span>'
}
local old_cursor_twice, old_wibox_twice
twice_line:connect_signal("mouse::enter", function(c)
    local wb_twice = mouse.current_wibox
    old_cursor_twice, old_wibox_twice = wb_twice.cursor, wb_twice
    wb_twice.cursor = "hand1"
    twice_line.markup = '<span font="Roboto Mono normal" color="#ffffffff">TW</span>'
end
)
twice_line:connect_signal("mouse::leave", function(c)
    if old_wibox_twice then
        old_wibox_twice.cursor = old_cursor_twice
        old_wibox_twice = nil
    end
    twice_line.markup = '<span font="Roboto Mono normal" color="#ffffff90">TW</span>'
end
)
twice_line:connect_signal("button::press", function() 
    awful.spawn.with_shell(do_twice)
    awesome.restart() 
end
)

return twice_line
