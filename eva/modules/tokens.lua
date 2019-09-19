local M = {}

local tokens_prefs = {}


function M.add(token_id, amount)

end


function M.pay(token_id, amount)

end


function M.is_enough(token_id, amount)

end

function M.on_game_start()
	M._eva.saver.add_save_part("eva.tokens", tokens_prefs)
end


return M
