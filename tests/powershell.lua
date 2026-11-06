-- Run from the workspace root:
-- nvim --headless -u NONE -i NONE -l nier-deploy/tests/powershell.lua
local root = vim.fn.fnamemodify(arg[0], ":p:h:h") .. "/nvim"
package.path = root .. "/lua/?.lua;" .. package.path
local discover = require("config.powershell").discover
local executable = "/custom path/pwsh"
local readable = {}
vim.fn.exepath = function(name)
    assert(name == "pwsh")
    return executable
end
vim.fn.filereadable = function(path)
    return readable[path] and 1 or 0
end
vim.env.POWERSHELL_EDITOR_SERVICES_PATH = nil
executable = ""
local result, reason = discover()
assert(result == nil and reason:find("PATH"))
executable = "/custom path/pwsh"
result, reason = discover()
assert(result == nil and reason:find("Editor Services"))
local default = "/opt/powershell-editor-services/current"
readable[default .. "/PowerShellEditorServices/Start-EditorServices.ps1"] = true
result = assert(discover())
assert(result.pwsh == executable and result.bundle == default)
vim.env.POWERSHELL_EDITOR_SERVICES_PATH = "/custom services"
result = discover()
assert(result == nil, "Invalid override must not fall back")
readable["/custom services/PowerShellEditorServices/Start-EditorServices.ps1"] = true
result = assert(discover())
assert(result.bundle == "/custom services")
assert(result.script == "/custom services/PowerShellEditorServices/Start-EditorServices.ps1")
vim.env.POWERSHELL_EDITOR_SERVICES_PATH = "/custom services/PowerShellEditorServices/"
assert(assert(discover()).bundle == "/custom services")
vim.env.POWERSHELL_EDITOR_SERVICES_PATH = nil
readable = {
    [vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1"] = true,
}
assert(assert(discover()).bundle:find("mason/packages/powershell%-editor%-services$"))

-- Verify that discovery controls server registration and its final arguments.
local configs, enabled, warning
local function run_config()
    configs, enabled = {}, {}
    vim.lsp.config = function(name, config) configs[name] = config end
    vim.lsp.enable = function(names)
        if type(names) == "string" then names = { names } end
        for _, name in ipairs(names) do enabled[name] = true end
    end
    vim.notify = function(message) warning = message end
    dofile(root .. "/lua/config/lsp.lua")
end
run_config()
assert(enabled.powershell_es and configs.powershell_es.cmd[1] == executable)
assert(configs.powershell_es.cmd[5]:find("Start%-EditorServices.ps1$"))
executable = ""
run_config()
assert(not enabled.powershell_es and not configs.powershell_es)
assert(enabled.lua_ls and enabled.rust_analyzer)
vim.api.nvim_exec_autocmds("FileType", { pattern = "ps1" })
assert(warning:find("PowerShell LSP disabled"))
warning = nil
vim.api.nvim_exec_autocmds("FileType", { pattern = "ps1" })
assert(warning == nil, "Warn only once per session")
print("PASS: PATH, missing dependencies, overrides, paths with spaces, Mason, LSP arguments and one-time warning")
