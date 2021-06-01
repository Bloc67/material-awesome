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
local box = require('widget.progressbox.box')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

-- Clock / Calendar 24h format
local mytextclock = wibox.widget.textclock('<span font="Roboto Mono normal 9">%d.%m.%Y</span><span font="Roboto Mono bold 9" color="#70e0f0"> %H:%M</span>')

-- Add a calendar (credits to kylekewley for the original code)
--local month_calendar = awful.widget.calendar_popup.month({
--  screen = s,
--  start_sunday = false,
--  week_numbers = true
--})
--month_calendar:attach(textclock)

--local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(8), dpi(8))

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
    --icon = 'film',
    --margins = 8,
    --size = 13,
    --border = 2,
    --shape = 'rounded_rect',
    type = 'outline', 
    text_size = 7,
    text = 'TV',    
    color = 'olive' ,
    onclick = do_hdmi,
    restart = 1 
}
local pc = awesomebuttons.with_text{ 
    --icon = 'tv',
    text_size = 7,
    text = 'PC',    
    type = 'outline', 
    --margins = 8,
    --size = 13,
    --border = 2,
    color = 'grey' ,
    --shape = 'rounded_rect',
    onclick = do_stereo,
    restart = 1 
}

local cpu = box.with_text{ 
    text_size = 7,
    text = 'CPU',    
    onclick = 'terminal -e top',
    restart = 1 
}


--CPU radial
--local cputext = wibox.widget {
--   font = 'Play 8',
--   align = 'center',
--   valign = 'center',
--   widget = wibox.widget.textbox,
--   markup = 'L' 
--}

--local cputext_with_background = wibox.container.background(cputext)
--cpuload2 = wibox.widget {
--    cputext_with_background,
--    max_value = 10,
--    border_color = "#0000ff",
--    rounded_edge = true,
--    thickness = 2,
--    start_angle = 4.71238898, -- 2pi*3/4
--    forced_height = 30,
--    forced_width = 30,
--    bg = '#ffffff22',
--    paddings = 1,
--    colors = {
--        "#ffffff66",
--    },
--   widget = wibox.container.arcchart
--}
cpuload2 = wibox.widget {
    value            = 0,
    max_value        = 10,
    background_color = "#112933",
    border_width     = 1,
    border_color     = "#888888",
    color            = "#888888",
    forced_height    = 14,
    forced_width     = 20,
    paddings         = 0,
    margins          = {
        top    = 15,
        bottom = 15,
    },
    widget = wibox.widget.progressbar,
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
    local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 100

    cpuload2.value = math.ceil(diff_usage)

    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)
cpuload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e top") 
end
)




--TEMPERATURE
--temp radial
local temptext = wibox.widget {
   font = 'Play 8',
   align = 'center',
   valign = 'center',
   widget = wibox.widget.textbox,
   markup = "°C"
}

--local temptext_with_background = wibox.container.background(temptext)
--tempload2 = wibox.widget {
--    temptext_with_background,
--    max_value = 94,
--    border_color = "#0000ff",
--    rounded_edge = true,
--    thickness = 2,
--    start_angle = 4.71238898, -- 2pi*3/4
--    forced_height = 30,
--    forced_width = 30,
--    bg = '#ffff0022',
--    paddings = 1,
--    colors = {
--        "#ffff0088",
--    },
--   widget = wibox.container.arcchart
--}
tempload2 = wibox.widget {
    value            = 0,
    max_value        = 94,
    background_color = "#112933",
    border_width     = 1,
    border_color     = "#888800",
    color            = "#888800",
    forced_height    = 14,
    forced_width     = 30,
    paddings         = 0,
    margins          = {
        top    = 15,
        bottom = 15,
    },
    widget = wibox.widget.progressbar,
}
watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  12,
  function(_, stdout)
    local temp = tonumber(stdout)
    --tempload0.markup = '<span color="#606060">' .. temp .. "°" .. '</span>'
    tempload2.value = temp
    temptext.markup = temp .. "°"
    collectgarbage('collect')
  end
)
tempload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e sensors") 
end
)

--temp GPU radial
local tempgputext = wibox.widget {
   font = 'Play 8',
   align = 'center',
   valign = 'center',
   widget = wibox.widget.textbox,
}

--local tempgputext_with_background = wibox.container.background(tempgputext)
--tempgpuload2 = wibox.widget {
--    tempgputext_with_background,
--    max_value = 94,
--    border_color = "#0000ff",
--    rounded_edge = true,
--    thickness = 2,
--    start_angle = 4.71238898, -- 2pi*3/4
--    forced_height = 30,
--    forced_width = 30,
--    bg = '#80ffd022',
--    paddings = 1,
--    colors = {
--        "#80ffd088",
--    },
--   widget = wibox.container.arcchart
--}
tempgpuload2 = wibox.widget {
    value            = 0,
    max_value        = 94,
    background_color = "#112933",
    border_width     = 1,
    border_color     = "#338800",
    color            = "#338800",
    forced_height    = 14,
    forced_width     = 30,
    paddings         = 0,
    margins          = {
        top    = 15,
        bottom = 15,
    },
    widget = wibox.widget.progressbar,
}
watch(
  'bash -c "sensors | grep temp1: | cut -c16-17"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)
    tempgpuload2.value = temp
    tempgputext.markup = temp .. "°"
    collectgarbage('collect')
  end
)
tempgpuload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e sensors") 
end
)


--MEMORY
--local memload = wibox.widget.textbox()
--watch(
--  'bash -c "free | grep -z Mem.*Swap.*"',
--  10,
--  function(_, stdout)
--    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
--      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
--    memload.markup = '<span color="#606060">' .. math.ceil(used / total * 28) .. '/28GB</span>' 
--    collectgarbage('collect')
--  end
--)

--MEMORY radial
--local memtext = wibox.widget {
--   font = 'Play 8',
--   align = 'center',
--   markup = 'M',
--   valign = 'center',
--   widget = wibox.widget.textbox
--}

--local memtext_with_background = wibox.container.background(memtext)
--memload2 = wibox.widget {
--    memtext_with_background,
--    max_value = 10,
--    border_color = "#0000ff",
--    rounded_edge = true,
--    thickness = 2,
--    start_angle = 4.71238898, -- 2pi*3/4
--    forced_height = 30,
--    forced_width = 30,
--    bg = '#00f0ff22',
--    paddings = 1,
--    colors = {
--        "#00f0ff88",
--    },
--    widget = wibox.container.arcchart
--}
memload2 = wibox.widget {
    value            = 0,
    max_value        = 10,
    background_color = "#112933",
    border_width     = 1,
    border_color     = "#5555aa",
    color            = "#5555aa",
    forced_height    = 14,
    forced_width     = 20,
    paddings         = 0,
    margins          = {
        top    = 15,
        bottom = 15,
    },
    widget = wibox.widget.progressbar,
}
watch(
  'bash -c "free | grep -z Mem.*Swap.*"',
  10,
  function(_, stdout)
    local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
    memload2.value = math.ceil(used / total * 10) 
    collectgarbage('collect')
  end
)
memload2:connect_signal("button::press", function() 
    awful.spawn.with_shell("terminator -e htop") 
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
-- ...
-- Create a textclock widget
--mytextclock = wibox.widget.textclock()
-- default
local cw = calendar_widget()
-- or customized
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
            wibox.container.margin (cpu,0,5,0,0),
            --wibox.container.margin (cpuload2,0,5,4,2),
            wibox.container.margin (memload2,0,5,4,2),
            wibox.container.margin (tempgputext,0,5,4,2),
            wibox.container.margin (tempgpuload2,0,5,4,2),
            wibox.container.margin (temptext,0,5,4,2),
            wibox.container.margin (tempload2,0,5,4,2),
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
              }),0,5,15,15),
            layout = wibox.layout.fixed.horizontal,
      },
--      wibox.container.margin (tv,5,5,18,5),
--      wibox.container.margin (pc,0,5,18,5),
      wibox.container.margin (mytextclock,5,5,10,10),
      -- Layout box
      LayoutBox(s)
    }
  }

  return panel
end

return TopPanel
