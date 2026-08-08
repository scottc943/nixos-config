require "nvchad.mappings"

local map = vim.keymap.set

-- Convenient NvChad starter mappings.
map("n", ";", ":", {
  desc = "Enter command mode",
})

map("i", "jk", "<ESC>", {
  desc = "Exit insert mode",
})
