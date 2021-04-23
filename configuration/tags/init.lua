local awful = require('awful')
local gears = require('gears')
local icons = require('theme.icons')
local apps = require('configuration.apps')

local tags = {
  {
    icon = icons.volume,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.film,
    type = 'windows',
    defaultApp = 'emby-theater',
    screen = 1
  },
  {
    icon = icons.brave,
    type = 'browser',
    defaultApp = 'brave-browser',
    screen = 1
  },
  {
    icon = icons.chrome,
    type = 'browser',
    defaultApp = 'chromium',
    screen = 1
  },
  {
    icon = icons.code,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.folder,
    type = 'file',
    defaultApp = 'nemo',
    screen = 1
  },
  {
    icon = icons.thermometer,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.memory,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.lab,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.picture,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.qb,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.music,
    type = 'music',
    defaultApp = apps.default.rofi,
    screen = 1
  }
}

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.fair.v,
  --awful.layout.suit.magnifier
  --awful.layout.suit.corner.nw,
  --awful.layout.suit.floating
  --awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top
}

awful.screen.connect_for_each_screen(
  function(s)
    for i, tag in pairs(tags) do
      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = false,
          layout = awful.layout.suit.tile,
          gap_single_client = false,
          gap = 0,
          screen = s,
          defaultApp = tag.defaultApp,
          selected = i == 1
        }
      )
    end
  end
)

_G.tag.connect_signal(
  'property::layout',
  function(t)
    local currentLayout = awful.tag.getproperty(t, 'layout')
    if (currentLayout == awful.layout.suit.max) then
      t.gap = 0
    else
      t.gap = 0
    end
  end
)
