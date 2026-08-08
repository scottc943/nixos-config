return {
  formatters_by_ft = {
    lua = {
      "stylua",
    },

    javascript = {
      "prettier",
    },

    javascriptreact = {
      "prettier",
    },

    typescript = {
      "prettier",
    },

    typescriptreact = {
      "prettier",
    },

    html = {
      "prettier",
    },

    css = {
      "prettier",
    },

    json = {
      "prettier",
    },

    python = {
      "ruff_format",
    },

    go = {
      "gofumpt",
    },

    c = {
      "clang_format",
    },

    cpp = {
      "clang_format",
    },

    rust = {
      "rustfmt",
    },
  },

  format_on_save = {
    timeout_ms = 1500,
    lsp_format = "fallback",
  },
}
