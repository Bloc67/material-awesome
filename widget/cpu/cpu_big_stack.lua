local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

-- CPU big progressbar
local cpu_big_text = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "%",
}
local cpu_big = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#ddffee30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local cpu_big_stack = wibox.widget {
    wibox.widget {
        cpu_big,
        forced_width  = 80,
        direction     = 'east',
        layout        = wibox.container.rotate
    },
    cpu_big_text,    
    layout = wibox.layout.stack
}

local total_prev = 0
local idle_prev = 0
watch(
  [[bash -c "cat /proc/stat | grep '^cpu '"]],
  2,
  function(_, stdout)
    local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
      stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

    local total = user + nice + system + idle + iowait + irq + softirq + steal

    local diff_idle = idle - idle_prev
    local diff_total = total - total_prev
    local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

    cpu_big.value = math.ceil(diff_usage)
    cpu_big_text.markup = '<span font="Roboto Mono normal" color="#808080">CPU </span><span font="Roboto Mono bold">' .. math.ceil(diff_usage) .. '%</span>'
    if math.ceil(diff_usage) > 90 then
        cpu_big.color = "#ff808080"        
    end    
    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
cpu_big_stack:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
cpu_big_stack:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
cpu_big_stack:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)

return cpu_big_stack
