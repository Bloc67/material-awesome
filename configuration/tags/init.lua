local awful = require('awful')
local gears = require('gears')
local icons = require('theme.icons')
local apps = require('configuration.apps')
local lain = require("lain")

local tags = {
  {
    icon = icons.volume,
    type = 'any',
    defaultApp = apps.default.rofi,
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'master_width_factor',
    nwidth = 0.4,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.emby,
    type = 'windows',
    defaultApp = 'emby-theater',
    screen = 1,
    layout = awful.layout.suit.tile,
    nmaster = 1,
    npolicy = 'expand',
    nwidth = 0.4,
    ncol = 1 
  },
  {
    icon = icons.brave,
    type = 'browser',
    defaultApp = 'brave-browser',
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'expand',
    nwidth = 0.7,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.comic,
    type = 'comic',
    defaultApp = 'foliate',
    screen = 1,
    layout = awful.layout.suit.max,
    npolicy = 'expand',
    nwidth = 1,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.folder,
    type = 'any',
    defaultApp = apps.default.files,
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'expand',
    nwidth = 0.5,
    nmaster = 1,
    ncol = 2 
  },
  {
    icon = icons.code,
    type = 'any',
    defaultApp = 'terminator',
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'expand',
    nwidth = 0.5,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.picture,
    type = 'any',
    defaultApp = 'gthumb',
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'master_width_factor',
    nwidth = 0.5,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.qb,
    type = 'any',
    defaultApp = 'qbittorent',
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'expand',
    nwidth = 0.5,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.music,
    type = 'music',
    defaultApp = apps.default.music,
    screen = 1,
    layout = awful.layout.suit.tile,
    npolicy = 'expand',
    nwidth = 0.5,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.virtbox,
    type = 'virtual',
    defaultApp = 'virtualbox',
    screen = 1,
    layout = awful.layout.suit.max,
    npolicy = 'expand',
    nwidth = 1,
    nmaster = 1,
    ncol = 1 
  },
  {
    icon = icons.video,
    type = 'video',
    defaultApp = apps.default.files,
    screen = 1,
    layout = awful.layout.suit.max,
    npolicy = 'expand',
    nwidth = 1,
    nmaster = 1,
    ncol = 1 
  }
}

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.max,
  awful.layout.suit.tile.bottom,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.fair.v,
  --awful.layout.suit.magnifier
  --awful.layout.suit.corner.nw,
  --awful.layout.suit.floating
  --awful.layout.suit.spiral.dwindle,
}

--lain.layout.termfair.nmaster = 3
--lain.layout.termfair.ncol    = 1

awful.screen.connect_for_each_screen(
  function(s)
    for i, tag in pairs(tags) do
      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = false,
          layout = tag.layout,
          master_count = tag.nmaster,
          column_count = tag.ncol,
          master_width_factor = tag.nwidth,
          master_fill_policy = tag.npolicy,    
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
