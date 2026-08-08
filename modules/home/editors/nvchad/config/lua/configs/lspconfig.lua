-- Load NvChad's default LSP behavior first.
require("nvchad.configs.lspconfig").defaults()

-- Every server in this list is installed through Nix rather than Mason.
--
-- This keeps the actual language-server binaries reproducible and
-- available directly from PATH.
local servers = {
  -- Lua / NvChad
  "lua_ls",

  -- React / JavaScript / TypeScript
  "html",
  "cssls",
  "ts_ls",

  -- Python
  "pyright",

  -- Go
  "gopls",

  -- C / C++
  "clangd",

  -- Rust
  "rust_analyzer",

  -- Java
  "jdtls",
}

vim.lsp.enable(servers)
