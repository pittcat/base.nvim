-- spec/log_spec.lua
-- Base.nvim 日志系统测试

describe("base.nvim logging", function()
  local log

  before_each(function()
    -- 重新加载日志模块以确保测试隔离
    package.loaded['base.logger'] = nil
    log = require('base.logger')
  end)

  it("should load logger module without errors", function()
    assert.is_not_nil(log)
    assert.is_function(log.info)
    assert.is_function(log.warn)
    assert.is_function(log.error)
    assert.is_function(log.debug)
    assert.is_function(log.trace)
    assert.is_function(log.fatal)
  end)

  it("should log at different levels without errors", function()
    assert.has_no.errors(function()
      log.trace("trace message")
      log.debug("debug message")
      log.info("info message")
      log.warn("warn message")
      log.error("error message")
      log.fatal("fatal message")
    end)
  end)

  it("should support formatted logging", function()
    assert.has_no.errors(function()
      log.fmt_info("User %s has %d items", "alice", 42)
      log.fmt_warn("Warning: %s", "something happened")
      log.fmt_error("Error code: %d, message: %s", 404, "Not found")
    end)
  end)

  it("should support structured logging", function()
    assert.has_no.errors(function()
      log.structured("info", "user_action", {
        action = "file_open",
        file = "test.lua",
        duration_ms = 45
      })
    end)
  end)

  it("should handle various data types", function()
    assert.has_no.errors(function()
      log.info("String message")
      log.info("Number:", 42)
      log.info("Boolean:", true)
      log.info("Table:", {a = 1, b = 2})
      log.info("Nil value:", nil)
    end)
  end)

  it("should work with multiple arguments", function()
    assert.has_no.errors(function()
      log.info("Processing", "user_input", "with", "multiple", "arguments")
      log.warn("Warning:", "config_key", "is missing")
      log.error("Failed to connect:", "connection_error", "timeout")
    end)
  end)
end)

describe("base.nvim main module with logging", function()
  local base

  before_each(function()
    -- 重新加载模块
    package.loaded['base.init'] = nil
    package.loaded['base.config'] = nil
    package.loaded['base.logger'] = nil
    base = require('base')
  end)

  it("should expose log interface", function()
    assert.is_not_nil(base.log)
    assert.is_function(base.log.info)
    assert.is_function(base.log.error)
  end)

  it("should setup with logging", function()
    assert.has_no.errors(function()
      local result = base.setup({
        name = "Test User",
        log = {
          level = "debug",
          use_console = false,
          use_file = false
        }
      })
      assert.is_true(result)
    end)
  end)

  it("should handle setup errors gracefully", function()
    -- 模拟配置错误
    assert.has_no.errors(function()
      local result = base.setup(nil)
      assert.is_true(result)
    end)
  end)

  it("should log during hello/bye operations", function()
    assert.has_no.errors(function()
      base.setup({ name = "Test User" })
      local hello_msg = base.hello()
      local bye_msg = base.bye()
      
      assert.is_string(hello_msg)
      assert.is_string(bye_msg)
      assert.match("Hello Test User", hello_msg)
      assert.match("Bye Test User", bye_msg)
    end)
  end)
end)