--- Eva save migrations
-- Can apply migrations to save
-- Migrations applied before cleaning with protobuf
-- So you can store previos values to the new save
-- @submodule eva

local log = require("eva.log")
local app = require("eva.app")

local logger = log.get_logger("eva.migrations")

local M = {}


--- Add migration to the system
-- Need to call this before save loaded
-- You should directly point the migration version
-- And add them in straight way, from 1 to the last.
-- You have to define migrations before call eva.init()
-- @function eva.migrations.add
function M.add(version, code)
	app.migrations = app.migrations or {}

	table.insert(app.migrations, code)
	assert(#app.migrations == version)
end


function M.set_migrations(migration_list)
	for i = 1, #migration_list do
		M.add(i, migration_list[i])
	end
end


--- Return amount of migrations
function M.get_count()
	return #app.migrations
end


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
