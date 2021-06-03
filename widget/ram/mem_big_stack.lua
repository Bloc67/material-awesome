local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

--MEMory gadget
local mem_big_text = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "%",
}
local mem_big = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#aaddff30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local mem_big_stack = wibox.widget {
    wibox.widget {
        mem_big,
        forced_width  = 80,
        direction     = 'east',
        layout        = wibox.container.rotate
    },
    mem_big_text,    
    layout = wibox.layout.stack
}
watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    
    mem_big.value = math.ceil(used / total * 100) 
    mem_big_text.markup = "MEM " .. math.ceil(used / total * 100) .. "%"
    
    collectgarbage('collect')
  end
)
mem_big_stack:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor4, old_wibox4
mem_big_stack:connect_signal("mouse::enter", function(c)
    local wb4 = mouse.current_wibox
    old_cursor4, old_wibox4 = wb4.cursor, wb4
    wb4.cursor = "hand1"
end)
mem_big_stack:connect_signal("mouse::leave", function(c)
    if old_wibox4 then
        old_wibox4.cursor = old_cursor4
        old_wibox4 = nil
    end
end
) 

return mem_big_stack
