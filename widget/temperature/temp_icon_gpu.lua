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

--temp GPU radial
local temp_gpu = wibox.widget {
    align = 'left',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff50">GPU </span><span font="Roboto Mono normal" color="#ffffff80">0°</span>'
}

local temp_icon_gpu = wibox.widget {
    wibox.widget {
        image = icons.temperature,
        forced_width = 16,
        opacity = 0.3,
        resize = true,
        widget = wibox.widget.imagebox
    },
    temp_gpu,
    layout = wibox.layout.align.horizontal    
}

watch(
  'bash -c "sensors | grep temp1: | cut -c16-17"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)

    temp_gpu.markup = '<span font="Roboto Mono normal" color="#ffffffb0">' .. temp .. '°</span>'
    if temp > 55 then
        temp_gpu.markup = '<span font="Roboto Mono normal" color="#ff4000ff">' .. temp .. '°</span>'
    end
    collectgarbage('collect')
  end
)
temp_icon_gpu:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor3, old_wibox3
temp_icon_gpu:connect_signal("mouse::enter", function(c)
    local wb3 = mouse.current_wibox
    old_cursor3, old_wibox3 = wb3.cursor, wb3
    wb3.cursor = "hand1"
end)
temp_icon_gpu:connect_signal("mouse::leave", function(c)
    if old_wibox3 then
        old_wibox3.cursor = old_cursor3
        old_wibox3 = nil
    end
end)


return temp_icon_gpu


