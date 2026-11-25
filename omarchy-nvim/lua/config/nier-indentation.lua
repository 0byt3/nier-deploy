-- Default indentation; filetype settings, EditorConfig, and formatters may override it.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Keep each language's indentexpr. Where a filetype only enables smartindent,
-- use cindent so existing auto-paired closing braces are dedented correctly.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nier_fallback_indentation", { clear = true }),
    callback = function(event)
        local options = vim.bo[event.buf]
        if options.indentexpr == "" and options.smartindent then
            options.smartindent = false
            options.cindent = true
            vim.b[event.buf].undo_indent = (vim.b[event.buf].undo_indent or "")
                .. " | setlocal cindent< smartindent<"
        end
    end,
})
