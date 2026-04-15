return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({})

    -- Telescope integration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
      }):find()
    end

    -- Keymaps (using <leader>m for harpoon "marks/menu")
    vim.keymap.set("n", "<leader>ma", function()
      harpoon:list():add()
    end, { desc = "Harpoon: Add file" })

    vim.keymap.set("n", "<leader>mm", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon: Open menu (Telescope)" })

    vim.keymap.set("n", "<leader>mr", function()
      harpoon:list():remove()
    end, { desc = "Harpoon: Remove file" })

    -- Quick file selection (1-9)
    vim.keymap.set("n", "<leader>m1", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon: File 1" })

    vim.keymap.set("n", "<leader>m2", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon: File 2" })

    vim.keymap.set("n", "<leader>m3", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon: File 3" })

    vim.keymap.set("n", "<leader>m4", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon: File 4" })

    vim.keymap.set("n", "<leader>m5", function()
      harpoon:list():select(5)
    end, { desc = "Harpoon: File 5" })

    vim.keymap.set("n", "<leader>m6", function()
      harpoon:list():select(6)
    end, { desc = "Harpoon: File 6" })

    vim.keymap.set("n", "<leader>m7", function()
      harpoon:list():select(7)
    end, { desc = "Harpoon: File 7" })

    vim.keymap.set("n", "<leader>m8", function()
      harpoon:list():select(8)
    end, { desc = "Harpoon: File 8" })

    vim.keymap.set("n", "<leader>m9", function()
      harpoon:list():select(9)
    end, { desc = "Harpoon: File 9" })

    -- Navigate prev/next
    vim.keymap.set("n", "<leader>mp", function()
      harpoon:list():prev()
    end, { desc = "Harpoon: Previous" })

    vim.keymap.set("n", "<leader>mn", function()
      harpoon:list():next()
    end, { desc = "Harpoon: Next" })
  end,
}
