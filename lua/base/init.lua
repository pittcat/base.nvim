local log = require('base.logger')
local M = {}

---Setup the base plugin
---@param opts UserOptions: plugin options
M.setup = function(opts)
  log.info("Starting base.nvim setup")
  
  -- 验证配置
  if not opts then
    log.warn("No configuration provided, using defaults")
    opts = {}
  end
  
  log.debug("Configuration:", vim.inspect(opts))
  
  -- 初始化配置
  local success, err = pcall(function()
    require("base.config").setup(opts)
  end)
  
  if not success then
    log.error("Setup failed:", err)
    return false
  end
  
  log.info("base.nvim setup completed successfully")
  return true
end

---Say hello to the user
---@return string: message to the user
M.hello = function()
  log.debug("hello() function called")
  local str = "Hello " .. require("base.config").options.name
  log.info("Greeting user:", str)
  vim.print(str)
  return str
end

---Say bye to the user
---@return string: message to the user
M.bye = function()
  log.debug("bye() function called")
  local str = "Bye " .. require("base.config").options.name
  log.info("Saying goodbye to user:", str)
  vim.print(str)
  return str
end

-- 导出日志接口供用户使用
M.log = log

return M
