local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

local temp_cpu = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = '<span font="Roboto Mono normal" color="#ffffff50">CORES </span><span font="Roboto Mono normal" color="#ffffff80">0°</span>'
}
watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  12,
  function(_, stdout)
    local temp = tonumber(stdout)
    temp_cpu.markup = '<span font="Roboto Mono normal" color="#ffffff50">CORES </span><span font="Roboto Mono normal" color="#ffffff80">' .. temp .. '°</span>'
    if temp > 55 then
        temp_cpu.markup = '<span font="Roboto Mono normal" color="#ff4000ff">CORES </span><span font="Roboto Mono normal" color="#ff4000ff">' .. temp .. '°</span>'
    end
     collectgarbage('collect')
  end
)
temp_cpu:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor2, old_wibox2
temp_cpu:connect_signal("mouse::enter", function(c)
    local wb2 = mouse.current_wibox
    old_cursor2, old_wibox2 = wb2.cursor, wb2
    wb2.cursor = "hand1"
end)
temp_cpu:connect_signal("mouse::leave", function(c)
    if old_wibox2 then
        old_wibox2.cursor = old_cursor2
        old_wibox2 = nil
    end
end)


return temp_cpu
