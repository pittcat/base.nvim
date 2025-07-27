# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim plugin template called `base.nvim`. It provides a modern starting point for Neovim plugin development with best practices, testing framework, CI/CD pipelines, and integrated logging system using vlog.nvim.

## Common Development Commands

### Testing

Uses **busted + nlua** testing framework with real Neovim environment:

```bash
# Run all tests (automatically defaults to spec/ directory)
busted

# Run specific test file  
busted spec/base_spec.lua
busted spec/log_spec.lua

# Verbose output
busted --verbose

# Run single test by filter
busted --filter="should support formatted logging"
```

**Environment**: Project is pre-configured with `nlua-busted` wrapper (auto-defaults to `spec/` directory) and `run-busted-nlua.lua` launcher to solve nlua+busted compatibility issues. No additional setup required.

### Health Check
```vim
:checkhealth base
```

### Development Dependencies

Install via luarocks (Lua 5.1):
```bash
luarocks --lua-version=5.1 install nlua
luarocks --lua-version=5.1 install busted
```

## Architecture

### Plugin Loading Pattern
The plugin follows a lazy-loading architecture:
1. **Entry Point**: `plugin/base.lua` - Defines `:Base` command without loading main module
2. **Main Module**: `lua/base/init.lua` - Loaded on first command execution, exports `setup()`, `hello()`, `bye()` 
3. **Configuration Management**: `lua/base/config.lua` - Handles plugin configuration with validation
4. **Module Dependencies**: Main module requires logger, which requires config, creating a dependency chain

### Logging Architecture
Integrated vlog.nvim-based logging system:
- **Core Library**: `lua/base/log.lua` - vlog.nvim implementation with `new()` factory function
- **Wrapper**: `lua/base/logger.lua` - Plugin-specific logger instance with structured logging support
- **Log Levels**: trace, debug, info, warn, error, fatal
- **Output**: `~/.local/share/nvim/base.nvim.log` + console output
- **Control**: `BASE_LOG_LEVEL` environment variable

Key logging features:
```lua
log.structured("info", "user_action", { action = "file_open", file = "test.lua" })
log.fmt_info("User %s has %d items", "alice", 42)  -- Formatted logging
```

### Testing Architecture
- **Framework**: busted + nlua (real Neovim environment, no mocks)
- **Compatibility Layer**: `nlua-busted` wrapper + `run-busted-nlua.lua` launcher 
- **Test Location**: `spec/*_spec.lua` files
- **Environment Isolation**: Tests run with temporary XDG directories

### Configuration System
- **Type Safety**: LuaCATS annotations in `lua/base/types.lua`
- **Validation**: Configuration schema validation in setup process
- **Default Handling**: Falls back to defaults when no config provided

### CI/CD Pipeline
- **Testing**: nvim-neorocks/nvim-busted-action on PR/push
- **Release Management**: Conventional commits → Release Please → GitHub + LuaRocks publishing
- **Dependencies**: Declared in `base.nvim-scm-1.rockspec` (nlua, busted for tests)

### Template Features
This is a **plugin template** designed for:
- Modern Neovim plugin development
- Real environment testing (not mocked)
- Integrated logging system
- Type-safe development with LuaCATS
- Automated CI/CD workflows
- LuaRocks packaging