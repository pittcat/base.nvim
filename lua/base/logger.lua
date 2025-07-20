-- lua/base/logger.lua
-- Base.nvim 日志系统包装器
local vlog = require('base.log')

-- 创建 base.nvim 专用的日志实例
local log = vlog.new {
  plugin = 'base.nvim',
  use_console = true,
  highlights = true,
  use_file = true,
  level = vim.env.BASE_LOG_LEVEL or "info",  -- 支持环境变量控制
  modes = {
    { name = "trace", hl = "Comment" },
    { name = "debug", hl = "Comment" },
    { name = "info", hl = "Directory" },
    { name = "warn", hl = "WarningMsg" },
    { name = "error", hl = "ErrorMsg" },
    { name = "fatal", hl = "ErrorMsg" },
  },
  float_precision = 0.01,
}

-- 添加结构化日志支持
function log.structured(level, event, data)
  local msg = string.format("[%s] %s", event, vim.inspect(data))
  log[level](msg)
end

-- 添加条件日志支持（生产环境优化）
local is_debug = vim.env.NODE_ENV ~= "production"

local original_trace = log.trace
local original_debug = log.debug

function log.trace(...)
  if is_debug then
    original_trace(...)
  end
end

function log.debug(...)
  if is_debug then
    original_debug(...)
  end
end

return log