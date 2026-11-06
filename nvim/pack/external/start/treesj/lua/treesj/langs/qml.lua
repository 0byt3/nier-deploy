local lang_utils = require('treesj.langs.utils')

local statement_preset = {
  join = {
    force_insert = ';',
    space_in_brackets = true,
    space_separator = true,
  },
}

local function get_block_preset(extra_no_insert, penultimate)
  local no_insert = extra_no_insert or {}

  if penultimate then
    table.insert(no_insert, lang_utils.helpers.if_penultimate)
  end

  return lang_utils.set_preset_for_dict({

    join = {
      force_insert = ';',
      space_in_brackets = true,
      space_separator = true,
      no_insert_if = no_insert,
      format_resulted_lines = function(lines)
        if penultimate then
          local target_index = #lines - 1

          if target_index > 1 and lines[target_index] then
            lines[target_index] = lines[target_index]:gsub(';%s*$', '')
          end

          return lines
        end

        return lines
      end,
    },

    split = {
      separator = '',
      force_insert = '',
      space_in_brackets = true,
      space_separator = true,
      recursive = true,
      format_resulted_lines = function(lines)
        for i, line in ipairs(lines) do
          lines[i] = line:gsub(';%s*$', '')
        end
        return lines
      end,
    },
  })
end

return {
  array = lang_utils.set_preset_for_list(),
  ui_object_array = lang_utils.set_preset_for_list(),

  object = lang_utils.set_preset_for_dict(),
  ui_object_definition = lang_utils.set_preset_for_dict(),
  ui_object_initializer = get_block_preset({
    'ui_object_definition',
    'ui_object_definition_binding',
    'ui_inline_component',
    'function_declaration',
  }, true),

  function_declaration = {
    target_nodes = { 'formal_parameters', 'statement_block' },
  },
  formal_parameters = lang_utils.set_preset_for_list(),

  statement_block = get_block_preset({}, false),

  if_statement = {
    target_nodes = { 'statement_block' },
  },

  else_clause = {
    target_nodes = { 'statement_block' },
  },

  lexical_declaration = statement_preset,
  variable_declaration = statement_preset,
  break_statement = statement_preset,
  continue_statement = statement_preset,
}
