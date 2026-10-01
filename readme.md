![screen](./screens/screen.jpg)

# Conky Cairo Circle Charts

### Overview

A lightweight Conky extension Lua script that renders system metrics as circular histograms and line charts using Cairo. Designed to be resolution-independent, all positions and radii are defined as fractions (0.0–1.0) of the conky window size.


### Features

-  **Metrics:** All Conky system resources like CPU load and frequency, memory or net upstream/downstream.
- **Resolution Independent:** Coordinates scale automatically based on `conky_window.width` & `conky_window.height`.
- **Separated Config:** Visual settings are isolated in `config.lua` for easy tweaking.
- **Visuals:** Multiple chart modes: bar, dot, line. Rotating fade effect for bar and dot.


### Requirements

- **Conky** built with **Lua** and **Cairo** support: https://github.com/brndnmtthws/conky
- Verify with: `conky -v | grep -E "lua|cairo"`


### Installation

1.  Place `charts.lua` and `config.lua` in your Conky config directory (e.g., `~/.config/conky/`).

2.  Add the following to your `~/.config/conky/conky.conf`:

        lua_draw_hook_post = 'conky_cairo_circle_charts',  -- The function name has to start with `conky_`.
        lua_load = './charts.lua',
        update_interval = 1.0,

3.  On Gnome shell running wayland you might need to specify `minimum_height` and `minimum_width` as `Resolution/Scale`:

        minimum_height = 1624,  -- On wayland this is Resolution/Scale: 2160/1.33 with Scale=133%
        minimum_width = 3849,  -- On wayland this is Resolution/Scale: 5120/1.33 with Scale=133%
        out_to_wayland = true,
        out_to_x = false,

    More Conky configuration settings: https://conky.cc/config_settings

4.  Restart Conky: `conky`


### Configuration

Edit `config.lua` Lua script to adjust layout. Each entry in `config.metrics` is a table with these optional keys:

| Key                | Default          | Description                                                                                                                            |
|--------------------|------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `expr`             | `"cpu"`          | Conky variable name to read (without `${}`), e.g. `"cpu N"`, `"memperc"`, `"frequency N"`.                                             |
| `fade_min`         | `0.5`            | Minimum alpha for historical data. Older slots fade out to at least this value (0‑1). Only in bar/dots mode.                           |
| `mode`             | `"line"`         | Drawing style: `"line"` (connected smooth curve) or `"bar"` (individual small bars) or `"dot"` (individual small dots).                |
| `r`, `g`, `b`, `a` | `1,1,1,1`        | RGBA color of the chart.                                                                                                               |
| `rad`              | `0.1 * min(W,H)` | Base radius of the circle. Given as a fraction of the smaller window dimension.                                                        |
| `scale`            | `1`              | Divides the raw value before it is used as a radial offset. Use to normalise (e.g. `42` for a 4.2GHz frequency to stay between 1–100). |
| `text`             | `false`          | If `true`, draws the slot value `k` as text (mainly for debugging).                                                                    |
| `width`            | `1`              | Line thickness (in `"line"` mode) or bar/dot width (in bar/dot mode).                                                                  |
| `x`, `y`           | `0.5*W`, `0.5*H` | Center of the chart. Given as fractions of the Conky window width/height.                                                              |
| `zero`             | `true`           | If `true`, zero values are drawn; if `false`, zero values are skipped.                                                                 |

The `config.lua` is interpreted by Lua so it can have loops and functions like in this example to add one curve for each thread that is found.

More Conky Variables: https://conky.cc/variables
