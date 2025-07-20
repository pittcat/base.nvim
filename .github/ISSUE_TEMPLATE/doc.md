# Neovim 插件日志系统集成建议

## 概览

类似 Python loguru 的日志系统特性包括：
- 简单易用的 API
- 多种日志级别
- 彩色输出
- 文件输出支持
- 结构化日志
- 自动轮转
- 零配置开箱即用

## 推荐方案对比

### 🏆 方案一：tjdevries/vlog.nvim（推荐）

**特点**：
- ✅ 专为 Neovim 插件设计
- ✅ 单文件，零依赖
- ✅ 类似 loguru 的简洁 API
- ✅ 支持彩色控制台输出
- ✅ 支持文件输出
- ✅ 多种日志级别
- ✅ 可配置的高亮显示

**API 示例**：
```lua
local log = require('base.log')

-- 类似 print 的用法
log.info("Processing", user_input, "with options")
log.warn("Configuration missing:", config_key)
log.error("Failed to connect:", error_msg)

-- 类似 string.format 的用法
log.fmt_info("Processing %s with %d options", filename, count)
log.fmt_error("Error code: %d, message: %s", code, msg)

-- 支持的级别
log.trace(...)  -- 最详细
log.debug(...)  -- 调试信息
log.info(...)   -- 一般信息
log.warn(...)   -- 警告
log.error(...)  -- 错误
log.fatal(...)  -- 致命错误
```

**配置选项**：
```lua
local config = {
  plugin = 'base.nvim',           -- 插件名称前缀
  use_console = true,             -- 控制台输出
  highlights = true,              -- 彩色高亮
  use_file = true,               -- 文件输出
  level = "debug",               -- 最低日志级别
  float_precision = 0.01,        -- 浮点数精度
  modes = {                      -- 自定义级别颜色
    { name = "trace", hl = "Comment" },
    { name = "debug", hl = "Comment" },
    { name = "info", hl = "None" },
    { name = "warn", hl = "WarningMsg" },
    { name = "error", hl = "ErrorMsg" },
    { name = "fatal", hl = "ErrorMsg" },
  }
}
```

### 🥈 方案二：内置 vim.notify + 自定义包装

**特点**：
- ✅ 使用 Neovim 内置功能
- ✅ 与 Neovim 生态完美集成
- ✅ 支持通知插件（如 nvim-notify）
- ❌ 需要自定义实现文件日志
- ❌ 功能相对有限

**实现示例**：
```lua
-- lua/base/log.lua
local M = {}

-- 日志级别映射
local levels = {
  TRACE = vim.log.levels.TRACE,
  DEBUG = vim.log.levels.DEBUG,
  INFO = vim.log.levels.INFO,
  WARN = vim.log.levels.WARN,
  ERROR = vim.log.levels.ERROR,
}

local config = {
  level = levels.DEBUG,
  use_file = true,
  log_file = vim.fn.stdpath('log') .. '/base.nvim.log'
}

function M.log(level, ...)
  if level < config.level then return end
  
  local msg = table.concat(vim.tbl_map(tostring, {...}), ' ')
  
  -- 控制台输出
  vim.notify(msg, level)
  
  -- 文件输出
  if config.use_file then
    M.write_to_file(level, msg)
  end
end

function M.info(...) M.log(levels.INFO, ...) end
function M.warn(...) M.log(levels.WARN, ...) end
function M.error(...) M.log(levels.ERROR, ...) end
function M.debug(...) M.log(levels.DEBUG, ...) end

return M
```

### 🥉 方案三：通用 Lua 日志库（如 rxi/log.lua）

**特点**：
- ✅ 功能完整
- ✅ 社区维护
- ❌ 非 Neovim 专用
- ❌ 可能有额外依赖
- ❌ 与 Neovim 生态集成度较低

## 集成到 base.nvim 的具体步骤

### Step 1: 选择并集成 vlog.nvim

#### 方法一：直接复制（推荐）
```bash
# 在 base.nvim 项目根目录
mkdir -p lua/base/
curl -o lua/base/log.lua https://raw.githubusercontent.com/tjdevries/vlog.nvim/master/lua/vlog.lua
```

#### 方法二：作为依赖安装
```lua
-- 在 base.nvim 的安装说明中添加
{
  "tjdevries/vlog.nvim",
  lazy = true,
}
```

### Step 2: 配置日志模块

创建 `lua/base/log.lua`：
```lua
-- lua/base/log.lua
local vlog = require('vlog')

return vlog.new {
  plugin = 'base.nvim',
  use_console = true,
  highlights = true,
  use_file = true,
  level = vim.env.BASE_LOG_LEVEL or "info",  -- 支持环境变量
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
```

### Step 3: 在主模块中集成

修改 `lua/base/init.lua`：
```lua
-- lua/base/init.lua
local log = require('base.log')

local M = {}

function M.setup(opts)
  log.info("Starting base.nvim setup")
  
  -- 验证配置
  if not opts then
    log.warn("No configuration provided, using defaults")
    opts = {}
  end
  
  log.debug("Configuration:", vim.inspect(opts))
  
  -- 你的插件逻辑
  local success, err = pcall(function()
    -- 插件初始化代码
  end)
  
  if not success then
    log.error("Setup failed:", err)
    return false
  end
  
  log.info("base.nvim setup completed successfully")
  return true
end

-- 导出日志接口供用户使用
M.log = log

return M
```

### Step 4: 在健康检查中使用

修改 `lua/base/health.lua`：
```lua
-- lua/base/health.lua
local log = require('base.log')

local M = {}

function M.check()
  vim.health.start("base.nvim")
  
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
  local log_dir = vim.fn.stdpath('log')
  if vim.fn.isdirectory(log_dir) == 1 then
    vim.health.ok("Log directory accessible: " .. log_dir)
    log.debug("Log directory check passed:", log_dir)
  else
    vim.health.warn("Log directory not found: " .. log_dir)
    log.warn("Log directory check failed:", log_dir)
  end
end

return M
```

### Step 5: 添加测试用例

创建 `spec/log_spec.lua`：
```lua
-- spec/log_spec.lua
describe("base.nvim logging", function()
  local log = require('base.log')
  
  it("should log at different levels", function()
    assert.has_no.errors(function()
      log.trace("trace message")
      log.debug("debug message")
      log.info("info message")
      log.warn("warn message")
      log.error("error message")
    end)
  end)
  
  it("should support formatted logging", function()
    assert.has_no.errors(function()
      log.fmt_info("User %s has %d items", "alice", 42)
    end)
  end)
end)
```

## 高级功能扩展

### 1. 环境变量控制
```lua
-- 支持通过环境变量控制日志级别
-- export BASE_LOG_LEVEL=debug
local level = vim.env.BASE_LOG_LEVEL or "info"
```

### 2. 条件编译（类似 loguru）
```lua
-- lua/base/log.lua
local M = {}

-- 生产环境自动禁用 trace/debug
local is_debug = vim.env.NODE_ENV ~= "production"

function M.trace(...)
  if is_debug then
    log.trace(...)
  end
end

function M.debug(...)
  if is_debug then
    log.debug(...)
  end
end
```

### 3. 结构化日志支持
```lua
function M.structured(level, event, data)
  local msg = string.format("[%s] %s", event, vim.inspect(data))
  log[level](msg)
end

-- 使用示例
log.structured("info", "user_action", {
  action = "file_open",
  file = "test.lua",
  duration_ms = 45
})
```

## 使用建议

### 开发阶段
```lua
-- 启用详细日志
export BASE_LOG_LEVEL=trace
nvim
```

### 生产使用
```lua
-- 只显示重要信息
export BASE_LOG_LEVEL=warn
nvim
```

### 调试特定功能
```lua
log.debug("Function entry:", {args = vim.inspect(args)})
-- 你的代码
log.debug("Function exit:", {result = vim.inspect(result)})
```

## 总结

**推荐使用 tjdevries/vlog.nvim**，因为它：
1. 专为 Neovim 设计，API 简洁易用
2. 功能完整，类似 loguru 的体验
3. 零依赖，易于集成到 base.nvim 模板
4. 支持彩色输出和文件日志
5. 活跃维护，社区认可度高

这个方案能让你在 base.nvim 中获得类似 Python loguru 的优秀日志体验，同时保持 Neovim 生态的原生性和性能。
