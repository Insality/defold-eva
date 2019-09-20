# Lang Eva Module

### Namespace
eva.lang

### API
- eva.lang.set_lang
- eva.lang.get_lang
- eva.lang.txt
- eva.lang.txp

### Экспорт
Экспортировать локали с помощью sheets-exporter в формате JSON
Пример документа:


Пример конфига экспорта:
```json
	"locale": {
		"parts": ["locale_general", "locale_dialogs", "locale_relics"],
		"save_param": {
			"separate_langs": [
				"ru", "en"
			]
		}
	}
```

### Обязательные поля:
time_format_d
time_format_h
time_format_m