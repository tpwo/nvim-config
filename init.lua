vim.o.number = true
vim.o.relativenumber = false
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.winborder = 'solid'
vim.o.termguicolors = true

-- Ask instead of failing e.g. when quiting from a file with unsaved changes
vim.o.confirm = true

-- Insert spaces when pressing a tab
vim.o.expandtab = true
-- Set how many columns are used to render a tab
vim.o.tabstop = 4
-- Reuse tabstop value
vim.o.shiftwidth = 0
-- Reuse shiftwidth value
vim.o.softtabstop = -1

vim.o.smartindent = true

vim.o.wrap = false

-- Now <C-E> and <C-Y> scroll by a single *screen line* (like <gj> and <gk>)
-- if soft wrap is on.
vim.o.smoothscroll = true

-- Enable spell check
vim.o.spelllang = 'en_us,pl'
vim.o.spell = true

-- Auto-complete phrases with `-`
vim.opt.iskeyword:append '-'

vim.o.list = true
-- NOTE: vim.opt has to be used for listchars
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Save undo history and disable swapfiles and backups
-- Undos are by default saved in `~/.local/state/nvim/undo`
-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false

vim.g.mapleader = ' '

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Build telescope-fzf-native automatically

local function build_fzf(ev)
  if ev.data.spec.name ~= 'telescope-fzf-native.nvim' then return end

  if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

  vim.system({ 'make' }, { cwd = ev.data.path })
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = build_fzf,
})

vim.pack.add {
  -- Telescope with its deps and recommended fzf-native plugin
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },

  { src = 'https://github.com/christoomey/vim-tmux-navigator' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/j-hui/fidget.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/mbbill/undotree' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-mini/mini.statusline', version = 'stable' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/stevearc/oil.nvim' },

  { src = 'https://github.com/folke/tokyonight.nvim' },
}

require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
  },
}

vim.keymap.set('n', '<leader>f', function() require('conform').format { async = true, lsp_fallback = true } end, { desc = 'Format buffer' })

-- ensure basic parser are installed
local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- check if parser exists and load it
  if not vim.treesitter.language.add(language) then return end
  -- enables syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- enables treesitter based folds
  -- for more info on folds see `:help folds`
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- check if treesitter indentation is available for this language, and if so enable it
  -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

  -- enables treesitter based indentation
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      -- enable the parser if it is installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})

require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function() gitsigns.diffthis '@' end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git hunk [Q]uickfix list (all files in repo)' })
    map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)' })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff' })

    -- Text object
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
  end,
}

-- Set mapped sequence wait time
vim.o.timeoutlen = 300

vim.keymap.set('n', '<leader>?', ':WhichKey<CR>')

require('which-key').setup {
  delay = 0,
  spec = {
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
require('fidget').setup()
require('mason').setup()
require('mini.statusline').setup { use_icons = false }
require('oil').setup()
require('todo-comments').setup { signs = false }

-- Telescope

require('telescope').setup {
  extensions = {
    fzf = {},
  },
}
pcall(require('telescope').load_extension, 'fzf')

-- Telescope pickers

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

vim.keymap.set('n', '<leader>sf', function() builtin.find_files { hidden = false } end, { desc = '[S]earch [F]iles' })

-- Search in files including hidden and gitignored
vim.keymap.set(
  'n',
  '<leader>sF',
  function()
    builtin.find_files {
      hidden = true,
      no_ignore = true,
      no_ignore_parent = true,
    }
  end,
  { desc = '[S]earch [F]iles (Hidden)' }
)

-- Search in files including hidden and gitignored
vim.keymap.set(
  'n',
  '<leader>sA',
  function()
    builtin.find_files {
      hidden = true,
      no_ignore = true,
      no_ignore_parent = true,
    }
  end,
  { desc = '[S]earch *[A]ll* files' }
)

vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

vim.keymap.set('n', '<leader>sg', function()
  builtin.live_grep {
    additional_args = function()
      -- Pass rgrip options here
      return { '--hidden' }
    end,
  }
end, { desc = '[S]earch by [G]rep' })

vim.keymap.set('n', '<leader>sd', function()
  builtin.diagnostics {
    root_dir = vim.fn.getcwd(),
  }
end, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
-- it is better explained there). This allows easily switching between pickers if you prefer using something else!
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    -- This is where a variable was first declared, or where a function is defined, etc.
    -- To jump back, press <C-t>.
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    -- Symbols are things like variables, functions, types, etc.
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    -- Similar to document symbols, except searches over your entire project.
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    -- Useful when you're not sure what type a variable is and you want to see
    -- the definition of its *type*, not where it was *defined*.
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

-- Toggle pickers
vim.keymap.set('n', '<leader>tf', builtin.filetypes, { desc = '[T]oggle [F]iletype' })

-- Git pickers

-- Helper function checking if we're in a Git repo. Without it, telescope Git pickers fail with a loud error
local function require_git_repo(fn)
  return function()
    local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
    if git_root == '' then
      vim.notify('Not in a git repository', vim.log.levels.ERROR)
      return
    end
    fn()
  end
end

vim.keymap.set('n', '<leader>gs', require_git_repo(builtin.git_status), { desc = '[G]it [S]tatus' })

vim.keymap.set(
  'n',
  '<leader>gf',
  require_git_repo(
    function()
      builtin.find_files {
        prompt_title = 'Git Files',
        find_command = {
          'git',
          'ls-files',
          '--exclude-standard',
          '--cached',
          vim.fn.getcwd(),
        },
      }
    end
  ),
  { desc = '[G]it [F]iles' }
)

vim.keymap.set('n', '<leader>gF', require_git_repo(builtin.git_files), { desc = '[G]it [F]iles (All)' })

vim.keymap.set('n', '<leader>gb', require_git_repo(builtin.git_branches), { desc = '[G]it [B]ranches' })

-- TODO: I want to see commit author and date in this output
vim.keymap.set('n', '<leader>gc', require_git_repo(builtin.git_commits), { desc = '[G]it [C]ommits' })

vim.keymap.set(
  'n',
  '<leader>gh',
  require_git_repo(function() builtin.git_bcommits { prompt_title = 'Git File History' } end),
  { desc = '[G]it file [H]istory' }
)

vim.keymap.set(
  'n',
  '<leader>gl',
  require_git_repo(function() builtin.git_bcommits_range { prompt_title = 'Git Line History' } end),
  { desc = '[G]it [L]ine history' }
)

-- Dotfiles picker
-- Configured to work with: https://github.com/tpwo/dotfiles
vim.keymap.set(
  'n',
  '<leader>sD',
  function()
    builtin.find_files {
      prompt_title = 'Dotfiles',
      cwd = vim.fn.expand '~/ws/private/repos/tpwo/dotfiles/dotfiles',
      find_command = {
        'git',
        'ls-files',
        '--exclude-standard',
        '--cached',
      },
    }
  end,
  { desc = '[S]earch [D]otfiles' }
)

-- End of Telescope pickers

-- Disable showmode, as statusline contains it
vim.o.showmode = false

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method 'textDocument/completion' then vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true }) end
  end,
})
vim.cmd 'set completeopt+=noselect'

-- Remember that you have to install below LSPs manually (easiest way is to use :Mason)
vim.lsp.enable { 'lua_ls', 'pyright' }

vim.cmd.colorscheme 'tokyonight'

vim.keymap.set('n', '<leader>e', ':Oil<CR>')
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- When joining lines in normal mode with J make cursor stay where it is
vim.keymap.set('n', 'J', 'mzJ`z')

vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste not overwriting the register' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[D]elete into void register' })

vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[R]eplace-All for word under cursor' })

-- Keep system and vim clipboard separate, and only interact via:
-- - copy into the clipboard with <leader>y/Y
-- - paste from the clipboard with <Cmd+v> (MacOs) / <Ctrl+v>
-- vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[Y]ank into clipboard' })
-- vim.keymap.set('n', '<leader>Y', '"+Y', { desc = '[Y]ank into clipboard' })

vim.filetype.add {
  pattern = {
    ['.bash.*'] = 'sh',
  },
}

-- Use tabs instead of spaces in Makefiles and Justfiles
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'make', 'just' },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.softtabstop = 0
  end,
})

-- Use 2 spaces for indenting JS and TS files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript' },
  callback = function() vim.opt_local.tabstop = 2 end,
})

-- Break lines and keep words together
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'asciidoc', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
