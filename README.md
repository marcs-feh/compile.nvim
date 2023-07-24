# compile.nvim

This is quite similar to Emacs' `compile-mode` although much simpler.

`compile.nvim` allows you to specify specific commands/lua functions to
compile, run and test software in your favorite language.

## Configuring

```lua

--- These are the default options! feel free to just use an empty table here, or just override the ones you need
require 'compile'.setup{
    save_on_compile = false,
    comp_window_height = 20,
    bindings = {
        build = '<C-c><C-b>',
        run   = '<C-c><C-c>',
        test  = '<C-c><C-t>',
    },
    language_commands = {},
}
```

## Language Commands

These are the commands that will be searched for the 3 actions the plugin provides:

- `run`: build and run
- `build`: only build
- `test`: build and run test

The command is either a string or a lua function, if it is a function it is run
and its return type (must be a string) is used as a command. The plugin has the
following search order for its compile_command:

1. Buffer local: `b:compile_cmd_X='my command'` where `X` is either `run`, `build` or `test`
2. Plugin table: This is the `language_commands` table, this should be your preferred method of setting commands
3. Global: `g:compile_cmd_X='my command'` where `X` is either `run`, `build` or `test`

```lua
local get_comp_cmd_c = function(sub_cmd)
    local cmd = 'make'
    -- Use neovim's API to explore filesystem and discover
    -- the type of project, this is just a lua function feel
    -- free to do as you wish. Here we will assume a simple Makefile
    -- as an example
	cmd = ('%s %s'):format(cmd, sub_cmd)
    return cmd
end

require 'compile'.setup {
    language_commands = {
        ['odin'] = {
            build = 'odin build .',
            run = 'odin run .',
            test = 'odin test .',
        },
        ['zig'] = {
            build = 'zig build',
            run = 'zig build run',
            test = 'zig build test',
        },
        ['c'] = {
            build = function() return get_comp_cmd_c('all') end,
            run = function() return get_comp_cmd_c('run') end,
            test = function() return get_comp_cmd_c('test') end,
        },
    },
}
```

### Advanced example
