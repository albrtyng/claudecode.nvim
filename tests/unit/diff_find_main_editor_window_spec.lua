-- luacheck: globals expect
require("tests.busted_setup")

describe("diff._find_main_editor_window", function()
  local diff

  before_each(function()
    -- Reset mock state
    _G.vim._mock.reset()

    -- Clear cached modules
    package.loaded["claudecode.diff"] = nil
    package.loaded["claudecode.config"] = nil

    diff = require("claudecode.diff")
  end)

  it("should return a normal editor window", function()
    _G.vim._mock.add_window(1000, 1, { name = "/home/user/file.lua" })

    local result = diff._find_main_editor_window()
    expect(result).to_be(1000)
  end)

  it("should return nil when no suitable window exists", function()
    _G.vim._mock.add_window(1000, 1, {
      buf_options = { buftype = "terminal" },
    })
    _G.vim._mock.add_window(1001, 2, {
      buf_options = { filetype = "neo-tree" },
    })
    _G.vim._mock.add_window(1002, 3, {
      win_config = { relative = "editor" },
    })

    local result = diff._find_main_editor_window()
    expect(result).to_be_nil()
  end)

  it("should skip windows with snacks_win variable (picker preview)", function()
    -- Snacks picker preview window: has a real filetype (e.g. "lua") but
    -- Snacks sets the snacks_win window variable on it.
    _G.vim._mock.add_window(1000, 1, {
      name = "/home/user/file.lua",
      buf_options = { filetype = "lua" },
      win_vars = { snacks_win = true },
    })
    _G.vim._mock.add_window(1001, 2, { name = "/home/user/other.lua" })

    local result = diff._find_main_editor_window()
    expect(result).to_be(1001)
  end)

  it("should return nil when only Snacks-managed and terminal windows exist", function()
    -- Snacks picker preview (has snacks_win)
    _G.vim._mock.add_window(1000, 1, {
      name = "/home/user/file.lua",
      buf_options = { filetype = "lua" },
      win_vars = { snacks_win = true },
    })
    -- Snacks picker list (filetype)
    _G.vim._mock.add_window(1001, 2, {
      buf_options = { filetype = "snacks_picker_list" },
    })
    -- Terminal window
    _G.vim._mock.add_window(1002, 3, {
      buf_options = { buftype = "terminal" },
    })

    local result = diff._find_main_editor_window()
    expect(result).to_be_nil()
  end)

  it("should pick the real editor in a combined Snacks picker scenario", function()
    -- Snacks picker input (floating)
    _G.vim._mock.add_window(1000, 1, {
      buf_options = { filetype = "snacks_picker_input" },
      win_config = { relative = "editor" },
      win_vars = { snacks_win = true },
    })
    -- Snacks picker list (filetype + snacks_win)
    _G.vim._mock.add_window(1001, 2, {
      buf_options = { filetype = "snacks_picker_list" },
      win_vars = { snacks_win = true },
    })
    -- Snacks picker preview (real filetype, has snacks_win)
    _G.vim._mock.add_window(1002, 3, {
      name = "/home/user/previewed.lua",
      buf_options = { filetype = "lua" },
      win_vars = { snacks_win = true },
    })
    -- Real editor window
    _G.vim._mock.add_window(1003, 4, {
      name = "/home/user/real_editor.lua",
      buf_options = { filetype = "lua" },
    })
    -- Terminal window
    _G.vim._mock.add_window(1004, 5, {
      buf_options = { buftype = "terminal" },
    })

    local result = diff._find_main_editor_window()
    expect(result).to_be(1003)
  end)
end)
