[![](media/eva_logo.png)](https://insality.github.io/defold-eva/)
[![Build Status](https://travis-ci.org/Insality/defold-eva.svg?branch=master)](https://travis-ci.org/Insality/defold-eva)
[![codecov](https://codecov.io/gh/Insality/defold-eva/branch/master/graph/badge.svg)](https://codecov.io/gh/Insality/defold-eva)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/insality/defold-eva)

**Eva** - basic Defold module, designed for mobile games with meta-game. It provides a lot of additional API and systems for easier game development.


## Features

**Eva** provides the basement for your game.

- Use *protobuf* for data and user profile validation, default values and marshaling
- Rich utilitary API for different actions
- Quests, festivals, offers, daily bonus, etc system embedded
- General event system, with already defined 50+ events
- Tiled support with 3 different grids support + pathfinding (grid, isogrid, hexgrid)
- Single input module to manage all input (in _go_ space)
- Data management with google docs and sheets-exporter
- Customize eva modules with single settings file
- Game time protection: use local, uptime or server time
- Tokens memory protection: protect from memory scanning (cheat engine)
- Monetization (iaps and ads) rich support
- Eva log system and errors caching for analytics
- Customizable modules with your own code (window, quests, trucks, etc)
- User profile migrations
- Eva render with customizable post-effects
- Promocodes, invoices and pushes support
- Included luax module with extended functions
- Debug functional for easier development included (save slots, reset profiles, game restart, etc)
- ~~Social and server integrations~~ (_not implemented_)

## Setup

Eva setup and initial configuration is quite massive, please read install instruction here
_TODO: write setup instructions in separate MD_


## Evadata format and export
For some modules, defined specific basic structure.

Proto eva data description can be [found here](https://github.com/Insality/defold-eva/blob/master/eva/resources/evadata.proto).

Google document with data example can be [found here](https://docs.google.com/spreadsheets/d/1-kbuk5avCvjkAgUwKM29fHf77Uc1-jZ5TtS3EHZbY4g/edit?usp=sharing).

Rules for export can be [found here](https://github.com/Insality/defold-eva/tree/master/export_config) (using [sheets-exporter](https://github.com/Insality/sheets-exporter)).


## Tiled exporter

Eva have defined workflow with tiled:
- Make assets (game objects) in defold in separate folder (subfolders allowed)
- Generate tilesets for Tiled via tiled-exporter module](https://github.com/Insality/defold-tiled-generator)
- Make level assets in Tiled via generated tilesets
- Export tmx files to Defold via tiled-exporter module](https://github.com/Insality/defold-tiled-generator)

*TODO: write instructions*


## Custom modules

Eva allows your to define new modules or rewrite existing one
_not implemented_

## Modules

|Module| Description | Status |
|--|--|--|
| [ads](https://insality.github.io/defold-eva/modules/eva.html#modules_ads_Functions) | Interstitial and rewarded ads integration | ✅ |
| [cache](https://insality.github.io/defold-eva/modules/eva.html#modules_cache_Functions) | Provides any external resources cache | ❌ |
| [callbacks](https://insality.github.io/defold-eva/modules/eva.html#modules_callbacks_Functions) | Wrap callbacks to call it via id. Pass callbacks in messages | ✅ |
| [camera](https://insality.github.io/defold-eva/modules/eva.html#modules_camera_Functions) | In-game camera with drag, pinch and zoom | ✅ |
| [daily](https://insality.github.io/defold-eva/modules/eva.html#modules_daily_Functions) | Provides game daily bonus system | ✅ |
| [db](https://insality.github.io/defold-eva/modules/eva.html#modules_db_Functions) | Contains all game configs, can verify it via protobuf | ✅ |
| [debug](https://insality.github.io/defold-eva/modules/eva.html#modules_debug_Functions) | Provides general debug options for eva systems | ✅ |
| [device](https://insality.github.io/defold-eva/modules/eva.html#modules_device_Functions) | Provides utilitary device functions | ✅ |
| [errors](https://insality.github.io/defold-eva/modules/eva.html#modules_errors_Functions) | Provides lua errors handler | ❌ |
| [events](https://insality.github.io/defold-eva/modules/eva.html#modules_events_Functions) | Eva event system | ✅ |
| [festivals](https://insality.github.io/defold-eva/modules/eva.html#modules_festivals_Functions) | Provides single or repeatable festivals system (halloween, weekend, etc) | ✅ |
| [game](https://insality.github.io/defold-eva/modules/eva.html#modules_game_Functions) | Provides utilitary game functions | ✅ |
| [gdpr](https://insality.github.io/defold-eva/modules/eva.html#modules_gdpr_Functions) | Provides GDPR API functions | ✅ |
| [generator](https://insality.github.io/defold-eva/modules/eva.html#modules_generator_Functions) | Utilitary generator functons | ❌ |
| [grid](https://insality.github.io/defold-eva/modules/eva.html#modules_grid_Functions) | API to work with matrix field | ✅ |
| [hexgrid](https://insality.github.io/defold-eva/modules/eva.html#modules_hexgrid_Functions) | API to work with hexagon field | ✅ |
| [iaps](https://insality.github.io/defold-eva/modules/eva.html#modules_iaps_Functions) | Provides rich API above defold-iap module | ✅ |
| [input](https://insality.github.io/defold-eva/modules/eva.html#modules_input_Functions) | Eva input system in _go_ system | ✅ |
| [invoices](https://insality.github.io/defold-eva/modules/eva.html#modules_invoices_Functions) | Eva invoices system. Delayed rewards, in-game mail, restricted time reward | ✅ |
| [isogrid](https://insality.github.io/defold-eva/modules/eva.html#modules_isogrid_Functions) | API to work with isometric matrix field | ✅ |
| [labels](https://insality.github.io/defold-eva/modules/eva.html#modules_labels_Functions) | Add labels to player for easier clusterization | ✅ |
| [lang](https://insality.github.io/defold-eva/modules/eva.html#modules_lang_Functions) | Eva localization module | ✅ |
| [loader](https://insality.github.io/defold-eva/modules/eva.html#modules_loader_Functions) | Carry on game load flow | ❌ |
| [migrations](https://insality.github.io/defold-eva/modules/eva.html#modules_migrations_Functions) | Provides migrations on player's profile between game versions | ✅ |
| [offers](https://insality.github.io/defold-eva/modules/eva.html#modules_offers_Functions) | Provides game offers system | ✅ |
| [pathfinder](https://insality.github.io/defold-eva/modules/eva.html#modules_pathfinder_Functions) | Pathfinding on any type of field (grid, isogrid, hexgrid) | ✅ |
| [promocode](https://insality.github.io/defold-eva/modules/eva.html#modules_promocode_Functions) | Apply tokens and bonuses by promocode. Promocodes can be time restricted | ✅ |
| [proto](https://insality.github.io/defold-eva/modules/eva.html#modules_proto_Functions) | Protobuf module, load and provide API to work with | ✅ |
| [push](https://insality.github.io/defold-eva/modules/eva.html#modules_push_Functions) | Notifications module | ✅ |
| [quests](https://insality.github.io/defold-eva/modules/eva.html#modules_quests_Functions) | Eva rich quests system | ✅ |
| [queue](https://insality.github.io/defold-eva/modules/eva.html#modules_queue_Functions) | Utilitary queue functions to work with sequence stuff | ❌ |
| [random](https://insality.github.io/defold-eva/modules/eva.html#modules_random_Functions) | Utilitary random function | ❌ |
| [rate](https://insality.github.io/defold-eva/modules/eva.html#modules_rate_Functions) | "Rate us" in-game logic | ✅ |
| [rating](https://insality.github.io/defold-eva/modules/eva.html#modules_rating_Functions) | Rating utilitary functions (elo rating) | ✅ |
| [render](https://insality.github.io/defold-eva/modules/eva.html#modules_render_Functions) | Provides different render effects and other render relative stuff | ❌ |
| [resources](https://insality.github.io/defold-eva/modules/eva.html#modules_resources_Functions) | Utilitary bundle resources function | ❌ |
| [saver](https://insality.github.io/defold-eva/modules/eva.html#modules_saver_Functions) | Provides API for save/load parts of data | ✅ |
| [server](https://insality.github.io/defold-eva/modules/eva.html#modules_server_Functions) | Provide API to work with server | ❌ |
| [status](https://insality.github.io/defold-eva/modules/eva.html#modules_status_Functions) | Status effects like passive or temporary bonuses | ❌ |
| [skill](https://insality.github.io/defold-eva/modules/eva.html#modules_skill_Functions) | Abilities with cast time, stacks and cooldown support | ❌ |
| [social](https://insality.github.io/defold-eva/modules/eva.html#modules_social_Functions) | Provide API to work with social networks (facebook, google play, app center) | ❌ |
| [sound](https://insality.github.io/defold-eva/modules/eva.html#modules_sound_Functions) | Eva sound system | ✅ |
| [storage](https://insality.github.io/defold-eva/modules/eva.html#modules_storage_Functions) | Simple eva key-value persistent storage | ✅ |
| [tiled](https://insality.github.io/defold-eva/modules/eva.html#modules_tiled_Functions) | Module to load map from tiled and provide API to it | ✅ |
| [timers](https://insality.github.io/defold-eva/modules/eva.html#modules_timers_Functions) | Eva timers/delayed results module | ✅ |
| [token](https://insality.github.io/defold-eva/modules/eva.html#modules_token_Functions) | Eva general token module (any items in game) | ✅ |
| [trucks](https://insality.github.io/defold-eva/modules/eva.html#modules_trucks_Functions) | Eva trucks system. It is periodic events with timers (foodtrack, traders, etc) | ✅ |
| [utils](https://insality.github.io/defold-eva/modules/eva.html#modules_utils_Functions) | System utilitary functions | ✅ |
| [wallet](https://insality.github.io/defold-eva/modules/eva.html#modules_wallet_Functions) | Wrap on token module, with player wallet token container | ✅ |
| [window](https://insality.github.io/defold-eva/modules/eva.html#modules_window_Functions) | Eva windows API | ✅ |


## Games powered by Eva:
_TODO_


## License
**MIT** License, [Insality](https://github.com/Insality)


## Issues and suggestions
If you have any issues, questions or suggestions please  [create an issue](https://github.com/insality/defold-eva/issues)  or contact me:  [insality@gmail.com](mailto:insality@gmail.com)
