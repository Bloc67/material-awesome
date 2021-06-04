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
local pc_button = wibox.widget{
   {
        {
            {            
                image = os.getenv("HOME") .. '/.config/awesome/awesome-buttons/icons/cpu.svg',
                resize = true,
                forced_height = 24,
                forced_width = 24,
                opacity = 0.5,
                widget = wibox.widget.imagebox
            },
            valign = 'center',
            align = 'center',
            widget = wibox.container.place
        },
        left = 10,
        right = 10,
        widget = wibox.container.margin
    },
    bg = bgcolor,
    widget = wibox.container.background
}
local old_cursor_pc, old_wibox_pc
pc_button:connect_signal("mouse::enter", function(c)
    local wb_pc = mouse.current_wibox
    old_cursor_pc, old_wibox_pc = wb_pc.cursor, wb_pc
    wb_pc.cursor = "hand1"
    pc_button.bg = bgcolorlite
end
)
pc_button:connect_signal("mouse::leave", function(c)
    if old_wibox_pc then
        old_wibox_pc.cursor = old_cursor_pc
        old_wibox_pc = nil
    end
    pc_button.bg = bgcolor
end
)
pc_button:connect_signal("button::press", function() 
    awful.spawn.with_shell(do_stereo)
    awesome.restart() 
end
)

return pc_button
