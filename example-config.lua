-- Example configuration for lazy.nvim
-- Copy this to your Neovim config and adjust as needed

return {
  -- GitHub repository
  "your-username/toggle-manager.nvim",
  
  -- Load on keymap
  keys = {
    { "<leader>tt", desc = "Toggle Menu" },
  },
  
  -- Dependencies (optional but recommended)
  dependencies = {
    "nvim-lualine/lualine.nvim",
  },
  
  -- Configuration
  config = function()
    -- Setup toggle-manager with your toggle definitions
    require('toggle-manager').setup({
      definitions = {
        -- Example: Diagnostics toggle (3 states)
        d = {
          name = 'diagnostics',
          states = {'off', 'cursor_only', 'full'},
          colors = {
            { fg = 'NonText' },                    -- off: gray
            { fg = 'DiagnosticWarn' },             -- cursor_only: yellow
            { fg = 'Normal', bg = 'DiagnosticError' } -- full: red background
          },
          default_state = 'cursor_only',
          desc = 'LSP Diagnostics',
          get_state = function()
            local config = vim.diagnostic.config()
            if not config.virtual_text and not config.signs then
              return 'off'
            elseif config.virtual_text then
              return 'full'
            else
              return 'cursor_only'
            end
          end,
          set_state = function(state)
            if state == 'off' then
              vim.diagnostic.config({
                virtual_text = false,
                signs = false,
              })
            elseif state == 'cursor_only' then
              vim.diagnostic.config({
                virtual_text = false,
                signs = true,
              })
            else -- full
              vim.diagnostic.config({
                virtual_text = true,
                signs = true,
              })
            end
          end
        },
        
        -- Example: Readonly toggle (2 states)
        r = {
          name = 'readonly',
          states = {'off', 'on'},
          colors = {
            { fg = 'NonText' },                  -- off: gray
            { fg = 'WarningMsg', bg = 'Visual' } -- on: warning colors
          },
          default_state = 'off',
          desc = 'Read-only Mode',
          get_state = function() 
            return vim.opt.readonly:get() and 'on' or 'off' 
          end,
          set_state = function(state) 
            vim.opt.readonly = (state == 'on') 
          end
        },
        
        -- Add more toggle definitions here...
      }
    })
    
    -- Setup keymap
    vim.keymap.set('n', '<leader>tt', function()
      require('toggle-manager').show_toggle_menu()
    end, { desc = 'Toggle Menu' })
    
    -- Optional: Setup lualine integration
    -- Make sure to add this to your lualine config
    -- require('lualine').setup({
    --   sections = {
    --     lualine_x = {
    --       require('toggle-manager').get_lualine_component(),
    --       -- other components...
    --     }
    --   }
    -- })
  end,
}