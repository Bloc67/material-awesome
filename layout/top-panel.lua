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

local bgcolor = '#192933'
local bgcolorhover = '#121e25'

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

-- Clock / Calendar 24h format
local mytextclock = wibox.widget.textclock('<span font="Roboto Mono normal 9">%d.%m.%Y</span><span font="Roboto Mono bold 9" color="#70e0f0"> %H:%M</span>')

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

local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo; pacmd set-sink-volume alsa_output.pci-0000_01_00.1.hdmi-stereo 23000"
local do_stereo = "xrandr --output DisplayPort-0 --off --output DVI-1 --gamma 1.15:1.15:1.15 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-0 --off --output HDMI-0 --off; pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo; pacmd set-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo 65536"

local tv = awesomebuttons.with_text{ 
    type = 'outline', 
    text_size = 7,
    text = 'TV',    
    color = 'olive' ,
    onclick = do_hdmi,
    restart = 1 
}
local pc = awesomebuttons.with_text{ 
    text_size = 7,
    text = 'PC',    
    type = 'outline', 
    color = 'grey' ,
    onclick = do_stereo,
    restart = 1 
}

-- CPU big progressbar
local cputext = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "%",
}
local cpuload = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#ddffee30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local cpuload2 = wibox.widget {
    wibox.widget {
        cpuload,
        forced_width  = 40,
        direction     = 'east',
        layout        = wibox.container.rotate
    },
    cputext,    
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

    cpuload.value = math.ceil(diff_usage)
    cputext.markup = cpuload.value .. "%"
    if cpuload.value > 90 then
        cpuload.color = "#ff808080"        
    end    
    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)

local old_cursor, old_wibox
cpuload2:connect_signal("mouse::enter", function(c)
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand1"
end)
cpuload2:connect_signal("mouse::leave", function(c)
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)
cpuload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)

--TEMPERATURE
--temp radial
local temptext = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "°C",
}
local tempload = wibox.widget {
    value            = 40,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#ffff8030",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local tempload2 = wibox.widget {
    wibox.widget {
        tempload,
        forced_width  = 40,
        direction     = 'north',
        layout        = wibox.container.rotate
    },
    temptext,    
    layout = wibox.layout.stack
}
watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  12,
  function(_, stdout)
    local temp = tonumber(stdout)
    --tempload0.markup = '<span color="#606060">' .. temp .. "°" .. '</span>'
    tempload.value = temp
    temptext.markup = temp .. "°"
    if temp > 65 then
        tempload.color = "#ff8080ff"        
    end    
     collectgarbage('collect')
  end
)
tempload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e sensors") 
end
)
local old_cursor2, old_wibox2
tempload2:connect_signal("mouse::enter", function(c)
    local wb2 = mouse.current_wibox
    old_cursor2, old_wibox2 = wb2.cursor, wb2
    wb2.cursor = "hand1"
end)
tempload2:connect_signal("mouse::leave", function(c)
    if old_wibox2 then
        old_wibox2.cursor = old_cursor2
        old_wibox2 = nil
    end
end)

--temp GPU radial
local tempgtext = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "°C",
}
local tempgload = wibox.widget {
    value            = 40,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#80ffff30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local tempgload2 = wibox.widget {
    wibox.widget {
        tempgload,
        forced_width  = 40,
        direction     = 'north',
        layout        = wibox.container.rotate
    },
    tempgtext,    
    layout = wibox.layout.stack
}
watch(
  'bash -c "sensors | grep temp1: | cut -c16-17"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)
    tempgload.value = temp
    tempgtext.markup = temp .. "°"
    if temp > 60 then
        tempqload.color = "#ff8080ff"        
    end    
    collectgarbage('collect')
  end
)
tempgload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e sensors") 
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

--MEMory gadget
local memtext = wibox.widget {
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
    markup = "%",
}
local memload = wibox.widget {
    value            = 4,
    max_value        = 100,
    background_color = bgcolorhover,
    border_width     = 0,
    color            = "#aaddff30",
    paddings         = 0,
    widget = wibox.widget.progressbar
}
local memload2 = wibox.widget {
    wibox.widget {
        memload,
        forced_width  = 40,
        direction     = 'east',
        layout        = wibox.container.rotate
    },
    memtext,    
    layout = wibox.layout.stack
}
watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    
    memload.value = math.ceil(used / total * 100) 
    memtext.markup = math.ceil(used / total * 100) .. "%"
    
    collectgarbage('collect')
  end
)
memload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e bashtop") 
end
)
local old_cursor4, old_wibox4
memload2:connect_signal("mouse::enter", function(c)
    local wb4 = mouse.current_wibox
    old_cursor4, old_wibox4 = wb4.cursor, wb4
    wb4.cursor = "hand1"
end)
memload2:connect_signal("mouse::leave", function(c)
    if old_wibox4 then
        old_wibox4.cursor = old_cursor4
        old_wibox4 = nil
    end
end
) 


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
      ),
      awful.button(
        {},
        11,
        function()
          awful.layout.inc(11)
        end
      ),
      awful.button(
        {},
        12,
        function()
          awful.layout.inc(12)
        end
      )
    )
  )
  return layoutBox
end

local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

--mytextclock = wibox.widget.textclock()
local cw = calendar_widget({
    theme = 'nord',
    placement = 'top_right',
    radius = 2,
})
mytextclock:connect_signal("button::press", 
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

local weather_widget = require("awesome-wm-widgets.weather-widget.weather")

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
            wibox.container.margin (cpuload2,0,4,0,0),
            wibox.container.margin (memload2,0,4,0,0),
            wibox.container.margin (tempgload2,0,4,0,0),
            wibox.container.margin (tempload2,0,5,0,0),
            wibox.container.margin ( weather_widget({
                    api_key='596e71c77713e6a51c75d1788ea41ce1',
                    coordinates = {62.7476225262126, 7.2289747750247795},
                    time_format_12h = false,
                    timeout = 900,
                    units = 'metric',
                    step_width = '4',
                    step_spacing = '2',
                    both_units_widget = false,
                    font_name = 'Carter One',
                    icons = 'weather-underground-icons',
                    icons_extension = '.png',
                    show_hourly_forecast = true,
                    show_daily_forecast = true,
              }),5,5,10,10),
            layout = wibox.layout.fixed.horizontal,
      },
      wibox.container.margin (tv,5,5,18,5),
      wibox.container.margin (pc,0,5,18,5),
      wibox.container.margin (mytextclock,5,5,10,10),
      -- Layout box
      LayoutBox(s)
    }
  }

  return panel
end

return TopPanel
