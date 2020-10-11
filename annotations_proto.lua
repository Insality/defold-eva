
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


