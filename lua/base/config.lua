---@class Config
local M = {}

---@class DefaultOptions
M.defaults = { 
  name = "John Doe",
  -- 日志配置选项
  log = {
    level = "info",          -- 日志级别: trace, debug, info, warn, error, fatal
    use_console = true,      -- 是否输出到控制台
    use_file = true,         -- 是否输出到文件
    highlights = true,       -- 是否使用高亮显示
    float_precision = 0.01   -- 浮点数精度
  }
}

---@class Options
M.options = {}

---Extend the defaults options table with the user options
---@param opts UserOptions: plugin options
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
  
  -- 配置日志系统
  if M.options.log then
    -- 如果用户提供了日志配置，更新环境变量
    if M.options.log.level then
      vim.env.BASE_LOG_LEVEL = M.options.log.level
    end
  end
end

return M
