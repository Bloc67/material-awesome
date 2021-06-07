local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

-- CPU big progressbar
local uptime_line = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "0 days",
}

watch(
  [[bash -c "uptime -p|grep '^up' | awk '{print $2}'"]],
  10,
  function(_, stdout)
    local days = stdout:match('(%d+)')
    uptime_line.markup = '<span font="Roboto Mono normal" color="#ffffff50">UP:</span><span font="Roboto Mono normal" color="#ffffff80">' .. days .. '</span>'
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
uptime_line:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
uptime_line:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
uptime_line:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e uptime") 
end
)

return uptime_line
