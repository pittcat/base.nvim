-- 演示如何在实际插件开发中使用 log2debug
local dbg = require('base.log2debug')

local M = {}

-- 示例：调试配置加载过程
function M.debug_config_loading()
  dbg.begin("config_loading")
  
  -- 记录开始
  dbg.checkpoint("start_loading")
  
  -- 模拟配置文件查找
  local config_paths = {
    vim.fn.stdpath('config') .. '/base.json',
    vim.fn.expand('~/.base.json'),
    '.base.json'
  }
  
  dbg.log("Searching config in paths", config_paths)
  
  local config = nil
  for i, path in ipairs(config_paths) do
    dbg.log(string.format("Checking path %d", i), { path = path })
    
    if vim.fn.filereadable(path) == 1 then
      dbg.checkpoint("config_found", { path = path })
      -- 这里实际读取配置
      config = { found_at = path, data = {} }
      break
    end
  end
  
  if not config then
    dbg.warn("No config file found, using defaults")
    config = { default = true }
  end
  
  dbg.done()
  return config
end

-- 示例：调试异步操作
function M.debug_async_operation()
  dbg.begin("async_operation")
  
  dbg.log("Starting async operation")
  
  -- 使用计时器模拟异步操作
  vim.defer_fn(function()
    dbg.log("Async callback triggered")
    
    -- 模拟处理
    for i = 1, 3 do
      dbg.checkpoint(string.format("processing_step_%d", i))
      vim.wait(10) -- 模拟耗时操作
    end
    
    dbg.log("Async operation completed")
    dbg.done()
  end, 100)
end

-- 示例：调试复杂函数调用链
function M.debug_call_chain()
  local function level_3(data)
    dbg.fn_call("level_3", data)
    dbg.assert(type(data) == "table", "Data must be table")
    
    local result = { processed = true, count = #data }
    dbg.fn_return("level_3", result)
    return result
  end
  
  local function level_2(items)
    dbg.fn_call("level_2", items)
    
    -- 验证输入
    dbg.assert(vim.tbl_islist(items), "Items must be a list")
    
    local processed = level_3(items)
    dbg.checkpoint("level_2_processed", processed)
    
    dbg.fn_return("level_2", processed)
    return processed
  end
  
  local function level_1()
    dbg.fn_call("level_1")
    
    local items = { "a", "b", "c" }
    local result = level_2(items)
    
    dbg.fn_return("level_1", result)
    return result
  end
  
  -- 执行并获取报告
  dbg.begin("call_chain_trace")
  local result = level_1()
  dbg.done()
  
  return result
end

-- 示例：调试事件处理
function M.debug_event_handling()
  local event_handler = dbg.wrap(function(event)
    dbg.checkpoint("handling_event", { type = event.type })
    
    if event.type == "file_open" then
      dbg.log("Processing file open", event.data)
    elseif event.type == "file_save" then
      dbg.log("Processing file save", event.data)
    else
      dbg.warn("Unknown event type", { type = event.type })
    end
    
    return { handled = true }
  end, "event_handler")
  
  -- 测试事件处理
  dbg.begin("event_processing")
  
  local events = {
    { type = "file_open", data = { file = "test.lua" } },
    { type = "file_save", data = { file = "test.lua" } },
    { type = "unknown", data = {} }
  }
  
  for _, event in ipairs(events) do
    event_handler(event)
  end
  
  dbg.done()
end

-- 示例：性能调试
function M.debug_performance()
  dbg.begin("performance_test")
  
  -- 测试不同操作的性能
  local operations = {
    {
      name = "string_concat",
      fn = function()
        local result = ""
        for i = 1, 1000 do
          result = result .. "x"
        end
        return result
      end
    },
    {
      name = "table_concat",
      fn = function()
        local parts = {}
        for i = 1, 1000 do
          parts[i] = "x"
        end
        return table.concat(parts)
      end
    }
  }
  
  for _, op in ipairs(operations) do
    dbg.begin(op.name)
    
    local start = vim.loop.hrtime()
    local result = op.fn()
    local duration = (vim.loop.hrtime() - start) / 1e6
    
    dbg.log("Operation completed", {
      duration_ms = duration,
      result_length = #result
    })
    
    dbg.done()
  end
  
  dbg.done()
  
  -- 获取性能报告
  local report = dbg.report("performance_test")
  return report
end

-- 运行所有演示
function M.run_all_demos()
  vim.print("Running log2debug demos...")
  
  -- 设置日志级别为 debug
  vim.env.BASE_LOG_LEVEL = "debug"
  
  vim.print("\n1. Config Loading Demo:")
  M.debug_config_loading()
  
  vim.print("\n2. Call Chain Demo:")
  M.debug_call_chain()
  
  vim.print("\n3. Event Handling Demo:")
  M.debug_event_handling()
  
  vim.print("\n4. Performance Demo:")
  local perf_report = M.debug_performance()
  
  vim.print("\n5. Async Demo (will complete in 100ms):")
  M.debug_async_operation()
  
  vim.print("\nAll demos completed! Check the log file for detailed output.")
  vim.print("Log file: " .. vim.fn.stdpath('data') .. "/base.nvim.log")
end

return M