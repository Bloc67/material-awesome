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

-- new PC button
local pc_line = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff50">PC</span>'
}
local old_cursor_pc, old_wibox_pc
pc_line:connect_signal("mouse::enter", function(c)
    local wb_pc = mouse.current_wibox
    old_cursor_pc, old_wibox_pc = wb_pc.cursor, wb_pc
    wb_pc.cursor = "hand1"
    pc_line.markup = '<span font="Roboto Mono normal" color="#ffffffff">PC</span>'
end
)
pc_line:connect_signal("mouse::leave", function(c)
    if old_wibox_pc then
        old_wibox_pc.cursor = old_cursor_pc
        old_wibox_pc = nil
    end
    pc_line.markup = '<span font="Roboto Mono normal" color="#ffffff50">PC</span>'
end
)
pc_line:connect_signal("button::press", function() 
    awful.spawn.with_shell(do_stereo)
    awesome.restart() 
end
)

return pc_line
