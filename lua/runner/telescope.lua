local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local list = function(opts)
	opts = opts or {}

	-- Set default telescope theme
	-- FIXME: User cannot set own telescope theme.
	opts = vim.tbl_extend("error", opts, require("telescope.themes").get_dropdown({}))

	local runner = require("runner")
	pickers
		.new(opts, {
			prompt_title = "Running tasks",
			finder = finders.new_table({
				results = runner.list(),
				entry_maker = function(entry)
					return {
						value = entry.buf_id,
						display = entry.task_def.name,
						ordinal = entry.task_def.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local win = vim.api.nvim_get_current_win()
					vim.api.nvim_win_set_buf(win, selection.value)
				end)
				return true
			end,
		})
		:find()
end

local run_task = function(opts)
	opts = opts or {}

	-- Set default telescope theme
	-- FIXME: User cannot set own telescope theme.
	opts = vim.tbl_extend("error", opts, require("telescope.themes").get_dropdown({}))

	local runner = require("runner")
	pickers
		.new(opts, {
			prompt_title = "Run task",
			finder = finders.new_table({
				results = runner.list_all_tasks(),
				entry_maker = function(entry)
					return {
						value = entry.name,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					runner.run_task(selection.value)
				end)
				return true
			end,
		})
		:find()
end

local run_group = function(opts)
	opts = opts or {}

	-- Set default telescope theme
	-- FIXME: User cannot set own telescope theme.
	opts = vim.tbl_extend("error", opts, require("telescope.themes").get_dropdown({}))

	local runner = require("runner")
	pickers
		.new(opts, {
			prompt_title = "Run group of tasks",
			finder = finders.new_table({
				results = runner.list_all_groups(),
				entry_maker = function(entry)
					return {
						value = entry.name,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					runner.run_group(selection.value)
				end)
				return true
			end,
		})
		:find()
end

local stop_task = function(opts)
	opts = opts or {}

	-- Set default telescope theme
	-- FIXME: User cannot set own telescope theme.
	opts = vim.tbl_extend("error", opts, require("telescope.themes").get_dropdown({}))

	local runner = require("runner")
	pickers
		.new(opts, {
			prompt_title = "Stop task",
			finder = finders.new_table({
				results = runner.list(),
				entry_maker = function(entry)
					return {
						value = entry.task_def.name,
						display = entry.task_def.name,
						ordinal = entry.task_def.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					runner.stop(selection.value)
				end)
				return true
			end,
		})
		:find()
end

return {
	register_extension = function()
		local ext = require("telescope").register_extension({
			exports = {
				list = list,
				run_task = run_task,
				run_group = run_group,
				stop = stop_task,
				runner = list,
			},
		})

		require("telescope").extensions["runner"] = ext.exports
	end,
}
