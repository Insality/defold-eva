---@class log
local log = {}

---Log with fatal level
---@param self unknown 
---@param msg unknown 
---@param context unknown 
function _log.fatal(self, msg, context) end

---Log with error level
---@param self unknown 
---@param msg unknown 
---@param context unknown 
function _log.error(self, msg, context) end

---Log with warning level
---@param self unknown 
---@param msg unknown 
---@param context unknown 
function _log.warn(self, msg, context) end

---Log with info level
---@param self unknown 
---@param msg unknown 
---@param context unknown 
function _log.info(self, msg, context) end

---Log with debug level
---@param self unknown 
---@param msg unknown 
---@param context unknown 
function _log.debug(self, msg, context) end

---@class luax
local luax = {}
luax.operators = {}
luax.math = {}
luax.string = {}
luax.vmath = {}
luax.debug = {}
luax.gui = {}
luax.table = {}
luax.go = {}

---math.step
function luax.math.step() end

---math.sign
function luax.math.sign() end

---math.lerp
function luax.math.lerp() end

---math.lerp_box
function luax.math.lerp_box() end

---math.clamp
function luax.math.clamp() end

---math.clamp_box
---@param pos vector3 
---@param box vector4 
---@param size vector3 
---@param change_point bool 
function luax.math.clamp_box(pos, box, size, change_point) end

---math.round
function luax.math.round() end

---math.is
function luax.math.is() end

---math.chance
function luax.math.chance() end

---math.distance
function luax.math.distance() end

---math.manhattan
function luax.math.manhattan() end

---math.vec2rad
function luax.math.vec2rad() end

---table.get_item_from_array
function luax.table.get_item_from_array() end

---table.contains
function luax.table.contains() end

---table.length
function luax.table.length() end

---table.remove_item
function luax.table.remove_item() end

---table.remove_by_dict
function luax.table.remove_by_dict() end

---table.is_empty
function luax.table.is_empty() end

---table.extend
function luax.table.extend() end

---table.random
function luax.table.random() end

---table.weight_random
function luax.table.weight_random() end

---table.shuffle
function luax.table.shuffle() end

---table.deepcopy
function luax.table.deepcopy() end

---table.override
function luax.table.override() end

---table.list
function luax.table.list() end

---table.tostring
function luax.table.tostring() end

---string.split
function luax.string.split() end

---string.add_prefix_zeros
function luax.string.add_prefix_zeros() end

---string.split_by_rank
function luax.string.split_by_rank() end

---string.starts
function luax.string.starts() end

---string.ends
function luax.string.ends() end

---string.random
function luax.string.random() end

---go.set_alpha
function luax.go.set_alpha() end

---gui.set_alpha
function luax.gui.set_alpha() end

---gui.get_alpha
function luax.gui.get_alpha() end

---debug.timelog
function luax.debug.timelog() end

---gui.is_chain_enabled
function luax.gui.is_chain_enabled() end

---vmath.rad2vec
function luax.vmath.rad2vec() end

---vmath.vec2rad
function luax.vmath.vec2rad() end

---vmath.rad2quat
function luax.vmath.rad2quat() end

---vmath.vec2quat
function luax.vmath.vec2quat() end

---vmath.distance
function luax.vmath.distance() end

---operators.lt
function luax.operators.lt() end

---operators.le
function luax.operators.le() end

---operators.gt
function luax.operators.gt() end

---operators.ge
function luax.operators.ge() end

---operators.eq
function luax.operators.eq() end

---operators.neq
function luax.operators.neq() end

---@class eva
local eva = {}
eva.offers = {}
eva.server = {}
eva.trucks = {}
eva.hexgrid = {}
eva.isogrid = {}
eva.window = {}
eva.iaps = {}
eva.saver = {}
eva.device = {}
eva.rating = {}
eva.daily = {}
eva.migrations = {}
eva.storage = {}
eva.timers = {}
eva.quests = {}
eva.wallet = {}
eva.utils = {}
eva.events = {}
eva.token = {}
eva.tiled = {}
eva.input = {}
eva.gdpr = {}
eva.lang = {}
eva.ads = {}
eva.render = {}
eva.push = {}
eva.callbacks = {}
eva.game = {}
eva.sound = {}
eva.grid = {}
eva.labels = {}
eva.camera = {}
eva.proto = {}
eva.db = {}
eva.invoices = {}
eva.rate = {}
eva.festivals = {}
eva.promocode = {}
eva.pathfinder = {}

---Call this to init Eva module
---@param settings_path string   path to eva_settings.json
---@param module_settings table   Settings to modules. See description on eva.lua
function init(settings_path, module_settings) end

---Call this on main update loop
---@param dt number   delta time
function update(dt) end

---Call this on main game on_input
function on_input() end

---Check is page ads ready.
---@return bool  is page ads ready
function eva.ads.is_page_ready() end

---Check is rewarded ads ready.
---@return bool  is rewarded ads ready
function eva.ads.is_rewarded_ready() end

---Start show rewarded ads
---On success it will throw ADS_SUCCESS_REWARDED event
function eva.ads.show_rewarded() end

---Start show page ads
function eva.ads.show_page() end

---Set enabled ads state
---@param state bool   ads state
function eva.ads.set_enabled(state) end

---Get total ads watched
---@param Total number   watched ads count
function eva.ads.get_watched(Total) end

---Check ads is enabled
---@return bool  is ads enabled
function eva.ads.is_enabled() end

---Wrap callback
---It return index for callback, You can call it now
---via eva.callbacks.call(index, ...)
---@param callback function   Callback to wrap
---@return number  index New index of wrapped callback
function eva.callbacks.create(callback) end

---Call wrapped callback
---@param index number   Index of wrapped callback
---@param ... args   Args of calling callback
function eva.callbacks.call(index, ...) end

---Clear callback
---@param index number   Index of wrapped callback
function eva.callbacks.clear(index) end

---Set the camera game object and size of the camera
---@param cam_id string   url of camera game object
---@param camera_box vector3   size of the camera at zoom=1
function eva.camera.set_camera(cam_id, camera_box) end

---Set the borders of the camera zone
---@param border_soft vector4   Soft zones of camera. Order is: left-top-right-bot.
---@param border_hard vector4   Hard zones of camera. Order is: left-top-right-bot.
function eva.camera.set_borders(border_soft, border_hard) end

---Set the camera position
---@param x number   X position
---@param y number   Y position
function eva.camera.set_position(x, y) end

---Set the camera game object and size of the camera
---@param zoom_soft vector3   Setup zoom soft values. vector3(min_value, max_value, 0)
---@param zoom_hard vector3   Setup zoom hard values. vector3(min_value, max_value, 0)
function eva.camera.set_zoom_borders(zoom_soft, zoom_hard) end

---Eva camera update should be called manually
---Due the it uses context go.set_position
---@param dt number   Delta time
function eva.camera.update(dt) end

---Return is active now daily system
function eva.daily.is_active() end

---Set active daily system
---It will reset last pick time
function eva.daily.set_active() end

---Pick current prize
function eva.daily.pick() end

---Return time until you can pickup prize
function eva.daily.get_time() end

---Return time until you can lose the unpicked reward
function eva.daily.get_wait_time() end

---Return current state
---@return table  Array with booleans to show picked rewards
function eva.daily.get_current_state() end

---Return config by config_name
---@param config_name string   Config name from eva settings
---@return table  Config table
function eva.db.get(config_name) end

---Can override db with custom tables (useful for tests)
---@param settings table   Custom db settings
function eva.db.set_settings(settings) end

---Return device id.
---@return string  device_id
function eva.device.get_device_id() end

---Generate uuid
---@param except table   list of uuid, what not need to be generated
---@return string  the uuid
function eva.device.get_uuid(except) end

---Return device region.
---@return string  region
function eva.device.get_region() end

---Return device_info
function eva.device.get_device_info() end

---Check if device on android
function eva.device.is_android() end

---Check if device on iOS
function eva.device.is_ios() end

---Check if device is native mobile (Android or iOS)
function eva.device.is_mobile() end

---Check if device is HTML5
function eva.device.is_web() end

---Throws the game event
---@param event string   name of event
---@param params table   params
function eva.events.event(event, params) end

---Setup current game screen
---@param screen_id string   screen id
function eva.events.screen(screen_id) end

---Subscribe the callback on event
---@param event_name string   Event name
---@param callback function   Event callback
function eva.events.subscribe(event_name, callback) end

---Subscribe the pack of events by map
---@param map table   {Event = Callback} map
function eva.events.subscribe_map(map) end

---Unsubscribe the event from events flow
---@param event_name string   Event name
---@param callback function   Event callback
function eva.events.unsubscribe(event_name, callback) end

---Unsubscribe the pack of events by map
---@param map table   {Event = Callback} map
function eva.events.unsubscribe_map(map) end

---Check if callback is already subscribed
---@param event_name string   Event name
---@param callback function   Event callback
function eva.events.is_subscribed(event_name, callback) end

---Return is festival is active now
---@param festival_id string   Festival id from Festivals json
---@return bool  Current festival state
function eva.festivals.is_active(festival_id) end

---Return is festival is completed
---Return true for repeated festivals, is they are completed now
---@param festival_id string   Festival id from Festivals json
---@return number  Festival completed counter (For repeat festivals can be > 1)
function eva.festivals.is_completed(festival_id) end

---Return next start time for festival_id
---@param festival_id string   Festival id from Festivals json
---@return number  Time in seconds since epoch
function eva.festivals.get_start_time(festival_id) end

---Return next end time for festival_id
---@param festival_id string   Festival id from Festivals json
---@return number  Time in seconds since epoch
function eva.festivals.get_end_time(festival_id) end

---Return current festivals
---@return table  array of current festivals
function eva.festivals.get_current() end

---Return completed festivals
---@return table  array of completed festivals
function eva.festivals.get_completed() end

---Start festival without check any condition
---@param festival_id string   Festival id from Festivals json
function eva.festivals.debug_start_festival(festival_id) end

---End festival without check any condition
---@param festival_id string   Festival id from Festivals json
function eva.festivals.debug_end_festival(festival_id) end

---Set game festivals settings.
function eva.festivals.set_settings() end

---Open store page in store application
function eva.game.open_store_page() end

---Reboot the game
---@param delay number   Delay before reboot, in seconds
function eva.game.reboot(delay) end

---Exit from the game
---@param code int   The exit code
function eva.game.exit(code) end

---Check game on debug mode
function eva.game.is_debug() end

---Get game time
---@return number  Return game time in seconds
function eva.game.get_time() end

---Return unique id for local session
---@return number  Unique id in this game session
function eva.game.get_session_uid() end

---Return unique id for player profile
---@return number  Unique id in player profile
function eva.game.get_uid() end

---Get current time in string format
---@return string  Time format in iso e.g. "2019-09-25T01:48:19Z"
function eva.game.get_current_time_string() end

---Get days since first game launch
---@return number  Days since first game launch
function eva.game.get_days_played() end

---Apply the GDPR to the game profile
function eva.gdpr.apply_gdpr() end

---Return if GDPR is accepted
function eva.gdpr.is_accepted() end

---Open the policy URL
function eva.gdpr.open_policy_url() end

---Get map params data to work with it
---You can pass directly params in every method or set is as default
---with eva.grid.set_default_map_params
---Pass the map sizes to calculate correct coordinates
---@return map_params  Map params data
function eva.grid.get_map_params() end

---Set default map params
---To don`t pass it every time in transform functions
---@param map_params map_params   Params from eva.grid.get_map_params
function eva.grid.set_default_map_params(map_params) end

---Transform hex to pixel position
function eva.grid.cell_to_pos() end

---Transform pixel to hex
function eva.grid.pos_to_cell() end

---Get Z position from object Y position and his z_layer
---@param y number   Object Y position
---@param z_layer number   Object Z layer index
---@return map_params  Map params data
function eva.grid.get_z(y, z_layer) end

---Get object position
---Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3  Object position
function eva.grid.get_object_pos() end

---Convert tiled object position to scene position
---@return number,number  x,y Object scene position
function eva.grid.get_tiled_scene_pos() end

---Get tile position.
---@return vector3  Tile position
function eva.grid.get_tile_pos() end

---Get map params data to work with it
---You can pass directly params in every method or set is as default
---with eva.hexgrid.set_default_map_params
---Pass the map sizes to calculate correct coordinates
---@param tilewidth number   Hexagon width
---@param tileheight number   Hexagon height
---@param tileside number   Hexagon side length (flat side)
---@param width number   Map width in tiles count
---@param height number   Map height in tiles count
---@param invert_y bool   If true, zero pos will be at top, else on bot
---@return map_params  Map params data
function eva.hexgrid.get_map_params(tilewidth, tileheight, tileside, width, height, invert_y) end

---Set default map params
---To dont pass it every time in transform functions
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.set_default_map_params(map_params) end

---Transform hex to pixel position.
---@param i number   Cell i coordinate
---@param j number   Cell j coordinate
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.cell_to_pos(i, j, map_params) end

---Transform pixel to hex.
---@param x number   World x position
---@param y number   World y position
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.pos_to_cell(x, y, map_params) end

---Transform hex to pixel position.
---@param i number   Cell i coordinate
---@param j number   Cell j coordinate
---@param k number   Cell k coordinate
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.cell_cube_to_pos(i, j, k, map_params) end

---Transform pixel to hex.
---@param x number   World x position
---@param y number   World y position
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.pos_to_cell_cube(x, y, map_params) end

---Transfrom offset coordinates to cube coordinates
---@param i number   I coordinate
---@param j number   J coordinate
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.offset_to_cube(i, j, map_params) end

---Transfrom cube coordinates to offset coordinates
---@param i number   I coordinate
---@param j number   m coordinate
---@param j number   m coordinate
---@param map_params map_params   Params from eva.hexgrid.get_map_params
function eva.hexgrid.offset_to_cube(i, j, j, map_params) end

---Rotate offset coordinate by N * 60degree
---@param i number   I coordinate
---@param j number   m coordinate
---@param j number   m coordinate
---@param N number   Number, how much rotate on 60 degrees. Positive - rotate right, Negative - left
---@return number,  number, number Offset coordinate
function eva.hexgrid.rotate_offset(i, j, j, N) end

---Get Z position from object Y position and his z_layer
---@param y number   Object Y position
---@param z_layer number   Object Z layer index
---@return map_params  Map params data
function eva.hexgrid.get_z(y, z_layer) end

---Get object position
---Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3  Object position
function eva.hexgrid.get_object_pos() end

---Convert tiled object position to scene position
---@return number,number  x,y Object scene position
function eva.hexgrid.get_tiled_scene_pos() end

---Get tile position.
---@return vector3  Tile position
function eva.hexgrid.get_tile_pos() end

---Buy the inapp
---@param iap_id string   In-game inapp ID from iaps settings
function eva.iaps.buy(iap_id) end

---Get reward from iap_id
---@param iap_id string   the inapp id
function eva.iaps.get_reward(iap_id) end

---Get iap info by iap_id
---@param iap_id string   the inapp id
function eva.iaps.get_iap(iap_id) end

---Get all iaps.
---@param category string   Category of iap
---@return list  of iap products
function eva.iaps.get_iaps(category) end

---Check is iap is available
---@param iap_id string   the inapp id
---@return bool  Is available
function eva.iaps.is_available(iap_id) end

---Get price from iap_id
---@param iap_id string   the inapp id
---@return number  Price of iap
function eva.iaps.get_price(iap_id) end

---Get price_string from iap_id
---@param iap_id string   the inapp id
---@return string  The iap price string
function eva.iaps.get_price_string(iap_id) end

---Refresh iap list.
function eva.iaps.refresh_iap_list() end

---Get total lifetime value (from iaps)
---@return number  Player's LTV
function eva.iaps.get_ltv() end

---Get player max payment
---@return number  Max player payment
function eva.iaps.get_max_payment() end

---Register the input to handle user actions
---If callback return true it will stop handle next input
---@param name string   Name of input system
---@param callback function   The input callback
---@param priority number   Priority of input. Lower first
function eva.input.register(name, callback, priority) end

---Unregister prev.
---@param name string   Name of input system
function eva.input.unregister(name) end

---Add invoice to game profile
---If time is not provided, add invoice instantly
---If time is provided, add invoice in this time
---Invoice should be consumed to get reward
---@param category string   Category param of the invoice
---@param reward evadata.Tokens   Tokens reward list
---@param time number   Game time to add invoice
---@param life_time number   Time in seconds of invoice available
---@param title string   Text invoice title
---@param text string   Text invoice desc
function eva.invoices.add(category, reward, time, life_time, title, text) end

---Return current list of invoices
function eva.invoices.get_invoices() end

---Get invoice data by id
---@return eva.InvoiceInfo  Invoice data
function eva.invoices.get_invoce() end

---Check is invoice can be consumed
---@return bool  Can consume invoice
function eva.invoices.can_consume() end

---Consume the invoice to the game profile
---@param invoice_id number   The id of invoice
function eva.invoices.consume(invoice_id) end

---Get map params data to work with it
---You can pass directly params in every method or set is as default
---with eva.isogrid.set_default_map_params
---Pass the map sizes to calculate correct coordinates
---@return map_params  Map params data
function eva.isogrid.get_map_params() end

---Set default map params
---To don`t pass it every time in transform functions
---@param map_params map_params   Params from eva.isogrid.get_map_params
function eva.isogrid.set_default_map_params(map_params) end

---Transform hex to pixel position
function eva.isogrid.cell_to_pos() end

---Transform pixel to hex
function eva.isogrid.pos_to_cell() end

---Get Z position from object Y position and his z_layer
---@param y number   Object Y position
---@param z_layer number   Object Z layer index
---@return map_params  Map params data
function eva.isogrid.get_z(y, z_layer) end

---Get object position
---Can pass the offset to calculate it correctly (+ z coordinate)
---@return vector3  Object position
function eva.isogrid.get_object_pos() end

---Convert tiled object position to scene position
---@return number,number  x,y Object scene position
function eva.isogrid.get_tiled_scene_pos() end

---Get tile position.
---@return vector3  Tile position
function eva.isogrid.get_tile_pos() end

---Check label is exist in player profile
---@param label string   The label id
---@return bool  True, if label in player profile
function eva.labels.is_exist(label) end

---Return localized time format from seconds
function eva.lang.time_format() end

---Set current language
---@param lang string   current language code from eva-settings
function eva.lang.set_lang(lang) end

---Get current language
---@return string  return current language code
function eva.lang.get_lang() end

---Get translation for locale id
---@param lang_id string   locale id from your localization
---@return string  translated locale
function eva.lang.txt(lang_id) end

---Get translation for locale id with params
---@param lang_id string   Locale id from your localization
---@param ... string   Params for string.format for lang_id
---@return string  Translated locale
function eva.lang.txp(lang_id, ...) end

---Check is translation with lang_id exist
---@param lang_id strng   Locale id from your localization
---@return bool  Is translation exist
function eva.lang.is_exist(lang_id) end

---Return list of available languages
---@return table  List of available languages
function eva.lang.get_langs() end

---Add migration to the eva system
---Pass the migrations list in eva.init
---You should directly point the migration version
---in migration list (array from 1 to N)
function eva.migrations.set_migrations() end

---Return amount of migrations
function eva.migrations.get_count() end

---Apply the migrations
function eva.migrations.apply() end

---Start new offer
---Every offer is unique.
---@param offer_id string   offer id from db
---@return eva.Offer  new offer
function eva.offers.add(offer_id) end

---Remove offers from active list
---@param offer_id string   offer id from db
function eva.offers.remove(offer_id) end

---Return time till offer end.
---@param offer_id string   offer id from db
---@return number  time in seconds
function eva.offers.get_time(offer_id) end

---Check is offer active not
---@param offer_id string   offer id from db
---@return bool  is offer active
function eva.offers.is_active(offer_id) end

---Get token group of offer reward.
---@param offer_id string   offer id from db
---@return evadata.Tokens  token list
function eva.offers.get_reward(offer_id) end

---Get token group of offer price.
---@param offer_id string   offer id from db
---@return evadata.Tokens  token list
function eva.offers.get_price(offer_id) end

---Check is offer for inapp
---@param offer_id string   offer id from db
---@return bool  is offer inapp
function eva.offers.is_iap(offer_id) end

---Init astar for map, init get_tile callback
---get_node_fn - function to get tile: function(i, j)
---should return cost of node.
---@param map_data map_data   Map data from eva.tiled.load_map
---@param get_node_fn function   Get node cost function from map
---@param options table   Options for map handlers:  - diagonal boolean, to grid and isogrid pathfinding
---@return map_handler  Handler for astar work
function eva.pathfinder.init_astar(map_data, get_node_fn, options) end

---Return path between two points for map.
---@param from_x unknown   Cell X from map
---@param from_y unknown   Cell Y from map
---@param to_x unknown   Cell X from map
---@param to_y unknown   Cell Y from map
---@param map_handler map_handler   Map handler to handle map for astar
---@return table|nil  Table of points. See eva.libs.astar.path. Nil if path is not exist
function eva.pathfinder.path(from_x, from_y, to_x, to_y, map_handler) end

---Get list of all redeemed codes
---@return string[]  List of applied codes
function eva.promocode.get_applied_codes() end

---Check if promocode is already applied
---@param code string   The promocode itself
---@return bool  True if code is already redeemed
function eva.promocode.is_applied(code) end

---Try redeem the code and get rewards
---@param code string   The promocode itself
---@return bool  Result of success
function eva.promocode.redeem_code(code) end

---Check if promocode can be redeem
---@param code string   The promocode itself
---@return bool  True of false
function eva.promocode.is_can_redeem(code) end

---Set promocode settings.
function eva.promocode.set_settings() end

---Get empty template from proto type
---@param proto_type string   name of proto message e.g. 'eva.Token'
---@return table  empty table with default values from proto
function eva.proto.get(proto_type) end

---Encode protobuf
function eva.proto.encode() end

---Decode protobuf
function eva.proto.decode() end

---Clear all pushes, what already
---should be invoked.
function eva.push.clear_old_pushes() end

---Schedule notification
function eva.push.schedule() end

---Schedule by list
---Every notifications have: after, title, text, category, payload
function eva.push.schedule_list() end

---Unschedule the push notification
function eva.push.unschedule() end

---Cancel all pushes with category
---If category is not provided, cancel all pushes
function eva.push.unschedule_all() end

---Get current progress on quest
---@param quest_id string   Quest id
---@return table  List of progress of quest tasks in task order
function eva.quests.get_progress(quest_id) end

---Get current active quests
---@return table  List of active quests
function eva.quests.get_current() end

---Get completed quests list
---@return table  List of active quests
function eva.quests.get_completed() end

---Check if there is quests in current with
---pointer action and object
---@param action string   Task action
---@param object string   Task object
---@return bool  True, if there is quest with similar tasks
function eva.quests.is_current_with_task(action, object) end

---Check quest is active
---@return bool  Quest active state
function eva.quests.is_active() end

---Check quest is completed
---@return bool  Quest completed state
function eva.quests.is_completed() end

---Check quest is can be started now
---@return bool  Quest is can start state
function eva.quests.is_can_start_quest() end

---Start quest, if it can be started
---@param quest_id string   Quest id
function eva.quests.start_quest(quest_id) end

---Check quest is can be completed now
---@return bool  Quest is can complete quest state
function eva.quests.is_can_complete_quest() end

---Complete quest, if it can be completed
---@param quest_id string   Quest id
function eva.quests.complete_quest(quest_id) end

---Reset quets progress, only on current quests
---@param quest_id string   Quest id
function eva.quests.reset_progress(quest_id) end

---Apply quest event to all current quests
---@param action string   Type of event
---@param object string   Object of event
---@param amount number   Amount of event
function eva.quests.quest_event(action, object, amount) end

---Start eva quests system.
function eva.quests.start_quests() end

---Update quests list
---It will start and end quests, by checking quests condition
function eva.quests.update_quests() end

---Add event, to trigger quest list update.
function eva.quests.add_update_quest_event() end

---Set game quests settings.
function eva.quests.set_settings() end

---Set never promt rate again
function eva.rate.set_never_show() end

---Set rate as accepted.
function eva.rate.set_accepted() end

---Try to promt rate game to the player
function eva.rate.promt_rate() end

---Open store or native rating on iOS
function eva.rate.open_rate() end

---Call elo rating
---@param rating_a number   Player rating
---@param rating_b number   Opponent rating
---@param game_koef number   Result of game. 1 is win, 0 on loose, 0.5 is draw
function eva.rating.elo(rating_a, rating_b, game_koef) end

---Change render
function eva.render.set_blur() end

---Change render
function eva.render.set_light() end

---Change render
function eva.render.set_vignette() end

---Load the game save
function eva.saver.load() end

---Save the game save
function eva.saver.save() end

---Delete the save
---@param filename string   The save filename. Can be default by settings
function eva.saver.delete(filename) end

---Reset the game profile
function eva.saver.reset() end

---Add save part to the save table
function eva.saver.add_save_part() end

---Login at playfab server
---@param callback function   Callback after login
function eva.server.login(callback) end

---Send save to the server
---@param json_data string   JSON data
function eva.server.send_save(json_data) end

---End use of channeling spell or end effect of skill
---with duration
---@param container_id unknown 
---@param skill_id unknown 
function end_use(container_id, skill_id) end

---Time between use and end_use
---@param container_id unknown 
---@param skill_id unknown 
function is_active(container_id, skill_id) end

---Play the sound in the game
function eva.sound.play() end

---Start playing music
function eva.sound.play_music() end

---Stop any music in the game
function eva.sound.stop_music() end

---Slowly fade music to another one or empty
function eva.sound.fade_music() end

---Stop all sounds in the game
function eva.sound.stop_all() end

---Set music gain
function eva.sound.set_music_gain() end

---Set sound gain
function eva.sound.set_sound_gain() end

---Check music gain
function eva.sound.is_music_enabled() end

---Check sound gain
function eva.sound.is_sound_enabled() end

---Get the value from the storage.
---@param id string   The record id
function eva.storage.get(id) end

---Set the value to eva storage
---@param id string   The record id
---@param value string|number|bool   Value
function eva.storage.set(id, value) end

---Load map from tiled json data
---@param data table   Json map data
---@param create_object_fn callback   Module call this with param(object_layer, object_id, position)
function eva.tiled.load_map(data, create_object_fn) end

---Add tile to the map by tile index from tiled tileset
---@param layer_name string   Name of tiled layer
---@param spawner_name string   Name of tileset
---@param index number   Tile index from tileset
---@param i number   Cell x position
---@param j number   Cell y position
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.add_tile(layer_name, spawner_name, index, i, j, map_data) end

---Get tile from the map by tile pos
---@param layer_name string   Name of tiled layer
---@param i number   Cell x position
---@param j number   Cell y position
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.get_tile(layer_name, i, j, map_data) end

---Delete tile from the map by tile pos
---@param layer string   Name of the tiled layer
---@param i number   Cell x position
---@param j number   Cell y position
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.delete_tile(layer, i, j, map_data) end

---Add object to the map by object index from tiled tileset
---@param layer_name string   Name of tiled layer
---@param spawner_name string   Name of tileset
---@param index number   Object index from tileset
---@param x number   x position
---@param y number   y position
---@param props table   Object additional properties
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.add_object(layer_name, spawner_name, index, x, y, props, map_data) end

---Get object to the map by game_object id
---@param game_object_id hash   Game object id
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.get_object(game_object_id, map_data) end

---Get mapping object info by name
---@param object_name unknown 
function get_object_data(object_name) end

---Delete object from the map by game_object id
---@param game_object_id hash   Game object id
---@param map_data map_data   Map_data returned by eva.tiled.load_map.  Last map by default
function eva.tiled.delete_object(game_object_id, map_data) end

---Add new timer
---Timer with slot_id should no exist
---@param slot_id string   identificator of timer
---@param timer_id string   string param of timer
---@param time number   time of timer, in seconds
---@param auto_trigger bool   true, if event should fire event at end
function eva.timers.add(slot_id, timer_id, time, auto_trigger) end

---Get timer
function eva.timers.get() end

---Get time until end, in seconds
---@param slot_id string   identificator of timer
---@return number  Time until end of timer. -1 if timer is not exist
function eva.timers.get_time(slot_id) end

---Check is timer has ended
---@param slot_id string   identificator of timer
function eva.timers.is_end(slot_id) end

---Clear the timer slot
---@param slot_id string   identificator of timer
function eva.timers.clear(slot_id) end

---Set timer pause state
---@param slot_id string   identificator of timer
---@param is_pause boolean   pause state
function eva.timers.set_pause(slot_id, is_pause) end

---Check if token container exist
---@param container_id string   Container id
---@return bool  Container exist state
function eva.token.is_exist_container(container_id) end

---Create new token container
---@param container_id string   Container id
---@param container_type string   Container type to match from token config
function eva.token.create_container(container_id, container_type) end

---Delete token container
---@param container_id string   Container id
function eva.token.delete_container(container_id) end

---Clear all tokens from container
---@param container_id string   Container id
function eva.token.clear_container(container_id) end

---Return evadata.Tokens tokens format.
---@param tokens table   Map with token_id = amount
function eva.token.get_tokens(tokens) end

---Return token group by id.
---@param token_group_id string   the token group id
---@return evadata.Tokens  the token list
function eva.token.get_token_group(token_group_id) end

---Return lot reward by lot_id.
---@param lot_id string   the token lot id
---@return evadata.Tokens  the token list
function eva.token.get_lot_reward(lot_id) end

---Return lot price by lot_id.
---@param lot_id string   the token lot id
---@return evadata.Tokens  the token list
function eva.token.get_lot_price(lot_id) end

---Add tokens to save
function eva.token.add() end

---Add multiply tokens
function eva.token.add_many() end

---Add multiply tokens by token_group_id
function eva.token.add_group() end

---Set tokens to save
function eva.token.set() end

---Get current token amount from save
function eva.token.get() end

---Get all tokens from container
---@param container_id string   Container id
---@return evadata.Tokens  Tokens from container
function eva.token.get_many(container_id) end

---Try to pay tokens from save
---@param token_id string   Token id
---@param amount number   Amount to pay
---@param reason string   The reason to pay
function eva.token.pay(token_id, amount, reason) end

---Pay multiply tokens
---@param tokens evadata.Tokens   Tokens data
---@param reason string   The reason to pay
function eva.token.pay_many(tokens, reason) end

---Pay multiply tokens by token_group_id
---@param token_group_id string   The token group id
---@param reason string   The reason to pay
function eva.token.pay_group(token_group_id, reason) end

---Check is enough to pay token
function eva.token.is_enough() end

---Check multiply tokens
---@param tokens evadata.Tokens   list
function eva.token.is_enough_many(tokens) end

---Check multiply tokens by token_group_id
---@param token_group_id string   the token group id
function eva.token.is_enough_group(token_group_id) end

---Return is token is maximum
function eva.token.is_max() end

---Return is tokens equals to 0
function eva.token.is_empty() end

---Add to tokens infinity time usage
function eva.token.add_infinity_time() end

---Return is token is infinity now
function eva.token.is_infinity() end

---Get amount of seconds till end of infinity time
function eva.token.get_infinity_seconds() end

---Get current time to next restore point
function eva.token.get_seconds_to_restore() end

---Reset visual debt of tokens
function eva.token.sync_visual() end

---Add visual debt to token
function eva.token.add_visual() end

---Get current visual debt of token
function eva.token.get_visual() end

---Check if truck is already arrived
---@param truck_id string   Truck id
---@return bool  Is arrived now
function eva.trucks.is_arrived(truck_id) end

---Get time for next truck arrive
---@param truck_id string   Truck id
---@return number  Time in seconds
function eva.trucks.get_time_to_arrive(truck_id) end

---Check if truck can be arrived now
---@param truck_id string   Truck id
---@return bool  Is can arrive now
function eva.trucks.is_can_arrive(truck_id) end

---Arrive truck right now, even it can't be
---arrived now.
---@param truck_id string   Truck id
function eva.trucks.arrive(truck_id) end

---Get time for next truck leave
---@param truck_id string   Truck id
---@return number  Time in seconds
function eva.trucks.get_time_to_leave(truck_id) end

---Check if truck can leave now
---@param truck_id string   Truck id
---@return bool  Is can leave now
function eva.trucks.is_can_leave(truck_id) end

---Leave truck right now, even it can
---leave now.
---@param truck_id string   Truck id
function eva.trucks.leave(truck_id) end

---Check is truck enabled now
---@param truck_id string   Truck id
---@return bool  Is truck enabled
function eva.trucks.is_enabled(truck_id) end

---Set truck enabled state
---@param truck_id string   Truck id
function eva.trucks.set_enabled(truck_id) end

---Set trucks settings with custom callbacks.
---@param trucks_settings table   Table with callbacks
function eva.trucks.set_settings(trucks_settings) end

---Make after closure
function eva.utils.after() end

---Load json from bundled resource
function eva.utils.load_json() end

---Convert hex color to rgb color
function eva.utils.hex2rgb() end

---Convert rgb color to hex color
function eva.utils.rgb2hex() end

---Add tokens to save
function eva.wallet.add() end

---Add multiply tokens
function eva.wallet.add_many() end

---Add multiply tokens by token_group_id
function eva.wallet.add_group() end

---Set tokens to save
function eva.wallet.set() end

---Get current token amount from save
function eva.wallet.get() end

---Try to pay tokens from save
---@param token_id string   Token id
---@param amount number   Amount to pay
---@param reason string   The reason to pay
function eva.wallet.pay(token_id, amount, reason) end

---Pay multiply tokens
---@param tokens evadata.Tokens   Tokens data
---@param reason string   The reason to pay
function eva.wallet.pay_many(tokens, reason) end

---Pay multiply tokens by token_group_id
---@param token_group_id string   The token group id
---@param reason string   The reason to pay
function eva.wallet.pay_group(token_group_id, reason) end

---Check is enough to pay token
function eva.wallet.is_enough() end

---Check multiply tokens
---@param tokens evadata.Tokens   list
function eva.wallet.is_enough_many(tokens) end

---Check multiply tokens by token_group_id
---@param token_group_id string   the token group id
function eva.wallet.is_enough_group(token_group_id) end

---Return is token is maximum
function eva.wallet.is_max() end

---Return is tokens equals to 0
function eva.wallet.is_empty() end

---Add to tokens infinity time usage
function eva.wallet.add_infinity_time() end

---Return is token is infinity now
function eva.wallet.is_infinity() end

---Get amount of seconds till end of infinity time
function eva.wallet.get_infinity_seconds() end

---Reset visual debt of tokens
function eva.wallet.sync_visual() end

---Add visual debt to token
function eva.wallet.add_visual() end

---Get current visual debt of token
function eva.wallet.get_visual() end

---Get current time to next restore point
function eva.wallet.get_seconds_to_restore() end

---Load the game scene
function eva.window.show_scene() end

---Show the game window
---It will close current window and open new, if any opened
---It can be popup on popup, so don't close prev.
function eva.window.show() end

---Check is window is opened now
function eva.window.is_open() end

---Close window by id or last window
function eva.window.close() end

---Close all windows
function eva.window.close_all() end

---Appear functions for all windows
---Need to call inside window
function eva.window.appear() end

---Disappear functions for all windows
---Need to call inside window
function eva.window.disappear() end

---Set game windows settings
function eva.window.set_settings() end

---@class uuid
local uuid = {}

---Creates a new uuid.
---@param hwaddr unknown   (optional) string containing a unique hex value (e.g.: `00:0c:29:69:41:c6`), to be used to compensate for the lesser `math_random()` function. Use a mac address for solid results. If omitted, a fully randomized uuid will be generated, but then you must ensure that the random seed is set properly!
---@return   a properly formatted uuid string
function new(hwaddr) end

---Improved randomseed function.
---@param seed unknown   the random seed to set (integer from 0 - 2^32, negative values will be made positive)
---@return   the (potentially modified) seed used
function randomseed(seed) end

---Seeds the random generator.
function seed() end

---@class time_string
local time_string = {}

---Get seconds from ISO string time format
---@param str string   time in ISO format
function parse_ISO(str) end

---Get time in ISO format from seconds
---@param seconds unknown 
function get_ISO(seconds) end

---Return next time in seconds on event
---@param start_time number   date in seconds
---@param delta_time string   delta in next format: "1Y 10M 2W 1D 12h 30m". Can pass part of time
---@param cur_time number   date in seconds. local time by default
function get_next_time(start_time, delta_time, cur_time) end

---Convert Delta string format to seconds
---@param delta_str unknown 
function get_delta_seconds(delta_str) end

---@class flow
local flow = {}

---Start a new flow.
---@param fn unknown   The function to run within the flow
---@param options unknown   Key value pairs. Allowed keys: 		parallel = true if running flow shouldn't wait for this flow
---@param on_error unknown   Function to call if something goes wrong while  running the flow
---@return   The created flow instance
function start(fn, options, on_error) end

---Stop a created flow before it has completed
---@param instance unknown   This can be either the returned value from  a call to @{start}, a coroutine or URL. Defaults to the URL of the  running script
function stop(instance) end

---Wait until a certain time has elapsed
---@param seconds unknown 
function delay(seconds) end

---Wait until a certain number of frames have elapsed
---@param frames unknown 
function frames(frames) end

---Wait until a function returns true
---@param fn unknown 
function until_true(fn) end

---Wait until any message is received
---@return   message_id
---@return   message
---@return   sender
function until_any_message() end

---Wait until a specific message is received
---@param message_1 unknown   Message to wait for
---@param message_2 unknown   Message to wait for
---@param message_n unknown   Message to wait for
---@return   message_id
---@return   message
---@return   sender
function until_message(message_1, message_2, message_n) end

---Wait until input action with pressed state
---@param action_1 unknown   Action to wait for (nil for any action)
---@param action_2 unknown   Action to wait for
---@param action_n unknown   Action to wait for
---@return   action_id
---@return   action
function until_input_pressed(action_1, action_2, action_n) end

---Wait until input action with released state
---@param action_1 unknown   Action to wait for (nil for any action)
---@param action_2 unknown   Action to wait for
---@param action_n unknown   Action to wait for
---@return   action_id
---@return   action
function until_input_released(action_1, action_2, action_n) end

---Wait until a callback function is invoked
---@param fn unknown   The function to call. The function must take a callback function as its first argument
---@param arg1 unknown   Additional argument to pass to fn
---@param arg2 unknown   Additional argument to pass to fn
---@param argn unknown   Additional argument to pass to fn
---@return   Any values passed to the callback function
function until_callback(fn, arg1, arg2, argn) end

---Load a collection and wait until it is loaded and enabled
---@param collection_url unknown 
function load(collection_url) end

---Unload a collection and wait until it is unloaded
---@param collection_url unknown   The collection to unload
function unload(collection_url) end

---Call go.animate and wait until it has finished
---@param url unknown 
---@param property unknown 
---@param playback unknown 
---@param to unknown 
---@param easing unknown 
---@param duration unknown 
---@param delay unknown 
function go_animate(url, property, playback, to, easing, duration, delay) end

---Call gui.animate and wait until it has finished
---NOTE: The argument order differs from gui.animate() (playback is shifted
---to the same position as for go.animate)
---@param node unknown 
---@param property unknown 
---@param playback unknown 
---@param to unknown 
---@param easing unknown 
---@param duration unknown 
---@param delay unknown 
function gui_animate(node, property, playback, to, easing, duration, delay) end

---Play a sprite animation and wait until it has finished
---@param sprite_url unknown 
---@param id unknown 
function play_animation(sprite_url, id) end

---Forward any received messages in your scripts to this function
---@param message_id unknown 
---@param message unknown 
---@param sender unknown 
function on_message(message_id, message, sender) end

---@class const
local const = {}


