local M = {}

-- Accept either the bundle root or its PowerShellEditorServices directory.
local function find_services(directory)
    for _, script in ipairs({
        directory .. "/PowerShellEditorServices/Start-EditorServices.ps1",
        directory .. "/Start-EditorServices.ps1",
    }) do
        if vim.fn.filereadable(script) == 1 then
            local service_dir = vim.fs.dirname(script)
            return vim.fs.dirname(service_dir), script
        end
    end
end

function M.discover()
    local pwsh = vim.fn.exepath("pwsh")
    if pwsh == "" then
        return nil, "pwsh is not on PATH"
    end

    local override = vim.env.POWERSHELL_EDITOR_SERVICES_PATH
    local candidates = {
        "/opt/powershell-editor-services/current",
        "/opt/powershell-editor-services",
        "/usr/share/powershell-editor-services",
        "/usr/lib/powershell-editor-services",
        vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    }
    -- An explicit override is authoritative: report mistakes instead of silently
    -- starting a different installation.
    if override and override ~= "" then
        candidates = { override }
    end
    for _, directory in ipairs(candidates) do
        local bundle, script = find_services(directory:gsub("/+$", ""))
        if bundle then
            return { pwsh = pwsh, bundle = bundle, script = script }
        end
    end
    return nil, "Editor Services not found; set POWERSHELL_EDITOR_SERVICES_PATH to its bundle or PowerShellEditorServices directory"
end

return M
