local recent_wins = {}
local seen_wins = {}
local restoring_win = false

local function is_normal_win(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ""
end

local function remember_win(win)
    if restoring_win or not is_normal_win(win) then
        return
    end

    for i = #recent_wins, 1, -1 do
        if recent_wins[i].win == win then
            table.remove(recent_wins, i)
        end
    end

    table.insert(recent_wins, {
        win = win,
        tab = vim.api.nvim_win_get_tabpage(win),
    })
end

local function prune_wins(closed)
    local closed_tab
    seen_wins[closed] = nil
    for i = #recent_wins, 1, -1 do
        local entry = recent_wins[i]
        if entry.win == closed then
            closed_tab = entry.tab
            table.remove(recent_wins, i)
        elseif not vim.api.nvim_win_is_valid(entry.win) then
            seen_wins[entry.win] = nil
            table.remove(recent_wins, i)
        end
    end
    return closed_tab
end

local function split_and_focus(command)
    return function()
        local existing = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if is_normal_win(win) then
                existing[win] = true
            end
        end

        local count = vim.v.count
        if count > 0 then
            vim.cmd(count .. command)
        else
            vim.cmd(command)
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if is_normal_win(win) and not existing[win] then
                vim.api.nvim_set_current_win(win)
                return
            end
        end
    end
end

vim.keymap.set("n", "<C-w>v", split_and_focus("vsplit"), { desc = "Vertical split and focus new window" })
vim.keymap.set("n", "<C-w><C-v>", split_and_focus("vsplit"), { desc = "Vertical split and focus new window" })
vim.keymap.set("n", "<C-w>s", split_and_focus("split"), { desc = "Horizontal split and focus new window" })
vim.keymap.set("n", "<C-w><C-s>", split_and_focus("split"), { desc = "Horizontal split and focus new window" })

local function previous_win_in_tab(tab)
    for i = #recent_wins, 1, -1 do
        local entry = recent_wins[i]
        if entry.tab == tab and vim.api.nvim_win_is_valid(entry.win) then
            return entry.win
        end
    end
end

local function mark_existing_wins()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        seen_wins[win] = true
    end
end

local window_focus_group = vim.api.nvim_create_augroup("window-focus-history", { clear = true })

vim.api.nvim_create_autocmd("WinNew", {
    group = window_focus_group,
    callback = function()
        local new_wins = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if not seen_wins[win] then
                seen_wins[win] = true
                table.insert(new_wins, win)
            end
        end

        if restoring_win then
            return
        end

        vim.schedule(function()
            if restoring_win then
                return
            end

            local current = vim.api.nvim_get_current_win()
            if vim.tbl_contains(new_wins, current) and is_normal_win(current) then
                return
            end

            local newest
            for _, win in ipairs(new_wins) do
                if is_normal_win(win) and (newest == nil or win > newest) then
                    newest = win
                end
            end

            if newest then
                pcall(vim.api.nvim_set_current_win, newest)
            end
        end)
    end,
})

vim.api.nvim_create_autocmd("WinEnter", {
    group = window_focus_group,
    callback = function()
        remember_win(vim.api.nvim_get_current_win())
    end,
})

vim.api.nvim_create_autocmd("WinClosed", {
    group = window_focus_group,
    callback = function(event)
        local closed = tonumber(event.match)
        local latest = recent_wins[#recent_wins]
        local closing_active = latest ~= nil and latest.win == closed
        local closed_tab = prune_wins(closed)
        if not closing_active or closed_tab == nil or closed_tab ~= vim.api.nvim_get_current_tabpage() then
            return
        end

        local prev = previous_win_in_tab(closed_tab)
        if not prev then
            return
        end

        restoring_win = true
        vim.schedule(function()
            if vim.api.nvim_win_is_valid(prev) then
                pcall(vim.api.nvim_set_current_win, prev)
            end
            restoring_win = false
        end)
    end,
})

mark_existing_wins()
remember_win(vim.api.nvim_get_current_win())

local hlslens_opts = { noremap = true, silent = true }

vim.keymap.set(
    "n",
    "n",
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    hlslens_opts
)
vim.keymap.set(
    "n",
    "N",
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    hlslens_opts
)
vim.keymap.set("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], hlslens_opts)
vim.keymap.set("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], hlslens_opts)
vim.keymap.set("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], hlslens_opts)
vim.keymap.set("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], hlslens_opts)

vim.keymap.set("n", "<leader>f", function()
    require("oil").toggle_float()
end, { desc = "File explorer" })

vim.keymap.set({ "n", "x" }, "<leader>F", function()
    require("conform").format({ async = true })
end, { desc = "Format buffer" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

vim.keymap.set(
    "n",
    "<leader>q",
    "<Cmd>Trouble diagnostics toggle focus=true<CR>",
    { desc = "Open diagnostic [Q]uickfix list" }
)

local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", telescope_builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", telescope_builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", telescope_builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", telescope_builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set({ "n", "v" }, "<leader>sw", telescope_builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", telescope_builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", telescope_builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", telescope_builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", telescope_builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader>sc", telescope_builtin.commands, { desc = "[S]earch [C]ommands" })
vim.keymap.set("n", "<leader><leader>", telescope_builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
    telescope_builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>s/", function()
    telescope_builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
    })
end, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>sn", function()
    telescope_builtin.find_files({ cwd = vim.fn.stdpath("config"), follow = true })
end, { desc = "[S]earch [N]eovim files" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
    callback = function(event)
        local buf = event.buf
        vim.keymap.set("n", "grr", telescope_builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
        vim.keymap.set(
            "n",
            "gri",
            telescope_builtin.lsp_implementations,
            { buffer = buf, desc = "[G]oto [I]mplementation" }
        )
        vim.keymap.set("n", "grd", telescope_builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
        vim.keymap.set(
            "n",
            "gO",
            telescope_builtin.lsp_document_symbols,
            { buffer = buf, desc = "Open Document Symbols" }
        )
        vim.keymap.set(
            "n",
            "gW",
            telescope_builtin.lsp_dynamic_workspace_symbols,
            { buffer = buf, desc = "Open Workspace Symbols" }
        )
        vim.keymap.set(
            "n",
            "grt",
            telescope_builtin.lsp_type_definitions,
            { buffer = buf, desc = "[G]oto [T]ype Definition" }
        )
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({
                border = "rounded",
                title = "Hover",
            })
        end, { buffer = buf, desc = "Hover documentation" })
    end,
})

vim.keymap.set("n", "<leader>m", function()
    require("treesj").toggle()
end, { desc = "Split or join treesitter node" })

vim.keymap.set({ "n", "x" }, "<leader>lg", function()
    require("chainsaw").variableLog()
end, { desc = "Log variable under cursor" })
