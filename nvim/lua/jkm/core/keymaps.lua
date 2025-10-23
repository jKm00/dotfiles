vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tabs
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Prev tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "New tab with current buffer" })

-- Buffer
keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Collapsing
keymap.set("n", "<leader>fc", "zc", { desc = "Close fold" })
keymap.set("n", "<leader>fo", "zo", { desc = "Open fold" })
keymap.set("n", "<leader>ff", "za", { desc = "Toggle fold" })
keymap.set("n", "<leader>fa", "zM", { desc = "Close all folds" })
keymap.set("n", "<leader>fz", "zR", { desc = "Open all folds" })
