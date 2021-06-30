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

local mem_line = wibox.widget {
    align = 'left',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = "Gb",
}
local mem_icon = wibox.widget {
    wibox.widget {
        image = icons.memory,
        forced_width = 16,
        opacity = 0.3,
        resize = true,
        widget = wibox.widget.imagebox
    },
    mem_line,
    layout = wibox.layout.align.horizontal    
}


watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    
    mem_line.markup = '<span font="Roboto Mono bold" color="#ffffffb0"> ' .. math.ceil(used / 1000000) .. '</span><span font="Roboto Mono normal" color="#ffffff80">/' .. math.ceil(total / 1000000) .. 'gb</span>'
    
    collectgarbage('collect')
  end
)
mem_icon:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor4, old_wibox4
mem_icon:connect_signal("mouse::enter", function(c)
    local wb4 = mouse.current_wibox
    old_cursor4, old_wibox4 = wb4.cursor, wb4
    wb4.cursor = "hand1"
end)
mem_icon:connect_signal("mouse::leave", function(c)
    if old_wibox4 then
        old_wibox4.cursor = old_cursor4
        old_wibox4 = nil
    end
end
) 

return mem_icon

