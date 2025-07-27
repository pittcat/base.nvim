# Testing Guide

本项目使用 **busted + nlua** 测试框架，提供真实的 Neovim 环境进行测试。

## 快速开始

### 安装依赖

```bash
# 安装 nlua 和 busted（Lua 5.1 版本）
luarocks --lua-version=5.1 install nlua
luarocks --lua-version=5.1 install busted
```

### 运行测试

```bash
# 运行所有测试
busted

# 运行指定测试文件
busted spec/base_spec.lua
busted spec/log_spec.lua

# 详细输出模式
busted --verbose

# 运行特定测试用例
busted --filter="hello"
```

## 测试文件结构

```
spec/
├── base_spec.lua    # 基础功能测试
└── log_spec.lua     # 日志系统测试
```

## 编写测试

### 基础测试示例

```lua
-- spec/my_feature_spec.lua
local base = require("base")

describe("My Feature", function()
  before_each(function()
    -- 每个测试前的设置
    base.setup({ name = "Test User" })
  end)
  
  it("should work correctly", function()
    local result = base.hello()
    assert.are.equal("Hello Test User", result)
  end)
end)
```

### 日志测试示例

```lua
describe("Logging", function()
  it("should log messages", function()
    local logger = require('base.logger')
    
    -- 测试日志输出（真实的日志会被记录）
    logger.info("Test message")
    logger.structured("info", "test_event", { key = "value" })
    
    -- 由于使用真实环境，可以验证日志文件
    assert.has_no.errors(function()
      logger.error("Test error message")
    end)
  end)
end)
```

## 测试环境特性

### 真实 Neovim 环境

- ✅ 完整的 `vim` API 支持
- ✅ 真实的文件系统操作
- ✅ 实际的日志输出
- ✅ Neovim 插件加载机制

### 环境隔离

每次测试运行时会设置临时的 XDG 目录：

```lua
-- 自动设置的环境变量
vim.env.XDG_CONFIG_HOME = "/tmp/nvim_test_config"
vim.env.XDG_DATA_HOME = "/tmp/nvim_test_data"
-- ...
```

## 测试最佳实践

### 1. 测试隔离

```lua
describe("Feature Tests", function()
  before_each(function()
    -- 每个测试前重置状态
    require("base.config").reset()
  end)
  
  after_each(function()
    -- 清理测试产生的副作用
    vim.cmd("silent! bufdo bdelete!")
  end)
end)
```

### 2. 异步测试

```lua
it("should handle async operations", function(done)
  vim.defer_fn(function()
    local result = some_async_function()
    assert.is_not_nil(result)
    done()
  end, 100)
end)
```

### 3. 错误处理测试

```lua
it("should handle errors gracefully", function()
  assert.has_error(function()
    base.setup(nil)  -- 传入 nil 应该报错
  end)
end)
```

## 调试测试

### 查看日志输出

测试运行时可以直接看到日志输出：

```bash
$ busted spec/base_spec.lua
[base.nvim] [INFO] Starting base.nvim setup
[base.nvim] [INFO] base.nvim setup completed successfully
++++
4 successes / 0 failures / 0 errors / 0 pending
```

### 调试失败的测试

```bash
# 详细输出模式
busted --verbose

# 只运行失败的测试
busted --filter="failing test name"

# 在测试中添加调试信息
it("debug test", function()
  print("Debug: ", vim.inspect(some_variable))
  -- 测试代码
end)
```

## 配置文件说明

### .busted

```lua
return {
  _all = {
    coverage = false,
    lpath = "lua/?.lua;lua/?/init.lua;spec/?.lua",
    lua = "./nlua-busted",  -- 使用 nlua 包装脚本
    helper = nil,           -- 不需要 mock，使用真实 vim API
  },
  default = {
    verbose = true,
  },
}
```

### nlua-busted 包装脚本

解决 nlua 与 busted 的兼容性问题，自动设置正确的 Lua 路径和参数。

## 常见问题

### Q: 测试运行很慢？

A: nlua 需要启动 Neovim 环境，首次启动会稍慢（~300ms），这是正常的。相比 mock 环境，真实环境的可靠性值得这个开销。

### Q: 如何测试 vim 命令？

A: 可以直接使用 `vim.cmd()` 执行命令：

```lua
it("should execute vim commands", function()
  vim.cmd("set number")
  local number_option = vim.o.number
  assert.is_true(number_option)
end)
```

### Q: 测试中如何创建临时文件？

A: 使用 vim.fn.tempname() 创建临时文件：

```lua
it("should work with files", function()
  local temp_file = vim.fn.tempname()
  vim.fn.writefile({"line1", "line2"}, temp_file)
  local content = vim.fn.readfile(temp_file)
  assert.are.equal(2, #content)
end)
```

## 扩展测试

当添加新功能时，记得：

1. 在 `spec/` 目录下创建对应的测试文件
2. 使用描述性的测试名称
3. 确保测试能独立运行
4. 测试边界条件和错误情况
5. 运行完整测试套件确保没有回归

---

**总结**: busted + nlua 为 Neovim 插件提供了高保真的测试环境，确保测试结果与实际使用环境一致。虽然比 mock 环境稍慢，但真实性和可维护性的优势远超过性能开销。