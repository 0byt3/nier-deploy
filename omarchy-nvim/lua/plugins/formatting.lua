return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        nu = { "nufmt" },
      },
      formatters = {
        shfmt = {
          args = { "-filename", "$FILENAME", "-i", "4" },
        },
      },
    },
  },
}
