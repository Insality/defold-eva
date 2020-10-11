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
---@field skill eva.skill Submodule
---@field sound eva.sound Submodule
---@field storage eva.storage Submodule
---@field tiled eva.tiled Submodule
---@field timers eva.timers Submodule
---@field token eva.token Submodule
---@field trucks eva.trucks Submodule
---@field utils eva.utils Submodule
---@field wallet eva.wallet Submodule
---@field window eva.window Submodule
---@field init fun(settings_path:string, module_settings:table) Call this to init Eva module
---@field on_input fun() Call this on main game on_input
---@field update fun(dt:number) Call this on main update loop

---@class eva.ads
---@field get_watched fun(Total:number) Get total ads watched
---@field is_enabled fun():bool Check ads is enabled
---@field is_page_ready fun():bool Check is page ads ready.
---@field is_rewarded_ready fun():bool Check is rewarded ads ready.
---@field set_enabled fun(state:bool) Set enabled ads state
---@field show_page fun() Start show page ads
---@field show_rewarded fun() Start show rewarded ads  On success it will throw ADS_SUCCESS_REWARDED event

---@class eva.callbacks
---@field call fun(index:number, ...:args) Call wrapped callback
---@field clear fun(index:number) Clear callback
---@field create fun(callback:function):number Wrap callback  It return index for callback, You can call it now  via eva.callbacks.call(index, ...)

---@class eva.camera
---@field set_borders fun(border_soft:vector4, border_hard:vector4) Set the borders of the camera zone
---@field set_camera fun(cam_id:string, camera_box:vector3) Set the camera game object and size of the camera
---@field set_control fun(enabled:bool) Enable or disable camera user control
---@field set_position fun(x:number, y:number) Set the camera position
---@field set_target_position fun(x:number, y:number) Set target camera position
---@field set_zoom_borders fun(zoom_soft:vector3, zoom_hard:vector3) Set the camera game object and size of the camera
---@field update fun(dt:number) Eva camera update should be called manually  Due the it uses context go.set_position

---@class eva.daily
---@field get_current_state fun():table Return current state
---@field get_time fun() Return time until you can pickup prize
---@field get_wait_time fun() Return time until you can lose the unpicked reward
---@field is_active fun() Return is active now daily system
---@field pick fun() Pick current prize
---@field set_active fun() Set active daily system  It will reset last pick time

---@class eva.db
---@field get fun(config_name:string):table Return config by config_name
---@field set_settings fun(settings:table) Can override db with custom tables (useful for tests)

---@class eva.device
---@field get_device_id fun():string Return device id.
---@field get_device_info fun() Return device_info
---@field get_region fun():string Return device region.
---@field get_uuid fun(except:table):string Generate uuid
---@field is_android fun() Check if device on android
---@field is_ios fun() Check if device on iOS
---@field is_mobile fun() Check if device is native mobile (Android or iOS)
---@field is_web fun() Check if device is HTML5

---@class eva.events
---@field event fun(event:string, params:table) Throws the game event
---@field is_subscribed fun(event_name:string, callback:function) Check if callback is already subscribed
---@field screen fun(screen_id:string) Setup current game screen
---@field subscribe fun(event_name:string, callback:function) Subscribe the callback on event
---@field subscribe_map fun(map:table) Subscribe the pack of events by map
---@field unsubscribe fun(event_name:string, callback:function) Unsubscribe the event from events flow
---@field unsubscribe_map fun(map:table) Unsubscribe the pack of events by map

---@class eva.festivals
---@field debug_end_festival fun(festival_id:string) End festival without check any condition
---@field debug_start_festival fun(festival_id:string) Start festival without check any condition
---@field get_completed fun():table Return completed festivals
---@field get_current fun():table Return current festivals
---@field get_end_time fun(festival_id:string):number Return next end time for festival_id
---@field get_start_time fun(festival_id:string):number Return next start time for festival_id
---@field is_active fun(festival_id:string):bool Return is festival is active now
---@field is_completed fun(festival_id:string):number Return is festival is completed  Return true for repeated festivals, is they are completed now
---@field set_settings fun() Set game festivals settings.

---@class eva.game
---@field exit fun(code:int) Exit from the game
---@field get_current_time_string fun():string Get current time in string format
---@field get_days_played fun():number Get days since first game launch
---@field get_session_uid fun():number Return unique id for local session
---@field get_time fun():number Get game time
---@field get_uid fun():number Return unique id for player profile
---@field is_debug fun() Check game on debug mode
---@field is_first_launch fun():bool Return true, if game launched first time
---@field open_store_page fun() Open store page in store application
---@field reboot fun(delay:number) Reboot the game

---@class eva.gdpr
---@field apply_gdpr fun() Apply the GDPR to the game profile
---@field is_accepted fun() Return if GDPR is accepted
---@field open_policy_url fun() Open the policy URL

---@class eva.grid
---@field cell_to_pos fun() Transform hex to pixel position
---@field get_map_params fun():map_params Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.grid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@field get_object_pos fun():vector3 Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@field get_tile_pos fun():vector3 Get tile position.
---@field get_tiled_scene_pos fun():number,number Convert tiled object position to scene position
---@field get_z fun(y:number, z_layer:number):map_params Get Z position from object Y position and his z_layer
---@field pos_to_cell fun() Transform pixel to hex
---@field set_default_map_params fun(map_params:map_params) Set default map params  To don`t pass it every time in transform functions

---@class eva.hexgrid
---@field cell_cube_to_pos fun(i:number, j:number, k:number, map_params:map_params) Transform hex to pixel position.
---@field cell_to_pos fun(i:number, j:number, map_params:map_params) Transform hex to pixel position.
---@field get_map_params fun(tilewidth:number, tileheight:number, tileside:number, width:number, height:number, invert_y:bool):map_params Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.hexgrid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@field get_object_pos fun():vector3 Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@field get_tile_pos fun():vector3 Get tile position.
---@field get_tiled_scene_pos fun():number,number Convert tiled object position to scene position
---@field get_z fun(y:number, z_layer:number):map_params Get Z position from object Y position and his z_layer
---@field offset_to_cube fun(i:number, j:number, k:number, map_params:map_params) Transfrom cube coordinates to offset coordinates
---@field offset_to_cube fun(i:number, j:number, map_params:map_params) Transfrom offset coordinates to cube coordinates
---@field pos_to_cell fun(x:number, y:number, map_params:map_params) Transform pixel to hex.
---@field pos_to_cell_cube fun(x:number, y:number, map_params:map_params) Transform pixel to hex.
---@field rotate_offset fun(i:number, j:number, k:number, N:number):number, Rotate offset coordinate by N * 60degree
---@field set_default_map_params fun(map_params:map_params) Set default map params  To dont pass it every time in transform functions

---@class eva.iaps
---@field buy fun(iap_id:string) Buy the inapp
---@field get_iap fun(iap_id:string) Get iap info by iap_id
---@field get_iaps fun(category:string):list Get all iaps.
---@field get_ltv fun():number Get total lifetime value (from iaps)
---@field get_max_payment fun():number Get player max payment
---@field get_price fun(iap_id:string):number Get price from iap_id
---@field get_price_string fun(iap_id:string):string Get price_string from iap_id
---@field get_reward fun(iap_id:string) Get reward from iap_id
---@field is_available fun(iap_id:string):bool Check is iap is available
---@field refresh_iap_list fun() Refresh iap list.

---@class eva.input
---@field register fun(name:string, callback:function, priority:number) Register the input to handle user actions  If callback return true it will stop handle next input
---@field unregister fun(name:string) Unregister prev.

---@class eva.invoices
---@field add fun(category:string, reward:evadata.Tokens, time:number, life_time:number, title:string, text:string) Add invoice to game profile  If time is not provided, add invoice instantly  If time is provided, add invoice in this time  Invoice should be consumed to get reward
---@field can_consume fun():bool Check is invoice can be consumed
---@field consume fun(invoice_id:number) Consume the invoice to the game profile
---@field get_invoce fun():eva.InvoiceInfo Get invoice data by id
---@field get_invoices fun() Return current list of invoices

---@class eva.isogrid
---@field cell_to_pos fun() Transform hex to pixel position
---@field get_map_params fun():map_params Get map params data to work with it  You can pass directly params in every method or set is as default  with eva.isogrid.set_default_map_params  Pass the map sizes to calculate correct coordinates
---@field get_object_pos fun():vector3 Get object position  Can pass the offset to calculate it correctly (+ z coordinate)
---@field get_tile_pos fun():vector3 Get tile position.
---@field get_tiled_scene_pos fun():number,number Convert tiled object position to scene position
---@field get_z fun(y:number, z_layer:number):map_params Get Z position from object Y position and his z_layer
---@field pos_to_cell fun() Transform pixel to hex
---@field set_default_map_params fun(map_params:map_params) Set default map params  To don`t pass it every time in transform functions

---@class eva.labels
---@field is_exist fun(label:string):bool Check label is exist in player profile

---@class eva.lang
---@field get_lang fun():string Get current language
---@field get_langs fun():table Return list of available languages
---@field is_exist fun(lang_id:strng):bool Check is translation with lang_id exist
---@field set_lang fun(lang:string) Set current language
---@field time_format fun() Return localized time format from seconds
---@field txp fun(lang_id:string, ...:string):string Get translation for locale id with params
---@field txt fun(lang_id:string):string Get translation for locale id

---@class eva.migrations
---@field apply fun() Apply the migrations
---@field get_count fun() Return amount of migrations
---@field set_migrations fun() Add migration to the eva system  Pass the migrations list in eva.init  You should directly point the migration version  in migration list (array from 1 to N)

---@class eva.offers
---@field add fun(offer_id:string):eva.Offer Start new offer  Every offer is unique.
---@field get_price fun(offer_id:string):evadata.Tokens Get token group of offer price.
---@field get_reward fun(offer_id:string):evadata.Tokens Get token group of offer reward.
---@field get_time fun(offer_id:string):number Return time till offer end.
---@field is_active fun(offer_id:string):bool Check is offer active not
---@field is_iap fun(offer_id:string):bool Check is offer for inapp
---@field remove fun(offer_id:string) Remove offers from active list

---@class eva.pathfinder
---@field init_astar fun(map_data:map_data, get_node_fn:function, options.:table):map_handler Init astar for map, init get_tile callback  get_node_fn - function to get tile: function(i, j)  should return cost of node.
---@field path fun(from_x:unknown, from_y:unknown, to_x:unknown, to_y:unknown, map_handler:map_handler):table|nil Return path between two points for map.

---@class eva.promocode
---@field get_applied_codes fun():string[] Get list of all redeemed codes
---@field is_applied fun(code:string):bool Check if promocode is already applied
---@field is_can_redeem fun(code:string):bool Check if promocode can be redeem
---@field redeem_code fun(code:string):bool Try redeem the code and get rewards
---@field set_settings fun() Set promocode settings.

---@class eva.proto
---@field decode fun() Decode protobuf
---@field encode fun() Encode protobuf
---@field get fun(proto_type:string):table Get empty template from proto type

---@class eva.push
---@field clear_old_pushes fun() Clear all pushes, what already  should be invoked.
---@field schedule fun() Schedule notification
---@field schedule_list fun() Schedule by list  Every notifications have: after, title, text, category, payload
---@field unschedule fun() Unschedule the push notification
---@field unschedule_all fun() Cancel all pushes with category  If category is not provided, cancel all pushes

---@class eva.quests
---@field add_update_quest_event fun() Add event, to trigger quest list update.
---@field complete_quest fun(quest_id:string) Complete quest, if it can be completed
---@field get_completed fun():table Get completed quests list
---@field get_current fun():table Get current active quests
---@field get_progress fun(quest_id:string):table Get current progress on quest
---@field is_active fun():bool Check quest is active
---@field is_can_complete_quest fun():bool Check quest is can be completed now
---@field is_can_start_quest fun():bool Check quest is can be started now
---@field is_completed fun():bool Check quest is completed
---@field is_current_with_task fun(action:string, object:string):bool Check if there is quests in current with  pointer action and object
---@field quest_event fun(action:string, object:string, amount:number) Apply quest event to all current quests
---@field reset_progress fun(quest_id:string) Reset quets progress, only on current quests
---@field set_settings fun() Set game quests settings.
---@field start_quest fun(quest_id:string) Start quest, if it can be started
---@field start_quests fun() Start eva quests system.
---@field update_quests fun() Update quests list  It will start and end quests, by checking quests condition

---@class eva.rate
---@field open_rate fun() Open store or native rating on iOS
---@field promt_rate fun() Try to promt rate game to the player
---@field set_accepted fun() Set rate as accepted.
---@field set_never_show fun() Set never promt rate again

---@class eva.rating
---@field elo fun(rating_a:number, rating_b:number, game_koef:number) Call elo rating

---@class eva.render
---@field set_blur fun() Change render
---@field set_light fun() Change render
---@field set_vignette fun() Change render

---@class eva.saver
---@field add_save_part fun() Add save part to the save table
---@field delete fun(filename:string) Delete the save
---@field load fun() Load the file from save directory
---@field reset fun() Reset the game profile
---@field save fun() Save the game file in save directory
---@field save_data fun() Save the data in save directory

---@class eva.server
---@field login fun(callback:function) Login at playfab server
---@field send_save fun(json_data:string) Send save to the server

---@class eva.skill
---@field add_stack fun() Add amount to skill stacks
---@field end_use fun() End use of channeling spell or end effect of skill  with duration
---@field get_active_progress fun() Return current skill progress time
---@field get_active_time fun() Return skill active time (duration)
---@field get_active_time_left fun() Return skill active left time (until end of duration)
---@field get_cooldown_progress fun() Get cooldown progress
---@field get_cooldown_time fun() Return skill cooldown time
---@field get_cooldown_time_left fun() Return skill cooldown time left
---@field get_stack_amount fun() Get current skill stack amount
---@field is_active fun() Time between use and end_use
---@field is_can_use fun() Return true if skill can be used now
---@field is_empty_stack fun() Return true if skill is empty now
---@field is_full_stack fun() Return true if skill on full stack
---@field is_on_cooldown fun() Return true if skill on the cooldown
---@field restore_all fun() Restore all skills in containers
---@field skil_cooldown_time fun() Skill cooldown
---@field use fun() Use skill

---@class eva.sound
---@field fade_music fun() Slowly fade music to another one or empty
---@field is_music_enabled fun() Check music gain
---@field is_sound_enabled fun() Check sound gain
---@field play fun() Play the sound in the game
---@field play_music fun() Start playing music
---@field set_music_gain fun() Set music gain
---@field set_sound_gain fun() Set sound gain
---@field stop_all fun() Stop all sounds in the game
---@field stop_music fun() Stop any music in the game

---@class eva.storage
---@field get fun(id:string) Get the value from the storage.
---@field set fun(id:string, value:string|number|bool) Set the value to eva storage

---@class eva.tiled
---@field add_object fun(layer_name:string, spawner_name:string, index:number, x:number, y:number, props:table, map_data:map_data) Add object to the map by object index from tiled tileset
---@field add_tile fun(layer_name:string, spawner_name:string, index:number, i:number, j:number, map_data:map_data) Add tile to the map by tile index from tiled tileset
---@field delete_object fun(game_object_id:hash, map_data:map_data) Delete object from the map by game_object id
---@field delete_tile fun(layer:string, i:number, j:number, map_data:map_data) Delete tile from the map by tile pos
---@field get_object fun(game_object_id:hash, map_data:map_data) Get object to the map by game_object id
---@field get_object_data fun(object_name:string) Get mapping object info by name
---@field get_tile fun(layer_name:string, i:number, j:number, map_data:map_data) Get tile from the map by tile pos
---@field load_map fun(data:table, create_object_fn:callback) Load map from tiled json data

---@class eva.timers
---@field add fun(slot_id:string, timer_id:string, time:number, auto_trigger:bool) Add new timer  Timer with slot_id should no exist
---@field clear fun(slot_id:string) Clear the timer slot
---@field get fun() Get timer
---@field get_time fun(slot_id:string):number Get time until end, in seconds
---@field is_end fun(slot_id:string) Check is timer has ended
---@field set_pause fun(slot_id:string, is_pause:boolean) Set timer pause state

---@class eva.token
---@field add fun() Add tokens to save
---@field add_group fun() Add multiply tokens by token_group_id
---@field add_infinity_time fun() Add to tokens infinity time usage
---@field add_many fun() Add multiply tokens
---@field add_visual fun() Add visual debt to token
---@field clear_container fun(container_id:string) Clear all tokens from container
---@field create_container fun(container_id:string, container_type:string) Create new token container
---@field delete_container fun(container_id:string) Delete token container
---@field get fun() Get current token amount from save
---@field get_infinity_seconds fun() Get amount of seconds till end of infinity time
---@field get_lot_price fun(lot_id:string):evadata.Tokens Return lot price by lot_id.
---@field get_lot_reward fun(lot_id:string):evadata.Tokens Return lot reward by lot_id.
---@field get_many fun(container_id:string):evadata.Tokens Get all tokens from container
---@field get_seconds_to_restore fun() Get current time to next restore point
---@field get_token_group fun(token_group_id:string):evadata.Tokens Return token group by id.
---@field get_tokens fun(tokens:table) Return evadata.Tokens tokens format.
---@field get_visual fun() Get current visual debt of token
---@field is_empty fun() Return is tokens equals to 0
---@field is_enough fun() Check is enough to pay token
---@field is_enough_group fun(token_group_id:string) Check multiply tokens by token_group_id
---@field is_enough_many fun(tokens:evadata.Tokens) Check multiply tokens
---@field is_exist_container fun(container_id:string):bool Check if token container exist
---@field is_infinity fun() Return is token is infinity now
---@field is_max fun() Return is token is maximum
---@field pay fun(token_id:string, amount:number, reason:string) Try to pay tokens from save
---@field pay_group fun(token_group_id:string, reason:string) Pay multiply tokens by token_group_id
---@field pay_many fun(tokens:evadata.Tokens, reason:string) Pay multiply tokens
---@field set fun() Set tokens to save
---@field sync_visual fun() Reset visual debt of tokens

---@class eva.trucks
---@field arrive fun(truck_id:string) Arrive truck right now, even it can't be  arrived now.
---@field get_time_to_arrive fun(truck_id:string):number Get time for next truck arrive
---@field get_time_to_leave fun(truck_id:string):number Get time for next truck leave
---@field is_arrived fun(truck_id:string):bool Check if truck is already arrived
---@field is_can_arrive fun(truck_id:string):bool Check if truck can be arrived now
---@field is_can_leave fun(truck_id:string):bool Check if truck can leave now
---@field is_enabled fun(truck_id:string):bool Check is truck enabled now
---@field leave fun(truck_id:string) Leave truck right now, even it can  leave now.
---@field set_enabled fun(truck_id:string) Set truck enabled state
---@field set_settings fun(trucks_settings:table) Set trucks settings with custom callbacks.

---@class eva.utils
---@field after fun() Make after closure
---@field get_days_in_month fun() Return days in month
---@field hex2rgb fun() Convert hex color to rgb color
---@field load_json fun() Load json from bundled resource
---@field rgb2hex fun() Convert rgb color to hex color
---@field save_json fun() Save json in bundled resource (desktop only)

---@class eva.wallet
---@field add fun() Add tokens to save
---@field add_group fun() Add multiply tokens by token_group_id
---@field add_infinity_time fun() Add to tokens infinity time usage
---@field add_many fun() Add multiply tokens
---@field add_visual fun() Add visual debt to token
---@field get fun() Get current token amount from save
---@field get_infinity_seconds fun() Get amount of seconds till end of infinity time
---@field get_seconds_to_restore fun() Get current time to next restore point
---@field get_visual fun() Get current visual debt of token
---@field is_empty fun() Return is tokens equals to 0
---@field is_enough fun() Check is enough to pay token
---@field is_enough_group fun(token_group_id:string) Check multiply tokens by token_group_id
---@field is_enough_many fun(tokens:evadata.Tokens) Check multiply tokens
---@field is_infinity fun() Return is token is infinity now
---@field is_max fun() Return is token is maximum
---@field pay fun(token_id:string, amount:number, reason:string) Try to pay tokens from save
---@field pay_group fun(token_group_id:string, reason:string) Pay multiply tokens by token_group_id
---@field pay_many fun(tokens:evadata.Tokens, reason:string) Pay multiply tokens
---@field set fun() Set tokens to save
---@field sync_visual fun() Reset visual debt of tokens

---@class eva.window
---@field appear fun() Appear functions for all windows  Need to call inside window
---@field close fun() Close window by id or last window
---@field close_all fun() Close all windows
---@field disappear fun() Disappear functions for all windows  Need to call inside window
---@field is_open fun() Check is window is opened now
---@field preload fun(window_id:string, callback:function) Preload window via monarch
---@field set_settings fun() Set game windows settings
---@field show fun() Show the game window  It will close current window and open new, if any opened  It can be popup on popup, so don't close prev.
---@field show_scene fun() Load the game scene

---@class eva_const
---@field AD eva_const.AD Available ads values
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
---@field UNKNOWN_REGION field Unknown region for eva.device.get_region()
---@field WALLET_CONTAINER field Default player container
---@field WALLET_TYPE field Default wallet container type

---@class eva_const.AD
---@field INTERSTITIAL field
---@field REWARDED field

---@class eva_const.DAILY
---@field RESET field
---@field SKIP field
---@field WAIT field

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

---@class eva_const.EVENT
---@field ADS_READY field
---@field ADS_SHOW_PAGE field
---@field ADS_SHOW_REWARDED field
---@field ADS_SUCCESS_PAGE field
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
---@field SCENE_CLOSE field
---@field SCENE_SHOW field
---@field SERVER_LOGIN field
---@field SKILL_COOLDOWN_END field
---@field SKILL_COOLDOWN_START field
---@field SKILL_USE field
---@field SKILL_USE_END field
---@field TIMER_TRIGGER field
---@field TOKEN_CHANGE field
---@field TRUCK_ARRIVE field
---@field TRUCK_CLOSE_TO_LEAVE field
---@field TRUCK_LEAVE field
---@field WINDOW_CLOSE field
---@field WINDOW_EVENT field
---@field WINDOW_SHOW field

---@class eva_const.IAP
---@field FAILED field
---@field PURCHASED field
---@field RESTORED field
---@field STATE field
---@field UNVERIFIED field

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
---@field KEY_P field
---@field KEY_Q field
---@field KEY_R field
---@field MULTITOUCH field
---@field SCROLL_DOWN field
---@field SCROLL_UP field
---@field TOUCH field

---@class eva_const.INPUT_SWIPE
---@field DOWN field
---@field LEFT field
---@field RIGHT field
---@field UP field

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

---@class eva_const.OS
---@field ANDROID field
---@field BROWSER field
---@field IOS field
---@field LINUX field
---@field MAC field
---@field WINDOWS field

---@class luax
---@field debug luax.debug Submodule
---@field go luax.go Submodule
---@field gui luax.gui Submodule
---@field math luax.math Submodule
---@field operators luax.operators Submodule
---@field string luax.string Submodule
---@field table luax.table Submodule
---@field vmath luax.vmath Submodule

---@class luax.debug
---@field timelog fun() debug.timelog

---@class luax.go
---@field set_alpha fun() go.set_alpha

---@class luax.gui
---@field get_alpha fun() gui.get_alpha
---@field is_chain_enabled fun() gui.is_chain_enabled
---@field set_alpha fun() gui.set_alpha

---@class luax.math
---@field chance fun() math.chance
---@field clamp fun() math.clamp
---@field clamp_box fun(pos:vector3, box:vector4, size:vector3, change_point:bool) math.clamp_box
---@field distance fun() math.distance
---@field is fun() math.is
---@field lerp fun() math.lerp
---@field lerp_box fun() math.lerp_box
---@field manhattan fun() math.manhattan
---@field round fun() math.round
---@field sign fun() math.sign
---@field step fun() math.step
---@field vec2rad fun() math.vec2rad

---@class luax.operators
---@field eq fun() operators.eq
---@field ge fun() operators.ge
---@field gt fun() operators.gt
---@field le fun() operators.le
---@field lt fun() operators.lt
---@field neq fun() operators.neq

---@class luax.string
---@field add_prefix_zeros fun() string.add_prefix_zeros
---@field ends fun() string.ends
---@field random fun() string.random
---@field split fun() string.split
---@field split_by_rank fun() string.split_by_rank
---@field starts fun() string.starts

---@class luax.table
---@field contains fun() table.contains
---@field copy fun() table.copy array
---@field deepcopy fun() table.deepcopy
---@field extend fun() table.extend
---@field get_item_from_array fun() table.get_item_from_array
---@field is_empty fun() table.is_empty
---@field length fun() table.length
---@field list fun() table.list
---@field override fun() table.override
---@field random fun() table.random
---@field remove_by_dict fun() table.remove_by_dict
---@field remove_item fun() table.remove_item
---@field shuffle fun() table.shuffle
---@field tostring fun() table.tostring
---@field weight_random fun() table.weight_random

---@class luax.vmath
---@field distance fun() vmath.distance
---@field rad2quat fun() vmath.rad2quat
---@field rad2vec fun() vmath.rad2vec
---@field vec2quat fun() vmath.vec2quat
---@field vec2rad fun() vmath.vec2rad



--======== File: /Users/insality/code/defold/defold-eva/eva/resources/eva.proto ========--
---@class eva.Ads
---@field ads_disabled boolean
---@field ads_loaded number
---@field interstitial_watched number
---@field rewarded_watched number

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


