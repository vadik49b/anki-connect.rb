# Changelog

## 0.2.0 - 2026-07-23

- **Breaking:** Redesign the public API around idiomatic Ruby naming and current Anki “note type” terminology, without 0.1 compatibility aliases.
- Normalize nested wrapper inputs from snake_case to AnkiConnect wire keys.
- Add wrappers for all nondeprecated actions in AnkiConnect commit `de6e6e1`.
- Fix the `findAndReplaceInModels` request shape and media-only note updates.
- Add local argument validation for note selectors, media sources, tags, and parallel card values.
- Add HTTP and HTTPS endpoint support, configurable timeouts, protocol validation, and typed errors.
- Require HTTPS when sending API keys to non-loopback endpoints and stop exposing configured keys through a reader.
- Separate safe unit tests from explicit live integration tests and test Ruby 3.4 and 4.0 in CI.

### Renamed API

- Cards: `get_ease_factors` -> `ease_factors`; `update_card` -> `set_card_values`; `suspended?` -> `card_suspended?` / `card_suspension_statuses`; `due?` -> `card_due?` / `card_due_statuses`; `get_intervals` -> `card_intervals`; `get_note_ids` -> `note_ids_for_cards`; `get_cards_mod_time` -> `card_modification_times`; `get_cards` -> `cards`.
- Decks: `get_decks_for_cards` -> `decks_for_cards`; `get_deck_config` -> `deck_config`; `get_deck_stats` -> `deck_stats`.
- Note types: `model_names` -> `note_type_names`; `model_names_and_ids` -> `note_type_names_and_ids`; `get_models_by_id` / `get_models_by_name` -> `note_types_by_id` / `note_types_by_name`; `get_field_names` / `get_field_descriptions` / `get_field_fonts` / `get_fields_on_templates` -> their `note_type_*` forms; `create_model` -> `create_note_type`; `get_templates` / `get_styling` -> `note_type_templates` / `note_type_styling`; `update_model` -> `update_note_type_templates` / `update_note_type_styling`; `find_and_replace_in_model` -> `find_and_replace_in_note_type`; template and field mutation methods now include `note_type` (for example, `rename_template` -> `rename_note_type_template` and `set_field_font` -> `set_note_type_field_font`).
- Notes: `can_add_notes` -> `note_addable?` / `note_addability` / `note_addability_statuses` / `note_addability_details`; `change_note_model` -> `change_note_type`; `get_note_tags` -> `note_tags`; `all_tags` -> `tags`; `get_notes` -> `notes`; `get_notes_mod_time` -> `note_modification_times`; `remove_empty_notes` -> `remove_unused_note_types`.
- Media and miscellaneous: `list_media` -> `media_files`; `media_dir_path` -> `media_directory`; `version` -> `api_version`; `api_reflect` -> `api_capabilities`; `multi` -> `batch`; `import_deck` -> `import_package`.
- Statistics: `get_reviews` -> `reviews`; `get_reviews_for_cards` -> `reviews_for_cards`; `latest_review_time` -> `latest_review_id`.
