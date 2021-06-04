local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

local mem_line = wibox.widget {
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "%",
}

watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    
    mem_line.markup = '<span font="Roboto Mono normal" color="#ffffff50">RAM </span><span font="Roboto Mono normal" color="#ffffff80">' .. math.ceil(used / total * 100) .. '%</span>'
    
    collectgarbage('collect')
  end
)
mem_line:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor4, old_wibox4
mem_line:connect_signal("mouse::enter", function(c)
    local wb4 = mouse.current_wibox
    old_cursor4, old_wibox4 = wb4.cursor, wb4
    wb4.cursor = "hand1"
end)
mem_line:connect_signal("mouse::leave", function(c)
    if old_wibox4 then
        old_wibox4.cursor = old_cursor4
        old_wibox4 = nil
    end
end
) 

return mem_line

