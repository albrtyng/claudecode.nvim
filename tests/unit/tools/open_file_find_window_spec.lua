-- luacheck: globals expect
require("tests.busted_setup")

describe("open_file._find_main_editor_window", function()
  local find_main_editor_window

  before_each(function()
    -- Reset mock state
    _G.vim._mock.reset()

    -- Clear cached module
    package.loaded["claudecode.tools.open_file"] = nil

    find_main_editor_window = require("claudecode.tools.open_file")._find_main_editor_window
  end)

  it("should return a normal editor window", function()
    _G.vim._mock.add_window(1000, 1, { name = "/home/user/file.lua" })

    local result = find_main_editor_window()
    expect(result).to_be(1000)
  end)

  it("should skip snacks_picker_list windows", function()
    _G.vim._mock.add_window(1000, 1, {
      buf_options = { filetype = "snacks_picker_list" },
    })
    _G.vim._mock.add_window(1001, 2, { name = "/home/user/file.lua" })

    local result = find_main_editor_window()
    expect(result).to_be(1001)
  end)

  it("should return nil when no suitable window exists", function()
    _G.vim._mock.add_window(1000, 1, {
      buf_options = { buftype = "terminal" },
    })
    _G.vim._mock.add_window(1001, 2, {
      win_config = { relative = "editor" },
    })

    local result = find_main_editor_window()
    expect(result).to_be_nil()
  end)
end)
