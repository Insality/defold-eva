-- luacheck: ignore


---@class app
local app = {}

--- Clear the app state or the app value
---@param value unknown
function app.clear(value) end


---@class eva
---@field ads eva.ads Submodule
---@field callbacks eva.callbacks Submodule
---@field camera eva.camera Submodule
---@field daily eva.daily Submodule
---@field db eva.db Submodule
---@field device eva.device Submodule
---@field events eva.events Submodule
---@field festivals eva.festivals Submodule
---@field game eva.game Submodule
---@field gdpr eva.gdpr Submodule
---@field grid eva.grid Submodule
---@field hexgrid eva.hexgrid Submodule
---@field iaps eva.iaps Submodule
---@field input eva.input Submodule
---@field invoices eva.invoices Submodule
---@field isogrid eva.isogrid Submodule
---@field labels eva.labels Submodule
---@field lang eva.lang Submodule
---@field migrations eva.migrations Submodule
---@field offers eva.offers Submodule
---@field pathfinder eva.pathfinder Submodule
---@field promocode eva.promocode Submodule
---@field proto eva.proto Submodule
---@field push eva.push Submodule
---@field quests eva.quests Submodule
---@field rate eva.rate Submodule
---@field rating eva.rating Submodule
---@field render eva.render Submodule
---@field saver eva.saver Submodule
---@field server eva.server Submodule
---@field share eva.share Submodule
---@field skill eva.skill Submodule
---@field sound eva.sound Submodule
---@field storage eva.storage Submodule
---@field tiled eva.tiled Submodule
---@field timers eva.timers Submodule
---@field token eva.token Submodule
---@field trucks eva.trucks Submodule
---@field utils eva.utils Submodule
---@field vibrate eva.vibrate Submodule
---@field wallet eva.wallet Submodule
---@field window eva.window Submodule
local eva = {}

--- Return logger from eva.log module
---@param logger_name string[opt=default] The logger name
---@return logger The logger instance
function eva.get_logger(logger_name) end

--- Call this to init Eva module
---@param settings_path string path to eva_settings.json
---@param module_settings table Settings to modules. See description on eva.lua
function eva.init(settings_path, module_settings) end

--- Call this on main update loop
---@param dt number delta time
function eva.update(dt) end


---@class eva.ads
local eva__ads = {}

--- Return current ads adapter name
---@return string The adapter name
function eva__ads.get_adapter_name() end

--- Return seconds when placement will be ready
---@param ad_id string The Ad placement id
---@param The number amount in seconds
---@return number The seconds amount until ads available
function eva__ads.get_time_to_ready(ad_id, The) end

--- Get total ads watched
---@param Total number watched ads count
function eva__ads.get_watched(Total) end

--- Check is ads are blocked with network or tokens for player
---@param ad_id string The Ad placement id
function eva__ads.is_blocked(ad_id) end

--- Check ads is enabled
---@return bool is ads enabled
function eva__ads.is_enabled() end

--- Check is ads are ready to show now
---@param ad_id string The Ad placement id
function eva__ads.is_ready(ad_id) end

--- Set enabled ads state
---@param state boolean ads state
function eva__ads.set_enabled(state) end

--- Show ad by placement id
---@param ad_id string The Ad placement id
---@param success_callback function The success callback
---@param finish_callback function The ads finish callback
function eva__ads.show(ad_id, success_callback, finish_callback) end


---@class eva.callbacks
local eva__callbacks = {}

--- Call wrapped callback
---@param index number Index of wrapped callback
---@param ... args Args of calling callback
function eva__callbacks.call(index, ...) end

--- Clear callback
---@param index number Index of wrapped callback
function eva__callbacks.clear(index) end

--- Wrap callback  It return index for callback, You can call it now  via eva.callbacks.call(index, ...)
---@param callback function Callback to wrap
---@return number index New index of wrapped callback
function eva__callbacks.create(callback) end


---@class eva.camera
local eva__camera = {}

--- Set the borders of the camera zone
---@param border_soft vector4 Soft zones of camera. Order is: left-top-right-bot.
---@param border_hard vector4 Hard zones of camera. Order is: left-top-right-bot.
function eva__camera.set_borders(border_soft, border_hard) end

--- Set the camera game object and size of the camera
---@param cam_id string url of camera game object
---@param camera_box vector3 size of the camera at zoom=1
function eva__camera.set_camera(cam_id, camera_box) end

--- Enable or disable camera user control
---@param enabled boolean state
function eva__camera.set_control(enabled) end

--- Set the camera position
---@param x number X position
---@param y number Y position
function eva__camera.set_position(x, y) end

--- Set target camera position
---@param x number X position
---@param y number Y position
function eva__camera.set_target_position(x, y) end

--- Set the camera game object and size of the camera
---@param zoom_soft vector3 Setup zoom soft values. vector3(min_value, max_value, 0)
---@param zoom_hard vector3 Setup zoom hard values. vector3(min_value, max_value, 0)
function eva__camera.set_zoom_borders(zoom_soft, zoom_hard) end

--- Eva camera update should be called manually  Due the it uses context go.set_position
---@param dt number Delta time
function eva__camera.update(dt) end


---@class eva.daily
local eva__daily = {}

--- Return current state
---@return table Array with booleans to show picked rewards
function eva__daily.get_current_state() end

--- Return time until you can pickup prize
function eva__daily.get_time() end

--- Return time until you can lose the unpicked reward
function eva__daily.get_wait_time() end

--- Return is active now daily system
function eva__daily.is_active() end

--- Pick current prize
function eva__daily.pick() end

--- Set active daily system  It will reset last pick time
function eva__daily.set_active() end


---@class eva.db
local eva__db = {}

--- Return config by config_name
---@param config_name string Config name from eva settings
---@return table Config table
function eva__db.get(config_name) end

--- Can override db with custom tables (useful for tests)
---@param settings table Custom db settings
function eva__db.set_settings(settings) end


---@class eva.device
local eva__device = {}

--- Return device id.
---@return string device_id
function eva__device.get_device_id() end

--- Return device_info
function eva__device.get_device_info() end

--- Return device region.
---@return string region
function eva__device.get_region() end

--- Generate uuid
---@param except table list of uuid, what not need to be generated
---@return string the uuid
function eva__device.get_uuid(except) end

--- Check if device on android
function eva__device.is_android() end

--- Check if device is desktop (Windows/MacOS)
function eva__device.is_desktop() end

--- Check if device on iOS
function eva__device.is_ios() end

--- Check if device is native mobile (Android or iOS)
function eva__device.is_mobile() end

--- Check if device is HTML5
function eva__device.is_web() end

--- Check if device is HTML5 mobile
function eva__device.is_web_mobile() end


---@class eva.events
local eva__events = {}

--- Throws the game event
---@param event string name of event
---@param params table params
function eva__events.event(event, params) end

--- Check if callback is already subscribed
---@param event_name string Event name
---@param callback function Event callback
function eva__events.is_subscribed(event_name, callback) end

--- Setup current game screen
---@param screen_id string screen id
function eva__events.screen(screen_id) end

--- Subscribe the callback on event
---@param event_name string Event name
---@param callback function Event callback
---@param callback_context table The first param for callback on fire
function eva__events.subscribe(event_name, callback, callback_context) end

--- Subscribe the pack of events by map
---@param map table {Event = Callback} map
function eva__events.subscribe_map(map) end

--- Unsubscribe the event from events flow
---@param event_name string Event name
---@param callback function Event callback
function eva__events.unsubscribe(event_name, callback) end

--- Unsubscribe the pack of events by map
---@param map table {Event = Callback} map
function eva__events.unsubscribe_map(map) end


---@class eva.festivals
local eva__festivals = {}

--- End festival without check any condition
---@param festival_id string Festival id from Festivals json
function eva__festivals.debug_end_festival(festival_id) end

--- Start festival without check any condition
---@param festival_id string Festival id from Festivals json
function eva__festivals.debug_start_festival(festival_id) end

--- Return completed festivals
---@return table array of completed festivals
function eva__festivals.get_completed() end

--- Return current festivals
---@return table array of current festivals
function eva__festivals.get_current() end

--- Return next end time for festival_id
---@param festival_id string Festival id from Festivals json
---@return number Time in seconds since epoch
function eva__festivals.get_end_time(festival_id) end

--- Return next start time for festival_id
---@param festival_id string Festival id from Festivals json
---@return number Time in seconds since epoch
function eva__festivals.get_start_time(festival_id) end

--- Return is festival is active now
---@param festival_id string Festival id from Festivals json
---@return bool Current festival state
function eva__festivals.is_active(festival_id) end

--- Return is festival is completed  Return true for repeated festivals, is they are completed now
---@param festival_id string Festival id from Festivals json
---@return number Festival completed counter (For repeat festivals can be > 1)
function eva__festivals.is_completed(festival_id) end

--- Set game festivals settings.
function eva__festivals.set_settings() end


---@class eva.game
local eva__game = {}

--- Exit from the game
---@param code int The exit code
function eva__game.exit(code) end

--- Get current date in format: YYYYMMDD
---@return number Current day in format YYYYMMDD
function eva__game.get_current_date_code() end

--- Get current time in string format
---@return string Time format in iso e.g. "2019-09-25T01:48:19Z"
function eva__game.get_current_time_string() end

--- Get days since first game launch
---@return number Days since first game launch
function eva__game.get_days_played() end

--- Get time in seconds until next day from current time
---@return number Seconds until next day
function eva__game.get_seconds_until_new_day() end

--- Return unique id for local session
---@return number Unique id in this game session
function eva__game.get_session_uid() end

--- Get game time
---@return number Return game time in seconds
function eva__game.get_time() end

--- Return unique id for player profile
---@return number Unique id in player profile
function eva__game.get_uid() end

--- Check game on debug mode
function eva__game.is_debug() end

--- Return true, if game launched first time
---@return bool True, if game first time launch
function eva__game.is_first_launch() end

--- Open store page in store application
function eva__game.open_store_page() end

--- Reboot the game
---@param delay number Delay before reboot, in seconds
function eva__game.reboot(delay) end


---@class eva.gdpr
local eva__gdpr = {}

--- Apply the GDPR to the game profile
function eva__gdpr.apply_gdpr() end

--- Return if GDPR is accepted
function eva__gdpr.is_accepted() end

--- Open the policy URL
function eva__gdpr.open_policy_url() end


---@class eva.grid
local eva__grid = {}

--- Transform hex to pixel position
function eva__grid.cell_to_pos() end

--- Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.grid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@return map_params Map params data
function eva__grid.get_map_params() end

--- Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3 Object position
function eva__grid.get_object_pos() end

--- Get tile position.
---@return vector3 Tile position
function eva__grid.get_tile_pos() end

--- Convert tiled object position to scene position
---@return number,number x,y Object scene position
function eva__grid.get_tiled_scene_pos() end

--- Get Z position from object Y position and his z_layer
---@param y number Object Y position
---@param z_layer number Object Z layer index
---@return map_params Map params data
function eva__grid.get_z(y, z_layer) end

--- Transform pixel to hex
function eva__grid.pos_to_cell() end

--- Set default map params  To don`t pass it every time in transform functions
---@param map_params map_params Params from eva.grid.get_map_params
function eva__grid.set_default_map_params(map_params) end


---@class eva.hexgrid
local eva__hexgrid = {}

--- Transform hex to pixel position.
---@param i number Cell i coordinate
---@param j number Cell j coordinate
---@param k number Cell k coordinate
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.cell_cube_to_pos(i, j, k, map_params) end

--- Transform hex to pixel position.
---@param i number Cell i coordinate
---@param j number Cell j coordinate
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.cell_to_pos(i, j, map_params) end

--- Transfrom cube coordinates to offset coordinates
---@param i number I coordinate
---@param j number J coordinate
---@param k number K coordinate
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.cube_to_offset(i, j, k, map_params) end

--- Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.hexgrid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@param tilewidth number Hexagon width
---@param tileheight number Hexagon height
---@param tileside number Hexagon side length (flat side)
---@param width number Map width in tiles count
---@param height number Map height in tiles count
---@param invert_y boolean If true, zero pos will be at top, else on bot
---@return map_params Map params data
function eva__hexgrid.get_map_params(tilewidth, tileheight, tileside, width, height, invert_y) end

--- Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3 Object position
function eva__hexgrid.get_object_pos() end

--- Get tile position.
---@return vector3 Tile position
function eva__hexgrid.get_tile_pos() end

--- Convert tiled object position to scene position
---@return number,number x,y Object scene position
function eva__hexgrid.get_tiled_scene_pos() end

--- Get Z position from object Y position and his z_layer
---@param y number Object Y position
---@param z_layer number Object Z layer index
---@return map_params Map params data
function eva__hexgrid.get_z(y, z_layer) end

--- Transfrom offset coordinates to cube coordinates
---@param i number I coordinate
---@param j number J coordinate
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.offset_to_cube(i, j, map_params) end

--- Transform pixel to hex.
---@param x number World x position
---@param y number World y position
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.pos_to_cell(x, y, map_params) end

--- Transform pixel to hex.
---@param x number World x position
---@param y number World y position
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.pos_to_cell_cube(x, y, map_params) end

--- Rotate offset coordinate by N * 60degree
---@param i number I coordinate
---@param j number J coordinate
---@param k number K coordinate
---@param N number Number, how much rotate on 60 degrees. Positive - rotate right, Negative - left
---@return number, number, number Offset coordinate
function eva__hexgrid.rotate_offset(i, j, k, N) end

--- Set default map params  To dont pass it every time in transform functions
---@param map_params map_params Params from eva.hexgrid.get_map_params
function eva__hexgrid.set_default_map_params(map_params) end


---@class eva.iaps
local eva__iaps = {}

--- Buy the inapp
---@param iap_id string In-game inapp ID from iaps settings
function eva__iaps.buy(iap_id) end

--- Get iap info by iap_id
---@param iap_id string the inapp id
function eva__iaps.get_iap(iap_id) end

--- Get all iaps.
---@param category string Category of iap
---@return list of iap products
function eva__iaps.get_iaps(category) end

--- Get total lifetime value (from iaps)
---@return number Player's LTV
function eva__iaps.get_ltv() end

--- Get player max payment
---@return number Max player payment
function eva__iaps.get_max_payment() end

--- Get price from iap_id
---@param iap_id string the inapp id
---@return number Price of iap
function eva__iaps.get_price(iap_id) end

--- Get price_string from iap_id
---@param iap_id string the inapp id
---@return string The iap price string
function eva__iaps.get_price_string(iap_id) end

--- Get reward from iap_id
---@param iap_id string the inapp id
function eva__iaps.get_reward(iap_id) end

--- Check is iap is available
---@param iap_id string the inapp id
---@return bool Is available
function eva__iaps.is_available(iap_id) end

--- Refresh iap list.
function eva__iaps.refresh_iap_list() end


---@class eva.input
local eva__input = {}

--- Register the input to handle user actions  If callback return true it will stop handle next input
---@param name string Name of input system
---@param callback function The input callback
---@param priority number Priority of input. Lower first
function eva__input.register(name, callback, priority) end

--- Unregister prev.
---@param name string Name of input system
function eva__input.unregister(name) end


---@class eva.invoices
local eva__invoices = {}

--- Add invoice to game profile  If time is not provided, add invoice instantly  If time is provided, add invoice in this time  Invoice should be consumed to get reward
---@param category string Category param of the invoice
---@param reward evadata.Tokens Tokens reward list
---@param time number Game time to add invoice
---@param life_time number Time in seconds of invoice available
---@param title string Text invoice title
---@param text string Text invoice desc
function eva__invoices.add(category, reward, time, life_time, title, text) end

--- Check is invoice can be consumed
---@return bool Can consume invoice
function eva__invoices.can_consume() end

--- Consume the invoice to the game profile
---@param invoice_id number The id of invoice
function eva__invoices.consume(invoice_id) end

--- Get invoice data by id
---@return eva.InvoiceInfo Invoice data
function eva__invoices.get_invoce() end

--- Return current list of invoices
function eva__invoices.get_invoices() end


---@class eva.isogrid
local eva__isogrid = {}

--- Transform hex to pixel position
function eva__isogrid.cell_to_pos() end

--- Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.isogrid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@return map_params Map params data
function eva__isogrid.get_map_params() end

--- Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3 Object position
function eva__isogrid.get_object_pos() end

--- Get tile position.
---@return vector3 Tile position
function eva__isogrid.get_tile_pos() end

--- Convert tiled object position to scene position
---@return number,number x,y Object scene position
function eva__isogrid.get_tiled_scene_pos() end

--- Get Z position from object Y position and his z_layer
---@param y number Object Y position
---@param z_layer number Object Z layer index
---@return map_params Map params data
function eva__isogrid.get_z(y, z_layer) end

--- Transform pixel to hex
function eva__isogrid.pos_to_cell() end

--- Set default map params  To don`t pass it every time in transform functions
---@param map_params map_params Params from eva.isogrid.get_map_params
function eva__isogrid.set_default_map_params(map_params) end


---@class eva.labels
local eva__labels = {}

--- Check label is exist in player profile
---@param label string The label id
---@return bool True, if label in player profile
function eva__labels.is_exist(label) end


---@class eva.lang
local eva__lang = {}

--- Get current language
---@return string return current language code
function eva__lang.get_lang() end

--- Return list of available languages
---@return table List of available languages
function eva__lang.get_langs() end

--- Check is translation with lang_id exist
---@param lang_id strng Locale id from your localization
---@return bool Is translation exist
function eva__lang.is_exist(lang_id) end

--- Set current language
---@param lang string current language code from eva-settings
function eva__lang.set_lang(lang) end

--- Return localized time format from seconds
function eva__lang.time_format() end

--- Get translation for locale id with params
---@param lang_id string Locale id from your localization
---@param ... string Params for string.format for lang_id
---@return string Translated locale
function eva__lang.txp(lang_id, ...) end

--- Get random translation for locale id, split by \n symbol
---@param lang_id string locale id from your localization
---@return string translated locale
function eva__lang.txr(lang_id) end

--- Get translation for locale id
---@param lang_id string locale id from your localization
---@return string translated locale
function eva__lang.txt(lang_id) end


---@class eva.migrations
local eva__migrations = {}

--- Apply the migrations
function eva__migrations.apply() end

--- Return amount of migrations
function eva__migrations.get_count() end

--- Add migration to the eva system  Pass the migrations list in eva.init  You should directly point the migration version  in migration list (array from 1 to N)
function eva__migrations.set_migrations() end


---@class eva.offers
local eva__offers = {}

--- Start new offer  Every offer is unique.
---@param offer_id string offer id from db
---@return eva.Offer new offer
function eva__offers.add(offer_id) end

--- Get token group of offer price.
---@param offer_id string offer id from db
---@return evadata.Tokens token list
function eva__offers.get_price(offer_id) end

--- Get token group of offer reward.
---@param offer_id string offer id from db
---@return evadata.Tokens token list
function eva__offers.get_reward(offer_id) end

--- Return time till offer end.
---@param offer_id string offer id from db
---@return number time in seconds
function eva__offers.get_time(offer_id) end

--- Check is offer active not
---@param offer_id string offer id from db
---@return bool is offer active
function eva__offers.is_active(offer_id) end

--- Check is offer for inapp
---@param offer_id string offer id from db
---@return bool is offer inapp
function eva__offers.is_iap(offer_id) end

--- Remove offers from active list
---@param offer_id string offer id from db
function eva__offers.remove(offer_id) end


---@class eva.pathfinder
local eva__pathfinder = {}

--- Init astar for map, init get_tile callback  get_node_fn - function to get tile: function(i, j)  should return cost of node.
---@param map_data map_data Map data from eva.tiled.load_map
---@param get_node_fn function Get node cost function from map
---@param options table Options for map handlers:  - diagonal boolean, to grid and isogrid pathfinding
---@return map_handler Handler for astar work
function eva__pathfinder.init_astar(map_data, get_node_fn, options) end

--- Return path between two points for map.
---@param from_x unknown Cell X from map
---@param from_y unknown Cell Y from map
---@param to_x unknown Cell X from map
---@param to_y unknown Cell Y from map
---@param map_handler map_handler Map handler to handle map for astar
---@return table|nil Table of points. See eva.libs.astar.path. Nil if path is not exist
function eva__pathfinder.path(from_x, from_y, to_x, to_y, map_handler) end


---@class eva.promocode
local eva__promocode = {}

--- Get list of all redeemed codes
---@return string[] List of applied codes
function eva__promocode.get_applied_codes() end

--- Check if promocode is already applied
---@param code string The promocode itself
---@return bool True if code is already redeemed
function eva__promocode.is_applied(code) end

--- Check if promocode can be redeem
---@param code string The promocode itself
---@return bool True of false
function eva__promocode.is_can_redeem(code) end

--- Try redeem the code and get rewards
---@param code string The promocode itself
---@return bool Result of success
function eva__promocode.redeem_code(code) end

--- Set promocode settings.
function eva__promocode.set_settings() end


---@class eva.proto
local eva__proto = {}

--- Decode protobuf
function eva__proto.decode() end

--- Encode protobuf
function eva__proto.encode() end

--- Get empty template from proto type
---@param proto_type string name of proto message e.g. 'eva.Token'
---@return table empty table with default values from proto
function eva__proto.get(proto_type) end

--- Check data to match the proto_type  Return data with default values according to proto_type
---@param proto_type string The prototype name
---@param data table The user data
function eva__proto.verify(proto_type, data) end


---@class eva.push
local eva__push = {}

--- Clear all pushes, what already  should be invoked.
function eva__push.clear_old_pushes() end

--- Schedule notification
function eva__push.schedule() end

--- Schedule by list  Every notifications have: after, title, text, category, payload
function eva__push.schedule_list() end

--- Unschedule the push notification
function eva__push.unschedule() end

--- Cancel all pushes with category  If category is not provided, cancel all pushes
function eva__push.unschedule_all() end


---@class eva.quests
local eva__quests = {}

--- Add event, to trigger quest list update.
function eva__quests.add_update_quest_event() end

--- Complete quest, if it can be completed
---@param quest_id string Quest id
function eva__quests.complete_quest(quest_id) end

--- Get completed quests list
---@return table List of active quests
function eva__quests.get_completed() end

--- Get current active quests
---@return table List of active quests
function eva__quests.get_current() end

--- Get current progress on quest
---@param quest_id string Quest id
---@return table List of progress of quest tasks in task order
function eva__quests.get_progress(quest_id) end

--- Check quest is active
---@return bool Quest active state
function eva__quests.is_active() end

--- Check quest is can be completed now
---@return bool Quest is can complete quest state
function eva__quests.is_can_complete_quest() end

--- Check quest is can be started now
---@return bool Quest is can start state
function eva__quests.is_can_start_quest() end

--- Check quest is completed
---@return bool Quest completed state
function eva__quests.is_completed() end

--- Check if there is quests in current with  pointer action and object
---@param action string Task action
---@param object string Task object
---@return bool True, if there is quest with similar tasks
function eva__quests.is_current_with_task(action, object) end

--- Apply quest event to all current quests
---@param action string Type of event
---@param object string Object of event
---@param amount number Amount of event
function eva__quests.quest_event(action, object, amount) end

--- Reset quets progress, only on current quests
---@param quest_id string Quest id
function eva__quests.reset_progress(quest_id) end

--- Set game quests settings.
function eva__quests.set_settings() end

--- Start quest, if it can be started
---@param quest_id string Quest id
function eva__quests.start_quest(quest_id) end

--- Start eva quests system.
function eva__quests.start_quests() end

--- Update quests list  It will start and end quests, by checking quests condition
function eva__quests.update_quests() end


---@class eva.rate
local eva__rate = {}

--- Open store or native rating if available
function eva__rate.open_rate() end

--- Try to promt rate game to the player
function eva__rate.promt_rate() end

--- Set rate as accepted.
function eva__rate.set_accepted() end

--- Set never promt rate again
function eva__rate.set_never_show() end


---@class eva.rating
local eva__rating = {}

--- Call elo rating
---@param rating_a number Player rating
---@param rating_b number Opponent rating
---@param game_koef number Result of game. 1 is win, 0 on loose, 0.5 is draw
function eva__rating.elo(rating_a, rating_b, game_koef) end


---@class eva.render
local eva__render = {}

--- Change render
function eva__render.set_blur() end

--- Change render
function eva__render.set_light() end

--- Change render
function eva__render.set_vignette() end


---@class eva.saver
local eva__saver = {}

--- Add save part to the save table
function eva__saver.add_save_part() end

--- Delete the save
---@param filename string The save filename. Can be default by settings
function eva__saver.delete(filename) end

--- Return save table
---@return table
function eva__saver.get_save_data() end

--- Return current save version.
---@return number
function eva__saver.get_save_version() end

--- Load the file from save directory
function eva__saver.load() end

--- Reset the game profile
function eva__saver.reset() end

--- Save the game file in save directory
function eva__saver.save() end

--- Save the data in save directory
---@param data table The save data table
---@param filename string The save filename
function eva__saver.save_data(data, filename) end

--- Set autosave timer for game.
---@param seconds number The time in seconds
function eva__saver.set_autosave_timer(seconds) end


---@class eva.server
local eva__server = {}

--- Login at nakama server
---@param callback function Callback after login
function eva__server.connect(callback) end

--- Return nakama client
---@return table
function eva__server.get_client() end

--- Return nakama socket
---@return table
function eva__server.get_socket() end

--- Return is currently server connected
---@return boolean If server connected
function eva__server.is_connected() end


---@class eva.share
local eva__share = {}

--- Share screenshot of the game
---@param text string The optional text to share with screenshot
function eva__share.screen(text) end


---@class eva.skill
local eva__skill = {}

--- Add amount to skill stacks
function eva__skill.add_stack() end

--- End use of channeling spell or end effect of skill  with duration
function eva__skill.end_use() end

--- Return current skill progress time
function eva__skill.get_active_progress() end

--- Return skill active time (duration)
function eva__skill.get_active_time() end

--- Return skill active left time (until end of duration)
function eva__skill.get_active_time_left() end

--- Get cooldown progress
function eva__skill.get_cooldown_progress() end

--- Return skill cooldown time
function eva__skill.get_cooldown_time() end

--- Return skill cooldown time left
function eva__skill.get_cooldown_time_left() end

--- Get current skill stack amount
function eva__skill.get_stack_amount() end

--- Time between use and end_use
function eva__skill.is_active() end

--- Return true if skill can be used now
function eva__skill.is_can_use() end

--- Return true if skill is empty now
function eva__skill.is_empty_stack() end

--- Return true if skill on full stack
function eva__skill.is_full_stack() end

--- Return true if skill on the cooldown
function eva__skill.is_on_cooldown() end

--- Restore all skills in containers
function eva__skill.restore_all() end

--- Skill cooldown
function eva__skill.skil_cooldown_time() end

--- Use skill
function eva__skill.use() end


---@class eva.sound
local eva__sound = {}

--- Fade sound from one gain to another
---@param sound_id string
---@param to number
---@param time number
---@param callback function
function eva__sound.fade(sound_id, to, time, callback) end

--- Slowly fade music to another one or empty
---@param to number
---@param time number
---@param callback function
function eva__sound.fade_music(to, time, callback) end

--- Get music gain
function eva__sound.get_music_gain() end

--- Get sound gain
function eva__sound.get_sound_gain() end

--- Check music gain
function eva__sound.is_music_enabled() end

--- Check sound gain
function eva__sound.is_sound_enabled() end

--- Play the sound in the game
---@param sound_id string
---@param gain number
---@param speed number
function eva__sound.play(sound_id, gain, speed) end

--- Start playing music
---@param music_id string
---@param gain number
---@param callback function
function eva__sound.play_music(music_id, gain, callback) end

--- Play the random sound from sound names array
---@param sound_ids string[]
---@param gain number
---@param speed number
function eva__sound.play_random(sound_ids, gain, speed) end

--- Set music gain
function eva__sound.set_music_gain() end

--- Set sound gain
function eva__sound.set_sound_gain() end

--- Stop sound playing
---@param sound_id string
function eva__sound.stop(sound_id) end

--- Stop all sounds in the game
function eva__sound.stop_all() end

--- Stop any music in the game
function eva__sound.stop_music() end


---@class eva.storage
local eva__storage = {}

--- Get the value from the storage.
---@param id string The record id
function eva__storage.get(id) end

--- Set the value to eva storage
---@param id string The record id
---@param value string|number|bool Value
function eva__storage.set(id, value) end


---@class eva.tiled
local eva__tiled = {}

--- Add object to the map by object index from tiled tileset
---@param layer_name string Name of tiled layer
---@param spawner_name string Name of tileset
---@param index number Object index from tileset
---@param x number x position
---@param y number y position
---@param props table Object additional properties
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.add_object(layer_name, spawner_name, index, x, y, props, map_data) end

--- Add tile to the map by tile index from tiled tileset
---@param layer_name string Name of tiled layer
---@param spawner_name string Name of tileset
---@param index number Tile index from tileset
---@param i number Cell x position
---@param j number Cell y position
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.add_tile(layer_name, spawner_name, index, i, j, map_data) end

--- Delete object from the map by game_object id
---@param game_object_id hash Game object id
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.delete_object(game_object_id, map_data) end

--- Delete tile from the map by tile pos
---@param layer string Name of the tiled layer
---@param i number Cell x position
---@param j number Cell y position
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.delete_tile(layer, i, j, map_data) end

--- Get object to the map by game_object id
---@param game_object_id hash Game object id
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.get_object(game_object_id, map_data) end

--- Get mapping object info by name
---@param object_name string The game object name
function eva__tiled.get_object_data(object_name) end

--- Get tile from the map by tile pos
---@param layer_name string Name of tiled layer
---@param i number Cell x position
---@param j number Cell y position
---@param map_data map_data Map_data returned by eva.tiled.load_map.  Last map by default
function eva__tiled.get_tile(layer_name, i, j, map_data) end

--- Load map from tiled json data
---@param data table Json map data
---@param create_object_fn callback Module call this with param(object_layer, object_id, position)
function eva__tiled.load_map(data, create_object_fn) end


---@class eva.timers
local eva__timers = {}

--- Add new timer  Timer with slot_id should no exist
---@param slot_id string identificator of timer
---@param timer_id string string param of timer
---@param time number time of timer, in seconds
---@param auto_trigger bool true, if event should fire event at end
function eva__timers.add(slot_id, timer_id, time, auto_trigger) end

--- Clear the timer slot
---@param slot_id string identificator of timer
function eva__timers.clear(slot_id) end

--- Get timer
function eva__timers.get() end

--- Get time until end, in seconds
---@param slot_id string identificator of timer
---@return number Time until end of timer. -1 if timer is not exist
function eva__timers.get_time(slot_id) end

--- Check is timer has ended
---@param slot_id string identificator of timer
function eva__timers.is_end(slot_id) end

--- Set timer pause state
---@param slot_id string identificator of timer
---@param is_pause boolean pause state
function eva__timers.set_pause(slot_id, is_pause) end


---@class eva.token
local eva__token = {}

--- Add tokens to save
function eva__token.add() end

--- Add multiply tokens by token_group_id
function eva__token.add_group() end

--- Add to tokens infinity time usage
function eva__token.add_infinity_time() end

--- Add multiply tokens
function eva__token.add_many() end

--- Add visual debt to token
function eva__token.add_visual() end

--- Clear all tokens from container
---@param container_id string Container id
function eva__token.clear_container(container_id) end

--- Create new token container
---@param container_id string Container id
---@param container_type string Container type to match from token config
function eva__token.create_container(container_id, container_type) end

--- Delete token container
---@param container_id string Container id
function eva__token.delete_container(container_id) end

--- Get current token amount from save
function eva__token.get() end

--- Get amount of seconds till end of infinity time
function eva__token.get_infinity_seconds() end

--- Return lot price by lot_id.
---@param lot_id string the token lot id
---@return evadata.Tokens the token list
function eva__token.get_lot_price(lot_id) end

--- Return lot reward by lot_id.
---@param lot_id string the token lot id
---@return evadata.Tokens the token list
function eva__token.get_lot_reward(lot_id) end

--- Get all tokens from container
---@param container_id string Container id
---@return evadata.Tokens Tokens from container
function eva__token.get_many(container_id) end

--- Return token maximum value
---@param container_id string Container id
---@param token_id string Token id
---@return number|nil The token maximum value if exists
function eva__token.get_max(container_id, token_id) end

--- Get current time to next restore point
function eva__token.get_seconds_to_restore() end

--- Return token group by id.
---@param token_group_id string the token group id
---@return evadata.Tokens the token list
function eva__token.get_token_group(token_group_id) end

--- Return evadata.Tokens tokens format.
---@param tokens table Map with token_id = amount
function eva__token.get_tokens(tokens) end

--- Get current visual debt of token
function eva__token.get_visual() end

--- Return is tokens equals to 0
---@param container_id string Container id
---@param token_id string Token id
function eva__token.is_empty(container_id, token_id) end

--- Check is enough to pay token
function eva__token.is_enough() end

--- Check multiply tokens by token_group_id
---@param token_group_id string the token group id
function eva__token.is_enough_group(token_group_id) end

--- Check multiply tokens
---@param tokens evadata.Tokens list
function eva__token.is_enough_many(tokens) end

--- Check if token container exist
---@param container_id string Container id
---@return bool Container exist state
function eva__token.is_exist_container(container_id) end

--- Return is token is infinity now
function eva__token.is_infinity() end

--- Return is token is maximum
---@param container_id string Container id
---@param token_id string Token id
function eva__token.is_max(container_id, token_id) end

--- Try to pay tokens from save
---@param token_id string Token id
---@param amount number Amount to pay
---@param reason string The reason to pay
function eva__token.pay(token_id, amount, reason) end

--- Pay multiply tokens by token_group_id
---@param token_group_id string The token group id
---@param reason string The reason to pay
function eva__token.pay_group(token_group_id, reason) end

--- Pay multiply tokens
---@param tokens evadata.Tokens Tokens data
---@param reason string The reason to pay
function eva__token.pay_many(tokens, reason) end

--- Set tokens to save
function eva__token.set() end

--- Reset visual debt of tokens
function eva__token.sync_visual() end


---@class eva.trucks
local eva__trucks = {}

--- Arrive truck right now, even it can't be  arrived now.
---@param truck_id string Truck id
function eva__trucks.arrive(truck_id) end

--- Get time for next truck arrive
---@param truck_id string Truck id
---@return number Time in seconds
function eva__trucks.get_time_to_arrive(truck_id) end

--- Get time for next truck leave
---@param truck_id string Truck id
---@return number Time in seconds
function eva__trucks.get_time_to_leave(truck_id) end

--- Check if truck is already arrived
---@param truck_id string Truck id
---@return bool Is arrived now
function eva__trucks.is_arrived(truck_id) end

--- Check if truck can be arrived now
---@param truck_id string Truck id
---@return bool Is can arrive now
function eva__trucks.is_can_arrive(truck_id) end

--- Check if truck can leave now
---@param truck_id string Truck id
---@return bool Is can leave now
function eva__trucks.is_can_leave(truck_id) end

--- Check is truck enabled now
---@param truck_id string Truck id
---@return bool Is truck enabled
function eva__trucks.is_enabled(truck_id) end

--- Leave truck right now, even it can  leave now.
---@param truck_id string Truck id
function eva__trucks.leave(truck_id) end

--- Set truck enabled state
---@param truck_id string Truck id
function eva__trucks.set_enabled(truck_id) end

--- Set trucks settings with custom callbacks.
---@param trucks_settings table Table with callbacks
function eva__trucks.set_settings(trucks_settings) end


---@class eva.utils
local eva__utils = {}

--- Make after closure
function eva__utils.after() end

--- Return days in month
function eva__utils.get_days_in_month() end

--- Convert hex color to rgb color
function eva__utils.hex2rgb() end

--- Load image to GUI node
function eva__utils.load_image() end

--- Load json from bundled resource
function eva__utils.load_json() end

--- Convert rgb color to hex color
function eva__utils.rgb2hex() end

--- Save json in bundled resource (desktop only)
function eva__utils.save_json() end


---@class eva.vibrate
local eva__vibrate = {}

--- Return if vibrate is enabled for user
---@return boolean|nil Is vibrate enabled
function eva__vibrate.is_enabled() end

--- Turn on or off vibrate for user
---@param is_enabled boolean Vibrate state
function eva__vibrate.set_enabled(is_enabled) end

--- Make phone vibrate
---@param vibrate_pattern number Vibrate const.VIBRATE
function eva__vibrate.vibrate(vibrate_pattern) end


---@class eva.wallet
local eva__wallet = {}

--- Add tokens to save
function eva__wallet.add() end

--- Add multiply tokens by token_group_id
function eva__wallet.add_group() end

--- Add to tokens infinity time usage
function eva__wallet.add_infinity_time() end

--- Add multiply tokens
function eva__wallet.add_many() end

--- Add visual debt to token
function eva__wallet.add_visual() end

--- Get current token amount from save
function eva__wallet.get() end

--- Get amount of seconds till end of infinity time
function eva__wallet.get_infinity_seconds() end

--- Return token maximum value
---@param token_id string Token id
---@return number|nil The token maximum value if exists
function eva__wallet.get_max(token_id) end

--- Get current time to next restore point
function eva__wallet.get_seconds_to_restore() end

--- Get current visual debt of token
function eva__wallet.get_visual() end

--- Return is tokens equals to 0
function eva__wallet.is_empty() end

--- Check is enough to pay token
function eva__wallet.is_enough() end

--- Check multiply tokens by token_group_id
---@param token_group_id string the token group id
function eva__wallet.is_enough_group(token_group_id) end

--- Check multiply tokens
---@param tokens evadata.Tokens list
function eva__wallet.is_enough_many(tokens) end

--- Return is token is infinity now
function eva__wallet.is_infinity() end

--- Return is token is maximum
---@param token_id string Token id
---@param True boolean , if token at maximum value
function eva__wallet.is_max(token_id, True) end

--- Try to pay tokens from save
---@param token_id string Token id
---@param amount number Amount to pay
---@param reason string The reason to pay
function eva__wallet.pay(token_id, amount, reason) end

--- Pay multiply tokens by token_group_id
---@param token_group_id string The token group id
---@param reason string The reason to pay
function eva__wallet.pay_group(token_group_id, reason) end

--- Pay multiply tokens
---@param tokens evadata.Tokens Tokens data
---@param reason string The reason to pay
function eva__wallet.pay_many(tokens, reason) end

--- Set tokens to save
function eva__wallet.set() end

--- Reset visual debt of tokens
function eva__wallet.sync_visual() end


---@class eva.window
local eva__window = {}

--- Appear functions for all windows  Need to call inside window
---@param window_id string The window id
---@param callback func Callback after window open
function eva__window.appear(window_id, callback) end

--- Close window by id or last window
---@param window_id string The window id
function eva__window.close(window_id) end

--- Close all windows
function eva__window.close_all() end

--- Disappear functions for all windows  Need to call inside window
---@param window_id string The window id
---@param callback func Callback after window close
function eva__window.disappear(window_id, callback) end

--- Return passed data to scene/window
function eva__window.get_data() end

--- Check is window is opened now
---@param window_id string The window id
function eva__window.is_open(window_id) end

--- Send message to the last open window
---@param message_id hash
---@param message table
function eva__window.msg_post(message_id, message) end

--- On message function to manage windows
---@param window_id string
---@param message_id hash
---@param message table
---@param sender url
function eva__window.on_message(window_id, message_id, message, sender) end

--- Preload window via monarch
---@param window_id string The window id
---@param callback function The callback function
function eva__window.preload(window_id, callback) end

--- Set game windows settings
function eva__window.set_settings() end

--- Show the game window  It will close current window and open new, if any opened  It can be popup on popup, so don't close prev.
function eva__window.show() end

--- Load the game scene
function eva__window.show_scene() end


---@class eva_const
---@field DAILY eva_const.DAILY Available daily bonus values
---@field EVA eva_const.EVA Inner eva protodata names
---@field EVA_VERSION field Need to check basic config and protofiles
---@field EVENT eva_const.EVENT Eva built-in game events
---@field FPS field Game FPS constant
---@field IAP eva_const.IAP Iap states
---@field INPUT eva_const.INPUT Eva input events
---@field INPUT_KEYS field[] This is all keys from all.input_binding
---@field INPUT_SWIPE eva_const.INPUT_SWIPE Eva built-in input swipe directions
---@field INPUT_TYPE eva_const.INPUT_TYPE Eva built-in input type
---@field OS eva_const.OS Available OS values
---@field STORAGE eva_const.STORAGE Reserved strings for eva.storage values from other modules
---@field UNKNOWN_REGION field Unknown region for eva.device.get_region()
---@field VIBRATE eva_const.VIBRATE Vibrate constants for eva.vibrate
---@field WALLET_CONTAINER field Default player container
---@field WALLET_TYPE field Default wallet container type
---@field require field Hack for require dynamic libraries
(exlude from defold dependencies tree, need to manual pre-require some libraries)
local eva_const = {}


---@class eva_const.DAILY
---@field RESET field
---@field SKIP field
---@field WAIT field
local eva_const__DAILY = {}


---@class eva_const.EVA
---@field ADS field
---@field CONTAINER field
---@field CONTAINERS field
---@field DAILY field
---@field DEVICE field
---@field FESTIVALS field
---@field GAME field
---@field GDPR field
---@field IAPS field
---@field IAP_INFO field
---@field INVOICES field
---@field INVOICE_INFO field
---@field LABELS field
---@field LANG field
---@field OFFER field
---@field OFFERS field
---@field PROMOCODES field Part of data
---@field PUSH field
---@field PUSH_INFO field
---@field QUESTS field
---@field RATE field
---@field SAVER field
---@field SERVER field
---@field SKILL field
---@field SKILLS field
---@field SKILL_CONTAINERS field
---@field SOUND field
---@field STATUSES field
---@field STORAGE field
---@field STORAGE_VALUE field
---@field TIMER field
---@field TIMERS field
---@field TOKEN field
---@field TOKENS_DATA field
---@field TOKEN_RESTORE_CONFIG field
---@field TRUCKS field
local eva_const__EVA = {}


---@class eva_const.EVENT
---@field ADS_ERROR field
---@field ADS_READY field
---@field ADS_SHOW field
---@field ADS_SUCCESS field
---@field ADS_SUCCESS_REWARDED field
---@field CODE_REDEEM field
---@field DAILY_LOST field
---@field DAILY_NEW_CYCLE field
---@field DAILY_RESET field
---@field DAILY_REWARD field
---@field FESTIVAL_CLOSE_TO_END field
---@field FESTIVAL_END field
---@field FESTIVAL_START field
---@field GAME_FOCUS field
---@field GAME_START field Game start eva event
---@field IAP_CANCEL field
---@field IAP_INVALID field
---@field IAP_PURCHASE field
---@field IAP_START field
---@field IAP_UPDATE field
---@field IAP_VALID field
---@field INVOICE_ADD field
---@field INVOICE_CONSUME field
---@field INVOICE_EXPIRE field
---@field LABEL_ADD field
---@field LABEL_REMOVE field
---@field LANG_UPDATE field
---@field MUSIC_GAIN_CHANGE field
---@field NEW_DAY field
---@field NEW_SESSION field
---@field OFFERS_CLEAR field
---@field OFFERS_START field
---@field PUSH_CANCEL field
---@field PUSH_SCHEDULED field
---@field QUEST_END field
---@field QUEST_PROGRESS field
---@field QUEST_REGISTER field
---@field QUEST_START field
---@field QUEST_TASK_COMPLETE field
---@field RATE_OPEN field
---@field SCENE_CLOSE field
---@field SCENE_SHOW field
---@field SERVER_LOGIN field
---@field SKILL_COOLDOWN_END field
---@field SKILL_COOLDOWN_START field
---@field SKILL_USE field
---@field SKILL_USE_END field
---@field SOUND_GAIN_CHANGE field
---@field TIMER_TRIGGER field
---@field TOKEN_CHANGE field
---@field TRUCK_ARRIVE field
---@field TRUCK_CLOSE_TO_LEAVE field
---@field TRUCK_LEAVE field
---@field WINDOW_CLOSE field
---@field WINDOW_EVENT field
---@field WINDOW_SHOW field
local eva_const__EVENT = {}


---@class eva_const.IAP
---@field FAILED field
---@field PURCHASED field
---@field RESTORED field
---@field STATE field
---@field UNVERIFIED field
local eva_const__IAP = {}


---@class eva_const.INPUT
---@field CALLBACK field
---@field CLOSE field
---@field KEY_1 field
---@field KEY_2 field
---@field KEY_3 field
---@field KEY_D field
---@field KEY_LALT field
---@field KEY_LCTRL field
---@field KEY_N field
---@field KEY_O field
---@field KEY_P field
---@field KEY_Q field
---@field KEY_R field
---@field MULTITOUCH field
---@field SCROLL_DOWN field
---@field SCROLL_UP field
---@field TOUCH field
local eva_const__INPUT = {}


---@class eva_const.INPUT_SWIPE
---@field DOWN field
---@field LEFT field
---@field RIGHT field
---@field UP field
local eva_const__INPUT_SWIPE = {}


---@class eva_const.INPUT_TYPE
---@field DRAG field
---@field DRAG_END field
---@field DRAG_START field it mean touch_cancel too
---@field KEY_HOLD field
---@field KEY_PRESSED field
---@field KEY_RELEASED field
---@field KEY_REPEATED field
---@field LONG_TOUCH field
---@field PINCH field
---@field PINCH_END field
---@field PINCH_START field
---@field TOUCH field
---@field TOUCH_END field
---@field TOUCH_START field
local eva_const__INPUT_TYPE = {}


---@class eva_const.OS
---@field ANDROID field
---@field BROWSER field
---@field IOS field
---@field LINUX field
---@field MAC field
---@field WINDOWS field
local eva_const__OS = {}


---@class eva_const.STORAGE
---@field VIBRATE_IS_ENABLED field
local eva_const__STORAGE = {}


---@class eva_const.VIBRATE
---@field LIGHT field in milliseconds
---@field iOS field
local eva_const__VIBRATE = {}


---@class event
local event = {}

--- Clear all event callbacks
function event.clear() end

--- Check is event is empty
---@return boolean True if event has no any subscribed callbacks
function event.is_empty() end

--- Subscribe on the event
---@param callback function The event callback function
---@param callback_context any The first argument for callback function
function event.subscribe(callback, callback_context) end

--- Trigger the even
---@param args args The args for event trigger
function event.trigger(args) end

--- Unsubscribe from the event
---@param callback function The event callback function
---@param callback_context any The first argument for callback function
---@return If event was unsubscribed or not
function event.unsubscribe(callback, callback_context) end

--- Unsubscribe from the event
---@param callback function The default event callback function
---@param callback_context any The first argument for callback function
---@return boolean Is there is event with callback and context
function event.unsubscribe(callback, callback_context) end


---@class log
local log = {}

--- Return the new logger instance
---@param name string
---@return logger
function log.get_logger(name) end


---@class logger
local logger = {}

--- Call log with DEBUG level
---@param The self log instance
---@param msg string The log message
---@param context table The log context
function logger.debug(The, msg, context) end

--- Call log with ERROR level
---@param self userdata The log instance
---@param msg string The log message
---@param table context The log context
function logger.error(self, msg, table) end

--- Call log with FATAL level
---@param self userdata The log instance
---@param msg string The log message
---@param table context The log context
function logger.fatal(self, msg, table) end

--- Call log with INFO level
---@param self userdata The log instance
---@param msg string The log message
---@param table context The log context
function logger.info(self, msg, table) end

--- Call log with WARN level
---@param self userdata The log instance
---@param msg string The log message
---@param table context The log context
function logger.warn(self, msg, table) end


---@class luax
---@field debug luax.debug Submodule
---@field go luax.go Submodule
---@field gui luax.gui Submodule
---@field math luax.math Submodule
---@field operators luax.operators Submodule
---@field string luax.string Submodule
---@field table luax.table Submodule
---@field vmath luax.vmath Submodule
local luax = {}


---@class luax.debug
local luax__debug = {}

--- debug.timelog
function luax__debug.timelog() end


---@class luax.go
local luax__go = {}

--- go.set_alpha
function luax__go.set_alpha() end


---@class luax.gui
local luax__gui = {}

--- gui.get_alpha
function luax__gui.get_alpha() end

--- gui.is_chain_enabled
function luax__gui.is_chain_enabled() end

--- gui.set_alpha
function luax__gui.set_alpha() end

--- gui.set_x
function luax__gui.set_x() end

--- gui.set_y
function luax__gui.set_y() end

--- gui.set_z
function luax__gui.set_z() end


---@class luax.math
local luax__math = {}

--- math.chance
function luax__math.chance() end

--- math.clamp
function luax__math.clamp() end

--- math.clamp_box
---@param pos vector3
---@param box vector4
---@param size vector3
---@param change_point bool
function luax__math.clamp_box(pos, box, size, change_point) end

--- math.distance
function luax__math.distance() end

--- math.is
function luax__math.is() end

--- math.lerp
function luax__math.lerp() end

--- math.lerp_box
function luax__math.lerp_box() end

--- math.manhattan
function luax__math.manhattan() end

--- math.randm_sign
function luax__math.random_sign() end

--- math.round
function luax__math.round() end

--- math.sign
function luax__math.sign() end

--- math.step
function luax__math.step() end

--- math.vec2rad
function luax__math.vec2rad() end


---@class luax.operators
local luax__operators = {}

--- operators.eq
function luax__operators.eq() end

--- operators.ge
function luax__operators.ge() end

--- operators.gt
function luax__operators.gt() end

--- operators.le
function luax__operators.le() end

--- operators.lt
function luax__operators.lt() end

--- operators.neq
function luax__operators.neq() end


---@class luax.string
local luax__string = {}

--- string.add_prefix_zeros
function luax__string.add_prefix_zeros() end

--- string.ends
function luax__string.ends() end

--- string.random
function luax__string.random() end

--- string.split
function luax__string.split() end

--- string.split_by_rank
function luax__string.split_by_rank() end

--- string.starts
function luax__string.starts() end


---@class luax.table
local luax__table = {}

--- table.contains
function luax__table.contains() end

--- table.copy array
function luax__table.copy() end

--- table.deepcopy
function luax__table.deepcopy() end

--- table.extend
function luax__table.extend() end

--- table.get_item_from_array
function luax__table.get_item_from_array() end

--- table.is_empty
function luax__table.is_empty() end

--- table.length
function luax__table.length() end

--- table.list
function luax__table.list() end

--- table.override
function luax__table.override() end

--- table.random
function luax__table.random() end

--- table.remove_by_dict
function luax__table.remove_by_dict() end

--- table.remove_item
function luax__table.remove_item() end

--- table.shuffle
function luax__table.shuffle() end

--- table.tostring
function luax__table.tostring() end

--- table.weight_random
function luax__table.weight_random() end


---@class luax.vmath
local luax__vmath = {}

--- vmath.distance
function luax__vmath.distance() end

--- vmath.rad2quat
function luax__vmath.rad2quat() end

--- vmath.rad2vec
function luax__vmath.rad2vec() end

--- vmath.vec2quat
function luax__vmath.vec2quat() end

--- vmath.vec2rad
function luax__vmath.vec2rad() end


---@class profi
---@field getTime field Local Functions:
local profi = {}

--- Implementations methods:
function profi.ProFi:shouldReturn() end



--======== File: /Users/insality/code/defold/defold-eva/eva/resources/eva.proto ========--
---@class eva.Ads
---@field ads_disabled boolean
---@field ads_loaded number
---@field daily_watched table<string, number>
---@field last_watched_time table<string, number>
---@field total_watched table<string, number>

---@class eva.Container
---@field infinity_timers table<string, number>
---@field restore_config table<string, eva.TokenRestoreConfig>
---@field tokens table<string, eva.Token>
---@field type string

---@class eva.Containers
---@field containers table<string, eva.Container>

---@class eva.Daily
---@field is_active boolean
---@field last_pick_time number
---@field reward_state boolean[]

---@class eva.Device
---@field device_id string

---@class eva.Festivals
---@field completed table<string, number>
---@field current string[]

---@class eva.Game
---@field first_start_time number
---@field game_start_count number
---@field game_start_dates string[]
---@field game_uid number
---@field last_diff_time number
---@field last_play_date number
---@field last_play_timepoint number
---@field last_uptime number
---@field played_time number
---@field prefer_playing_time number
---@field session_start_time number

---@class eva.Gdpr
---@field accept_date string
---@field is_accepted boolean

---@class eva.IapDetails
---@field currency_code string
---@field description string
---@field ident string
---@field is_available boolean
---@field price number
---@field price_string string
---@field title string

---@class eva.IapInfo
---@field date string
---@field iap_id string
---@field ident string
---@field state number
---@field transaction_id string

---@class eva.Iaps
---@field invalid_iaps eva.IapInfo[]
---@field purchased_iaps eva.IapInfo[]

---@class eva.InvoiceInfo
---@field category string
---@field life_time number
---@field reward evadata.Tokens
---@field start_time number
---@field text string
---@field title string

---@class eva.Invoices
---@field invoices table<string, eva.InvoiceInfo>

---@class eva.Labels
---@field labels string[]

---@class eva.Lang
---@field lang string

---@class eva.Lot
---@field price eva.Tokens
---@field reward eva.Tokens

---@class eva.Offer
---@field timer_id string

---@class eva.Offers
---@field offers table<string, eva.Offer>

---@class eva.Promocodes
---@field applied string[]

---@class eva.Push
---@field pushes eva.PushInfo[]

---@class eva.PushInfo
---@field category string
---@field id number
---@field is_triggered boolean
---@field time number

---@class eva.QuestData
---@field is_active boolean
---@field progress number[]
---@field start_time number

---@class eva.Quests
---@field completed string[]
---@field current table<string, eva.QuestData>

---@class eva.Rate
---@field is_accepted boolean
---@field is_never_show boolean
---@field promt_count number

---@class eva.Saver
---@field last_game_version string
---@field migration_version number
---@field version number

---@class eva.Server
---@field token string

---@class eva.Skill
---@field end_duration_time number
---@field is_active boolean
---@field is_cooldown boolean
---@field last_use_time number
---@field next_restore_time number
---@field stacks number
---@field use_count number

---@class eva.SkillContainers
---@field containers table<string, eva.Skills>

---@class eva.Skills
---@field skill_data table<string, eva.Skill>

---@class eva.Sound
---@field music_gain number
---@field sound_gain number

---@class eva.Storage
---@field storage table<string, eva.StorageValue>

---@class eva.StorageValue
---@field b_value boolean
---@field i_value number
---@field s_value string

---@class eva.Timer
---@field auto_trigger boolean
---@field end_time number
---@field is_pause boolean
---@field pause_time number
---@field timer_id string

---@class eva.Timers
---@field timers table<string, eva.Timer>

---@class eva.Token
---@field amount number
---@field offset number

---@class eva.TokenRestoreConfig
---@field is_enabled boolean
---@field last_restore_time number
---@field max number Default: 2147483647
---@field timer number
---@field value number Default: 1

---@class eva.Tokens
---@field tokens table<string, eva.Token>

---@class eva.Truck
---@field arrive_time number
---@field is_arrived boolean
---@field is_enabled boolean
---@field leave_time number

---@class eva.Trucks
---@field trucks table<string, eva.Truck>


--======== File: evadata.proto ========--
---@class evadata.Ads
---@field ads table<string, evadata.Ads.AdSettings>

---@class evadata.Ads.AdSettings
---@field all_ads_daily_limit number
---@field daily_limit number
---@field required_token_group string
---@field time_between_shows number
---@field time_between_shows_all number
---@field time_from_game_start number
---@field type string

---@class evadata.Festivals
---@field festivals table<string, evadata.Festivals.Festival>

---@class evadata.Festivals.Festival
---@field category string
---@field close_time number
---@field duration number
---@field repeat_time string
---@field start_date string

---@class evadata.IapsConfig
---@field iaps table<string, evadata.IapsConfig.IapConfig>

---@class evadata.IapsConfig.IapConfig
---@field category string
---@field forever boolean
---@field ident string
---@field price number
---@field token_group_id string

---@class evadata.Lots
---@field token_lots table<string, evadata.Lots.Lot>

---@class evadata.Lots.Lot
---@field price string
---@field reward string

---@class evadata.Offers
---@field offers table<string, evadata.Offers.Offer>

---@class evadata.Offers.Offer
---@field category string
---@field iap_id string
---@field lot_id string
---@field time number

---@class evadata.Promocodes
---@field promocodes table<string, evadata.Promocodes.Promocode>

---@class evadata.Promocodes.Promocode
---@field end_date string
---@field start_date string
---@field tokens evadata.Tokens

---@class evadata.Quests
---@field quests table<string, evadata.Quests.Quest>

---@class evadata.Quests.Quest
---@field autofinish boolean
---@field autostart boolean
---@field category string
---@field events_offline boolean
---@field repeatable boolean
---@field required_quests string[]
---@field required_tokens evadata.Tokens
---@field reward evadata.Tokens
---@field tasks evadata.Quests.Quest.QuestTasks[]
---@field use_max_task_value boolean

---@class evadata.Quests.Quest.QuestTasks
---@field action string
---@field initial number
---@field object string
---@field param1 string
---@field param2 string
---@field required number

---@class evadata.Skills
---@field skills table<string, evadata.Skills.Skill>

---@class evadata.Skills.Skill
---@field cast_time number
---@field channel boolean
---@field cooldown number
---@field duration number
---@field manual_time boolean
---@field max_stack number Default: 1
---@field restore_amount number Default: 1

---@class evadata.TokenConfig
---@field token_config table<string, evadata.TokenConfig.TokenConfigData>

---@class evadata.TokenConfig.TokenConfigData
---@field default number
---@field max number Default: 2147483647
---@field min number
---@field name string

---@class evadata.TokenGroups
---@field token_groups table<string, evadata.Tokens>

---@class evadata.TokenRestoreConfig
---@field max number
---@field timer number
---@field value number

---@class evadata.Tokens
---@field tokens evadata.Tokens.Token[]

---@class evadata.Tokens.Token
---@field amount number
---@field token_id string

---@class evadata.Trucks
---@field trucks table<string, evadata.Trucks.Truck>

---@class evadata.Trucks.Truck
---@field autoarrive boolean
---@field autoleave boolean
---@field cooldown number
---@field lifetime number


