# nvim-config

My config for Neovim 0.12+ which uses native vim.pack plugin manager.

Run `:PackUpdate` to update plugins. Their versions are stored in [nvim-pack-lock.json](nvim-pack-lock.json).

The [justfile](justfile) provides helper commands: run `just` to list them, `just pre-commit` to run pre-commit hooks on all files, or `just updatePlugins` to update Neovim plugins.
