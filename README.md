# toggle-manager.nvim

**Version 1.2.0**

A comprehensive toggle system for Neovim features with beautiful UI and lualine integration.

## Requirements

- Neovim >= 0.8.0
- Optional: `nvim-lualine/lualine.nvim` for status line integration

## Features

- 🎨 **Colorful lualine display** - State-based colored indicators with smart color extraction
- 🖼️ **Floating UI** - Intuitive toggle menu with real-time state updates
- 🎯 **Dynamic highlighting** - Smart fg/bg color handling from colorscheme
- 🔧 **Self-contained config** - Setup directly in configuration files
- 💾 **State persistence** - Settings are saved automatically
- ⚡ **Fast loading** - Works with any loading timing

## Installation & Configuration

### Option 1: Self-Contained Configuration (Recommended)

Create a configuration file (e.g., `lua/toggle_config.lua`) that sets up everything:

```lua
-- lua/toggle_config.lua
-- This file can be loaded at any time and will configure toggle-manager

-- Define your toggles
local definitions = {
  d = { -- Diagnostics toggle
    name = 'diagnostics',
    states = { 'cursor_only', 'full_with_underline', 'signs_only' },
    colors = {
      { fg = 'Normal', bg = 'Normal' },          -- cursor_only: subtle
      { fg = '#000000', bg = 'DiagnosticWarn' }, -- full: black on warn
      { fg = '#000000', bg = 'DiagnosticError' } -- signs: black on error
    },
    default_state = 'cursor_only',
    desc = 'Diagnostics Mode',
    get_state = function()
      local config = vim.diagnostic.config()
      if config.virtual_text then
        return 'full_with_underline'
      elseif config.signs and not config.virtual_text then
        return 'cursor_only'
      else
        return 'signs_only'
      end
    end,
    set_state = function(state)
      if state == 'cursor_only' then
        vim.diagnostic.config({
          virtual_text = false,
          signs = true,
          underline = false,
        })
      elseif state == 'full_with_underline' then
        vim.diagnostic.config({
          virtual_text = { prefix = "●", spacing = 2 },
          signs = true,
          underline = true,
        })
      else -- signs_only
        vim.diagnostic.config({
          virtual_text = false,
          signs = true,
          underline = false,
        })
      end
    end
  },
  -- Add more toggles here...
}

-- Setup toggle-manager when available
local function setup_toggle_manager()
  local ok, toggle_manager = pcall(require, 'toggle-manager')
  if not ok then
    return false -- Plugin not loaded yet
  end
  
  toggle_manager.setup({ definitions = definitions })
  return true
end

-- Try setup immediately, fallback to VimEnter if needed
if not setup_toggle_manager() then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = setup_toggle_manager,
    once = true,
  })
end
```

**Plugin configuration** (in your plugin manager):

```lua
-- lazy.nvim
{
  dir = "/path/to/your/toggle-manager.nvim", -- or GitHub URL
  lazy = false,  -- Load early so config can use it
  priority = 100,
  -- No config needed - handled by toggle_config.lua
},
```

**Keymap configuration** (in your keymap file):

```lua
-- Add to your keymap configuration
vim.keymap.set('n', '<LocalLeader>0', function()
  require('toggle-manager').show_menu()
end, { desc = 'Toggle Menu' })
```

### Option 2: Traditional Plugin Configuration

```lua
{
  "your-username/toggle-manager.nvim",
  dependencies = {
    "nvim-lualine/lualine.nvim", -- Optional but recommended
  },
  config = function()
    require('toggle-manager').setup({
      definitions = {
        -- Your toggle definitions here
      }
    })
  end,
  keys = {
    { "<leader>tt", function() require('toggle-manager').show_menu() end, desc = "Toggle Menu" },
  },
}
```

## Usage

### Toggle Menu Navigation

- `<LocalLeader>0` (typically `<Space>0`) - Open toggle menu
- **Small letters** (e.g. `d`, `r`, `p`) - Toggle state to next option
- **Capital letters** (e.g. `D`, `R`, `P`) - Toggle lualine display visibility
- `s` - Save current states as defaults
- `ESC` or `q` - Close menu

### Toggle States

Each toggle cycles through its defined states. For example, diagnostics might cycle:
`cursor_only` → `full_with_underline` → `signs_only` → `cursor_only`

## Color Configuration

Toggle-manager supports flexible color definitions:

### Color Definition Options

```lua
colors = {
  -- Option 1: Use existing highlight group names
  'DiagnosticWarn',  -- Uses the fg color from DiagnosticWarn
  
  -- Option 2: Specify fg and/or bg from highlight groups
  { fg = 'Normal', bg = 'Normal' },          -- fg from Normal, bg from Normal
  { fg = '#000000', bg = 'DiagnosticWarn' }, -- literal fg, bg from DiagnosticWarn
  { fg = 'Normal' },                         -- fg from Normal, default bg
  { bg = 'DiagnosticError' },                -- default fg, bg from DiagnosticError
  
  -- Option 3: Direct color values
  { fg = '#ffffff', bg = '#ff0000' },        -- literal white text on red background
}
```

### Smart Color Extraction

- **fg specification**: Uses the foreground color from the specified highlight group
- **bg specification**: Prioritizes background color, falls back to foreground color if bg is not set
- This ensures good contrast and colorscheme compatibility

## Lualine Integration

Add toggle states to your lualine status line:

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      'encoding', 'fileformat', 'filetype',
      -- Toggle component with automatic color handling
      {
        function()
          local ok, toggle = pcall(require, 'toggle-manager')
          if ok and toggle.get_lualine_component then
            local component_fn = toggle.get_lualine_component()
            if type(component_fn) == 'function' then
              return component_fn() or ''
            end
          end
          return ''
        end,
      },
    },
  }
})
```

### Lualine Display Control

- **In toggle menu**: Use capital letters to show/hide each toggle in lualine
- **Colored indicators**: Each visible toggle shows as a colored letter (e.g., `D`, `R`, `P`)
- **Auto-spacing**: First toggle gets proper spacing to prevent color bleeding
- **State-aware colors**: Colors change based on current toggle state

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

### API Methods

```lua
local toggle_manager = require('toggle-manager')

-- Main setup function
toggle_manager.setup({ definitions = {...} })

-- Show toggle menu (main function)
toggle_manager.show_menu()

-- Get lualine component function
local component_fn = toggle_manager.get_lualine_component()

-- For backward compatibility
toggle_manager.show_toggle_menu()  -- alias for show_menu()
```

### Version Migration

**From v1.1.x to v1.2.x:**

- ✅ **API**: `show_toggle_menu()` → `show_menu()` (old name still works)
- ✅ **Colors**: Enhanced color extraction logic (no changes needed)
- ✅ **Config**: Self-contained configuration pattern recommended
- ✅ **Lualine**: Improved spacing and color handling (no changes needed)

## License

Public Domain - Use freely!