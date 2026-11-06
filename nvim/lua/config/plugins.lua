require("vim._core.ui2").enable({})

require("nvim-treesitter").setup()
require("nvim-treesitter").install({
    "bash",
    "json",
    "markdown",
    "markdown_inline",
    "nu",
    "odin",
    "rust",
    "toml",
    "yaml",
})

vim.treesitter.language.register("json", "jsonl")

vim.api.nvim_create_autocmd("FileType", {
    callback = function(event)
        pcall(vim.treesitter.start, event.buf)
    end,
})

require("blink.cmp").setup({
    keymap = { preset = "default" },
    cmdline = {
        completion = {
            menu = { auto_show = true },
        },
    },
    fuzzy = { implementation = "prefer_rust" },
})

require("tiny-cmdline").setup({
    on_reposition = require("tiny-cmdline").adapters.blink,
})

require("lualine").setup({
    options = {
        theme = "tokyo_custom",
    },
})
require("modicator").setup()

require("treesj").setup({
    use_default_keymaps = false,
})

require("hlslens").setup()
require("chainsaw").setup()
require("tabout").setup()

local function topiary_formatter(language)
    return {
        command = "topiary",
        args = { "format", "--language", language },
    }
end

require("conform").setup({
    formatters_by_ft = {
        bash = { "topiary_bash" },
        sh = { "topiary_bash" },
        json = { "topiary_json" },
        jsonl = { "jq_jsonl" },
        markdown = { "mdformat" },
        nu = { "topiary_nu" },
        odin = { "odinfmt" },
        rust = { "rustfmt" },
        toml = { "topiary_toml" },
        -- yaml and yaml.ansible intentionally have no formatter.
    },
    formatters = {
        topiary_bash = topiary_formatter("bash"),
        topiary_json = topiary_formatter("json"),
        topiary_nu = topiary_formatter("nu"),
        topiary_toml = topiary_formatter("toml"),
        jq_jsonl = {
            command = "jq",
            args = { "-c", "." },
        },
    },
    format_after_save = function(bufnr)
        if vim.tbl_isempty(require("conform").list_formatters(bufnr)) then
            return
        end

        return { timeout_ms = 15000 }
    end,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

require("lint").linters_by_ft = {
    bash = { "shellcheck" },
    sh = { "shellcheck" },
    yaml = { "yamllint" },
    ["yaml.docker-compose"] = { "yamllint" },
    ["yaml.gitlab"] = { "yamllint" },
    ["yaml.helm-values"] = { "yamllint" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

require("trouble").setup({
    focus = true,
})

require("telescope").setup({
    extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown() },
    },
})
pcall(require("telescope").load_extension, "ui-select")

require("oil").setup({
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
        show_hidden = true,
    },
    float = {
        padding = 2,
        max_width = 0.8,
        max_height = 0.8,
        border = "rounded",
        win_options = {
            winblend = 10,
        },
    },
    keymaps = {
        ["<CR>"] = { "actions.select", opts = { close = true } },
        ["q"] = { "actions.close", mode = "n" },
        ["<Esc>"] = { "actions.close", mode = "n" },
    },
})

require("which-key").setup({
    spec = {
        { "<leader>f", desc = "File explorer" },
        { "<leader>F", desc = "Format buffer" },
        { "<leader>y", desc = "Yank to system clipboard", mode = { "n", "x" } },
        { "<leader>q", desc = "Open diagnostic [Q]uickfix list" },
        { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
        { "<leader>l", group = "log" },
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer local keymaps",
        },
    },
})
