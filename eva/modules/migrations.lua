--- Eva save migrations
-- Can apply migrations to save
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")

local logger = log.get_logger("eva.migrations")

local M = {}


local function add(version, code)
	table.insert(app.migrations, code)
	assert(#app.migrations == version)
end


--- Add migration to the eva system
-- Pass the migrations list in eva.init
-- You should directly point the migration version
-- in migration list (array from 1 to N)
-- @function eva.migrations.set_migrations
function M.set_migrations(migration_list)
	app.migrations = {}
	for i = 1, #migration_list do
		add(i, migration_list[i])
	end
end


--- Return amount of migrations
-- @function eva.migrations.get_count
function M.get_count()
	return app.migrations and #app.migrations or 0
end


--- Apply the migrations
-- @function eva.migrations.apply
function M.apply(version, save_table)
	logger:info("Start apply migration to save", { version = version })
	local migration_code = app.migrations[version]

	if not migration_code then
		logger:error("No migration with code", { version = version })
	end

	migration_code(save_table)

	logger:info("Migration applied to save", { version = version })
end


return M
