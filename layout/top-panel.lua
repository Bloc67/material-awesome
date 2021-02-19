local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')
local watch = require('awful.widget.watch')
local awesomebuttons = require("awesome-buttons.awesome-buttons")

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

-- Clock / Calendar 24h format
local textclock = wibox.widget.textclock('<span font="Roboto Mono normal 8">%d.%m.%Y</span><span font="Roboto Mono bold 11" color="#70e0f0">\n  %H:%M</span>')

-- Clock / Calendar 12AM/PM fornat
-- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 9">%d.%m.%Y\n  %I:%M %p</span>\n<span font="Roboto Mono bold 9">%p</span>')
-- textclock.forced_height = 56

-- Add a calendar (credits to kylekewley for the original code)
local month_calendar = awful.widget.calendar_popup.month({
  screen = s,
  start_sunday = false,
  week_numbers = true
})
month_calendar:attach(textclock)

local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(8), dpi(8))

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(24)))
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.bottom_right
          }
        )
      end
    )
  )
)

-- my buttons

-- if they change: pacmd list-sources | grep -e 'index:' -e device.string -e 'name:'


--local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extral"
--local do_hdmi = "pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo"
local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo"
--local do_stereo = "xrandr --output DisplayPort-0 --off --output DVI-1 --gamma 1.15:1.15:1.15 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-0 --off --output HDMI-0 --off; pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo"
--local do_stereo = "pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo"
local do_stereo = "xrandr --output DisplayPort-0 --off --output DVI-1 --gamma 1.15:1.15:1.15 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-0 --off --output HDMI-0 --off; pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo"

local do_pulse = "nohup pulseeffects &"


local awesome_restart = awesomebuttons.with_icon{ 
    icon = 'refresh-cw',
    type = 'outline', 
    margins = 8,
    size = 15,
    border = 2,
    color = 'teal' ,
    shape = 'circle',
    restart = 1 
}
local tv = awesomebuttons.with_icon{ 
    icon = 'film',
    type = 'outline', 
    margins = 8,
    size = 15,
    border = 2,
    color = 'olive' ,
    shape = 'circle',
    onclick = do_hdmi,
    restart = 1 
}
local mypulse = awesomebuttons.with_icon{ 
    icon = 'headphones',
    type = 'outline', 
    margins = 8,
    size = 15,
    border = 2,
    color = 'steelblue' ,
    shape = 'circle',
    onclick = do_pulse,
}
local pc = awesomebuttons.with_icon{ 
    icon = 'tv',
    type = 'outline', 
    margins = 8,
    size = 15,
    border = 2,
    color = 'grey' ,
    shape = 'circle',
    onclick = do_stereo,
    restart = 1 
}


-- CPU
local total_prev = 0
local idle_prev = 0
local cpuload = wibox.widget.textbox()
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

    cpuload.markup = '<span color="#c0c0c0">' .. math.ceil(diff_usage) .. "% " .. '</span>'

    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)
--TEMPERATURE
local max_temp = 80
local tempload = wibox.widget.textbox()
watch(
  'bash -c "cat /sys/class/thermal/thermal_zone0/temp"',
  3,
  function(_, stdout)
    local temp = stdout:match('(%d+)')
    tempload.markup = '<span color="#e0e0e0">' .. math.ceil((temp / 1000) / max_temp * 100) .. "° " .. '</span>'
    collectgarbage('collect')
  end
)
--MEMORY
local memload = wibox.widget.textbox()
watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    memload.markup = '<span color="#c0c0c0">' .. math.ceil(used / total * 28) .. '</span><span color="#808080">/28GB</span>' 
    collectgarbage('collect')
  end
)
--DISKS
-- sde2 /
-- sda1 /mnt/Filmer
-- sda2 /mnt/Torrents
-- sdd1 /mnt/familiebilder
-- sdf1 /mnt/tvseries
-- sdb1 /mnt/tvseries2

local diskhome = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#338877',
    color               = '#44aa99',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /home | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    diskhome:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local diskhomelabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">HOME</span>')

local disktorrent = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#3377cc',
    color               = '#4488bb',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /mnt/Torrents | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    disktorrent:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local disktorrentlabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">TORR</span>')

local disktv = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#3377cc',
    color               = '#4488bb',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /mnt/tvseries | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    disktv:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local disktvlabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">TV1</span>')

local disktv2 = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#3377cc',
    color               = '#4488bb',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /mnt/tvseries2 | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    disktv2:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local disktv2label = wibox.widget.textbox('<span font="Roboto Mono normal 6">TV2</span>')


local diskdbox = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#3377cc',
    color               = '#4488bb',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /mnt/DBox | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    diskdbox:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local diskdboxlabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">DBOX</span>')

local diskfam = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#3377cc',
    color               = '#4488bb',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /mnt/1TB-data | grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    diskfam:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local diskfamlabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">FAM</span>')

-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        2,
        function()
          awful.layout.inc(2)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(3)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(4)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(5)
        end
      ),
      awful.button(
        {},
        6,
        function()
          awful.layout.inc(6)
        end
      ),
      awful.button(
        {},
        7,
        function()
          awful.layout.inc(7)
        end
      ),
      awful.button(
        {},
        8,
        function()
          awful.layout.inc(8)
        end
      ),
      awful.button(
        {},
        9,
        function()
          awful.layout.inc(9)
        end
      ),
      awful.button(
        {},
        10,
        function()
          awful.layout.inc(10)
        end
      )
    )
  )
  return layoutBox
end

local TopPanel = function(s, offset)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(48)
  end
  local panel =
    wibox(
    {
      ontop = true,
      screen = s,
      height = dpi(48),
      width = s.geometry.width - offsetx,
      x = s.geometry.x + offsetx,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(48)
      }
    }
  )

  panel:struts(
    {
      top = dpi(48)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      -- Create a taglist widget
      TaskList(s),
      add_button
    },
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      {
            wibox.container.margin (cpuload,0,5,7,2),
            wibox.container.margin (tempload,0,5,7,2),
            wibox.container.margin (memload,0,10,7,2),
            layout = wibox.layout.fixed.horizontal,
      },
--      {
--            wibox.container.margin (diskhomelabel,10,0,7,2),
--            wibox.container.margin (diskhome,5,5,20,15),
--            wibox.container.margin (disktorrentlabel,0,5,7,2),
--            wibox.container.margin (disktorrent,0,5,20,15),
--            wibox.container.margin (disktvlabel,0,5,7,2),
--            wibox.container.margin (disktv,0,5,20,15),
--            wibox.container.margin (disktv2label,0,5,7,2),
--            wibox.container.margin (disktv2,0,5,20,15),
--            wibox.container.margin (diskdboxlabel,0,5,7,2),
--            wibox.container.margin (diskdbox,0,5,20,15),
--            wibox.container.margin (diskfamlabel,0,5,7,2),
--            wibox.container.margin (diskfam,0,5,20,15),
--            layout = wibox.layout.fixed.horizontal,
--      },
      wibox.container.margin (tv,15,3,9,7),
      wibox.container.margin (pc,0,13,9,7),
      wibox.container.margin (mypulse,0,3,9,7),
      wibox.container.margin (awesome_restart,0,3,9,7),
      pulse,
      clock_widget,
      -- Layout box
      LayoutBox(s)
    }
  }

  return panel
end

return TopPanel
