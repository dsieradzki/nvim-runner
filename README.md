# Introduction
This is experimental plugin for running generic tasks with definition saved in working directory. I have created this plugin to help create background processes during development like database, backend, frontend.

# Installation
lazy.nvim
```lua
{
    'dsieradzki/nvim-runner'
}
```

# Commands

- RunnerRunGroup [group name]
- RunnerRunTask [task name]
- RunnerList
- RunnerStop <task name>
- RunnerStopAll

# Example tasks.lua
```lua
return {
	default_group = "dev",
	default_task = "backend",
	groups = {
		{
			name = "dev",
			tasks = { "database", "backend", "frontend" },
		},
	},
	tasks = {
		{
			name = "database",
			exec = "make dev.db",
			keep_output = false,
		},
		{
			name = "backend",
			exec = "cargo watch -x run",
			working_dir = "server/web-api",
		},
		{
			name = "frontend",
			exec = "pnpm run dev",
			working_dir = "web",
		},
	},
}
```