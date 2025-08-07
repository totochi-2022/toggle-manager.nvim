-- plugin.lua for toggle-manager.nvim
-- This file contains plugin metadata and version information

return {
  name = "toggle-manager.nvim",
  version = "1.0.0",
  author = "Motoki Tanaka",
  description = "A comprehensive toggle system for Neovim features with beautiful UI and lualine integration",
  license = "Public Domain",
  repository = "https://github.com/your-username/toggle-manager.nvim",
  
  -- Neovim version compatibility
  nvim_version = ">=0.8.0",
  
  -- Plugin dependencies (optional)
  dependencies = {
    "nvim-lualine/lualine.nvim",  -- Optional but recommended for status line integration
  },
  
  -- Plugin capabilities
  features = {
    "colorful_lualine_display",
    "floating_ui", 
    "dynamic_highlighting",
    "state_persistence",
    "modular_design"
  }
}