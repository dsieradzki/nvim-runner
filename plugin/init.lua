local runner = require("runner")

local function run_task(opts)
	runner.run_task(opts.args)
end

local function run_group(opts)
	runner.run_group(opts.args)
end

local function stop(opts)
	runner.stop(opts.args)
end

vim.api.nvim_create_user_command("RunnerRunGroup", run_group, { nargs = "?" })
vim.api.nvim_create_user_command("RunnerRunTask", run_task, { nargs = "?" })
vim.api.nvim_create_user_command("RunnerList", runner.list, {})
vim.api.nvim_create_user_command("RunnerStop", stop, { nargs = 1 })
vim.api.nvim_create_user_command("RunnerStopAll", runner.stop_all, {})
