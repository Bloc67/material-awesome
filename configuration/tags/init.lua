local awful = require('awful')
local gears = require('gears')
local icons = require('theme.icons')
local apps = require('configuration.apps')

local tags = {
  {
    icon = icons.lab,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1
  },
  {
    icon = icons.harddisk,
    type = 'windows',
    defaultApp = 'emby-theater',
    screen = 1
  },
  {
    icon = icons.chrome,
    type = 'chrome',
    defaultApp = 'opera',
    screen = 1
  },
  {
    icon = icons.code,
    type = 'code',
    defaultApp = 'terminator',
    screen = 1
  },
  {
    icon = icons.folder,
    type = 'files',
    defaultApp = 'nemo',
    screen = 1
  },
  {
    icon = icons.brightness,
    type = 'media',
    defaultApp = 'nemo',
    screen = 1
  },
  {
    icon = icons.thermometer,
    type = 'any',
    defaultApp = 'nemo',
    screen = 1
  },
  {
    icon = icons.memory,
    type = 'gimp',
    defaultApp = 'gimp',
    screen = 1
  },
  {
    icon = icons.search,
    type = 'gimp',
    defaultApp = 'gimp',
    screen = 1
  },
  {
    icon = icons.music,
    type = 'music',
    defaultApp = apps.default.music,
    screen = 1
  }
}

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max
  --awful.layout.suit.floating
}

awful.screen.connect_for_each_screen(
  function(s)
    for i, tag in pairs(tags) do
      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = true,
          layout = awful.layout.suit.tile,
          gap_single_client = false,
          gap = 4,
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
      t.gap = 4
    end
  end
)
