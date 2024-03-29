local function run_task(opts)
	require("runner").run_task(opts.args)
end

local function run_group(opts)
	require("runner").run_group(opts.args)
end

local function stop(opts)
	require("runner").stop(opts.args)
end
local function list()
	local result = require("runner").list()

	if #result == 0 then
		vim.notify("There is no running tasks", vim.log.levels.INFO)
		return nil
	end
	for _, task in ipairs(result) do
		vim.notify("[" .. task.task_id .. "] " .. task.task_def.name, vim.log.levels.INFO)
	end
end

vim.api.nvim_create_user_command("RunnerRunGroup", run_group, { nargs = "?" })
vim.api.nvim_create_user_command("RunnerRunTask", run_task, { nargs = "?" })
vim.api.nvim_create_user_command("RunnerList", list, {})
vim.api.nvim_create_user_command("RunnerStop", stop, { nargs = 1 })
vim.api.nvim_create_user_command("RunnerStopAll", require("runner").stop_all, {})
