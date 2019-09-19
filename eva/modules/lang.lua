local M = {}


local dict = {}


function M.set_lang(lang)

end


function M.get_lang()

end


function M.txt(lang_id)
	assert(lang_id, "You must provide the lang id")
	return dict[lang_id] or lang_id
end


function M.txp(lang_id, ...)
	assert(lang_id, "You must provide the lang id")
	return string.format(M.txt(lang_id), ...)
end


return M
