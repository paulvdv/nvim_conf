local api = vim.api
local lsp = vim.lsp
local fn = vim.fn
local o = vim.o


local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed
    }
  end
end

local function lsp_name()
  local msg = ""
  local buf_ft = api.nvim_buf_get_option(0, "filetype")
  local clients = lsp.get_active_clients()
  if next(clients) == nil then
    return msg
  end
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and fn.index(filetypes, buf_ft) ~= -1 then
      return client.name
    end
  end
  return msg
end

local mode_symbols = {
  ["n"] = "",
  ["no"] = "*",
  ["nov"] = "*",
  ["noV"] = "*",
  ["no"] = "*",
  ["niI"] = "*",
  ["niR"] = "*",
  ["niV"] = "*",
  ["v"] = "",
  ["V"] = "- ",
  [""] = " ",
  ["s"] = "",
  ["S"] = " -",
  [""] = " ",
  ["i"] = "",
  ["ic"] = "",
  ["ix"] = "",
  ["R"] = "屢",
  ["Rc"] = "屢",
  ["Rv"] = "屢",
  ["Rx"] = "屢",
  ["c"] = "",
  ["cv"] = "",
  ["ce"] = "",
  ["r"] = "屢",
  ["rm"] = "ﱟ",
  ["r?"] = "",
  ["!"] = "",
  ["t"] = "",
  ["nt"] = "",
}


local separators = {
  none = { left = "", right = "" },
  arrow = { left = "", right = "" },
  bubble = { left = "", right = "" },
  slant = { left = "", right = "" },
}

local components = {
  buffers = { "buffers", mode = 0, show_filename_only = true, max_length = o.columns },
  encoding = { "o:encoding", fmt = string.upper },
  filename = { "filename", path = 1 },
  location = {
    "location",
    padding = { left = 2, right = 0 },
    separator = { right = separators.bubble.left }
  },
  progress = { "progress" },
  tabs = { "tabs", mode = 0 },
  mode = {
    function()
      local mode_code = api.nvim_get_mode().mode
      if mode_symbols[mode_code] == nil then
        return mode_code
      end
      return mode_symbols[mode_code]
    end,
    separator = { left = separators.bubble.right },
    padding = { left = 0, right = 2 },
  },

  diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic", "coc" },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
  },
  branch = {
    "b:gitsigns_head",
    icons_enabled = true,
    icon = "",
  },
  diff = {
    "diff",
    source = diff_source,
    symbols = { added = " ", modified = " ", removed = " " },
    color = {},
  },
  filetype = { "filetype", icon_only = true, colored = false },
  treesitter = {
    function()
      local b = api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then
        return ""
      end
      return ""
    end,
  },
}

local lualine_ok, lualine = pcall(require, "lualine")
if not lualine_ok then
  return
end

-- define how the statusline and tabline appear
lualine.setup({
  options = {
    theme = "dracula",
    icons_enabled = true,
    component_separators = "|",
    section_separators = separators.bubble,
    disabled_filetypes = { "dashboard", "NvimTree", "Outline" },
    symbols = { modified = " ", readonly = " " },
  },
  sections = {
    lualine_a = {
      components.mode
    },
    lualine_b = {
      components.filename,
      components.diff,
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      components.diagnostics,
      -- components.treesitter,
      components.branch,
      {
        lsp_name,
        icon = "",
      },
    },
    lualine_z = {
      components.location
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      components.filename,
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = {},
    lualine_b = { components.buffers },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { components.tabs },
    lualine_z = {},
  },
  extensions = { "nvim-tree" },
})
