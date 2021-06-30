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

local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo; pacmd set-sink-volume alsa_output.pci-0000_01_00.1.hdmi-stereo 15000"

-- new TV button
local tv_line = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff50">TV</span>'
}
local old_cursor_tv, old_wibox_tv
tv_line:connect_signal("mouse::enter", function(c)
    local wb_tv = mouse.current_wibox
    old_cursor_tv, old_wibox_tv = wb_tv.cursor, wb_tv
    wb_tv.cursor = "hand1"
    tv_line.markup = '<span font="Roboto Mono normal" color="#ffffffff">TV</span>'
end
)
tv_line:connect_signal("mouse::leave", function(c)
    if old_wibox_tv then
        old_wibox_tv.cursor = old_cursor_tv
        old_wibox_tv = nil
    end
    tv_line.markup = '<span font="Roboto Mono normal" color="#ffffff50">TV</span>'
end
)
tv_line:connect_signal("button::press", function() 
    awful.spawn.with_shell(do_hdmi)
    awesome.restart() 
end
)

return tv_line
