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

-- Variables: https://conky.cc/variables
local metrics = {
   {
      expr = "upspeedf wlp3s0",
      mode = "bar",
      rad = 0,
      width = 2,
   },
   {
      expr = "downspeedf wlp3s0",
      mode = "bar",
      rad = 0.1,
      width = 2,
      scale = 300,
   },
   {
      expr = "memperc",
      mode = "line",
      rad = 0.2,
      width = 2,
   },
   {
      expr = "cpu cpu0", -- average
      mode = "line",
      rad = 0.3,
      width = 1,
   },
}

local function get_cpu_count()
   local handle = io.popen("nproc")
   local count = handle:read("*n")
   handle:close()
   return count or 1
end

-- CPU counts are 0 to N, conky counts 1 to N+1.
local threads = get_cpu_count() + 1
for i = 1, threads do
   table.insert(metrics, {
      expr = "cpu cpu" .. i,
      mode = "line",
      rad = 0.3,
      width = 1,
   })
   table.insert(metrics, {
      expr = "freq " .. i,
      mode = "dot",
      rad = 0.4,
      width = 2,
      scale = 42,
   })
end

print("found " .. threads .. " threads.")

return {
   FONTS = {main = "Mono", size = 12},
   metrics = metrics,
}
