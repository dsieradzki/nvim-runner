# Introduction
This is experimental plugin for running generic tasks with definition saved in working directory. I have created this plugin to help create background processes during development like database, backend, frontend.

# Installation
lazy.nvim
```lua
  {
    'dsieradzki/nvim-runner',
    
    dependencies = {
      -- Only when telescope integration is enabled
      'nvim-telescope/telescope.nvim', -- optional

      -- Only when you want to use which-key in mappings in example below
      'folke/which-key.nvim', -- optional
    },
    config = function()
      require('runner').setup {
        --true|false(default): When integration with telescope is enabled, buffer is not shown on buffer list, unless task finish with error, or keep output is enabled in task, then buffer is unhidden
        telescope = true,
      }

      -- Example mappings, before apply check are not conflicting with your current mappints
      require('which-key').register {
        ['<leader>m'] = { name = 'Task runner', _ = 'which_key_ignore' },
      }
      vim.keymap.set('n', '<leader>mr', ':Telescope runner run_task<CR>', { desc = '[R]un task', silent = true })
      vim.keymap.set('n', '<leader>mg', ':Telescope runner run_group<CR>', { desc = 'Run [G]roup of tasks', silent = true })
      vim.keymap.set('n', '<leader>ml', ':Telescope runner list<CR>', { desc = '[L]ist running tasks', silent = true })
      vim.keymap.set('n', '<leader>ms', ':Telescope runner stop<CR>', { desc = '[S]op task', silent = true })
      vim.keymap.set('n', '<leader>mS', ':RunnerStopAll<CR>', { desc = '[S]op all tasks', silent = true })
    end,
  },
```

# Commands
- RunnerRunGroup [group name]
- RunnerRunTask [task name]
- RunnerList
- RunnerStop <task name>
- RunnerStopAll

# Telescope (when telescope integration is enabed)
- Telescope runner list
- Telescope runner run_task
- Telescope runner run_group
- Telescope runner stop

# Example: tasks.lua
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
