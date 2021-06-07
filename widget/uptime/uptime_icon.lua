local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')
local icons = require('theme.icons')
local dpi = require('beautiful').xresources.apply_dpi

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

local uptime_line = wibox.widget {
    align = 'left',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = "0 days",
}
local uptime_icon = wibox.widget {
    wibox.widget {
        image = icons.power,
        forced_width = 16,
        opacity = 0.3,
        resize = true,
        widget = wibox.widget.imagebox
    },
    uptime_line,
    layout = wibox.layout.align.horizontal    
}

watch(
  [[bash -c "uptime -p|grep '^up' | awk '{print $2}'"]],
  10,
  function(_, stdout)
    local days = stdout:match('(%d+)')
    uptime_line.markup = '<span font="Roboto Mono normal" color="#ffffffb0"> ' .. days .. 'd</span>'
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
uptime_icon:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
uptime_icon:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
uptime_icon:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e uptime") 
end
)

return uptime_icon


