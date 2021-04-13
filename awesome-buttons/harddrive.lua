local wibox = require("wibox")
local gears = require("gears")
local watch = require('awful.widget.watch')

local drives = {}

-- original
local diskhome = wibox.widget {
    max_value           = 100,
    value               = 0.33,
    forced_height       = 10,
    forced_width        = 30,
    --shape             = gears.shape.rounded_bar,
    border_width        = 1,
    border_color        = '#338877',
    color               = '#44aa99',
    background_color    = '#223344',
    widget              = wibox.widget.progressbar,
}
watch(
  [[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]],
  60,
  function(_, stdout)
    local space_consumed = stdout:match('(%d+)')
    diskhome:set_value(tonumber(space_consumed))
    collectgarbage('collect')
  end
)
local disklabel = wibox.widget.textbox('<span font="Roboto Mono normal 6">TO / H</span>')
--end


drives.multibox = function(args)

    local text = args.text
    local drivename = args.drivename
    local bordercolor = args.bordercolor
    local bgcolor = args.bgcolor
    local color = args.color

    local result = wibox.widget{
        {
            {
                {
                    image = icon,
                    resize = true,
                    forced_height = 20,
                    widget = wibox.widget.imagebox
                },
                margins = 4,
                widget = wibox.container.margin
            },
            {
                {
                    markup = '<span size="' .. text_size .. '000" foreground="' .. ((type == 'flat') and '#00000000' or color) .. '">' .. text ..'</span>',
                    widget = wibox.widget.textbox
                },
                top = 4, bottom = 4, right = 8,
                widget = wibox.container.margin
            },
            layout = wibox.layout.align.horizontal
        },
        bg = '#00000000',
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 4) end,
        widget = wibox.container.background
    }
    watch(
      [[bash -c "df -h /" .. "|grep '^/' | awk '{print $5}'"]],
      60,
      function(_, stdout)
        local space_consumed = stdout:match('(%d+)')
        diskhome:set_value(tonumber(space_consumed))
        collectgarbage('collect')
      end
    )

        if type == 'outline' then
            result:set_shape_border_color(color)
            result:set_shape_border_width(1)
        end

        if type == 'flat' then
            result:set_bg(color)
        end

        local old_cursor, old_wibox
        result:connect_signal("mouse::enter", function(c)
            if type ~= 'flat' then
                c:set_bg('#00000044')
            end
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand1"
        end)
        result:connect_signal("mouse::leave", function(c)
            if type ~= 'flat' then
                c:set_bg('#00000000')
            end
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)

        result:connect_signal("button::press", function() onclick() end)

        return result
end

return buttons
