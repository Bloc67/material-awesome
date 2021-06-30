local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')
local watch = require('awful.widget.watch')
--local awesomebuttons = require("awesome-buttons.awesome-buttons")

local bgcolor = '#192933'
local bgcolorlite = '#293943'
local bgcolorhover = '#121e25'

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

-- my widgets
local cpu_icon = require('widget.cpu.cpu_icon')
local mem_icon = require('widget.ram.mem_icon')

local tv_line = require('widget.buttons.tv_line')
local pc_line = require('widget.buttons.pc_line')

local temp_icon_cpu = require('widget.temperature.temp_icon_cpu')
local temp_icon_gpu = require('widget.temperature.temp_icon_gpu')

local uptime_icon = require('widget.uptime.uptime_icon')

-- Clock / Calendar 24h format
local mytextclock = wibox.widget.textclock('<span font="Roboto Mono bold 12" color="#70e0f0">%H:%M</span>\r<span font="Roboto Mono normal 7">%d.%m.%Y</span>')

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
--            wibox.container.margin (uptime_icon, 0,8,16,10),
            wibox.container.margin (cpu_icon, 0,5,16,10),
            wibox.container.margin (mem_icon, 5,5,16,10),
            wibox.container.margin (temp_icon_cpu, 0,5,16,10),
            wibox.container.margin (temp_icon_gpu, 0,5,16,10),
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
            wibox.container.margin (tv_line, 5,2,10,10),
            wibox.container.margin (pc_line, 2,10,10,10),
            layout = wibox.layout.fixed.horizontal,
      },
      wibox.container.margin (mytextclock,5,5,4,0),
      wibox.container {
        LayoutBox(s),
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
        opacity = 0.4,
        widget = wibox.container.margin          
      }
    }
  }

  return panel
end

return TopPanel
