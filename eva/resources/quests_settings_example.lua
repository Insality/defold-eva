-- Quest settings example
local M = {}


function M.is_can_start(quest_id, quest)
	return true
end


function M.is_can_complete(quest_id, quest)
	return true
end


function M.is_can_event(quest_id, quest)
	return true
end


function M.on_quest_start(quest_id, quest)

end


function M.on_quest_progress(quest_id, quest)

end


function M.on_quest_task_completed(quest_id, quest)

end


function M.on_quest_completed(quest_id, quest)

end


return M
