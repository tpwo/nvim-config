# print this help message
help:
	just -l

# run pre-commit
pre-commit:
	pre-commit run --all-files

# update Neovim plugins
updatePlugins:
	nvim -c 'lua vim.pack.update()'
