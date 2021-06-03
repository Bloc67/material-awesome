local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

-- CPU big progressbar
local mem_line_text = wibox.widget {
    align = 'left',
    valign = 'bottom',
    widget = wibox.widget.textbox,
    markup = "%",
}
local mem_line = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolor,
    border_width     = 0,
    color            = "#ddffee30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local mem_line_comb = wibox.widget {
    mem_line_text,    
    wibox.widget {
        mem_line,
        forced_width  = 50,
        forced_height = 5,
        direction     = 'north',
        layout        = wibox.container.rotate
    },
    forced_height = 24,
    layout = wibox.layout.ratio.vertical
}
mem_line_comb:ajust_ratio(2,0.8,0.2,0)

watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    
    mem_line.value = math.ceil(used / total * 100) 
    mem_line_text.markup = '<span font="Roboto Mono normal 8" color="#ffffff50">RAM </span><span font="Roboto Mono normal 8" color="#ffffff80">' .. math.ceil(used / total * 100) .. '%</span>'
    
    collectgarbage('collect')
  end
)
mem_line_comb:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor4, old_wibox4
mem_line_comb:connect_signal("mouse::enter", function(c)
    local wb4 = mouse.current_wibox
    old_cursor4, old_wibox4 = wb4.cursor, wb4
    wb4.cursor = "hand1"
end)
mem_line_comb:connect_signal("mouse::leave", function(c)
    if old_wibox4 then
        old_wibox4.cursor = old_cursor4
        old_wibox4 = nil
    end
end
) 

return mem_line_comb

