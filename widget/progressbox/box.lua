local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local awful = require("awful")

local boxes = {}

boxes.with_text = function(args)

    local text = args.text or 'CPU'
    local maxvalue = args.maxvalue or 100
    local onclick = args.onclick or function() end
    local color = args.color or '#888888'
    local hicolor = args.hicolor or '#ff8888'
    local text_size = args.text_size or 10
    local height = args.height or 14
    local width = args.width or 20
    local margins = args.margins or 15
    local margin = args.margin or 4

    local result = wibox.widget{
        {
            {
                {
                    markup = '<span size="' .. text_size .. '" color="' .. color .. '">' .. text ..'</span>',
                    widget = wibox.widget.textbox
                },
                margins = margin, 
                widget = wibox.container.margin
            },
            {
                {
                    value            = 50,
                    max_value        = maxvalue,
                    background_color = "#112933",
                    border_width     = 1,
                    border_color     = color,
                    color            = color,
                    forced_height    = height,
                    forced_width     = width,
                    paddings         = 0,
                    margins          = {
                        top    = margins,
                        bottom = margins,
                    },
                    widget = wibox.widget.progressbar,
                },
                margins = margin,
                widget = wibox.container.margin
            },
            layout = wibox.layout.align.horizontal
        },
        widget = wibox.container.background
    }

    local old_cursor, old_wibox
    result:connect_signal("mouse::enter", function(c)
        c:set_bg('#00000044')
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand1"
    end)
    result:connect_signal("mouse::leave", function(c)
        c:set_bg('#00000000')
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

   result:connect_signal("button::press", function() onclick() end)

   return result
end


return boxes
