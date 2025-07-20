local log = require('base.logger')
local M = {}


---Validate the options table obtained from merging defaults and user options
local function validate_opts_table()
  local opts = require("base.config").options

  local ok, err = pcall(function()
    vim.validate {
      name = { opts.name, "string" }
      --- validate other options here...
    }
  end)

  if not ok then
    vim.health.error("Invalid setup options: " .. err)
  else
    vim.health.ok("opts are correctly set")
  end
end


---This function is used to check the health of the plugin
---It's called by `:checkhealth` command
M.check = function()
  vim.health.start("base.nvim health check")
  
  log.debug("Running health check")
  
  -- 检查 Neovim 版本
  if vim.fn.has('nvim-0.10') == 1 then
    vim.health.ok("Neovim version >= 0.10")
    log.info("Neovim version check passed")
  else
    vim.health.error("Neovim version < 0.10")
    log.error("Neovim version check failed")
  end
  
  -- 检查日志文件权限
  local log_dir = vim.fn.stdpath('data')
  if vim.fn.isdirectory(log_dir) == 1 then
    vim.health.ok("Log directory accessible: " .. log_dir)
    log.debug("Log directory check passed:", log_dir)
  else
    vim.health.warn("Log directory not found: " .. log_dir)
    log.warn("Log directory check failed:", log_dir)
  end
  
  -- 检查日志系统是否正常工作
  local test_success, test_err = pcall(function()
    log.info("Health check test log message")
  end)
  
  if test_success then
    vim.health.ok("Logging system is working")
    log.debug("Logging system check passed")
  else
    vim.health.error("Logging system failed: " .. tostring(test_err))
    log.error("Logging system check failed:", test_err)
  end

  validate_opts_table()

  -- Add more checks:
  --  - check for requirements
  --  - check for Neovim options (e.g. python support)
  --  - check for other plugins required
  --  - check for LSP setup
  --  ...
end


return M
