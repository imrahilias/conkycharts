-- A lightweight Conky extension Lua script that renders system metrics as
-- circular histograms and line charts using Cairo.

-- Copyright (C) 2026 Moritz Siegel

-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU Affero General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option) any
-- later version.

-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
-- details.

-- You should have received a copy of the GNU Affero General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.

require 'cairo'

local data = {}
local SLOTS = 3600
local ARC = 2*math.pi / SLOTS
local XDG = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. ".config")
local path = XDG .. "/conky/config.lua"
local config = dofile(path)
local FONTS = config.FONTS
local metrics = config.metrics

local function configure(cfg)
   return {
      expr = cfg.expr or "cpu",
      fade_min = cfg.fade_min or 0.5,
      mode = cfg.mode or "line",
      r = cfg.r or 1,
      g = cfg.g or 1,
      b = cfg.b or 1,
      a = cfg.a or 1,
      rad = (cfg.rad or 0.1)*math.min(W, H),
      scale = cfg.scale or 1,
      text = cfg.text or false,
      width = cfg.width or 1,
      x = (cfg.x or 0.5)*W,  -- W, H = conky_window.width, conky_window.height
      y = (cfg.y or 0.5)*H,
      zero = cfg.zero or true,
   }
end

local function init(key)
   data[key] = {}
   for k = 1, SLOTS do
      data[key][k] = nil
   end
end

local function bar(val, cfg)
   cairo_new_path(cr)
   for k = 1, SLOTS do
      if val[k] and (val[k] > 0 or cfg.zero) then

         local fade = (k <= cursec) and ((k - cursec + SLOTS) / SLOTS) or ((k - cursec) / SLOTS)
         fade = fade*(1 - cfg.fade_min) + cfg.fade_min
         cairo_set_source_rgba(cr, cfg.r, cfg.g, cfg.b, fade*cfg.a)

         local x = cfg.x + cfg.rad*math.sin(ARC*k)
         local y = cfg.y - cfg.rad*math.cos(ARC*k)

         cairo_translate(cr, x, y)
         cairo_rotate(cr, ARC*k)

         if cfg.mode == "dot" then
            cairo_rectangle(cr, 0, -val[k], cfg.width, cfg.width)
         else
            cairo_rectangle(cr, 0, 0, cfg.width, -val[k])
         end

         if cfg.text then cairo_show_text(cr, k) end

         cairo_fill(cr)
         cairo_rotate(cr, -ARC*k)
         cairo_translate(cr, -x, -y)
      end
   end
end

local function line(val, cfg)
   -- Cyclic Boundaries: k element [1,SLOTS], k_prev wraps 1->SLOTS, k_next
   -- wraps SLOTS->1. Iterate SLOTS+1 to link the last with the first val.
   cairo_new_path(cr)
   cairo_set_line_width(cr, cfg.width)
   cairo_set_source_rgba(cr, cfg.r, cfg.g, cfg.b, cfg.a)
   for kt = 1,SLOTS+1 do
      k = (kt % SLOTS) + 1
      local k_prev = (k - 2) % SLOTS + 1
      local k_next = (k % SLOTS) + 1

      if val[k] then
         local x = cfg.x + (cfg.rad + val[k])*math.sin(ARC*k)
         local y = cfg.y - (cfg.rad + val[k])*math.cos(ARC*k)

         if val[k_prev] and (val[k] > 0 or cfg.zero) then
            cairo_line_to(cr, x, y)
         else
            cairo_move_to(cr, x, y)
         end
      end
   end
   cairo_stroke(cr)
end

function conky_cairo_circle_charts()
   -- The function name has to start with `conky_` to be called as a lua_hook.
   if conky_window == nil then return end
   cs = conky_surface()
   cr = cairo_create(cs)

   W, H = conky_window.width, conky_window.height
   cursec = tonumber(os.date("%S") + os.date("%M")*60 + 1)

   cairo_select_font_face(cr, FONTS.main, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
   cairo_set_font_size(cr, FONTS.size)

   for i, metric in ipairs(metrics) do
      local cfg = configure(metric)
      local val = tonumber(conky_parse('${' .. cfg.expr .. '}'))

      if not data[i] then init(i) end

      data[i][cursec] = val / cfg.scale

      if cfg.mode == "line" then
         line(data[i], cfg)
      else
         bar(data[i], cfg)
      end
   end
   cairo_destroy(cr)
end
