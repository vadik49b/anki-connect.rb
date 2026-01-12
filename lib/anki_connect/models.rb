# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to create and modify note types (models).
    module Models
      # Gets complete list of model names.
      #
      # @return [Array<String>] Array of model name strings
      def model_names
        request(:modelNames)
      end

      # Gets model names with their IDs.
      #
      # @return [Hash] Model names mapped to IDs
      def model_names_and_ids
        request(:modelNamesAndIds)
      end

      # Gets models by ID.
      #
      # @param ids [Array<Integer>] Array of model IDs
      # @return [Array<Hash>] Array of model objects
      def get_models_by_id(ids)
        request(:findModelsById, modelIds: ids)
      end

      # Gets models by name.
      #
      # @param names [Array<String>] Array of model names
      # @return [Array<Hash>] Array of model objects
      def get_models_by_name(names)
        request(:findModelsByName, modelNames: names)
      end

      # Gets field names for a model.
      #
      # @param model_name [String] Model name
      # @return [Array<String>] Array of field names in order
      def get_field_names(model_name)
        request(:modelFieldNames, modelName: model_name)
      end

      # Gets field descriptions for a model.
      #
      # @param model_name [String] Model name
      # @return [Array<String>] Array of description strings
      def get_field_descriptions(model_name)
        request(:modelFieldDescriptions, modelName: model_name)
      end

      # Gets field fonts and sizes for a model.
      #
      # @param model_name [String] Model name
      # @return [Hash] Field names mapped to { font:, size: }
      def get_field_fonts(model_name)
        request(:modelFieldFonts, modelName: model_name)
      end

      # Gets fields used on templates.
      #
      # @param model_name [String] Model name
      # @return [Hash] Template names mapped to [questionFields, answerFields]
      def get_fields_on_templates(model_name)
        request(:modelFieldsOnTemplates, modelName: model_name)
      end

      # Creates a new model.
      #
      # @param name [String] Model name
      # @param fields [Array<String>] Field names in order
      # @param templates [Array<Hash>] Template objects with Name, Front, Back
      # @param css [String, nil] CSS styling
      # @param is_cloze [Boolean] true for cloze type
      # @return [Hash] Complete model object
      def create_model(name:, fields:, templates:, css: nil, is_cloze: false)
        params = { modelName: name, inOrderFields: fields, cardTemplates: templates, isCloze: is_cloze }
        params[:css] = css if css
        request(:createModel, **params)
      end

      # Gets templates for a model.
      #
      # @param model_name [String] Model name
      # @return [Hash] Template names mapped to { Front:, Back: }
      def get_templates(model_name)
        request(:modelTemplates, modelName: model_name)
      end

      # Gets CSS styling for a model.
      #
      # @param model_name [String] Model name
      # @return [Hash] Object with css property
      def get_styling(model_name)
        request(:modelStyling, modelName: model_name)
      end

      # Updates a model's templates and/or CSS.
      #
      # @param name [String] Model name
      # @param templates [Hash, nil] Template names mapped to Front/Back
      # @param css [String, nil] CSS styling
      # @return [nil]
      def update_model(name, templates: nil, css: nil)
        request(:updateModelTemplates, model: { name: name, templates: templates }) if templates
        return unless css

        request(:updateModelStyling, model: { name: name, css: css })
      end

      # Find and replace in model templates/CSS.
      #
      # @param model_name [String] Model name
      # @param find [String] Text to find
      # @param replace [String] Replacement text
      # @param front [Boolean] Search front templates
      # @param back [Boolean] Search back templates
      # @param css [Boolean] Search CSS
      # @return [Integer] Number of replacements made
      def find_and_replace_in_model(model_name:, find:, replace:, front: true, back: true, css: true)
        request(:findAndReplaceInModels, model: {
                  modelName: model_name, findText: find, replaceText: replace,
                  front: front, back: back, css: css
                })
      end

      # Renames a template.
      #
      # @param model_name [String] Model name
      # @param from [String] Current template name
      # @param to [String] New template name
      # @return [nil]
      def rename_template(model_name, from:, to:)
        request(:modelTemplateRename, modelName: model_name, oldTemplateName: from, newTemplateName: to)
      end

      # Moves a template to a new position.
      #
      # @param model_name [String] Model name
      # @param template_name [String] Template name
      # @param index [Integer] New position (0-based)
      # @return [nil]
      def reposition_template(model_name, template_name, index)
        request(:modelTemplateReposition, modelName: model_name, templateName: template_name, index: index)
      end

      # Adds a template to a model.
      #
      # @param model_name [String] Model name
      # @param template [Hash] Template with Name, Front, Back
      # @return [nil]
      def add_template(model_name, template)
        request(:modelTemplateAdd, modelName: model_name, template: template)
      end

      # Removes a template from a model.
      #
      # @param model_name [String] Model name
      # @param template_name [String] Template name
      # @return [nil]
      def remove_template(model_name, template_name)
        request(:modelTemplateRemove, modelName: model_name, templateName: template_name)
      end

      # Renames a field.
      #
      # @param model_name [String] Model name
      # @param from [String] Current field name
      # @param to [String] New field name
      # @return [nil]
      def rename_field(model_name, from:, to:)
        request(:modelFieldRename, modelName: model_name, oldFieldName: from, newFieldName: to)
      end

      # Moves a field to a new position.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @param index [Integer] New position (0-based)
      # @return [nil]
      def reposition_field(model_name, field_name, index)
        request(:modelFieldReposition, modelName: model_name, fieldName: field_name, index: index)
      end

      # Adds a field to a model.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @param index [Integer, nil] Position (defaults to end)
      # @return [nil]
      def add_field(model_name, field_name, index: nil)
        params = { modelName: model_name, fieldName: field_name }
        params[:index] = index if index
        request(:modelFieldAdd, **params)
      end

      # Removes a field from a model.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @return [nil]
      def remove_field(model_name, field_name)
        request(:modelFieldRemove, modelName: model_name, fieldName: field_name)
      end

      # Sets font for a field.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @param font [String] Font name
      # @return [nil]
      def set_field_font(model_name, field_name, font)
        request(:modelFieldSetFont, modelName: model_name, fieldName: field_name, font: font)
      end

      # Sets font size for a field.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @param size [Integer] Font size
      # @return [nil]
      def set_field_font_size(model_name, field_name, size)
        request(:modelFieldSetFontSize, modelName: model_name, fieldName: field_name, fontSize: size)
      end

      # Sets description for a field.
      #
      # @param model_name [String] Model name
      # @param field_name [String] Field name
      # @param description [String] Description text
      # @return [Boolean] true on success
      def set_field_description(model_name, field_name, description)
        request(:modelFieldSetDescription, modelName: model_name, fieldName: field_name, description: description)
      end
    end
  end
end
