local M = {}

M.palette = {
    red = "#f7768e",
    love = "#eb6f92",
    orange = "#ff9e64",
    yellow = "#e0af68",
    light_green = "#9ece6a",
    green = "#73daca",
    aqua = "#2ac3de",
    teal = "#1abc9c",
    turquoise = "#89ddff",
    light_cyan = "#b4f9f8",
    cyan = "#7dcfff",
    blue = "#7aa2f7",
    purple = "#9d7cd8",
    magenta = "#bb9af7",
    comment = "#565f89",
    black = "#414868",
    add = "#449dab",
    change = "#6183bb",
    delete = "#914c54",
    error = "#db4b4b",
    info = "#0db9d7",
    hint = "#1abc9c",
    fg = "#c0caf5",
    fg_dark = "#a9b1d6",
    fg_gutter = "#3b4261",
    fg_linenr = "#737aa2",
    fg_selected = "#343a55",
    border = "#15161e",
    border_highlight = "#27a1b9",
    bg = "#1a1b26",
    bg_inlay = "#1a2b32",
    bg_selection = "#283457",
    bg_menu = "#16161e",
    bg_focus = "#292e42",
}

local p = M.palette

M.lualine = {
    normal = {
        a = { fg = p.bg, bg = p.blue, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    insert = {
        a = { fg = p.bg, bg = p.light_green, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    visual = {
        a = { fg = p.bg, bg = p.magenta, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    select = {
        a = { fg = p.bg, bg = p.magenta, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    replace = {
        a = { fg = p.bg, bg = p.red, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    command = {
        a = { fg = p.bg, bg = p.orange, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    terminal = {
        a = { fg = p.bg, bg = p.aqua, gui = "bold" },
        b = { fg = p.fg_dark, bg = p.bg_menu },
        c = { fg = p.fg_dark, bg = p.bg_menu },
    },
    inactive = {
        a = { fg = p.fg_gutter, bg = p.bg_menu },
        b = { fg = p.fg_gutter, bg = p.bg_menu },
        c = { fg = p.fg_gutter, bg = p.bg_menu },
    },
}

local function set(name, spec)
    vim.api.nvim_set_hl(0, name, spec)
end

local function link(name, target)
    vim.api.nvim_set_hl(0, name, { link = target })
end

function M.apply()
    vim.cmd.highlight("clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd.syntax("reset")
    end

    vim.o.termguicolors = true
    vim.o.background = "dark"
    vim.g.colors_name = "tokyo_custom"

    -- Editor chrome. Match Helix `ui.background = {}` so the terminal shows through.
    set("Normal", { fg = p.fg, bg = "NONE" })
    set("NormalNC", { fg = p.fg, bg = "NONE" })
    set("MsgArea", { fg = p.fg, bg = "NONE" })
    set("SignColumn", { fg = p.fg_gutter, bg = "NONE" })
    set("FoldColumn", { fg = p.fg_gutter, bg = "NONE" })
    set("EndOfBuffer", { fg = p.fg_gutter, bg = "NONE" })
    set("LineNr", { fg = p.fg_gutter, bg = "NONE" })
    set("LineNrAbove", { fg = p.fg_gutter, bg = "NONE" })
    set("LineNrBelow", { fg = p.fg_gutter, bg = "NONE" })
    set("CursorLineNr", { fg = p.fg_linenr, bg = "NONE" })
    set("CursorLine", { bg = p.bg_menu })
    set("CursorColumn", { bg = p.bg_menu })
    set("ColorColumn", { bg = p.fg_gutter })
    set("Visual", { bg = p.bg_selection })
    set("VisualNOS", { bg = p.bg_selection })
    set("Search", { bg = p.bg_focus })
    set("CurSearch", { fg = p.orange, bold = true })
    set("IncSearch", { fg = p.orange, bold = true })
    set("MatchParen", { fg = p.orange, bold = true })
    set("Whitespace", { fg = p.fg_gutter })
    set("NonText", { fg = p.fg_gutter })
    set("SpecialKey", { fg = p.fg_gutter })
    set("Conceal", { fg = p.comment })
    set("Folded", { fg = p.comment, bg = "NONE", italic = true })
    set("WinSeparator", { fg = p.border, bold = true })
    set("VertSplit", { fg = p.border, bold = true })
    set("StatusLine", { fg = p.fg_dark, bg = p.bg_menu })
    set("StatusLineNC", { fg = p.fg_gutter, bg = p.bg_menu })
    set("WinBar", { fg = p.fg_dark, bg = "NONE" })
    set("WinBarNC", { fg = p.fg_gutter, bg = "NONE" })
    set("TabLine", { fg = p.comment, bg = "NONE" })
    set("TabLineFill", { bg = "NONE" })
    set("TabLineSel", { fg = p.fg, bg = "NONE", underline = true, sp = p.magenta })
    set("Pmenu", { fg = p.fg, bg = p.bg_menu })
    set("PmenuSel", { bg = p.fg_selected })
    set("PmenuSbar", { bg = p.bg_menu })
    set("PmenuThumb", { bg = p.fg_gutter })
    set("PmenuKind", { fg = p.aqua, bg = p.bg_menu })
    set("PmenuExtra", { fg = p.comment, bg = p.bg_menu })
    set("NormalFloat", { fg = p.fg, bg = p.bg_menu })
    set("FloatBorder", { fg = p.border_highlight, bg = p.bg_menu })
    set("FloatTitle", { fg = p.fg, bg = p.bg_menu, bold = true })
    set("Directory", { fg = p.cyan })
    set("Title", { fg = p.blue, bold = true })
    set("Question", { fg = p.aqua })
    set("MoreMsg", { fg = p.aqua })
    set("ModeMsg", { fg = p.fg_dark })
    set("ErrorMsg", { fg = p.error })
    set("WarningMsg", { fg = p.yellow })
    set("QuickFixLine", { bg = p.bg_focus, bold = true })
    set("WildMenu", { bg = p.fg_selected })
    set("Cursor", { reverse = true })
    set("lCursor", { reverse = true })
    set("TermCursor", { reverse = true })

    -- Vim syntax groups, aligned to Helix scopes.
    set("Comment", { fg = p.comment, italic = true })
    set("Constant", { fg = p.orange })
    set("String", { fg = p.light_green })
    set("Character", { fg = p.light_green })
    set("Number", { fg = p.orange })
    set("Boolean", { fg = p.orange })
    set("Float", { fg = p.orange })
    set("Identifier", { fg = p.fg })
    set("Function", { fg = p.love, italic = true })
    set("Statement", { fg = p.purple, italic = true })
    set("Conditional", { fg = p.magenta })
    set("Repeat", { fg = p.magenta })
    set("Label", { fg = p.blue })
    set("Operator", { fg = p.turquoise })
    set("Keyword", { fg = p.purple, italic = true })
    set("Exception", { fg = p.magenta })
    set("PreProc", { fg = p.cyan })
    set("Include", { fg = p.cyan })
    set("Define", { fg = p.cyan })
    set("Macro", { fg = p.cyan })
    set("PreCondit", { fg = p.cyan })
    set("Type", { fg = p.aqua })
    set("StorageClass", { fg = p.purple, italic = true })
    set("Structure", { fg = p.aqua })
    set("Typedef", { fg = p.aqua })
    set("Special", { fg = p.fg })
    set("SpecialChar", { fg = p.magenta })
    set("Tag", { fg = p.magenta })
    set("Delimiter", { fg = p.turquoise })
    set("SpecialComment", { fg = p.yellow })
    set("Debug", { fg = p.orange })
    set("Underlined", { fg = p.blue, underline = true })
    set("Ignore", { fg = p.comment })
    set("Error", { fg = p.error })
    set("Todo", { fg = p.yellow, italic = true })

    set("Added", { fg = p.add })
    set("Changed", { fg = p.change })
    set("Removed", { fg = p.delete })
    set("DiffAdd", { fg = p.add })
    set("DiffChange", { fg = p.change })
    set("DiffDelete", { fg = p.delete })
    set("DiffText", { fg = p.change, bg = p.bg_focus })

    set("DiagnosticError", { fg = p.error })
    set("DiagnosticWarn", { fg = p.yellow })
    set("DiagnosticInfo", { fg = p.info })
    set("DiagnosticHint", { fg = p.hint })
    set("DiagnosticOk", { fg = p.light_green })
    set("DiagnosticUnnecessary", { fg = p.comment })
    set("DiagnosticDeprecated", { strikethrough = true })
    set("DiagnosticUnderlineError", { sp = p.error, undercurl = true })
    set("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
    set("DiagnosticUnderlineInfo", { sp = p.info, undercurl = true })
    set("DiagnosticUnderlineHint", { sp = p.hint, undercurl = true })
    set("DiagnosticUnderlineOk", { sp = p.light_green, undercurl = true })
    set("DiagnosticVirtualTextError", { fg = p.error, bg = "NONE" })
    set("DiagnosticVirtualTextWarn", { fg = p.yellow, bg = "NONE" })
    set("DiagnosticVirtualTextInfo", { fg = p.info, bg = "NONE" })
    set("DiagnosticVirtualTextHint", { fg = p.hint, bg = "NONE" })
    set("LspInlayHint", { fg = p.teal, bg = p.bg_inlay })
    set("LspReferenceText", { bg = p.bg_focus, bold = true })
    set("LspReferenceRead", { bg = p.bg_focus, bold = true })
    set("LspReferenceWrite", { bg = p.bg_focus, bold = true })
    set("LspSignatureActiveParameter", { fg = p.yellow, italic = true })
    set("LspCodeLens", { fg = p.comment, italic = true })

    set("SpellBad", { sp = p.error, undercurl = true })
    set("SpellCap", { sp = p.yellow, undercurl = true })
    set("SpellLocal", { sp = p.info, undercurl = true })
    set("SpellRare", { sp = p.hint, undercurl = true })

    -- Treesitter captures mapped from Helix scopes.
    set("@variable", { fg = p.fg })
    set("@variable.builtin", { fg = p.red })
    set("@variable.parameter", { fg = p.yellow, italic = true })
    set("@variable.parameter.builtin", { fg = p.yellow, italic = true })
    set("@variable.member", { fg = p.green })
    set("@property", { fg = p.green })
    set("@constant", { fg = p.orange })
    set("@constant.builtin", { fg = p.aqua })
    set("@constant.macro", { fg = p.cyan })
    set("@module", { fg = p.cyan })
    set("@module.builtin", { fg = p.cyan })
    set("@label", { fg = p.blue })
    set("@string", { fg = p.light_green })
    set("@string.documentation", { fg = p.yellow })
    set("@string.regexp", { fg = p.light_cyan })
    set("@string.escape", { fg = p.magenta })
    set("@string.special", { fg = p.aqua })
    set("@string.special.symbol", { fg = p.aqua })
    set("@string.special.url", { fg = p.blue, underline = true })
    set("@string.special.path", { fg = p.aqua })
    set("@character", { fg = p.light_green })
    set("@character.special", { fg = p.magenta })
    set("@boolean", { fg = p.orange })
    set("@number", { fg = p.orange })
    set("@number.float", { fg = p.orange })
    set("@type", { fg = p.aqua })
    set("@type.builtin", { fg = p.aqua })
    set("@type.definition", { fg = p.aqua })
    set("@attribute", { fg = p.cyan })
    set("@attribute.builtin", { fg = p.cyan })
    set("@function", { fg = p.love, italic = true })
    set("@function.call", { fg = p.love, italic = true })
    set("@function.builtin", { fg = p.aqua })
    set("@function.macro", { fg = p.cyan })
    set("@function.method", { fg = p.love, italic = true })
    set("@function.method.call", { fg = p.love, italic = true })
    set("@constructor", { fg = p.aqua })
    set("@operator", { fg = p.turquoise })
    set("@keyword", { fg = p.purple, italic = true })
    set("@keyword.coroutine", { fg = p.magenta })
    set("@keyword.function", { fg = p.magenta })
    set("@keyword.operator", { fg = p.magenta })
    set("@keyword.import", { fg = p.cyan })
    set("@keyword.type", { fg = p.purple, italic = true })
    set("@keyword.modifier", { fg = p.purple, italic = true })
    set("@keyword.repeat", { fg = p.magenta })
    set("@keyword.return", { fg = p.purple, italic = true })
    set("@keyword.debug", { fg = p.orange })
    set("@keyword.exception", { fg = p.magenta })
    set("@keyword.conditional", { fg = p.magenta })
    set("@keyword.conditional.ternary", { fg = p.magenta })
    set("@keyword.directive", { fg = p.cyan })
    set("@keyword.directive.define", { fg = p.cyan })
    set("@punctuation", { fg = p.turquoise })
    set("@punctuation.delimiter", { fg = p.turquoise })
    set("@punctuation.bracket", { fg = p.turquoise })
    set("@punctuation.special", { fg = p.fg })
    set("@comment", { fg = p.comment, italic = true })
    set("@comment.documentation", { fg = p.yellow })
    set("@comment.error", { fg = p.error })
    set("@comment.warning", { fg = p.yellow })
    set("@comment.todo", { fg = p.orange, italic = true })
    set("@comment.note", { fg = p.info })
    set("@markup.strong", { bold = true })
    set("@markup.italic", { italic = true })
    set("@markup.strikethrough", { strikethrough = true })
    set("@markup.underline", { underline = true })
    set("@markup.heading", { fg = p.blue, bold = true })
    set("@markup.heading.1", { fg = p.blue, bold = true })
    set("@markup.heading.2", { fg = p.blue, bold = true })
    set("@markup.heading.3", { fg = p.blue, bold = true })
    set("@markup.heading.4", { fg = p.blue, bold = true })
    set("@markup.heading.5", { fg = p.blue, bold = true })
    set("@markup.heading.6", { fg = p.blue, bold = true })
    set("@markup.quote", { fg = p.fg_dark, italic = true })
    set("@markup.math", { fg = p.aqua })
    set("@markup.link", { fg = p.blue, underline = true })
    set("@markup.link.label", { fg = p.teal })
    set("@markup.link.url", { underline = true })
    set("@markup.raw", { fg = p.teal })
    set("@markup.raw.block", { fg = p.teal })
    set("@markup.list", { fg = p.orange, bold = true })
    set("@markup.list.checked", { fg = p.light_green })
    set("@markup.list.unchecked", { fg = p.orange, bold = true })
    set("@diff.plus", { fg = p.add })
    set("@diff.minus", { fg = p.delete })
    set("@diff.delta", { fg = p.change })
    set("@tag", { fg = p.magenta })
    set("@tag.builtin", { fg = p.magenta })
    set("@tag.attribute", { fg = p.cyan })
    set("@tag.delimiter", { fg = p.turquoise })

    link("@lsp.type.class", "@type")
    link("@lsp.type.comment", "@comment")
    link("@lsp.type.decorator", "@attribute")
    link("@lsp.type.enum", "@type")
    link("@lsp.type.enumMember", "@constant")
    link("@lsp.type.event", "@function")
    link("@lsp.type.function", "@function")
    link("@lsp.type.interface", "@type")
    link("@lsp.type.keyword", "@keyword")
    link("@lsp.type.macro", "@function.macro")
    link("@lsp.type.method", "@function.method")
    link("@lsp.type.modifier", "@keyword.modifier")
    link("@lsp.type.namespace", "@module")
    link("@lsp.type.number", "@number")
    link("@lsp.type.operator", "@operator")
    link("@lsp.type.parameter", "@variable.parameter")
    link("@lsp.type.property", "@variable.member")
    link("@lsp.type.regexp", "@string.regexp")
    link("@lsp.type.string", "@string")
    link("@lsp.type.struct", "@type")
    link("@lsp.type.type", "@type")
    link("@lsp.type.typeParameter", "@type")
    link("@lsp.type.variable", "@variable")
    link("@lsp.typemod.function.defaultLibrary", "@function.builtin")
    link("@lsp.typemod.variable.defaultLibrary", "@variable.builtin")
    set("@lsp.mod.deprecated", { strikethrough = true })

    link("netrwDir", "Directory")
    link("netrwClassify", "Directory")
    link("netrwExe", "Function")
    link("netrwSymLink", "Operator")
    link("OilDir", "Directory")
    link("OilDirIcon", "Directory")
    link("OilSocket", "Keyword")
    link("OilLink", "Operator")
    link("OilLinkTarget", "Comment")
    link("OilFile", "Normal")
    link("OilCreate", "DiffAdd")
    link("OilDelete", "DiffDelete")
    link("OilMove", "DiffChange")
    link("OilCopy", "DiffAdd")
    link("OilChange", "DiffChange")
    link("WhichKey", "NormalFloat")
    link("WhichKeyBorder", "FloatBorder")
    link("WhichKeyNormal", "NormalFloat")
    link("HlSearchNear", "IncSearch")
    link("HlSearchLens", "Comment")
    link("HlSearchLensNear", "IncSearch")
end

return M
