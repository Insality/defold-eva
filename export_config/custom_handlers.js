function tokens(data, config) {
	for (let key in data) {
		let record = data[key]
		let tokens = []
		for (let i in config.fields) {
			if (!record[config.fields[i]]) {
				continue
			}
			let token_list = config.fields[i]

			for (let j = 0; j < record[token_list].length; j += 2) {
				tokens.push({
					token_id: record[token_list][j],
					amount: record[token_list][j+1]
				})
			}
			delete record[token_list]
		}
		if (config.id) {
			if (tokens.length > 0) {
				record[config.id] = { tokens: tokens }
			}
		}
		else {
			if (tokens.length > 0) {
				data[key] = { tokens: tokens }
			}
		}
	}

	return data
}

function quest_tasks(data, config) {
	for (let key in data) {
		let record = data[key]
		let tasks = []
		for (let i in config.fields) {
			if (!record[config.fields[i]]) {
				continue
			}

			tasks.push({
				action: record[config.fields[i]][0],
				object: record[config.fields[i]][1],
				required: record[config.fields[i]][2],
				param1: record[config.fields[i]][3],
				param2: record[config.fields[i]][4]
			})

			delete record[config.fields[i]]
		}
		record[config.id] = tasks
	}

	return data
}


module.exports = {
	tokens: tokens,
	quest_tasks: quest_tasks
}
