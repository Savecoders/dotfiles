return {
	{
		"lukas-reineke/virt-column.nvim",
		opts = {
		  char = { "┆" },
		  virtcolumn = "80",
		  highlight = { "NonText" },
		}
	  },
	  {
		"folke/noice.nvim",
		enabled = false,
	  },
	  {
		"j-hui/fidget.nvim",
		opts = {
		  notification = {
			window = {
			  winblend = 0,
			  border = "rounded",
			},
		  },
		},
	  },
	  {
		"rcarriga/nvim-notify",
		opts = {
		  timeout = 500,
		  render = "compact",
		  max_height = function()
			return math.floor(vim.o.lines * 0.75)
		  end,
		  max_width = function()
			return math.floor(vim.o.columns * 0.25)
		  end,
		  on_open = function(win)
			vim.api.nvim_win_set_config(win, { zindex = 100 })
		  end,
		},
	  },
	  -- filename
	  {
		"b0o/incline.nvim",
		event = "BufReadPre",
		priority = 1200,
		config = function()
		  require("incline").setup({
			highlight = {
			  groups = {
				InclineNormal = { guibg = "#303270", guifg = "#a9b1d6" },
				InclineNormalNC = { guibg = "none", guifg = "#a9b1d6" },
			  },
			},
			window = { margin = { vertical = 0, horizontal = 1 } },
			hide = { cursorline = true },
			render = function(props)
			  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
			  if vim.bo[props.buf].modified then
				filename = "[*]" .. filename
			  end
	
			  local icon, color = require("nvim-web-devicons").get_icon_color(filename)
	
			  return { { icon, guifg = color }, { " " }, { filename } }
			end,
		  })
		end,
	  },
	
	  -- bufferline
	  {
		"akinsho/bufferline.nvim",
		opts = {
		  options = {
			mode = "tabs",
			show_buffer_close_icons = false,
			show_close_icon = false,
		  },
		},
	  },
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		keys = {
			{

				"<leader>d",
				"<cmd>NvimTreeClose<cr><cmd>tabnew<cr><bar><bar><cmd>DBUI<cr>",
			},
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")

					local function opts(desc)
						return {
							desc = "nvim-tree: " .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true,
						}
					end

					-- default mappings
					api.config.mappings.default_on_attach(bufnr)

					-- custom mappings
					vim.keymap.set("n", "t", api.node.open.tab, opts("Tab"))
				end,
				actions = {
					open_file = {
						quit_on_open = true,
					},
				},
				sort = {
					sorter = "case_sensitive",
				},
				view = {
					width = 30,
					relativenumber = true,
				},
				renderer = {
					group_empty = true,
				},
				filters = {
					dotfiles = true,
					custom = {
						"node_modules/.*",
					},
				},
				log = {
					enable = true,
					truncate = true,
					types = {
						diagnostics = true,
						git = true,
						profile = true,
						watcher = true,
					},
				},
			})

			if vim.fn.argc(-1) == 0 then
				vim.cmd("NvimTreeFocus")
			end
		end,
	},
}