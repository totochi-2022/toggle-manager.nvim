-- toggle-manager.nvim
-- A comprehensive toggle system for Neovim features

local M = {
  version = "1.0.0"
}

-- Re-export from submodules
M.config = require('toggle-manager.config')
M.ui = require('toggle-manager.ui')
M.highlights = require('toggle-manager.highlights')

-- Main API
M.setup = function(opts)
  opts = opts or {}
  
  -- Initialize highlights
  M.highlights.init()
  
  -- Setup user configuration
  if opts.definitions then
    M.config.register_definitions(opts.definitions)
  end
  
  -- Initialize toggles
  M.config.initialize_toggles()
  
  -- Setup UI
  M.ui.setup()
end

-- Convenience functions
M.show_menu = function()
  M.ui.show_toggle_menu()
end

M.get_lualine_component = function()
  return M.ui.get_lualine_component()
end

M.show_toggle_menu = function()
  M.ui.show_toggle_menu()
end

-- Direct access to highlight function for compatibility
M.get_or_create_highlight = function(color_def, toggle_name, state_index)
  return M.highlights.get_or_create_highlight(color_def, toggle_name, state_index)
end

return M