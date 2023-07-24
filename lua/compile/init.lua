local M = {}
local api = vim.api

local default_options = {
	save_on_compile = false,
	comp_window_height = 20,
	bindings = {
		build = '<C-c><C-b>',
		run   = '<C-c><C-c>',
		test  = '<C-c><C-t>',
	},
	language_commands = {
	},
}

M.options = {}

local function keymap (mode, seq, cmd)
	vim.keymap.set(mode, seq, cmd, {noremap = true, silent = true})
end

function M.get_compile_cmd(kind)
	local ft = vim.bo.filetype

	local buf_cmd = vim.b['compile_cmd_'..kind]
	if buf_cmd then
		return buf_cmd
	end

	local lang_commands = Compile.options.language_commands[ft]

	if lang_commands then
		local lang_cmd = lang_commands[kind]
		if lang_cmd then
			if type(lang_cmd) == 'function' then
				return lang_cmd()
			else
				return lang_cmd
			end
		end
	end

	local global_cmd = vim.g['compile_cmd_'..kind]
	if global_cmd then
		return global_cmd
	end

	api.nvim_notify(("Could not find any compile command for action '%s'"):format(kind), vim.log.levels.ERROR, {})
	return nil
end

local function apply_defaults(opts)
	for key, defval in pairs(default_options) do
		if opts[key] == nil then
			opts[key] = defval
		end
	end
end

local function apply_keymaps()
	local binds = M.options.bindings
	if binds.build then
		keymap('n', binds.build, function() M.compile(M.get_compile_cmd('build')) end)
	end
	if binds.run then
		keymap('n', binds.run, function()
			local cmd = M.get_compile_cmd('run')
			M.compile(cmd)
		end)
	end
	if binds.test then
		keymap('n', binds.test, function() M.compile(M.get_compile_cmd('test')) end)
	end
end

local function make_comp_window(cmd)
	vim.cmd [[topleft split]]
	vim.cmd(('horizontal resize %d'):format(M.options.comp_window_height))
	vim.cmd.terminal(cmd)
	vim.cmd [[normal i]]
end

function M.compile(cmd)
	if cmd then
		if M.options.save_on_compile then
			vim.cmd [[wa!]]
		end
		make_comp_window(cmd)
	end
end

function M.setup(opts)
	if type(opts) ~= 'table' then opts = {} end
	apply_defaults(opts)
	M.options = opts
	apply_keymaps()
	--- Export
	Compile = M
	-- return Compile
end

return M
