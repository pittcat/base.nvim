local log = require('base.logger')

local M = {}

-- 调试上下文管理
local debug_contexts = {}
local current_context = nil

---开始一个调试上下文
---@param context string 上下文名称
function M.begin(context)
  current_context = context
  debug_contexts[context] = {
    start_time = vim.loop.hrtime(),
    logs = {},
  }
  log.debug(string.format("[DEBUG BEGIN] %s", context))
end

---结束当前调试上下文
function M.done()
  if not current_context then
    log.warn("No active debug context to end")
    return
  end
  
  local context = debug_contexts[current_context]
  if context then
    local duration = (vim.loop.hrtime() - context.start_time) / 1e6 -- 转换为毫秒
    log.debug(string.format("[DEBUG END] %s (took %.2fms)", current_context, duration))
  end
  
  current_context = nil
end

---记录调试信息
---@param msg string 消息
---@param data? table 额外数据
function M.log(msg, data)
  if not current_context then
    -- 无上下文时直接记录
    if data then
      log.debug(string.format("%s: %s", msg, vim.inspect(data)))
    else
      log.debug(msg)
    end
    return
  end
  
  -- 有上下文时记录到上下文中
  local context = debug_contexts[current_context]
  if context then
    local log_entry = {
      time = vim.loop.hrtime(),
      msg = msg,
      data = data
    }
    table.insert(context.logs, log_entry)
  end
  
  -- 同时输出到日志
  if data then
    log.debug(string.format("[%s] %s: %s", current_context, msg, vim.inspect(data)))
  else
    log.debug(string.format("[%s] %s", current_context, msg))
  end
end

---打印函数调用信息
---@param fn_name string 函数名
---@param ... any 参数
function M.fn_call(fn_name, ...)
  local args = {...}
  local args_str = {}
  for i, arg in ipairs(args) do
    args_str[i] = vim.inspect(arg)
  end
  M.log(string.format("Called %s(%s)", fn_name, table.concat(args_str, ", ")))
end

---打印函数返回值
---@param fn_name string 函数名
---@param ... any 返回值
function M.fn_return(fn_name, ...)
  local returns = {...}
  local ret_str = {}
  for i, ret in ipairs(returns) do
    ret_str[i] = vim.inspect(ret)
  end
  M.log(string.format("Return from %s: %s", fn_name, table.concat(ret_str, ", ")))
end

---装饰器：自动记录函数调用
---@param fn function 要装饰的函数
---@param name string 函数名称
---@return function 装饰后的函数
function M.wrap(fn, name)
  return function(...)
    M.fn_call(name, ...)
    local results = {fn(...)}
    M.fn_return(name, unpack(results))
    return unpack(results)
  end
end

---检查点：记录代码执行到某个位置
---@param checkpoint string 检查点名称
---@param data? table 额外数据
function M.checkpoint(checkpoint, data)
  M.log(string.format("✓ Checkpoint: %s", checkpoint), data)
end

---断言并记录
---@param condition any 条件
---@param msg string 消息
---@param data? table 额外数据
function M.assert(condition, msg, data)
  if not condition then
    log.error(string.format("Assertion failed: %s", msg), data)
    error(msg)
  else
    M.log(string.format("✓ Assert passed: %s", msg), data)
  end
end

---获取调试报告
---@param context? string 上下文名称，nil表示所有
---@return table 调试报告
function M.report(context)
  if context then
    return debug_contexts[context]
  else
    return debug_contexts
  end
end

---清空调试上下文
function M.clear()
  debug_contexts = {}
  current_context = nil
  log.debug("Debug contexts cleared")
end

---便捷方法：带作用域的调试
---@param context string 上下文名称
---@param fn function 要执行的函数
---@return any 函数返回值
function M.scope(context, fn)
  M.begin(context)
  local ok, result = pcall(fn)
  M.done()
  
  if not ok then
    log.error(string.format("Error in debug scope '%s': %s", context, result))
    error(result)
  end
  
  return result
end

-- 导出日志级别快捷方法
M.trace = function(msg, data) log.trace(data and string.format("%s: %s", msg, vim.inspect(data)) or msg) end
M.debug = function(msg, data) log.debug(data and string.format("%s: %s", msg, vim.inspect(data)) or msg) end
M.info = function(msg, data) log.info(data and string.format("%s: %s", msg, vim.inspect(data)) or msg) end
M.warn = function(msg, data) log.warn(data and string.format("%s: %s", msg, vim.inspect(data)) or msg) end
M.error = function(msg, data) log.error(data and string.format("%s: %s", msg, vim.inspect(data)) or msg) end

return M