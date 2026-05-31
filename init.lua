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

vim.pack.add({
    { src = 'https://github.com/christoomey/vim-tmux-navigator' },
    { src = 'https://github.com/folke/tokyonight.nvim' },
    { src = 'https://github.com/folke/which-key.nvim' },
    { src = 'https://github.com/j-hui/fidget.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mbbill/undotree' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-mini/mini.pick',           version = 'stable' },
    { src = 'https://github.com/nvim-mini/mini.statusline',     version = 'stable' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/folke/todo-comments.nvim' },
})

-- Set mapped sequence wait time
vim.o.timeoutlen = 300

vim.keymap.set('n', '<leader>?', ":WhichKey<CR>")

require('which-key').setup({
    delay = 0,
    spec = {
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
    }
})
require('fidget').setup()
require('mason').setup()
require('mini.statusline').setup({ use_icons = false })
require('oil').setup()
require('todo-comments').setup({ signs = false })

require('mini.pick').setup()
local builtin = require('mini.pick').builtin

vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Pick open [B]uffers' })
vim.keymap.set('n', '<leader>f', builtin.files, { desc = 'Pick [F]iles' })
vim.keymap.set('n', '<leader>h', builtin.help, { desc = 'Pick [H]elp' })
vim.keymap.set('n', '<leader>g', builtin.grep_live, { desc = 'Pick [G]rep' })

-- Disable showmode, as statusline contains it
vim.o.showmode = false

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})
vim.cmd('set completeopt+=noselect')

vim.lsp.enable({ 'lua_ls' })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.cmd.colorscheme('tokyonight')

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
    virtual_text = true,   -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = { float = true },
}

vim.keymap.set('n', '<leader>Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- When joining lines in normal mode with J make cursor stay where it is
vim.keymap.set('n', 'J', 'mzJ`z')

vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste not overwriting the register' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[D]elete into void register' })

vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = '[R]eplace-All for word under cursor' })

-- Keep system and vim clipboard separate, and only interact via:
-- - copy into the clipboard with <leader>y/Y
-- - paste from the clipboard with <Cmd+v> (MacOs) / <Ctrl+v>
-- vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = '[Y]ank into clipboard' })
-- vim.keymap.set('n', '<leader>Y', '"+Y', { desc = '[Y]ank into clipboard' })

vim.filetype.add {
    pattern = {
        ['.bash.*'] = 'sh',
    }
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
    callback = function()
        vim.opt_local.tabstop = 2
    end,
})

-- Break lines and keep words together
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'asciidoc', 'markdown' },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})
