
[![](media/eva_logo.png)](https://insality.github.io/defold-eva/)
[![Build Status](https://travis-ci.org/Insality/defold-eva.svg?branch=master)](https://travis-ci.org/Insality/defold-eva)
[![codecov](https://codecov.io/gh/Insality/defold-eva/branch/master/graph/badge.svg)](https://codecov.io/gh/Insality/defold-eva)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/insality/defold-eva)

Basic Defold module, designed for mobile games with meta-game


## Features


## Setup
#### Dependency
You can use the Defold-Eva extension in your own project by adding this project as a  [Defold library dependency](https://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

> [https://github.com/insality/defold-eva/archive/master.zip](https://github.com/insality/defold-eva/archive/master.zip)

Or point to the ZIP file of a  [specific release](https://github.com/insality/defold-eva/releases).

#### Code
Run `eva.init` in your loader script. Pass your eva custom settings and module specific settings in `eva.init` params:
```lua
local eva = require("eva.eva")
eva.init("/resources/eva_settings.json", {
	migrations = eva_migrations,
	window_settings = window_settings
})
```
Player's profile will be ready after `eva.init`. All eva stuff `eva.*` you can use after init.

In your main script file on the scene, call main loop functions:
```lua
local eva = require("eva.eva")
function update(self, dt)
	eva.update(dt)
end

function on_input(self, action_id, action)
	eva.on_input(action_id, action)
end

function on_message(self, message_id, message, sender)
	eva.on_message(message_id, message, sender)
end
```


## Eva settings


## Module settings
#### Quest settings
_TODO_
#### Festival settings
_TODO_
#### Trucks settings
_TODO_
#### Window settings
_TODO_
#### Migrations settings
_TODO_


## Custom modules
_TODO_


## Modules
- [ads](https://insality.github.io/defold-eva/modules/eva.html#modules_ads_Functions) - Ads integratio
- [cache](https://insality.github.io/defold-eva/modules/eva.html#modules_cache_Functions) - Resource/image cache
- [callbacks](https://insality.github.io/defold-eva/modules/eva.html#modules_callbacks_Functions) - Callbacks wrap to pass it via messages
- [camera](https://insality.github.io/defold-eva/modules/eva.html#modules_camera_Functions) - In-game camera with drag, pinch, zoom and other
- [daily](https://insality.github.io/defold-eva/modules/eva.html#modules_daily_Functions) - Game daily bonuses
- [db](https://insality.github.io/defold-eva/modules/eva.html#modules_db_Functions) - Wrap on all game configs
- [debug](https://insality.github.io/defold-eva/modules/eva.html#modules_debug_Functions) - Game debug and test functions on eva module
- [device](https://insality.github.io/defold-eva/modules/eva.html#modules_device_Functions) - Utilitary device functions
- [errors](https://insality.github.io/defold-eva/modules/eva.html#modules_errors_Functions) - Lua errors handler
- [events](https://insality.github.io/defold-eva/modules/eva.html#modules_events_Functions) - In-game event system
- [festivals](https://insality.github.io/defold-eva/modules/eva.html#modules_festivals_Functions) - Single or repeatable festivals system (halloween, weekend, etc)
- [game](https://insality.github.io/defold-eva/modules/eva.html#modules_game_Functions)
- [gdpr](https://insality.github.io/defold-eva/modules/eva.html#modules_gdpr_Functions) - Utilitary game functions
- [generator](https://insality.github.io/defold-eva/modules/eva.html#modules_generator_Functions) - Utilitary generator functons
- [grid](https://insality.github.io/defold-eva/modules/eva.html#modules_grid_Functions) - API to work with matrix field
- [hexgrid](https://insality.github.io/defold-eva/modules/eva.html#modules_hexgrid_Functions) - API to work with hexagon field
- [iaps](https://insality.github.io/defold-eva/modules/eva.html#modules_iaps_Functions) - Wrap on defold iap module
- [input](https://insality.github.io/defold-eva/modules/eva.html#modules_input_Functions) - Eva input system
- [invoices](https://insality.github.io/defold-eva/modules/eva.html#modules_invoices_Functions) - Invoices system. Delayed rewards, in-game mail, restricted time reward.
- [isogrid](https://insality.github.io/defold-eva/modules/eva.html#modules_isogrid_Functions) - API to work with isometric matrix field
- [lang](https://insality.github.io/defold-eva/modules/eva.html#modules_lang_Functions) - Localization module
- [loader](https://insality.github.io/defold-eva/modules/eva.html#modules_loader_Functions) - Carry on game load flow
- [migrations](https://insality.github.io/defold-eva/modules/eva.html#modules_migrations_Functions) - Apply migrations on player's profile
- [offers](https://insality.github.io/defold-eva/modules/eva.html#modules_offers_Functions) - Eva game offers system
- [pathfinder](https://insality.github.io/defold-eva/modules/eva.html#modules_pathfinder_Functions) - A* on any type of field (grid, isogrid, hexgrid)
- [proto](https://insality.github.io/defold-eva/modules/eva.html#modules_proto_Functions) - Protobuf module, load and provide API to work with
- [push](https://insality.github.io/defold-eva/modules/eva.html#modules_push_Functions) - Notifications module
- [quests](https://insality.github.io/defold-eva/modules/eva.html#modules_quests_Functions) - Eva rich quests system
- [queue](https://insality.github.io/defold-eva/modules/eva.html#modules_queue_Functions) - Utilitary queue functions to work with sequence stuff
- [random](https://insality.github.io/defold-eva/modules/eva.html#modules_random_Functions) - Utilitary random function
- [rate](https://insality.github.io/defold-eva/modules/eva.html#modules_rate_Functions) - "Rate us" in-game logic
- [rating](https://insality.github.io/defold-eva/modules/eva.html#modules_rating_Functions) - Rating utilitary functions (elo rating)
- [render](https://insality.github.io/defold-eva/modules/eva.html#modules_render_Functions) - Render effects and other render stuff
- [resources](https://insality.github.io/defold-eva/modules/eva.html#modules_resources_Functions) - Utilitary bundle resources function
- [saver](https://insality.github.io/defold-eva/modules/eva.html#modules_saver_Functions) - Game profile save module
- [server](https://insality.github.io/defold-eva/modules/eva.html#modules_server_Functions) - Provide API to work with server
- [social](https://insality.github.io/defold-eva/modules/eva.html#modules_social_Functions) - Provide API to work with social networks (facebook, google play, app center)
- [sound](https://insality.github.io/defold-eva/modules/eva.html#modules_sound_Functions) - Eva sound system
- [storage](https://insality.github.io/defold-eva/modules/eva.html#modules_storage_Functions) - Simple eva key-value persistent storage
- [tiled](https://insality.github.io/defold-eva/modules/eva.html#modules_tiled_Functions) - Module to load map from tiled and provide API to it
- [timers](https://insality.github.io/defold-eva/modules/eva.html#modules_timers_Functions) - Eva timers/delayed results module
- [token](https://insality.github.io/defold-eva/modules/eva.html#modules_token_Functions) - Eva general token module (any items in game)
- [trucks](https://insality.github.io/defold-eva/modules/eva.html#modules_trucks_Functions) - Eva trucks system. It is periodic events with timers (foodtrack, traders, etc)
- [utils](https://insality.github.io/defold-eva/modules/eva.html#modules_utils_Functions) - System utilitary functions
- [wallet](https://insality.github.io/defold-eva/modules/eva.html#modules_wallet_Functions) - Wrap on token module, with player wallet token container
- [window](https://insality.github.io/defold-eva/modules/eva.html#modules_window_Functions) - Eva windows API


## Games powered by Eva:
_TODO_


## License
MIT License, Insality


## Issues and suggestions
If you have any issues, questions or suggestions please  [create an issue](https://github.com/insality/defold-eva/issues)  or contact me:  [insality@gmail.com](mailto:insality@gmail.com)