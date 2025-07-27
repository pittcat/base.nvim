# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim plugin template called `base.nvim`. It provides a modern starting point for Neovim plugin development with best practices, testing framework, CI/CD pipelines, and integrated logging system powered by vlog.nvim.

## Common Development Commands

### Testing

本项目使用 **busted + nlua** 进行测试，提供真实的 Neovim 环境。

#### 运行测试

```bash
# 运行所有测试
busted

# 运行指定测试文件
busted spec/base_spec.lua

# 运行日志测试
busted spec/log_spec.lua

# 详细输出模式
busted --verbose
```

#### 测试环境设置

项目已配置好 nlua 环境，无需额外设置：

- `.busted` - 配置文件，使用 nlua 作为 Lua 解释器
- `nlua-busted` - 包装脚本，解决 nlua+busted 兼容性
- `run-busted-nlua.lua` - nlua 环境下的 busted 启动器

#### 优势

- ✅ **真实环境**: 使用真正的 vim API，无需 mock
- ✅ **完整日志**: 可以看到实际的日志输出和调试信息
- ✅ **易维护**: 不需要维护复杂的 mock 代码
- ✅ **高保真**: 测试结果与实际使用环境一致

#### 测试文件结构

```
spec/
├── base_spec.lua    # 基础功能测试
└── log_spec.lua     # 日志系统测试
```

### Health Check
```vim
:checkhealth base
```

## Architecture

### Plugin Structure
- **Entry Point**: `plugin/base.lua` - Defines user commands (`:Base`)
- **Main Module**: `lua/base/init.lua` - Exports `setup()`, `hello()`, and `bye()` functions
- **Configuration**: `lua/base/config.lua` - Manages plugin configuration with validation
- **Health Check**: `lua/base/health.lua` - Implements `:checkhealth` support
- **Logging System**: 
  - `lua/base/logger.lua` - Logging wrapper with structured logging support
  - `lua/base/log.lua` - vlog.nvim core logging library
- **Type Definitions**: `lua/base/types.lua` - LuaCATS type annotations

### Module Loading Pattern
The plugin follows a lazy-loading pattern where:
1. `plugin/base.lua` only defines commands without loading the main module
2. The actual module is loaded on first command execution
3. Configuration is managed through `M.setup()` function with schema validation

### Testing Framework
- Uses `busted` test framework with `nlua` as the Lua interpreter
- Tests are located in `spec/` directory
- Test files follow the `*_spec.lua` naming convention

## Development Guidelines

### Code Style
- 2 spaces for indentation
- Double quotes for strings
- 120 character line width
- Follow `.editorconfig` settings

### Type Annotations
Use LuaCATS annotations in `types.lua` for type safety:
```lua
---@class base.Config
---@field enabled boolean
---@field style "modern"|"classic"
```

### Adding New Features
1. Define types in `lua/base/types.lua`
2. Add configuration options in `lua/base/config.lua`
3. Implement functionality in appropriate module
4. Add appropriate logging with `require('base.logger')`
5. Add tests in `spec/`
6. Update documentation in `doc/base.txt`

### Logging Guidelines
- Use `require('base.logger')` for all logging operations
- Log levels: trace, debug, info, warn, error, fatal
- Use structured logging for complex events: `log.structured(level, event, data)`
- Control log level via `BASE_LOG_LEVEL` environment variable
- Logs are written to `~/.local/share/nvim/base.nvim.log`

### Log Level Usage
- **trace/debug**: Development and troubleshooting
- **info**: General operational information
- **warn**: Potentially harmful situations
- **error**: Error events that allow application to continue
- **fatal**: Severe errors that might cause termination

### CI/CD Workflow
- **Testing**: Automatically runs on PR and main branch pushes
- **Type Checking**: Uses Lua Language Server for static analysis
- **Releases**: Automated via Release Please (conventional commits)
- **Publishing**: Automatically publishes to LuaRocks on release

### Important Files
- `.busted`: Test framework configuration
- `.github/workflows/.luarc.json`: Lua Language Server configuration for CI
- `base.nvim-scm-1.rockspec`: LuaRocks package specification
- `docs/architecture.md`: System architecture diagrams (Mermaid)
- `docs/usage-zh.md`: Comprehensive Chinese documentation