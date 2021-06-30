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

local temp_cpu = wibox.widget {
    align = 'left',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff50">CORE </span><span font="Roboto Mono normal" color="#ffffff80">0°</span>'
}
local temp_icon_cpu = wibox.widget {
    wibox.widget {
        image = icons.temperature,
        forced_width = 16,
        opacity = 0.3,
        resize = true,
        widget = wibox.widget.imagebox
    },
    temp_cpu,
    layout = wibox.layout.align.horizontal    
}

watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  12,
  function(_, stdout)
    local temp = tonumber(stdout)
    temp_cpu.markup = '<span font="Roboto Mono normal" color="#90ff70d0">' .. temp .. '°</span>'
    if temp > 55 then
        temp_cpu.markup = '<span font="Roboto Mono normal" color="#ff4000ff">' .. temp .. '°</span>'
    end
     collectgarbage('collect')
  end
)
temp_icon_cpu:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor2, old_wibox2
temp_icon_cpu:connect_signal("mouse::enter", function(c)
    local wb2 = mouse.current_wibox
    old_cursor2, old_wibox2 = wb2.cursor, wb2
    wb2.cursor = "hand1"
end)
temp_icon_cpu:connect_signal("mouse::leave", function(c)
    if old_wibox2 then
        old_wibox2.cursor = old_cursor2
        old_wibox2 = nil
    end
end)


return temp_icon_cpu


