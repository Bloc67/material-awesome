local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

--TEMPERATURE
--temp radial
local temptext = wibox.widget {
    align = 'center',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = "°C",
    font = "Roboto Mono normal 8"
}
local tempload2 = wibox.widget {
    wibox.container.margin (temptext,0,0,4,0),    
    forced_width = 70,
    forced_height = 24,
    bg = "#ff200030",
    fg = "#ffffff80",
    widget = wibox.container.background
}
watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  12,
  function(_, stdout)
    local temp = tonumber(stdout)
    --tempload0.markup = '<span color="#606060">' .. temp .. "°" .. '</span>'
    temptext.markup = "CPU " .. temp .. "°"
    if temp > 55 then
        tempload2.bg = "#ff2000c0"        
    end    
    if temp > 70 then
        tempload2.bg = "#ff2000ff"        
    end    
     collectgarbage('collect')
  end
)
tempload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor2, old_wibox2
tempload2:connect_signal("mouse::enter", function(c)
    local wb2 = mouse.current_wibox
    old_cursor2, old_wibox2 = wb2.cursor, wb2
    wb2.cursor = "hand1"
end)
tempload2:connect_signal("mouse::leave", function(c)
    if old_wibox2 then
        old_wibox2.cursor = old_cursor2
        old_wibox2 = nil
    end
end)


return tempload2
