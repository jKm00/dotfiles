require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>nh", ":nohl<CR>")

-- window managers
map("n", "<leader>sv", "<C-w>v") -- split vertically
map("n", "<leader>sh", "<C-w>s") -- split horizontally
map("n", "<leader>se", "<C-w>=") -- make windows equal size
map("n", "<leader>sx", ":close<CR>") -- close current split window

map("n", "<leader>to", ":tabnew<CR>") -- open new tab
map("n", "<leader>tx", ":tabclose<CR>") -- close current tab
map("n", "<leader>tn", ":tabn<CR>") -- go to next tab
map("n", "<leader>tp", ":tabp<CR>") -- go to prev tab

-- Function to switch to window containing next/prev buffer if it exists,
-- otherwise switch buffer in a designated "main" window
local main_window = nil
local function smart_buffer_switch(direction)
    -- Get list of valid, listed buffers
    local bufs = vim.api.nvim_list_bufs()
    local valid_bufs = {}
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
            table.insert(valid_bufs, buf)
        end
    end

    -- Find index of current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local current_index = 1
    for i, buf in ipairs(valid_bufs) do
        if buf == current_buf then
            current_index = i
            break
        end
    end

    -- Calculate target buffer index
    local target_index
    if direction == "next" then
        target_index = current_index % #valid_bufs + 1
    else
        target_index = (current_index - 2 + #valid_bufs) % #valid_bufs + 1
    end
    local target_buf = valid_bufs[target_index]

    -- Check if target buffer is visible in any window
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        if vim.api.nvim_win_get_buf(win) == target_buf then
            -- If found, switch to that window
            vim.api.nvim_set_current_win(win)
            return
        end
    end

    -- If target buffer isn't visible in any other window, switch it in the main window
    if not main_window then
        main_window = vim.api.nvim_get_current_win()
    end
    vim.api.nvim_win_set_buf(main_window, target_buf)
    vim.api.nvim_set_current_win(main_window)
end

-- Map tab and shift-tab to smart buffer switching
map("n", "<tab>", function()
    smart_buffer_switch("next")
end, { desc = "Switch to next buffer or focus its window" })

map("n", "<S-tab>", function()
    smart_buffer_switch("prev")
end, { desc = "Switch to previous buffer or focus its window" })
