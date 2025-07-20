# Base.nvim 使用指南

Base.nvim 是一个现代化的 Neovim 插件模板，集成了强大的日志系统，为插件开发提供了完整的基础设施。

## 目录

- [安装](#安装)
- [快速开始](#快速开始)
- [配置选项](#配置选项)
- [日志系统](#日志系统)
- [API 参考](#api-参考)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

## 安装

### 使用 lazy.nvim

```lua
{
  "pittcat/base.nvim",
  config = function()
    require("base").setup({
      name = "您的姓名",
      log = {
        level = "info",
        use_console = true,
        use_file = true
      }
    })
  end
}
```

### 使用 packer.nvim

```lua
use {
  "pittcat/base.nvim",
  config = function()
    require("base").setup({
      name = "您的姓名"
    })
  end
}
```

### 使用 vim-plug

```vim
Plug 'pittcat/base.nvim'

lua << EOF
require("base").setup({
  name = "您的姓名"
})
EOF
```

## 快速开始

### 基本使用

```lua
-- 在您的 init.lua 中
require("base").setup({
  name = "张三",
  log = {
    level = "debug",  -- 开发时使用 debug 级别
    use_console = true,
    use_file = true
  }
})
```

### 使用命令

```vim
" 向用户问好
:Base hello

" 向用户告别
:Base bye

" 检查插件健康状态
:checkhealth base
```

### 在代码中使用日志

```lua
local base = require("base")

-- 基本日志记录
base.log.info("这是一条信息日志")
base.log.warn("这是一条警告日志")
base.log.error("这是一条错误日志")

-- 格式化日志
base.log.fmt_info("用户 %s 有 %d 个项目", "张三", 42)

-- 结构化日志
base.log.structured("info", "用户操作", {
  action = "文件打开",
  file = "config.lua",
  duration_ms = 150
})
```

## 配置选项

### 完整配置示例

```lua
require("base").setup({
  -- 基本配置
  name = "张三",
  
  -- 日志配置
  log = {
    level = "info",           -- 日志级别: trace, debug, info, warn, error, fatal
    use_console = true,       -- 是否输出到 Neovim 控制台
    use_file = true,          -- 是否写入日志文件
    highlights = true,        -- 是否在控制台使用语法高亮
    float_precision = 0.01    -- 浮点数显示精度
  }
})
```

### 配置选项详解

#### 基本选项

- **name** (string): 用户名称，用于问候消息
  - 默认值: `"John Doe"`

#### 日志选项

- **log.level** (string): 最低日志级别
  - 可选值: `"trace"`, `"debug"`, `"info"`, `"warn"`, `"error"`, `"fatal"`
  - 默认值: `"info"`
  - 说明: 只有等于或高于此级别的日志才会被记录

- **log.use_console** (boolean): 控制台输出
  - 默认值: `true`
  - 说明: 是否将日志输出到 Neovim 的消息区域

- **log.use_file** (boolean): 文件输出
  - 默认值: `true`
  - 说明: 是否将日志写入文件 `~/.local/share/nvim/base.nvim.log`

- **log.highlights** (boolean): 语法高亮
  - 默认值: `true`
  - 说明: 是否在控制台中使用不同颜色显示不同级别的日志

- **log.float_precision** (number): 浮点数精度
  - 默认值: `0.01`
  - 说明: 日志中浮点数的显示精度

## 日志系统

### 日志级别

Base.nvim 支持 6 个日志级别，按优先级从低到高：

1. **trace**: 最详细的调试信息
2. **debug**: 调试信息
3. **info**: 一般信息（默认级别）
4. **warn**: 警告信息
5. **error**: 错误信息
6. **fatal**: 致命错误

### 基本日志方法

```lua
local log = require("base").log

-- 基本用法（类似 print）
log.trace("详细的调试信息")
log.debug("调试信息", variable, "更多内容")
log.info("一般信息")
log.warn("警告信息")
log.error("错误信息")
log.fatal("致命错误")

-- 格式化用法（类似 string.format）
log.fmt_info("处理文件 %s，耗时 %.2f 秒", filename, duration)
log.fmt_error("错误代码: %d，消息: %s", error_code, error_msg)
```

### 结构化日志

结构化日志适用于记录复杂的事件数据：

```lua
local log = require("base").log

-- 用户操作事件
log.structured("info", "用户操作", {
  user_id = "user123",
  action = "文件保存",
  file_path = "/path/to/file.lua",
  file_size = 1024,
  timestamp = os.time()
})

-- 性能监控事件
log.structured("debug", "性能统计", {
  function_name = "parse_config",
  execution_time_ms = 45.2,
  memory_usage_mb = 12.5,
  cache_hit = true
})

-- 错误事件
log.structured("error", "API调用失败", {
  endpoint = "/api/v1/users",
  status_code = 500,
  response_time_ms = 3000,
  retry_count = 3,
  error_message = "Connection timeout"
})
```

### 环境变量控制

您可以通过环境变量动态控制日志级别：

```bash
# 开发环境 - 启用详细日志
export BASE_LOG_LEVEL=trace
nvim

# 生产环境 - 只显示重要信息
export BASE_LOG_LEVEL=warn
nvim

# 调试特定问题
export BASE_LOG_LEVEL=debug
nvim
```

### 条件日志

在生产环境中，trace 和 debug 级别的日志会被自动禁用以提高性能：

```lua
-- 这些调用在生产环境（NODE_ENV=production）中不会执行
log.trace("详细的追踪信息")
log.debug("调试信息")

-- 这些调用在所有环境中都会执行（如果级别允许）
log.info("一般信息")
log.warn("警告信息")
log.error("错误信息")
```

## API 参考

### 主要模块 (`require("base")`)

#### `setup(opts)`

初始化插件配置。

**参数:**
- `opts` (table, 可选): 配置选项表

**返回值:**
- `boolean`: 设置是否成功

**示例:**
```lua
local success = require("base").setup({
  name = "张三",
  log = { level = "debug" }
})

if not success then
  print("插件初始化失败")
end
```

#### `hello()`

向用户问好。

**返回值:**
- `string`: 问候消息

**示例:**
```lua
local message = require("base").hello()
print(message)  -- "Hello 张三"
```

#### `bye()`

向用户告别。

**返回值:**
- `string`: 告别消息

**示例:**
```lua
local message = require("base").bye()
print(message)  -- "Bye 张三"
```

#### `log`

日志接口对象，提供所有日志方法。

**示例:**
```lua
local base = require("base")
base.log.info("这是一条日志")
```

### 日志模块 (`require("base").log`)

#### 基本日志方法

- `trace(...)`
- `debug(...)`
- `info(...)`
- `warn(...)`
- `error(...)`
- `fatal(...)`

**参数:**
- `...`: 任意数量的参数，将被转换为字符串并连接

#### 格式化日志方法

- `fmt_trace(format, ...)`
- `fmt_debug(format, ...)`
- `fmt_info(format, ...)`
- `fmt_warn(format, ...)`
- `fmt_error(format, ...)`
- `fmt_fatal(format, ...)`

**参数:**
- `format` (string): 格式字符串
- `...`: 格式化参数

#### `structured(level, event, data)`

记录结构化日志。

**参数:**
- `level` (string): 日志级别
- `event` (string): 事件名称
- `data` (table): 事件数据

## 故障排除

### 常见问题

#### 1. 看不到日志输出

**可能原因:**
- 日志级别设置过高
- 控制台输出被禁用
- 文件输出路径权限问题

**解决方案:**
```lua
-- 检查当前配置
:lua print(vim.inspect(require("base.config").options))

-- 临时降低日志级别
:lua vim.env.BASE_LOG_LEVEL = "trace"

-- 检查日志文件
:lua print(vim.fn.stdpath('data') .. '/base.nvim.log')
```

#### 2. 插件初始化失败

**检查步骤:**
1. 运行健康检查: `:checkhealth base`
2. 检查 Neovim 版本: `:version`
3. 查看错误日志: `:messages`

#### 3. 日志文件过大

**解决方案:**
```bash
# 手动清理日志文件
rm ~/.local/share/nvim/base.nvim.log

# 或者禁用文件日志
require("base").setup({
  log = { use_file = false }
})
```

### 调试技巧

#### 启用详细日志

```lua
-- 在配置中启用 trace 级别
require("base").setup({
  log = {
    level = "trace",
    use_console = true,
    use_file = true
  }
})
```

#### 查看日志文件

```vim
" 在 Neovim 中打开日志文件
:lua vim.cmd('edit ' .. vim.fn.stdpath('data') .. '/base.nvim.log')

" 实时查看日志文件（需要终端）
:!tail -f ~/.local/share/nvim/base.nvim.log
```

#### 临时调试

```lua
-- 临时启用详细日志，无需重启 Neovim
:lua vim.env.BASE_LOG_LEVEL = "trace"

-- 测试日志功能
:lua require("base").log.debug("测试日志消息")
```

## 最佳实践

### 开发阶段

1. **使用适当的日志级别**
   ```lua
   require("base").setup({
     log = { level = "debug" }  -- 开发时使用 debug
   })
   ```

2. **记录关键操作**
   ```lua
   log.info("开始处理用户配置")
   log.debug("配置内容:", vim.inspect(config))
   -- 您的处理逻辑
   log.info("配置处理完成")
   ```

3. **使用结构化日志记录复杂事件**
   ```lua
   log.structured("info", "文件操作", {
     operation = "save",
     file_path = filepath,
     file_size = size,
     duration_ms = duration
   })
   ```

### 生产环境

1. **使用合适的日志级别**
   ```lua
   require("base").setup({
     log = { level = "warn" }  -- 生产环境只记录警告和错误
   })
   ```

2. **关闭控制台输出**
   ```lua
   require("base").setup({
     log = {
       level = "info",
       use_console = false,  -- 避免干扰用户
       use_file = true
     }
   })
   ```

3. **定期清理日志文件**
   ```bash
   # 添加到 crontab
   0 0 * * 0 find ~/.local/share/nvim/ -name "*.log" -mtime +7 -delete
   ```

### 错误处理

1. **记录错误上下文**
   ```lua
   local success, err = pcall(function()
     -- 可能出错的操作
   end)
   
   if not success then
     log.error("操作失败:", err)
     log.structured("error", "操作异常", {
       operation = "file_parse",
       file_path = filepath,
       error_message = err,
       stack_trace = debug.traceback()
     })
   end
   ```

2. **使用适当的日志级别**
   ```lua
   -- 用户输入错误 - 使用 warn
   log.warn("用户提供了无效的配置项:", invalid_key)
   
   -- 系统错误 - 使用 error
   log.error("无法读取配置文件:", config_path)
   
   -- 致命错误 - 使用 fatal
   log.fatal("插件初始化失败，无法继续运行")
   ```

### 性能优化

1. **避免频繁的 trace/debug 调用**
   ```lua
   -- 好的做法：使用条件检查
   if log_level <= DEBUG_LEVEL then
     log.debug("详细调试信息:", expensive_computation())
   end
   
   -- 更好的做法：使用内置的条件日志
   log.debug("详细调试信息:", expensive_computation())  -- 自动优化
   ```

2. **避免在循环中过度日志记录**
   ```lua
   -- 避免这样做
   for i = 1, 10000 do
     log.debug("处理项目", i)  -- 会产生大量日志
   end
   
   -- 推荐做法
   log.info("开始处理 10000 个项目")
   for i = 1, 10000 do
     -- 处理逻辑
     if i % 1000 == 0 then
       log.debug("已处理", i, "个项目")
     end
   end
   log.info("处理完成")
   ```

### 团队协作

1. **统一日志格式**
   ```lua
   -- 团队约定的日志格式
   log.structured("info", "模块初始化", {
     module_name = "config_parser",
     version = "1.0.0",
     init_time_ms = duration
   })
   ```

2. **使用有意义的事件名称**
   ```lua
   -- 清晰的事件命名
   log.structured("info", "用户配置加载", {...})
   log.structured("error", "网络请求失败", {...})
   log.structured("warn", "配置项已弃用", {...})
   ```

---

## 更多资源

- [项目主页](https://github.com/pittcat/base.nvim)
- [架构文档](./architecture.md)
- [API 文档](../doc/base.txt)
- [问题报告](https://github.com/pittcat/base.nvim/issues)

---

**作者**: Base.nvim 团队  
**版本**: 1.0.2  
**最后更新**: 2024年7月
