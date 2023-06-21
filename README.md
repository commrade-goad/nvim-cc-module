# NVIM-CC-MODULE
a simple module that enable better compile command stuff for neovim

## USAGE
### INSTALLING
```lua
local nvim_cc = require('nvim-cc')
```
### CONFIGURATION AND DESC
- this module will add couple of function    

| Name                            | Desc                                                                                                |
|---------------------------------|-----------------------------------------------------------------------------------------------------|
| change_auto_read(boolean)       | change how it will behave when new selected buffer detected (default = false)                       |
| set_compile_command_from_file() | automatically read a file called ``nvim-cc.txt`` in the current buffer path with removing ``/src/`` |
| input_compile_command()         | ask the user about what will the compile command would be                                           |
| run_compile_command()           | running the compile command specified with vsplit and terminal window                               |
| run_compile_command_silent()    | running the compile command specified with the default ``:!``                                       |
| sync_directory_to_buffer()      | will set the current buffer path to the cwd and automatically read ``nvim-cc.txt``                  |

- Example:
```lua
vim.api.nvim_set_keymap("n", "<leader>cc", function() nvim_cc.input_compile_command() end)
```

## NOTE
this is not a plugin but just a simple module
