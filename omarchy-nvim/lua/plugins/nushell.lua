return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nu" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nushell = {
          -- Nushell ships its language server; use the installed nu executable.
          mason = false,
          cmd = { "nu", "--lsp" },
        },
      },
    },
  },
}
