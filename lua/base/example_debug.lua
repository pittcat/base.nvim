local dbg = require('base.log2debug')

local M = {}

-- 示例1: 基础调试日志
function M.basic_example()
  dbg.debug("Starting basic example")
  
  local config = { name = "test", value = 42 }
  dbg.log("Configuration loaded", config)
  
  dbg.checkpoint("config_validated")
  
  dbg.info("Basic example completed")
end

-- 示例2: 使用调试上下文
function M.context_example()
  dbg.begin("user_action")
  
  dbg.log("User initiated action")
  dbg.log("Processing input", { input = "hello world" })
  
  -- 模拟一些处理
  vim.defer_fn(function()
    dbg.log("Async operation completed")
    dbg.done()
  end, 100)
end

-- 示例3: 函数调用追踪
function M.trace_example()
  local function process_data(data)
    dbg.fn_call("process_data", data)
    
    -- 处理逻辑
    local result = {
      processed = true,
      count = #data,
      items = data
    }
    
    dbg.fn_return("process_data", result)
    return result
  end
  
  process_data({"item1", "item2", "item3"})
end

-- 示例4: 使用装饰器自动追踪
function M.decorator_example()
  local function calculate(a, b)
    return a + b, a * b
  end
  
  -- 装饰函数
  local traced_calculate = dbg.wrap(calculate, "calculate")
  
  -- 调用会自动记录
  local sum, product = traced_calculate(5, 3)
  dbg.log("Results", { sum = sum, product = product })
end

-- 示例5: 带作用域的调试
function M.scope_example()
  local result = dbg.scope("data_processing", function()
    dbg.log("Loading data...")
    
    -- 模拟数据加载
    local data = { users = 10, posts = 50 }
    dbg.checkpoint("data_loaded", data)
    
    -- 模拟数据处理
    dbg.log("Processing data...")
    data.processed = true
    
    dbg.checkpoint("data_processed")
    
    return data
  end)
  
  dbg.info("Scope result", result)
end

-- 示例6: 条件断言
function M.assert_example()
  local function validate_input(input)
    dbg.assert(type(input) == "string", "Input must be string", { input = input })
    dbg.assert(#input > 0, "Input cannot be empty")
    dbg.assert(#input < 100, "Input too long", { length = #input })
    
    return true
  end
  
  -- 正常情况
  validate_input("hello")
  
  -- 这会触发错误
  -- validate_input("")
end

-- 示例7: 调试报告
function M.report_example()
  -- 创建一些调试上下文
  dbg.begin("operation_1")
  dbg.log("Step 1")
  dbg.log("Step 2")
  dbg.done()
  
  dbg.begin("operation_2")
  dbg.log("Another operation")
  dbg.done()
  
  -- 获取报告
  local report = dbg.report()
  dbg.info("Debug report", report)
  
  -- 清理
  dbg.clear()
end

-- 示例8: 复杂场景 - 调试插件初始化
function M.plugin_init_example()
  dbg.begin("plugin_initialization")
  
  -- 步骤1: 加载配置
  dbg.checkpoint("loading_config")
  local config = { enabled = true, options = { timeout = 5000 } }
  dbg.log("Config loaded", config)
  
  -- 步骤2: 验证环境
  dbg.checkpoint("validating_environment")
  dbg.assert(vim.fn.has("nvim-0.9") == 1, "Neovim 0.9+ required")
  
  -- 步骤3: 注册命令
  dbg.checkpoint("registering_commands")
  dbg.log("Registering command :MyPlugin")
  
  -- 步骤4: 设置自动命令
  dbg.checkpoint("setting_autocmds")
  dbg.log("Setting up autocmds", { 
    events = {"BufRead", "BufNewFile"},
    pattern = "*.lua"
  })
  
  dbg.done()
  
  -- 获取初始化报告
  local init_report = dbg.report("plugin_initialization")
  if init_report then
    local duration = (init_report.logs[#init_report.logs].time - init_report.start_time) / 1e6
    dbg.info(string.format("Plugin initialized in %.2fms", duration))
  end
end

return M