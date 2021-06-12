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

-- CPU big progressbar
local cpu_line = wibox.widget {
    align = 'left',
    valign = 'top',
    widget = wibox.widget.textbox,
    markup = "%",
}
local cpu_icon = wibox.widget {
    wibox.widget {
        image = icons.cpu,
        forced_width = 16,
        opacity = 0.3,
        resize = true,
        widget = wibox.widget.imagebox
    },
    cpu_line,
    layout = wibox.layout.align.horizontal    
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

    cpu_line.markup = '<span font="Roboto Mono normal" color="#ffffffb0"> ' .. math.ceil(diff_usage) .. '%</span>'
    if math.ceil(diff_usage) > 75 then
        cpu_line.markup = '<span font="Roboto Mono normal" color="#ff5020"> ' .. math.ceil(diff_usage) .. '%</span>'
    end    
    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
cpu_icon:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
cpu_icon:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
cpu_icon:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)

return cpu_icon
