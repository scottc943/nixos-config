return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",

    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",

    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "go",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "python",
        "rust",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
      },
    },
  },
}
