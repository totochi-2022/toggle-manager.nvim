# toggle-manager.nvim

**Version 1.0.0**

A comprehensive toggle system for Neovim features with beautiful UI and lualine integration.

## Requirements

- Neovim >= 0.8.0
- Optional: `nvim-lualine/lualine.nvim` for status line integration

## Features

- 🎨 **Colorful lualine display** - State-based colored indicators
- 🖼️ **Floating UI** - Intuitive toggle menu
- 🎯 **Dynamic highlighting** - Colorscheme-aware colors
- 🔧 **Modular design** - Clear separation of concerns
- 💾 **State persistence** - Settings are saved automatically

## Installation

### lazy.nvim (Recommended)

Add to your `lazy.nvim` plugin configuration:

```lua
{
  "motoki-tanaka/toggle-manager.nvim",  -- Replace with your GitHub username
  dependencies = {
    "nvim-lualine/lualine.nvim", -- Optional but recommended
  },
  config = function()
    require('toggle-manager').setup({
      definitions = {
        -- Example: Diagnostics toggle
        d = {
          name = 'diagnostics',
          states = {'off', 'cursor_only', 'full'},
          colors = {
            { fg = 'NonText' },                    -- off: gray
            { fg = 'DiagnosticWarn' },             -- cursor_only: warn color
            { fg = 'Normal', bg = 'DiagnosticError' } -- full: normal text on error bg
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
        -- Add more toggle definitions here...
      }
    })
    
    -- Setup keymap to open toggle menu
    vim.keymap.set('n', '<leader>tt', function()
      require('toggle-manager').show_toggle_menu()
    end, { desc = 'Toggle Menu' })
  end,
  keys = {
    { "<leader>tt", desc = "Toggle Menu" },
  },
}
```

### packer.nvim

```lua
use {
  "your-username/toggle-manager.nvim",
  requires = {
    "nvim-lualine/lualine.nvim", -- Optional
  },
  config = function()
    require('toggle-manager').setup({
      -- Your toggle definitions here
    })
    
    -- Setup keymap
    vim.keymap.set('n', '<leader>tt', function()
      require('toggle-manager').show_toggle_menu()
    end, { desc = 'Toggle Menu' })
  end
}
```

### Manual Setup Steps

1. **Install the plugin** using your preferred plugin manager
2. **Configure toggle definitions** in the `setup()` call
3. **Set up a keymap** to open the toggle menu (e.g., `<leader>tt`)
4. **Optional: Configure lualine** to display toggle states (see below)

## Usage

- `<Space>0` - Open toggle menu (configure keymap as needed)
- Small letters (e.g. `d`) - Toggle state
- Capital letters (e.g. `D`) - Toggle lualine display
- `s` - Save current states as defaults

## Lualine Integration

To display toggle states in your status line, add the toggle-manager component to your lualine configuration:

```lua
{
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      sections = {
        -- Add toggle component to any section (recommended: lualine_x or lualine_c)
        lualine_x = {
          require('toggle-manager').get_lualine_component(),
          'encoding', 'fileformat', 'filetype'
        },
        -- Or in the center section:
        -- lualine_c = {
        --   'filename',
        --   require('toggle-manager').get_lualine_component(),
        -- }
      }
    })
  end
}
```

The lualine component will show colored letters (e.g., `D`, `R`, `P`) representing active toggles. Colors automatically match your current colorscheme.

### Controlling Lualine Display

- **Capital letters** in toggle menu toggle lualine visibility per item
- **Example**: Press `D` to show/hide diagnostics status in lualine
- Settings are automatically saved and restored

## Configuration

### Data Storage

Toggle states and lualine display preferences are automatically saved to:
- `vim.fn.stdpath('data')/toggle-manager/defaults.json` - Default toggle states
- `vim.fn.stdpath('data')/toggle-manager/lualine_display.json` - Lualine display settings

### Custom Configuration

See [Configuration Documentation](docs/configuration.md) for detailed configuration options.

## Troubleshooting

### Common Issues

**Q: Toggle menu shows "No toggle definitions found!"**
A: Make sure you've called `require('toggle-manager').setup({definitions = {...}})` in your plugin configuration.

**Q: Lualine component is not showing**
A: Ensure you've added `require('toggle-manager').get_lualine_component()` to your lualine sections and that some toggles are set to display (use capital letters in toggle menu).

**Q: Colors not showing correctly**
A: Toggle-manager automatically adapts to your colorscheme. If colors look wrong, try restarting Neovim after changing colorschemes.

**Q: States not persisting between sessions**
A: Check that Neovim can write to `vim.fn.stdpath('data')`. Default paths are usually writable, but some systems may have restrictions.

### Debugging

Enable debug information:
```lua
-- Add to your toggle-manager setup
require('toggle-manager').setup({
  debug = true,  -- Shows state changes in messages
  definitions = {
    -- your definitions...
  }
})
```

## License

Public Domain - Use freely!