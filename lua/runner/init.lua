local M = {}

-- TODO: Integrate star command with telescope
-- TODO: Integrate stop command with telescope

---@alias buffer number: Buffer number
-----------------------------------------------------
--      [[ tasks.lua data type definition ]]
---@class TasksDef
---@field default_group string | nil: Default group to execute
---@field default_task string | nil: Default task to execute
---@field groups GroupDef[]: Array of groups
---@field tasks TaskDef[]: Array of tasks

---@class TaskDef
---@field name string: Name of the task
---@field exec string: Command to execute
---@field keep_output boolean: By default buffer associaded with tash will be deleted, to keep output set this to true
---@field working_dir string: Working directory for executed command, if path starts with "/" then is treated as a absolute path.

---@class GroupDef
---@field name string: Group name of tasks
---@field tasks string[]: Tasks to execute for given group
-----------------------------------------------------

---@class Task
---@field task_id integer: Task id
---@field buf_id buffer: Buffer number
---@field task_def TaskDef: Task definition

---@param buf buffer
---@param data string[]
local function add_to_buffer(buf, data)
	local count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, count, -1, false, data)
end

---@param task_id number
local function delete_task(task_id)
	for idx, task in ipairs(M._tasks) do
		if task.task_id == task_id then
			table.remove(M._tasks, idx)
			return
		end
	end
end

---@param task_def TaskDef
---@return Task | nil
local function run_task(task_def)
	if task_def.exec == nil or string.len(task_def.exec) == 0 then
		vim.notify("Exec cannot be empty", vim.log.levels.ERROR)
		return nil
	end
	if task_def.name == nil or string.len(task_def.name) == 0 then
		vim.notify("Name cannot be empty", vim.log.levels.ERROR)
		return nil
	end

	local buf_id = nil
	local target_buf_name = "Task: " .. task_def.name

	-- Searching for exising buffer with name
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_get_name(buf) == vim.loop.cwd() .. "/" .. target_buf_name then
			buf_id = buf
		end
	end

	-- Create new buffer if not exists
	if not buf_id then
		buf_id = vim.api.nvim_create_buf(not M._opts.telescope, true)
		if buf_id == 0 then
			vim.notify("Cannot create buffer", vim.log.levels.ERROR)
			return nil
		end
		vim.api.nvim_buf_set_name(buf_id, target_buf_name)
	end

	-- Configure working direcory for command
	local cwd = nil
	if task_def.working_dir and #task_def.working_dir > 0 then
		if task_def.working_dir:find("^/") == 1 then
			cwd = task_def.working_dir
		else
			cwd = vim.loop.cwd() .. "/" .. task_def.working_dir
		end
		if not vim.loop.fs_stat(cwd) then
			vim.notify("Working dir [" .. cwd .. "] not exists", vim.log.levels.ERROR)
			return
		end
	end

	local task_id = vim.fn.jobstart(task_def.exec, {
		stdout_buffered = false,
		stderr_buffered = false,
		cwd = cwd,
		on_start = function() end,
		on_exit = function(channel, status)
			if status == 0 and not task_def.keep_output then
				vim.api.nvim_buf_delete(buf_id, { force = true })
			end
			vim.api.nvim_buf_set_option(buf_id, "buflisted", true)
			delete_task(channel)
			vim.notify("Task [" .. task_def.name .. "] is finished.", vim.log.levels.INFO)
		end,
		on_stdout = function(_, data)
			if data then
				add_to_buffer(buf_id, data)
			end
		end,

		on_stderr = function(_, data)
			if data then
				add_to_buffer(buf_id, data)
			end
		end,
	})
	if task_id == 0 then
		vim.notify("Invalid arguments", vim.log.levels.ERROR)
	end
	if task_id == -1 then
		vim.notify("Path is not executable", vim.log.levels.ERROR)
	end
	if task_id > 0 then
		---@type Task
		local task = {
			task_id = task_id,
			buf_id = buf_id,
			task_def = task_def,
		}
		table.insert(M._tasks, task)
		vim.notify("Job [" .. task_def.name .. "] has been started.", vim.log.levels.INFO)
		return task
	end
	return nil
end

---@return TasksDef | nil
local function load_tasks_file()
	local tasks_path = vim.loop.cwd() .. "/tasks.lua"
	local stat = vim.loop.fs_stat(tasks_path)
	local exists = stat and stat.type == "file"
	if exists then
		return dofile(tasks_path)
	else
		return nil
	end
end
---@type Task[]
M._tasks = {}

---@param task_name string
M.run_task = function(task_name)
	local tasks_def = load_tasks_file()

	if not tasks_def then
		vim.notify("tasks.lua doesn't exists", vim.log.levels.ERROR)
		return
	end

	---@type string
	local task_name_to_run

	if task_name and #task_name > 0 then
		task_name_to_run = task_name
	elseif tasks_def.default_task then
		task_name_to_run = tasks_def.default_task
	else
		vim.notify("Task name is required", vim.log.levels.ERROR)
		return
	end

	for _, running_tasks in ipairs(M._tasks) do
		if running_tasks.task_def.name == task_name_to_run then
			vim.notify("Task [" .. task_name_to_run .. "] is already running", vim.log.levels.WARN)
			return
		end
	end

	for _, task_to_create in ipairs(tasks_def.tasks) do
		if task_to_create.name == task_name_to_run then
			run_task(task_to_create)
			return
		end
	end
	vim.notify("Task with name [" .. task_name_to_run .. "] doesn't exists", vim.log.levels.ERROR)
end

---@param group_name string
M.run_group = function(group_name)
	local tasks_def = load_tasks_file()
	if not tasks_def then
		vim.notify("tasks.lua doesn't exists", vim.log.levels.ERROR)
		return
	end

	local group_name_to_run
	if group_name and #group_name > 0 then
		group_name_to_run = group_name
	elseif tasks_def.default_group then
		group_name_to_run = tasks_def.default_group
	else
		vim.notify("Group name is required", vim.log.levels.ERROR)
		return
	end

	local tasks_to_run = {}

	for _, group in ipairs(tasks_def.groups) do
		if group_name_to_run == group.name then
			tasks_to_run = group.tasks
		end
	end

	for _, task_name in ipairs(tasks_to_run) do
		M.run_task(task_name)
	end
	vim.notify("All tasks from group [" .. group_name_to_run .. "] has been started", vim.log.levels.INFO)
end

---@param task_name string
M.stop = function(task_name)
	if not task_name then
		vim.notify("Task name is required", vim.log.levels.ERROR)
		return
	end

	for _, stored_task in ipairs(M._tasks) do
		if stored_task.task_def.name == task_name then
			vim.fn.jobstop(stored_task.task_id)
			return
		end
	end
end

M.stop_all = function()
	for _, task in ipairs(M._tasks) do
		vim.notify("Requesting to stop task: [" .. task.task_def.name .. "]", vim.log.levels.INFO)
		vim.fn.jobstop(task.task_id)
	end
	-- Clean tasks
	for k, _ in pairs(M._tasks) do
		M._tasks[k] = nil
	end

	vim.notify("All tasks has been stopped", vim.log.levels.INFO)
end

---@return Task[]
M.list = function()
	return M._tasks or {}
end

---@return TaskDef[] | nil
M.list_all_tasks = function()
	return load_tasks_file().tasks
end

---@return GroupDef[] | nil
M.list_all_groups = function()
	return load_tasks_file().groups
end

---@class Config
---@field telescope boolean: If true telescope integration will be enabled

---@param opts Config
M.setup = function(opts)
	M._opts = opts
	if opts.telescope then
		require("runner.telescope").register_extension()
	end
end
return M
