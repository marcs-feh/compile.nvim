local M = {}

local default_options = {
	save_on_compile = false,
	comp_window_height = 20,
	language_commands = { },
	bindings = {
		build = '<C-c><C-b>',
		run = '<C-c><C-c>',
		test = '<C-c><C-t>',
	},
}

local options = {}

local function keymap (mode, seq, cmd)
	vim.keymap.set(mode, seq, cmd, {noremap = true, silent = true})
end

local function apply_defaults(opts)
	for key, defval in pairs(default_options) do
		if opts[key] == nil then
			opts[key] = defval
		end
	end
end

local function apply_keymaps()
	local binds = options.bindings
	if binds.build then
		keymap('n', binds.build, function() M.compile(0, 'build') end)
	end
	if binds.run then
		keymap('n', binds.run, function() M.compile(0, 'run') end)
	end
	if binds.test then
		keymap('n', binds.test, function() M.compile(0, 'test') end)
	end
end

function M.setup(opts)
	if type(opts) ~= 'table' then opts = {} end
	apply_defaults(opts)
	options = opts
	apply_keymaps()
end

local function make_comp_window(cmd)
	if options.save_on_compile then
		vim.cmd [[wa!]]
	end
	vim.cmd [[topleft split]]
	vim.cmd(('horizontal resize %d'):format(options.comp_window_height))
	vim.cmd.terminal('echo '..cmd)
	vim.cmd [[normal i]]
end

function M.compile(bufnum, cmd)
	make_comp_window(cmd)
end

return M
