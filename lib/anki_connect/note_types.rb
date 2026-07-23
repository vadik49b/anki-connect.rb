# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to create and modify note types.
    module NoteTypes
      # Gets complete list of note type names.
      #
      # @return [Array<String>] Array of note type names
      def note_type_names
        request(:modelNames)
      end

      # Gets note type names with their IDs.
      #
      # @return [Hash] Note type names mapped to IDs
      def note_type_names_and_ids
        request(:modelNamesAndIds)
      end

      # Gets a note type name by ID.
      #
      # @param note_type_id [Integer] Note type ID
      # @return [String] Note type name
      def note_type_name_from_id(note_type_id)
        request(:modelNameFromId, modelId: note_type_id)
      end

      # Gets note types by ID.
      #
      # @param ids [Array<Integer>] Array of note type IDs
      # @return [Array<Hash>] Array of note type objects
      def note_types_by_id(ids)
        request(:findModelsById, modelIds: ids)
      end

      # Gets note types by name.
      #
      # @param names [Array<String>] Array of note type names
      # @return [Array<Hash>] Array of note type objects
      def note_types_by_name(names)
        request(:findModelsByName, modelNames: names)
      end

      # Gets field names for a note type.
      #
      # @param note_type_name [String] Note type name
      # @return [Array<String>] Array of field names in order
      def note_type_field_names(note_type_name)
        request(:modelFieldNames, modelName: note_type_name)
      end

      # Gets field descriptions for a note type.
      #
      # @param note_type_name [String] Note type name
      # @return [Array<String>] Array of description strings
      def note_type_field_descriptions(note_type_name)
        request(:modelFieldDescriptions, modelName: note_type_name)
      end

      # Gets field fonts and sizes for a note type.
      #
      # @param note_type_name [String] Note type name
      # @return [Hash] Field names mapped to { font:, size: }
      def note_type_field_fonts(note_type_name)
        request(:modelFieldFonts, modelName: note_type_name)
      end

      # Gets fields used on templates.
      #
      # @param note_type_name [String] Note type name
      # @return [Hash] Template names mapped to [questionFields, answerFields]
      def note_type_fields_on_templates(note_type_name)
        request(:modelFieldsOnTemplates, modelName: note_type_name)
      end

      # Creates a new note type.
      #
      # @param name [String] Note type name
      # @param fields [Array<String>] Field names in order
      # @param templates [Array<Hash>] Templates with name, front, and back
      # @param css [String, nil] CSS styling
      # @param cloze [Boolean] true for a cloze note type
      # @return [Hash] Complete note type object
      def create_note_type(name:, fields:, templates:, css: nil, cloze: false)
        params = {
          modelName: name,
          inOrderFields: fields,
          cardTemplates: templates.map { |template| normalize_template(template) },
          isCloze: cloze
        }
        params[:css] = css if css
        request(:createModel, **params)
      end

      # Gets templates for a note type.
      #
      # @param note_type_name [String] Note type name
      # @return [Hash] Template names mapped to { Front:, Back: }
      def note_type_templates(note_type_name)
        request(:modelTemplates, modelName: note_type_name)
      end

      # Gets CSS styling for a note type.
      #
      # @param note_type_name [String] Note type name
      # @return [Hash] Object with css property
      def note_type_styling(note_type_name)
        request(:modelStyling, modelName: note_type_name)
      end

      # Updates templates for a note type.
      #
      # @param name [String] Note type name
      # @param templates [Hash] Template names mapped to optional front/back values
      # @return [nil]
      def update_note_type_templates(name, templates)
        request(:updateModelTemplates, model: { name: name, templates: normalize_template_updates(templates) })
      end

      # Updates CSS styling for a note type.
      #
      # @param name [String] Note type name
      # @param css [String] CSS styling
      # @return [nil]
      def update_note_type_styling(name, css:)
        request(:updateModelStyling, model: { name: name, css: css })
      end

      # Find and replace in note type templates/CSS.
      #
      # @param note_type_name [String, nil] Note type name, or nil for all note types
      # @param find [String] Text to find
      # @param replace [String] Replacement text
      # @param front [Boolean] Search front templates
      # @param back [Boolean] Search back templates
      # @param css [Boolean] Search CSS
      # @return [Integer] Number of note types changed
      def find_and_replace_in_note_type(note_type_name: nil, find:, replace:, front: true, back: true, css: true)
        request(
          :findAndReplaceInModels,
          modelName: note_type_name,
          findText: find,
          replaceText: replace,
          front: front,
          back: back,
          css: css
        )
      end

      # Renames a template.
      #
      # @param note_type_name [String] Note type name
      # @param from [String] Current template name
      # @param to [String] New template name
      # @return [nil]
      def rename_note_type_template(note_type_name, from:, to:)
        request(:modelTemplateRename, modelName: note_type_name, oldTemplateName: from, newTemplateName: to)
      end

      # Moves a template to a new position.
      #
      # @param note_type_name [String] Note type name
      # @param template_name [String] Template name
      # @param index [Integer] New position (0-based)
      # @return [nil]
      def reposition_note_type_template(note_type_name, template_name, index)
        request(:modelTemplateReposition, modelName: note_type_name, templateName: template_name, index: index)
      end

      # Adds a template to a note type.
      #
      # @param note_type_name [String] Note type name
      # @param template [Hash] Template with Name, Front, Back
      # @return [nil]
      def add_note_type_template(note_type_name, template)
        request(:modelTemplateAdd, modelName: note_type_name, template: normalize_template(template))
      end

      # Removes a template from a note type.
      #
      # @param note_type_name [String] Note type name
      # @param template_name [String] Template name
      # @return [nil]
      def remove_note_type_template(note_type_name, template_name)
        request(:modelTemplateRemove, modelName: note_type_name, templateName: template_name)
      end

      # Renames a field.
      #
      # @param note_type_name [String] Note type name
      # @param from [String] Current field name
      # @param to [String] New field name
      # @return [nil]
      def rename_note_type_field(note_type_name, from:, to:)
        request(:modelFieldRename, modelName: note_type_name, oldFieldName: from, newFieldName: to)
      end

      # Moves a field to a new position.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @param index [Integer] New position (0-based)
      # @return [nil]
      def reposition_note_type_field(note_type_name, field_name, index)
        request(:modelFieldReposition, modelName: note_type_name, fieldName: field_name, index: index)
      end

      # Adds a field to a note type.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @param index [Integer, nil] Position (defaults to end)
      # @return [nil]
      def add_note_type_field(note_type_name, field_name, index: nil)
        params = { modelName: note_type_name, fieldName: field_name }
        params[:index] = index if index
        request(:modelFieldAdd, **params)
      end

      # Removes a field from a note type.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @return [nil]
      def remove_note_type_field(note_type_name, field_name)
        request(:modelFieldRemove, modelName: note_type_name, fieldName: field_name)
      end

      # Sets font for a field.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @param font [String] Font name
      # @return [nil]
      def set_note_type_field_font(note_type_name, field_name, font)
        request(:modelFieldSetFont, modelName: note_type_name, fieldName: field_name, font: font)
      end

      # Sets font size for a field.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @param size [Integer] Font size
      # @return [nil]
      def set_note_type_field_font_size(note_type_name, field_name, size)
        request(:modelFieldSetFontSize, modelName: note_type_name, fieldName: field_name, fontSize: size)
      end

      # Sets description for a field.
      #
      # @param note_type_name [String] Note type name
      # @param field_name [String] Field name
      # @param description [String] Description text
      # @return [Boolean] true on success
      def set_note_type_field_description(note_type_name, field_name, description)
        request(:modelFieldSetDescription, modelName: note_type_name, fieldName: field_name, description: description)
      end

      private

      TEMPLATE_KEYS = {
        'name' => :Name,
        'front' => :Front,
        'back' => :Back
      }.freeze
      TEMPLATE_UPDATE_KEYS = {
        'front' => :Front,
        'back' => :Back
      }.freeze
      private_constant :TEMPLATE_KEYS, :TEMPLATE_UPDATE_KEYS

      def normalize_template(template)
        normalized = normalize_keys(template, TEMPLATE_KEYS, name: 'template')
        missing_keys = TEMPLATE_KEYS.values.reject { |key| normalized.key?(key) }
        raise ArgumentError, "missing template keys: #{missing_keys.join(', ')}" unless missing_keys.empty?

        normalized
      end

      def normalize_template_updates(templates)
        raise ArgumentError, 'templates must be a Hash' unless templates.is_a?(Hash)

        templates.to_h do |name, template|
          normalized = normalize_keys(template, TEMPLATE_UPDATE_KEYS, name: 'template update')
          raise ArgumentError, 'template update must include front or back' if normalized.empty?

          [name, normalized]
        end
      end
    end
  end
end
