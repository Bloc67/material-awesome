local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

--temp GPU radial
local tempgtext = wibox.widget {
    align = 'center',
    valign = 'bottom',
    widget = wibox.widget.textbox,
    markup = "°C",
    font = "Roboto Mono normal 8"
}
local tempgload2 = wibox.widget {
    wibox.container.margin (tempgtext,0,0,0,4),    
    forced_width = 70,
    forced_height = 24,
    bg = "#ff200020",
    fg = "#ffffff80",
    widget = wibox.container.background
}
watch(
  'bash -c "sensors | grep temp1: | cut -c16-17"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)

    tempgtext.markup = "GPU " .. temp .. "°"
    if temp > 50 then
        tempgload2.bg = "#ff2000a0"        
    end    
    if temp > 70 then
        tempgload2.bg = "#ff2000ff"        
    end    
    collectgarbage('collect')
  end
)
tempgload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor3, old_wibox3
tempgload2:connect_signal("mouse::enter", function(c)
    local wb3 = mouse.current_wibox
    old_cursor3, old_wibox3 = wb3.cursor, wb3
    wb3.cursor = "hand1"
end)
tempgload2:connect_signal("mouse::leave", function(c)
    if old_wibox3 then
        old_wibox3.cursor = old_cursor3
        old_wibox3 = nil
    end
end)


return tempgload2
