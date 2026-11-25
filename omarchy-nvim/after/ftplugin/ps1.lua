-- PowerShell uses % as an alias for ForEach-Object, not as a comment leader.
-- The bundled ftplugin otherwise leaves Neovim's generic :% comment enabled.
vim.bo.comments = "s1:<#,mb:#,ex:#>,b:#"
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setlocal comments<"
