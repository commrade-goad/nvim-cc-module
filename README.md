# NVIM-CC-MODULE
a simple module that enable better compile command stuff for neovim

## USAGE
### CONFIGURATION AND DESC
- this module will add couple of function    

| Name                            | Desc                                                                                                |
|---------------------------------|-----------------------------------------------------------------------------------------------------|
| change_auto_read(boolean)       | change how it will behave when new selected buffer detected (default = false)                       |
| set_compile_command_from_file() | automatically read a file called ``nvim-cc.txt`` in the current buffer path with removing ``/src/`` |
| input_compile_command()         | ask the user about what will the compile command would be                                           |
| run_compile_command()           | running the compile command specified with vsplit and terminal window                               |
| run_compile_command_silent()    | running the compile command specified with the default ``:!``                                       |
| sync_directory_to_buffer()      | will set the current buffer path to the cwd                                                         |

- Example Usage:
- ``$PATH_TO_NVIM_CONF/lua/keys.lua``
```lua
local nvim_cc = require('nvim-cc')

-- your other config

vim.keymap.set("n", "<leader>cc", function() nvim_cc.input_compile_command() end)
vim.keymap.set("n", "<leader>cC", function() nvim_cc.run_compile_command() end)
vim.keymap.set("n", "<leader>cs", function() nvim_cc.run_compile_command_silent() end)
vim.keymap.set("n", "<leader>sd", function() nvim_cc.sync_directory_to_buffer() end)
vim.keymap.set("n", "<leader>cS", function() nvim_cc.set_compile_command_from_file() end)

-- your other config

```

- ``$PROJECT_PATH/nvim-cc.txt``
```sh
cargo run
```

## NOTE
this is not a plugin but just a simple module
