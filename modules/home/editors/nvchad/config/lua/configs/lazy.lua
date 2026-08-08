return {
  defaults = {
    lazy = true,
  },

  install = {
    colorscheme = {
      "nvchad",
    },
  },

  change_detection = {
    notify = false,
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrw",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
