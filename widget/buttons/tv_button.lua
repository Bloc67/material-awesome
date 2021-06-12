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

local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo; pacmd set-sink-volume alsa_output.pci-0000_01_00.1.hdmi-stereo 31000"

-- new TV button
local tv_button = wibox.widget{
   {
        {
            {            
                image = os.getenv("HOME") .. '/.config/awesome/awesome-buttons/icons/film.svg',
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
local old_cursor_tv, old_wibox_tv
tv_button:connect_signal("mouse::enter", function(c)
    local wb_tv = mouse.current_wibox
    old_cursor_tv, old_wibox_tv = wb_tv.cursor, wb_tv
    wb_tv.cursor = "hand1"
    tv_button.bg = bgcolorlite
end
)
tv_button:connect_signal("mouse::leave", function(c)
    if old_wibox_tv then
        old_wibox_tv.cursor = old_cursor_tv
        old_wibox_tv = nil
    end
    tv_button.bg = bgcolor
end
)
tv_button:connect_signal("button::press", function() 
    awful.spawn.with_shell(do_hdmi)
    awesome.restart() 
end
)

return tv_button
