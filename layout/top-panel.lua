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
local textclock = wibox.widget.textclock('<span font="Roboto Mono Normal 9">%d.%m.%Y   </span> <span font="Roboto Mono Bold 9">%H:%M</span>')

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

local do_hdmi = "xrandr --output DisplayPort-0 --off --output DVI-1 --off --output DVI-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal; pacmd set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo"
local do_stereo = "xrandr --output DisplayPort-0 --off --output DVI-1 --gamma 1.15:1.15:1.15 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-0 --off --output HDMI-0 --off; pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo"

local tv = awesomebuttons.with_text{ 
    margins = 0,
    text_size = 10,
    text = 'TV',
    color = 'olive',
    onclick = do_hdmi,
    restart = 1 
}
local pc = awesomebuttons.with_text{ 
    margins = 0,
    text_size = 10,
    text = 'PC',
    color = 'grey' ,
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

    cpuload.markup = '<span color="#406050">LOAD: </span><span color="#e080a0">' .. math.ceil(diff_usage) .. "% " .. '</span>'

    total_prev = total
    idle_prev = idle
    collectgarbage('collect')
  end
)

--TEMPERATURE
local tempload0 = wibox.widget.textbox()
watch(
  'bash -c "sensors | grep Core\\ 0 | cut -c17-18"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)
    tempload0.markup = '<span color="#406050">CPU: </span><span color="#e0e0e0">' .. temp .. "°" .. '</span>'
    collectgarbage('collect')
  end
)
local temploadq = wibox.widget.textbox()
watch(
  'bash -c "sensors | grep temp1: | cut -c16-17"',
  15,
  function(_, stdout)
    local temp = tonumber(stdout)
    temploadq.markup = '<span color="#406050">GPU: </span><span color="#e0e0e0">' .. temp .. "°" .. '</span>'
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
    memload.markup = '<span color="#406050"> MEM: </span><span color="#90b0d0">' .. math.ceil(used / total * 100) .. '%</span>' 
    collectgarbage('collect')
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
      height = dpi(28),
      width = s.geometry.width - offsetx,
      x = s.geometry.x + offsetx,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(28)
      }
    }
  )

  panel:struts(
    {
      top = dpi(28)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      -- Create a taglist widget
--      TagList(s),
      TaskList(s),
      add_button
    },
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      {
            wibox.container.margin (cpuload,0,5,0,0),
            wibox.container.margin (temploadq,0,5,0,0),
            wibox.container.margin (tempload0,0,5,0,0),
            wibox.container.margin (memload,0,10,0,0),
            layout = wibox.layout.fixed.horizontal,
      },
      wibox.container.margin (tv,0,8,0,0),
      wibox.container.margin (pc,0,0,0,0),
      wibox.container.margin (clock_widget,0,5,0,0),
      -- Layout box
      LayoutBox(s)
    }
  }

  return panel
end

return TopPanel
