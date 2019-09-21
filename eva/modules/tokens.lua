local M = {}


function M.add(token_id, amount)

end


function M.pay(token_id, amount)

end


function M.is_enough(token_id, amount)

end


function M.on_game_start()
	M._tokens_prefs = M._eva.proto.get("eva.Tokens")

	M._eva.saver.add_save_part("eva.Tokens", M._tokens_prefs)
end


return M
