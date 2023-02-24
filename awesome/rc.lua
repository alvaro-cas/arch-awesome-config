pcall(require, "luarocks.loader")

local vicious = require("vicious")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")

local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

local naughty = require("naughty")
naughty.config.defaults.timeout  = 3
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.ontop = true

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Errors during startup!",
                     text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "An error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
keyboard = false

-- "Mod1" for ALT
-- "Mod4" for Win
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}



-- {{{ Wibar
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "一", "二", "三", "四", "五", "六", "七", "八", "九" }, s, awful.layout.layouts[1])

    -- Create decoration widget
    dividerL = wibox.widget.textbox("")
    dividerL.font = "20"
    dividerR = wibox.widget.textbox("")
    dividerR.font = "20"
    spacer = wibox.widget.textbox(" ")

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
      screen   = s,
      filter   = awful.widget.tasklist.filter.minimizedcurrenttags,
      buttons  = gears.table.join(
      awful.button({ }, 1, function (c)
        if c == client.focus then
          c.minimized = true
        else
          c:emit_signal(
          "request::activate",
          "tasklist",
          {raise = true}
          )
        end
      end)),
      widget_template = {
        {
          {
            id     = 'clienticon',
            widget = awful.widget.clienticon,
          },
          margins = 1,
          widget  = wibox.container.margin,
          bg      = beautiful.wb_bg_0,
          widget  = wibox.container.background,
        },
        nil,
        create_callback = function(self, c, index, objects) --luacheck: no unused args
          self:get_children_by_id('clienticon')[1].client = c
        end,
        layout = wibox.layout.align.vertical,
      },
    }

    -- Create a keyboard widget
    key = awful.widget.keyboardlayout()

    -- Create a CPU widget
    cpu = wibox.widget.textbox()
    vicious.register(cpu, vicious.widgets.cpu, "  $1% ")

    -- Create a Memory widget
    mem = wibox.widget.textbox()
    vicious.register(mem, vicious.widgets.mem, " ﬙ $1% ")

    -- Create a Netowrk widget
    -- sudo pacman -S iw
    network = wibox.widget.textbox()
    vicious.register(network, vicious.widgets.wifiiw, "  ${ssid} ", 2, "wlo1")

    -- Create a date widget
    date = wibox.widget.textbox()
    vicious.register(date, vicious.widgets.date, "  %A, %d/%m/%Y ")

    -- Create a hdd widget
    hdd = wibox.widget.textbox()
    vicious.register(hdd, vicious.widgets.fs, "  ${/ avail_gb} GB ")

    -- Create a time widget
    time = wibox.widget.textbox()
    vicious.register(time, vicious.widgets.date, " 羽 %H:%M ")
    
    -- Cretae a volume widget
    volume = wibox.widget.textbox()
    vicious.register(volume, vicious.widgets.volume, "  $1% ", 0.1, "Master")

    --Create a battery widget
    battery = wibox.widget.textbox()
    vicious.register(battery, vicious.widgets.bat, "  $2% $3 ", 10, "BAT0")

    -- Create the wibox
    s.mywibox = awful.wibar({ 
        position = "top",
        screen = s,
        height = 30
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            {
              s.mytaglist,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerR,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_bg_1,
              widget = wibox.container.background
            },
            {
              network,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerR,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            {
              key,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerR,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_bg_1,
              widget = wibox.container.background
            },
            {
              spacer,
              bg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            wibox.widget.systray(),
            {
              s.mytasklist,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              spacer,
              bg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            {
              dividerR,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            {
              volume,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerR,
              bg = beautiful.bg_normal,
              fg = beautiful.wb_bg_1,
              widget = wibox.container.background
            },
        },
        { -- Middle widget
            layout = wibox.layout.fixed.horizontal,


        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- {
              -- dividerL,
              -- bg = beautiful.bg_normal,
              -- fg = beautiful.wb_bg_0,
              -- widget = wibox.container.background
            -- },
            -- {
              -- battery,
              -- bg = beautiful.wb_bg_0,
              -- fg = beautiful.wb_fg_0,
              -- widget = wibox.container.background
            -- },
            {
              dividerL,
              -- bg = beautiful.bg_normal,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_bg_1,
              widget = wibox.container.background
            },
            {
              cpu,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              mem,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerL,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            {
              hdd,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerL,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_bg_1,
              widget = wibox.container.background
            },
            {
              date,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
            {
              dividerL,
              bg = beautiful.wb_bg_1,
              fg = beautiful.wb_bg_0,
              widget = wibox.container.background
            },
            {
              time,
              bg = beautiful.wb_bg_0,
              fg = beautiful.wb_fg_0,
              widget = wibox.container.background
            },
        },
    }
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "k",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "j",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "0", function () awful.layout.inc( 1)                end,
              {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "0", function () awful.layout.inc(-1)                end,
              {description = "select previous layout", group = "layout"}),

    -- Launch Browser
    awful.key({ modkey },            "b", function () awful.util.spawn("firefox") end,
              {description = "run browser", group = "apps"}),
              
    -- Menubar
    awful.key({ modkey },            "p", function() awful.util.spawn_with_shell("rofi -show drun") end,
              {description = "show the menu bar", group = "launcher"}),

    -- Take a screenshot
    awful.key({ modkey, "Shift"   }, "s", function() awful.util.spawn_with_shell("sleep 0.2;maim -s ~/Desktop/ss_$(date +%s).png", false) end,
              {description = "take a screenshot with selection", group = "functions"}),

    -- Take a screenshot
    awful.key({ modkey, "Control" }, "s", function()
      awful.util.spawn_with_shell("sleep 0.2;maim -d 3 ~/Desktop/ss_$(date +%s).png", false)
      naughty.notify({ title = "Screenshot",
                       text = "Screenshot incoming!",
                       timeout = 2 })
    end,
              {description = "take a screenshot", group = "functions"}),

    -- Take a gif
    awful.key({ modkey, "Shift"   }, "g", function() awful.util.spawn_with_shell("sleep 0.2;peek", false) end,
              {description = "take a gif", group = "functions"}),

    -- Take a gif
    awful.key({ modkey, "Control" }, "g", function() awful.util.spawn_with_shell("sleep 0.2;peek --no-headerbar", false) end,
              {description = "take a gif no headerbar", group = "functions"}),

    -- Show emoji menu
    awful.key({ modkey, "Shift"   }, "e", function() awful.util.spawn_with_shell("sleep 0.2;rofi -modi emoji -show emoji --emoji-mode stdout -emoji-format '{emoji}' -theme ~/.config/rofi/emoji.rasi", false) end,

              {description = "emoji menu", group = "functions"}),
    -- Scan QR code
    awful.key({ modkey, "Shift"   }, "c", function() awful.util.spawn_with_shell("sleep 0.2;maim -qs | zbarimg -q --raw - | xclip -selection clipboard -f", false) end,
              {description = "scan a QR code", group = "functions"}),

   -- Use keyboard for controlling volume
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -D pulse sset Master 8%+", false) end),
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -D pulse sset Master 8%-", false) end),
    awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse sset Master toggle", false) end),
    awful.key({}, "XF86AudioPrev", function () awful.util.spawn("playerctl previous -p spotify", false) end),
    awful.key({}, "XF86AudioNext", function () awful.util.spawn("playerctl next -p spotify", false) end),
    awful.key({}, "XF86AudioPlay", function () awful.util.spawn("playerctl play-pause -p spotify", false) end),
    
    -- Change keyboard layout
    awful.key({ modkey            }, "space",
      function(c)
        if keyboard then
          awful.util.spawn_with_shell("setxkbmap us")
          keyboard = false
          naughty.notify({ title = "Keyboard",
                           text = "US" })
        else
          awful.util.spawn_with_shell("setxkbmap latam")
          keyboard = true
          naughty.notify({ title = "Keyboard",
                           text = "LATAM" })
        end
      end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,           }, "f",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "j",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "layout"})
)

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    { rule = { class = "KeePassXC" },
      properties = {
        screen = 1,
        tag = "九"
      }
    },
    { rule = { class = "VeraCrypt" },
      properties = {
        screen = 1,
        tag = "九"
      }
    },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Check battery status
gears.timer {
	timeout   = 120,
	call_now  = true,
	autostart = true,
	callback  = function()
		awful.spawn.easy_async_with_shell([[bash -c "cat /sys/class/power_supply/BAT0/capacity"]],
		function(stdout)
			if tonumber(stdout) <= 5 then
        naughty.notify({ bg = "#883c43",
                         fg = "#bbbbbb",
                         title = "Battery",
                         text = "Houston! Fuel is low!",
                         timeout = 20 })
			end
		end
		)
	end
}

-- Autostart Apps
awful.spawn.with_shell("~/.config/picom/picom.sh")
awful.spawn.with_shell("setxkbmap -option caps:swapescape &")
awful.spawn.with_shell("~/.config/awesome/autorun.sh")
