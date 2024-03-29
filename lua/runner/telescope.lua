local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local runner = require("runner")

local tasks = function(opts)
	opts = opts or {}

	-- Set default telescope theme
	-- FIXME: User cannot set own telescope theme.
	opts = vim.tbl_extend("error", opts, require("telescope.themes").get_dropdown({}))

	pickers
		.new(opts, {
			prompt_title = "Tasks",
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

return {
	register_extension = function()
		local ext = require("telescope").register_extension({
			exports = {
				runner = tasks,
			},
		})

		require("telescope").extensions["runner"] = ext.exports
	end,
}
