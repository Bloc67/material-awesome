local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local watch = require('awful.widget.watch')

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

-- CPU big progressbar
local cpu_line_text = wibox.widget {
    align = 'left',
    valign = 'bottom',
    widget = wibox.widget.textbox,
    markup = "%",
}
local cpu_line = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolor,
    border_width     = 0,
    color            = "#ddffee30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local cpu_line_comb = wibox.widget {
    cpu_line_text,    
    wibox.widget {
        cpu_line,
        forced_width  = 50,
        forced_height = 5,
        direction     = 'north',
        layout        = wibox.container.rotate
    },
    forced_height = 24,
    layout = wibox.layout.ratio.vertical
}
cpu_line_comb:ajust_ratio(2,0.8,0.2,0)

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

    cpu_line.value = math.ceil(diff_usage)
    cpu_line_text.markup = '<span font="Roboto Mono normal 8" color="#ffffff50">CPU </span><span font="Roboto Mono normal 8" color="#ffffff80">' .. math.ceil(diff_usage) .. '%</span>'
    if math.ceil(diff_usage) > 90 then
        cpu_big.color = "#ff808080"        
    end    
    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
cpu_line_comb:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
cpu_line_comb:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
cpu_line_comb:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)

return cpu_line_comb
