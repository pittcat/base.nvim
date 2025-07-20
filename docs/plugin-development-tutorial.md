# 基于 Base.nvim 模板的插件开发教程：从零到一

本教程将指导你使用 base.nvim 模板创建一个完整的 Neovim 插件。我们将以创建一个名为 "note-manager.nvim" 的笔记管理插件为例。

## 目录

- [前置准备](#前置准备)
- [第一步：使用模板创建项目](#第一步使用模板创建项目)
- [第二步：自定义插件信息](#第二步自定义插件信息)
- [第三步：设计插件功能](#第三步设计插件功能)
- [第四步：实现核心功能](#第四步实现核心功能)
- [第五步：编写测试](#第五步编写测试)
- [第六步：更新文档](#第六步更新文档)
- [第七步：本地测试](#第七步本地测试)
- [第八步：发布插件](#第八步发布插件)
- [第九步：持续维护](#第九步持续维护)

## 前置准备

### 环境要求

- **Neovim**: >= 0.10.0
- **Git**: 用于版本控制
- **GitHub 账号**: 用于托管代码
- **Node.js**: (可选) 用于一些开发工具
- **Lua 开发环境**: 
  - busted (测试框架)
  - luarocks (包管理器)

### 安装必要工具

```bash
# 安装 luarocks (macOS)
brew install luarocks

# 安装 busted 测试框架
luarocks install busted

# 安装 nlua (Neovim Lua 解释器)
luarocks install nlua
```

### 开发工具推荐

- **编辑器**: Neovim + LSP 配置
- **终端**: 任意现代终端
- **Git GUI**: (可选) GitKraken、SourceTree 等

## 第一步：使用模板创建项目

### 1.1 从模板创建新仓库

在 GitHub 上点击 "Use this template" 按钮，或者手动克隆：

```bash
# 克隆模板
git clone https://github.com/your-username/base.nvim.git note-manager.nvim
cd note-manager.nvim

# 更新远程仓库地址
git remote set-url origin https://github.com/your-username/note-manager.nvim.git

# 清理历史（可选）
rm -rf .git
git init
git add .
git commit -m "Initial commit from base.nvim template"
```

### 1.2 检查项目结构

```
note-manager.nvim/
├── lua/base/           # 需要重命名为 lua/note-manager/
├── plugin/base.lua     # 需要重命名为 plugin/note-manager.lua
├── spec/               # 测试目录
├── doc/                # 文档目录
├── docs/               # 额外文档
├── .github/workflows/  # CI/CD 配置
├── .busted             # 测试配置
├── .editorconfig       # 编辑器配置
├── README.md           # 项目说明
└── CLAUDE.md           # Claude 开发指导
```

## 第二步：自定义插件信息

### 2.1 重命名核心文件和目录

```bash
# 重命名主要目录
mv lua/base lua/note-manager

# 重命名插件入口文件
mv plugin/base.lua plugin/note-manager.lua

# 重命名测试文件
mv spec/base_spec.lua spec/note-manager_spec.lua

# 重命名文档文件
mv doc/base.txt doc/note-manager.txt
```

### 2.2 更新 rockspec 文件

```bash
mv base.nvim-scm-1.rockspec note-manager.nvim-scm-1.rockspec
```

编辑 `note-manager.nvim-scm-1.rockspec`：

```lua
local plugin_name = "note-manager.nvim"

local spec = {
  name = plugin_name,
  version = "scm-1",
  source = {
    url = "git://github.com/your-username/" .. plugin_name,
  },
  description = {
    summary = "A powerful note management plugin for Neovim",
    detailed = [[
      Note Manager provides an intuitive way to create, organize, and manage
      notes directly within Neovim. Features include note templates, tagging,
      search, and integration with various note formats.
    ]],
    homepage = "https://github.com/your-username/" .. plugin_name,
    license = "MIT",
  },
  dependencies = {
    "lua >= 5.1",
  },
  build = {
    type = "builtin",
  },
}

if not spec.source.url:find("https") and os.getenv "GITHUB_TOKEN" then
  spec.source.url = spec.source.url:gsub("git://github.com", "https://github.com")
end

return spec
```

### 2.3 更新 README.md

```markdown
# note-manager.nvim

一个强大的 Neovim 笔记管理插件，让你在编辑器中轻松管理笔记。

## ✨ 特性

- 📝 快速创建和编辑笔记
- 🏷️ 标签管理和分类
- 🔍 全文搜索和过滤
- 📋 笔记模板系统
- 📊 统计和分析
- 🔗 笔记间链接
- 📅 日期和时间管理

## 📦 安装

### lazy.nvim

```lua
{
  "your-username/note-manager.nvim",
  config = function()
    require("note-manager").setup({
      notes_dir = "~/notes",
      default_template = "daily",
    })
  end
}
```

## 🚀 快速开始

```lua
-- 创建新笔记
:NoteNew

-- 搜索笔记
:NoteSearch

-- 列出所有笔记
:NoteList
```

## 📖 文档

详细文档请查看 [使用指南](docs/usage-zh.md)
```

### 2.4 更新插件入口文件

编辑 `plugin/note-manager.lua`：

```lua
-- plugin/note-manager.lua
-- Note Manager plugin entry point

if vim.g.loaded_note_manager == 1 then
  return
end
vim.g.loaded_note_manager = 1

local function create_user_commands()
  vim.api.nvim_create_user_command("NoteManagerSetup", function(opts)
    require("note-manager").setup(opts.args)
  end, { desc = "Setup Note Manager plugin" })

  vim.api.nvim_create_user_command("NoteNew", function(opts)
    require("note-manager").new_note(opts.args)
  end, { 
    desc = "Create a new note",
    nargs = "?",
    complete = function()
      return require("note-manager").get_templates()
    end
  })

  vim.api.nvim_create_user_command("NoteSearch", function(opts)
    require("note-manager").search_notes(opts.args)
  end, { 
    desc = "Search notes",
    nargs = "?"
  })

  vim.api.nvim_create_user_command("NoteList", function()
    require("note-manager").list_notes()
  end, { desc = "List all notes" })

  vim.api.nvim_create_user_command("NoteOpen", function(opts)
    require("note-manager").open_note(opts.args)
  end, { 
    desc = "Open a specific note",
    nargs = 1,
    complete = function()
      return require("note-manager").get_note_names()
    end
  })
end

create_user_commands()
```

## 第三步：设计插件功能

### 3.1 功能规划

我们的笔记管理插件将包含以下核心功能：

1. **笔记创建**: 支持模板、自动命名
2. **笔记搜索**: 按标题、内容、标签搜索
3. **笔记列表**: 显示所有笔记的概览
4. **标签管理**: 添加、移除、搜索标签
5. **模板系统**: 预定义的笔记模板
6. **统计功能**: 笔记数量、字数统计

### 3.2 配置设计

编辑 `lua/note-manager/config.lua`：

```lua
---@class Config
local M = {}

---@class DefaultOptions
M.defaults = {
  -- 基本配置
  notes_dir = vim.fn.expand("~/notes"),  -- 笔记目录
  default_template = "basic",            -- 默认模板
  file_extension = ".md",                -- 文件扩展名
  
  -- 日志配置
  log = {
    level = "info",
    use_console = true,
    use_file = true,
    highlights = true,
    float_precision = 0.01
  },
  
  -- 搜索配置
  search = {
    ignore_case = true,              -- 忽略大小写
    include_content = true,          -- 搜索文件内容
    include_filename = true,         -- 搜索文件名
    max_results = 50                 -- 最大搜索结果
  },
  
  -- 模板配置
  templates = {
    basic = {
      name = "Basic Note",
      content = [[# {title}

Created: {date}
Tags: 

---

{cursor}
]]
    },
    daily = {
      name = "Daily Note",
      content = [[# Daily Note - {date}

## 今日计划
- 

## 今日总结
- 

## 明日计划
- 

---
Tags: daily, {date}
]]
    },
    meeting = {
      name = "Meeting Notes", 
      content = [[# Meeting: {title}

**Date**: {date}
**Attendees**: 
**Duration**: 

## Agenda
1. 

## Discussion
- 

## Action Items
- [ ] 

## Next Steps
- 

---
Tags: meeting, {date}
]]
    }
  },
  
  -- UI 配置
  ui = {
    width = 80,           -- 列表窗口宽度
    height = 20,          -- 列表窗口高度
    border = "rounded",   -- 窗口边框样式
    preview = true        -- 是否显示预览
  }
}

---@class Options
M.options = {}

---@class NoteManagerConfig
---@field notes_dir string
---@field default_template string
---@field file_extension string
---@field log table
---@field search table
---@field templates table
---@field ui table

---Extend the defaults options table with the user options
---@param opts NoteManagerConfig: plugin options
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
  
  -- 确保笔记目录存在
  local notes_dir = vim.fn.expand(M.options.notes_dir)
  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end
  
  -- 配置日志系统
  if M.options.log then
    if M.options.log.level then
      vim.env.NOTE_MANAGER_LOG_LEVEL = M.options.log.level
    end
  end
  
  return M.options
end

return M
```

### 3.3 类型定义

编辑 `lua/note-manager/types.lua`：

```lua
---@meta

---@class note-manager.Config
---@field notes_dir string 笔记目录路径
---@field default_template string 默认模板名称
---@field file_extension string 文件扩展名

---@class note-manager.Note
---@field title string 笔记标题
---@field path string 文件路径
---@field created_at number 创建时间戳
---@field modified_at number 修改时间戳
---@field tags string[] 标签列表
---@field content string 笔记内容

---@class note-manager.Template
---@field name string 模板名称
---@field content string 模板内容

---@class note-manager.SearchOptions
---@field query string 搜索查询
---@field include_content boolean 是否搜索内容
---@field include_filename boolean 是否搜索文件名
---@field tags string[] 按标签过滤

---@class note-manager.SearchResult
---@field note note-manager.Note 匹配的笔记
---@field matches table[] 匹配的位置信息
---@field score number 匹配分数
```

## 第四步：实现核心功能

### 4.1 更新主模块

编辑 `lua/note-manager/init.lua`：

```lua
local log = require('note-manager.logger')
local M = {}

---Setup the note-manager plugin
---@param opts NoteManagerConfig: plugin options
M.setup = function(opts)
  log.info("Starting note-manager.nvim setup")
  
  -- 验证配置
  if not opts then
    log.warn("No configuration provided, using defaults")
    opts = {}
  end
  
  log.debug("Configuration:", vim.inspect(opts))
  
  -- 初始化配置
  local success, err = pcall(function()
    require("note-manager.config").setup(opts)
  end)
  
  if not success then
    log.error("Setup failed:", err)
    return false
  end
  
  -- 初始化其他模块
  require("note-manager.notes").init()
  require("note-manager.templates").init()
  require("note-manager.search").init()
  
  log.info("note-manager.nvim setup completed successfully")
  return true
end

---Create a new note
---@param template_name? string Template to use
M.new_note = function(template_name)
  log.debug("new_note() called with template:", template_name)
  return require("note-manager.notes").create_note(template_name)
end

---Search notes
---@param query? string Search query
M.search_notes = function(query)
  log.debug("search_notes() called with query:", query)
  return require("note-manager.search").search(query)
end

---List all notes
M.list_notes = function()
  log.debug("list_notes() called")
  return require("note-manager.notes").list_notes()
end

---Open a specific note
---@param note_name string Note name or path
M.open_note = function(note_name)
  log.debug("open_note() called with:", note_name)
  return require("note-manager.notes").open_note(note_name)
end

---Get available templates
---@return string[] Template names
M.get_templates = function()
  return require("note-manager.templates").get_template_names()
end

---Get note names for completion
---@return string[] Note names
M.get_note_names = function()
  return require("note-manager.notes").get_note_names()
end

-- 导出日志接口供用户使用
M.log = log

return M
```

### 4.2 实现笔记管理模块

创建 `lua/note-manager/notes.lua`：

```lua
local log = require('note-manager.logger')
local config = require('note-manager.config')
local templates = require('note-manager.templates')

local M = {}

---Initialize notes module
M.init = function()
  log.debug("Initializing notes module")
  -- 确保笔记目录存在
  local notes_dir = vim.fn.expand(config.options.notes_dir)
  if vim.fn.isdirectory(notes_dir) == 0 then
    log.info("Creating notes directory:", notes_dir)
    vim.fn.mkdir(notes_dir, "p")
  end
end

---Generate a unique note filename
---@param title? string Note title
---@return string filename
local function generate_filename(title)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  if title then
    -- 清理标题，移除特殊字符
    local clean_title = title:gsub("[^%w%s-]", ""):gsub("%s+", "_"):lower()
    return timestamp .. "_" .. clean_title .. config.options.file_extension
  else
    return timestamp .. "_note" .. config.options.file_extension
  end
end

---Replace template variables
---@param content string Template content
---@param vars table Variables to replace
---@return string Processed content
local function replace_template_vars(content, vars)
  vars = vars or {}
  vars.date = vars.date or os.date("%Y-%m-%d")
  vars.time = vars.time or os.date("%H:%M:%S")
  vars.datetime = vars.datetime or os.date("%Y-%m-%d %H:%M:%S")
  vars.cursor = vars.cursor or ""
  
  local result = content
  for key, value in pairs(vars) do
    result = result:gsub("{" .. key .. "}", tostring(value))
  end
  
  return result
end

---Create a new note
---@param template_name? string Template to use
---@param title? string Note title
---@return string|nil filepath Created note path
M.create_note = function(template_name, title)
  template_name = template_name or config.options.default_template
  
  log.info("Creating new note with template:", template_name)
  
  -- 获取模板
  local template = templates.get_template(template_name)
  if not template then
    log.error("Template not found:", template_name)
    vim.notify("Template '" .. template_name .. "' not found", vim.log.levels.ERROR)
    return nil
  end
  
  -- 获取标题
  if not title then
    title = vim.fn.input("Note title: ")
    if title == "" then
      log.warn("Note creation cancelled - no title provided")
      return nil
    end
  end
  
  -- 生成文件名和路径
  local filename = generate_filename(title)
  local filepath = vim.fn.expand(config.options.notes_dir) .. "/" .. filename
  
  -- 处理模板内容
  local content = replace_template_vars(template.content, {
    title = title,
    date = os.date("%Y-%m-%d"),
    time = os.date("%H:%M:%S")
  })
  
  -- 写入文件
  local file = io.open(filepath, "w")
  if not file then
    log.error("Failed to create note file:", filepath)
    vim.notify("Failed to create note: " .. filepath, vim.log.levels.ERROR)
    return nil
  end
  
  file:write(content)
  file:close()
  
  log.info("Note created successfully:", filepath)
  log.structured("info", "note_created", {
    template = template_name,
    title = title,
    filepath = filepath,
    size = #content
  })
  
  -- 打开文件
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  
  -- 找到光标位置（如果模板中有 {cursor} 标记）
  local cursor_pos = content:find("{cursor}")
  if cursor_pos then
    -- 计算行号和列号
    local lines = vim.split(content:sub(1, cursor_pos), "\n")
    local line = #lines
    local col = #lines[#lines]
    vim.api.nvim_win_set_cursor(0, {line, col})
  end
  
  vim.notify("Note created: " .. title, vim.log.levels.INFO)
  return filepath
end

---Get all notes in the notes directory
---@return note-manager.Note[] notes
M.get_all_notes = function()
  local notes_dir = vim.fn.expand(config.options.notes_dir)
  local files = vim.fn.glob(notes_dir .. "/*" .. config.options.file_extension, false, true)
  
  local notes = {}
  for _, filepath in ipairs(files) do
    local stat = vim.loop.fs_stat(filepath)
    if stat and stat.type == "file" then
      local filename = vim.fn.fnamemodify(filepath, ":t:r")
      local title = filename:gsub("^%d+_%d+_", ""):gsub("_", " ")
      
      table.insert(notes, {
        title = title,
        path = filepath,
        created_at = stat.birthtime.sec,
        modified_at = stat.mtime.sec,
        tags = {},  -- TODO: 从文件内容中提取标签
        content = ""  -- 按需加载
      })
    end
  end
  
  -- 按修改时间排序
  table.sort(notes, function(a, b)
    return a.modified_at > b.modified_at
  end)
  
  return notes
end

---List all notes in a floating window
M.list_notes = function()
  local notes = M.get_all_notes()
  
  if #notes == 0 then
    vim.notify("No notes found in " .. config.options.notes_dir, vim.log.levels.INFO)
    return
  end
  
  log.info("Listing", #notes, "notes")
  
  -- 创建缓冲区内容
  local lines = {}
  table.insert(lines, "📝 Notes (" .. #notes .. ")")
  table.insert(lines, string.rep("─", 50))
  
  for i, note in ipairs(notes) do
    local date = os.date("%Y-%m-%d %H:%M", note.modified_at)
    local line = string.format("%2d. %-30s %s", i, note.title, date)
    table.insert(lines, line)
  end
  
  -- 创建浮动窗口
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  
  -- 计算窗口尺寸
  local width = math.min(config.options.ui.width, vim.o.columns - 4)
  local height = math.min(config.options.ui.height, #lines + 2, vim.o.lines - 4)
  
  -- 创建窗口
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = config.options.ui.border,
    title = " Note Manager ",
    title_pos = "center"
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- 设置按键映射
  local function open_note(index)
    vim.api.nvim_win_close(win, false)
    if notes[index] then
      vim.cmd("edit " .. vim.fn.fnameescape(notes[index].path))
    end
  end
  
  -- 数字键打开对应笔记
  for i = 1, math.min(9, #notes) do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      callback = function() open_note(i) end,
      noremap = true,
      silent = true
    })
  end
  
  -- 回车键打开当前行的笔记
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(win)[1]
      local index = line - 2  -- 减去标题行
      if index > 0 and index <= #notes then
        open_note(index)
      end
    end,
    noremap = true,
    silent = true
  })
  
  -- ESC 和 q 关闭窗口
  for _, key in ipairs({'<ESC>', 'q'}) do
    vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
      callback = function() vim.api.nvim_win_close(win, false) end,
      noremap = true,
      silent = true
    })
  end
  
  -- 设置光标位置（跳过标题行）
  vim.api.nvim_win_set_cursor(win, {3, 0})
end

---Open a note by name or path
---@param note_name string Note name or path
M.open_note = function(note_name)
  if not note_name or note_name == "" then
    log.warn("No note name provided")
    return
  end
  
  local notes = M.get_all_notes()
  local found_note = nil
  
  -- 按标题搜索
  for _, note in ipairs(notes) do
    if note.title:lower():find(note_name:lower(), 1, true) then
      found_note = note
      break
    end
  end
  
  -- 如果没找到，按文件名搜索
  if not found_note then
    for _, note in ipairs(notes) do
      local filename = vim.fn.fnamemodify(note.path, ":t:r")
      if filename:lower():find(note_name:lower(), 1, true) then
        found_note = note
        break
      end
    end
  end
  
  if found_note then
    log.info("Opening note:", found_note.title)
    vim.cmd("edit " .. vim.fn.fnameescape(found_note.path))
  else
    log.warn("Note not found:", note_name)
    vim.notify("Note not found: " .. note_name, vim.log.levels.WARN)
  end
end

---Get note names for completion
---@return string[] Note names
M.get_note_names = function()
  local notes = M.get_all_notes()
  local names = {}
  for _, note in ipairs(notes) do
    table.insert(names, note.title)
  end
  return names
end

return M
```

### 4.3 实现模板系统

创建 `lua/note-manager/templates.lua`：

```lua
local log = require('note-manager.logger')
local config = require('note-manager.config')

local M = {}

---Initialize templates module
M.init = function()
  log.debug("Initializing templates module")
end

---Get a template by name
---@param name string Template name
---@return note-manager.Template|nil template
M.get_template = function(name)
  local template = config.options.templates[name]
  if template then
    log.debug("Found template:", name)
    return template
  else
    log.warn("Template not found:", name)
    return nil
  end
end

---Get all template names
---@return string[] Template names
M.get_template_names = function()
  local names = {}
  for name, _ in pairs(config.options.templates) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

---Add or update a template
---@param name string Template name
---@param template note-manager.Template Template data
M.set_template = function(name, template)
  log.info("Setting template:", name)
  config.options.templates[name] = template
end

---Remove a template
---@param name string Template name
M.remove_template = function(name)
  log.info("Removing template:", name)
  config.options.templates[name] = nil
end

return M
```

### 4.4 实现搜索功能

创建 `lua/note-manager/search.lua`：

```lua
local log = require('note-manager.logger')
local config = require('note-manager.config')

local M = {}

---Initialize search module
M.init = function()
  log.debug("Initializing search module")
end

---Search notes
---@param query? string Search query
M.search = function(query)
  if not query or query == "" then
    query = vim.fn.input("Search notes: ")
    if query == "" then
      return
    end
  end
  
  log.info("Searching notes with query:", query)
  
  local notes = require('note-manager.notes').get_all_notes()
  local results = {}
  
  for _, note in ipairs(notes) do
    local score = 0
    local matches = {}
    
    -- 搜索标题
    if config.options.search.include_filename then
      local title_match = note.title:lower():find(query:lower(), 1, true)
      if title_match then
        score = score + 10
        table.insert(matches, {type = "title", position = title_match})
      end
    end
    
    -- 搜索内容
    if config.options.search.include_content then
      local file = io.open(note.path, "r")
      if file then
        local content = file:read("*all")
        file:close()
        
        local content_match = content:lower():find(query:lower(), 1, true)
        if content_match then
          score = score + 5
          table.insert(matches, {type = "content", position = content_match})
        end
      end
    end
    
    if score > 0 then
      table.insert(results, {
        note = note,
        matches = matches,
        score = score
      })
    end
  end
  
  -- 按分数排序
  table.sort(results, function(a, b)
    return a.score > b.score
  end)
  
  -- 限制结果数量
  if #results > config.options.search.max_results then
    results = vim.list_slice(results, 1, config.options.search.max_results)
  end
  
  log.info("Found", #results, "matching notes")
  
  if #results == 0 then
    vim.notify("No notes found matching: " .. query, vim.log.levels.INFO)
    return
  end
  
  -- 显示搜索结果
  M.show_search_results(query, results)
end

---Show search results in a floating window
---@param query string Search query
---@param results note-manager.SearchResult[] Search results
M.show_search_results = function(query, results)
  local lines = {}
  table.insert(lines, "🔍 Search: " .. query .. " (" .. #results .. " results)")
  table.insert(lines, string.rep("─", 50))
  
  for i, result in ipairs(results) do
    local score_bar = string.rep("★", math.floor(result.score / 2))
    local line = string.format("%2d. %-25s %s", i, result.note.title, score_bar)
    table.insert(lines, line)
  end
  
  -- 创建浮动窗口
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  
  local width = math.min(config.options.ui.width, vim.o.columns - 4)
  local height = math.min(config.options.ui.height, #lines + 2, vim.o.lines - 4)
  
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = 'minimal',
    border = config.options.ui.border,
    title = " Search Results ",
    title_pos = "center"
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- 设置按键映射
  local function open_result(index)
    vim.api.nvim_win_close(win, false)
    if results[index] then
      vim.cmd("edit " .. vim.fn.fnameescape(results[index].note.path))
    end
  end
  
  -- 数字键和回车键
  for i = 1, math.min(9, #results) do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      callback = function() open_result(i) end,
      noremap = true,
      silent = true
    })
  end
  
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(win)[1]
      local index = line - 2
      if index > 0 and index <= #results then
        open_result(index)
      end
    end,
    noremap = true,
    silent = true
  })
  
  -- 关闭窗口
  for _, key in ipairs({'<ESC>', 'q'}) do
    vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
      callback = function() vim.api.nvim_win_close(win, false) end,
      noremap = true,
      silent = true
    })
  end
  
  vim.api.nvim_win_set_cursor(win, {3, 0})
end

return M
```

### 4.5 创建日志包装器

创建 `lua/note-manager/logger.lua`：

```lua
-- lua/note-manager/logger.lua
-- Note Manager 日志系统包装器
local vlog = require('note-manager.log')

-- 创建 note-manager.nvim 专用的日志实例
local log = vlog.new {
  plugin = 'note-manager.nvim',
  use_console = true,
  highlights = true,
  use_file = true,
  level = vim.env.NOTE_MANAGER_LOG_LEVEL or "info",
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

-- 添加结构化日志支持
function log.structured(level, event, data)
  local msg = string.format("[%s] %s", event, vim.inspect(data))
  log[level](msg)
end

-- 添加条件日志支持（生产环境优化）
local is_debug = vim.env.NODE_ENV ~= "production"

local original_trace = log.trace
local original_debug = log.debug

function log.trace(...)
  if is_debug then
    original_trace(...)
  end
end

function log.debug(...)
  if is_debug then
    original_debug(...)
  end
end

return log
```

### 4.6 复制日志核心文件

```bash
# 复制 vlog.nvim 核心文件
cp lua/base/log.lua lua/note-manager/log.lua
```

## 第五步：编写测试

### 5.1 更新健康检查

编辑 `lua/note-manager/health.lua`：

```lua
local log = require('note-manager.logger')
local M = {}

---Validate the options table obtained from merging defaults and user options
local function validate_opts_table()
  local opts = require("note-manager.config").options
  
  local ok, err = pcall(function()
    vim.validate {
      notes_dir = { opts.notes_dir, "string" },
      default_template = { opts.default_template, "string" },
      file_extension = { opts.file_extension, "string" }
    }
  end)
  
  if not ok then
    vim.health.error("Invalid setup options: " .. err)
    log.error("Health check: Invalid options", err)
  else
    vim.health.ok("Configuration options are valid")
    log.info("Health check: Configuration validated")
  end
end

---This function is used to check the health of the plugin
---It's called by `:checkhealth note-manager` command
M.check = function()
  vim.health.start("note-manager.nvim health check")
  
  log.debug("Running health check")
  
  -- 检查 Neovim 版本
  if vim.fn.has('nvim-0.10') == 1 then
    vim.health.ok("Neovim version >= 0.10")
    log.info("Neovim version check passed")
  else
    vim.health.error("Neovim version < 0.10")
    log.error("Neovim version check failed")
  end
  
  -- 检查笔记目录
  local notes_dir = vim.fn.expand(require("note-manager.config").options.notes_dir)
  if vim.fn.isdirectory(notes_dir) == 1 then
    vim.health.ok("Notes directory exists: " .. notes_dir)
    log.info("Notes directory check passed:", notes_dir)
    
    -- 检查目录权限
    local test_file = notes_dir .. "/.health_check_test"
    local file = io.open(test_file, "w")
    if file then
      file:close()
      os.remove(test_file)
      vim.health.ok("Notes directory is writable")
      log.debug("Directory write permission check passed")
    else
      vim.health.error("Cannot write to notes directory")
      log.error("Directory write permission check failed")
    end
  else
    vim.health.warn("Notes directory not found: " .. notes_dir)
    log.warn("Notes directory check failed:", notes_dir)
  end
  
  -- 检查日志系统
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
  
  -- 检查模板
  local templates = require("note-manager.templates").get_template_names()
  if #templates > 0 then
    vim.health.ok("Templates available: " .. table.concat(templates, ", "))
    log.info("Template check passed:", #templates, "templates found")
  else
    vim.health.warn("No templates configured")
    log.warn("No templates found")
  end
  
  validate_opts_table()
end

return M
```

### 5.2 编写单元测试

编辑 `spec/note-manager_spec.lua`：

```lua
-- spec/note-manager_spec.lua
describe("note-manager.nvim", function()
  local note_manager
  local test_dir = "/tmp/note_manager_test"
  
  before_each(function()
    -- 清理测试环境
    package.loaded['note-manager'] = nil
    package.loaded['note-manager.config'] = nil
    package.loaded['note-manager.logger'] = nil
    
    -- 创建测试目录
    vim.fn.system("rm -rf " .. test_dir)
    vim.fn.mkdir(test_dir, "p")
    
    note_manager = require('note-manager')
  end)
  
  after_each(function()
    -- 清理测试目录
    vim.fn.system("rm -rf " .. test_dir)
  end)
  
  it("should load without errors", function()
    assert.is_not_nil(note_manager)
    assert.is_function(note_manager.setup)
    assert.is_function(note_manager.new_note)
    assert.is_function(note_manager.search_notes)
    assert.is_function(note_manager.list_notes)
  end)
  
  it("should setup with default configuration", function()
    local result = note_manager.setup({
      notes_dir = test_dir
    })
    assert.is_true(result)
  end)
  
  it("should setup with custom configuration", function()
    local result = note_manager.setup({
      notes_dir = test_dir,
      default_template = "daily",
      file_extension = ".txt",
      log = {
        level = "debug",
        use_console = false
      }
    })
    assert.is_true(result)
    
    local config = require('note-manager.config').options
    assert.equals(test_dir, config.notes_dir)
    assert.equals("daily", config.default_template)
    assert.equals(".txt", config.file_extension)
  end)
  
  it("should expose log interface", function()
    note_manager.setup({ notes_dir = test_dir })
    assert.is_not_nil(note_manager.log)
    assert.is_function(note_manager.log.info)
    assert.is_function(note_manager.log.error)
  end)
  
  it("should get template names", function()
    note_manager.setup({ notes_dir = test_dir })
    local templates = note_manager.get_templates()
    assert.is_table(templates)
    assert.is_true(#templates > 0)
    assert.is_true(vim.tbl_contains(templates, "basic"))
  end)
end)

describe("note-manager notes module", function()
  local notes
  local test_dir = "/tmp/note_manager_test"
  
  before_each(function()
    package.loaded['note-manager.notes'] = nil
    package.loaded['note-manager.config'] = nil
    package.loaded['note-manager.templates'] = nil
    
    vim.fn.system("rm -rf " .. test_dir)
    vim.fn.mkdir(test_dir, "p")
    
    require('note-manager').setup({
      notes_dir = test_dir,
      log = { use_console = false, use_file = false }
    })
    
    notes = require('note-manager.notes')
  end)
  
  after_each(function()
    vim.fn.system("rm -rf " .. test_dir)
  end)
  
  it("should initialize notes module", function()
    assert.has_no.errors(function()
      notes.init()
    end)
  end)
  
  it("should get empty note list initially", function()
    local all_notes = notes.get_all_notes()
    assert.is_table(all_notes)
    assert.equals(0, #all_notes)
  end)
  
  it("should get note names for completion", function()
    local names = notes.get_note_names()
    assert.is_table(names)
    assert.equals(0, #names)
  end)
end)

describe("note-manager templates module", function()
  local templates
  
  before_each(function()
    package.loaded['note-manager.templates'] = nil
    package.loaded['note-manager.config'] = nil
    
    require('note-manager').setup({
      notes_dir = "/tmp/test",
      log = { use_console = false, use_file = false }
    })
    
    templates = require('note-manager.templates')
  end)
  
  it("should initialize templates module", function()
    assert.has_no.errors(function()
      templates.init()
    end)
  end)
  
  it("should get template names", function()
    local names = templates.get_template_names()
    assert.is_table(names)
    assert.is_true(#names > 0)
    assert.is_true(vim.tbl_contains(names, "basic"))
    assert.is_true(vim.tbl_contains(names, "daily"))
    assert.is_true(vim.tbl_contains(names, "meeting"))
  end)
  
  it("should get template by name", function()
    local basic_template = templates.get_template("basic")
    assert.is_not_nil(basic_template)
    assert.is_string(basic_template.name)
    assert.is_string(basic_template.content)
    assert.equals("Basic Note", basic_template.name)
  end)
  
  it("should return nil for non-existent template", function()
    local template = templates.get_template("non_existent")
    assert.is_nil(template)
  end)
  
  it("should set and get custom template", function()
    local custom_template = {
      name = "Custom Template",
      content = "# Custom\n\n{cursor}"
    }
    
    templates.set_template("custom", custom_template)
    local retrieved = templates.get_template("custom")
    
    assert.is_not_nil(retrieved)
    assert.equals("Custom Template", retrieved.name)
    assert.equals("# Custom\n\n{cursor}", retrieved.content)
  end)
  
  it("should remove template", function()
    templates.set_template("temp", { name = "Temp", content = "temp" })
    local before = templates.get_template("temp")
    assert.is_not_nil(before)
    
    templates.remove_template("temp")
    local after = templates.get_template("temp")
    assert.is_nil(after)
  end)
end)
```

## 第六步：更新文档

### 6.1 更新 Vim 帮助文档

编辑 `doc/note-manager.txt`：

```
*note-manager.txt*    A powerful note management plugin for Neovim

==============================================================================
CONTENTS                                             *note-manager-contents*

    1. Introduction ........................ |note-manager-introduction|
    2. Setup ............................... |note-manager-setup|
    3. Commands ............................ |note-manager-commands|
    4. Configuration ....................... |note-manager-configuration|
    5. Templates ........................... |note-manager-templates|
    6. API ................................. |note-manager-api|
    7. License ............................. |note-manager-license|

==============================================================================
1. INTRODUCTION                                  *note-manager-introduction*

Note Manager is a powerful note management plugin for Neovim that provides
an intuitive way to create, organize, and manage notes directly within your
editor.

Features:
  • Quick note creation with templates
  • Full-text search across all notes
  • Tag-based organization
  • Customizable templates
  • Integrated logging system
  • Floating window interface

==============================================================================
2. SETUP                                                *note-manager-setup*

Add this to your configuration:

For lazy.nvim: >
    {
      "your-username/note-manager.nvim",
      config = function()
        require("note-manager").setup({
          notes_dir = "~/notes",
          default_template = "basic",
        })
      end
    }
<

For packer.nvim: >
    use {
      "your-username/note-manager.nvim",
      config = function()
        require("note-manager").setup()
      end
    }
<

==============================================================================
3. COMMANDS                                          *note-manager-commands*

:NoteNew [template]                                            *:NoteNew*
    Create a new note using the specified template.
    If no template is provided, uses the default template.

:NoteSearch [query]                                         *:NoteSearch*
    Search notes by title and content.
    If no query is provided, prompts for input.

:NoteList                                                    *:NoteList*
    Show all notes in a floating window.

:NoteOpen {name}                                              *:NoteOpen*
    Open a specific note by name or partial match.

==============================================================================
4. CONFIGURATION                                *note-manager-configuration*

Default configuration: >
    require("note-manager").setup({
      notes_dir = "~/notes",          -- Notes directory
      default_template = "basic",     -- Default template
      file_extension = ".md",         -- File extension
      
      log = {
        level = "info",               -- Log level
        use_console = true,           -- Console output
        use_file = true,              -- File output
        highlights = true,            -- Color highlights
      },
      
      search = {
        ignore_case = true,           -- Case-insensitive search
        include_content = true,       -- Search file content
        include_filename = true,      -- Search file names
        max_results = 50,             -- Maximum results
      },
      
      ui = {
        width = 80,                   -- Window width
        height = 20,                  -- Window height
        border = "rounded",           -- Border style
        preview = true,               -- Show preview
      }
    })
<

==============================================================================
5. TEMPLATES                                        *note-manager-templates*

Built-in templates:

basic ~
    A simple note template with title and content.

daily ~
    A daily note template with sections for planning and summary.

meeting ~
    A meeting notes template with agenda and action items.

Custom templates can be added in the configuration: >
    require("note-manager").setup({
      templates = {
        project = {
          name = "Project Note",
          content = [[
# Project: {title}

## Overview

## Goals
- 

## Tasks
- [ ] 

## Notes

---
Tags: project
]]
        }
      }
    })
<

Template variables:
  {title}    - Note title
  {date}     - Current date (YYYY-MM-DD)
  {time}     - Current time (HH:MM:SS)
  {datetime} - Current datetime
  {cursor}   - Cursor position marker

==============================================================================
6. API                                                    *note-manager-api*

require("note-manager").setup({opts})                  *note-manager.setup()*
    Initialize the plugin with configuration options.

require("note-manager").new_note({template})        *note-manager.new_note()*
    Create a new note with the specified template.

require("note-manager").search_notes({query})    *note-manager.search_notes()*
    Search notes with the given query.

require("note-manager").list_notes()              *note-manager.list_notes()*
    Show all notes in a floating window.

require("note-manager").open_note({name})          *note-manager.open_note()*
    Open a note by name.

require("note-manager").get_templates()          *note-manager.get_templates()*
    Get list of available template names.

require("note-manager").log                            *note-manager.log*
    Access to the logging interface.

==============================================================================
7. LICENSE                                            *note-manager-license*

MIT License. See LICENSE file for details.

vim:tw=78:ts=8:ft=help:norl:
```

### 6.2 更新项目 README

编辑根目录的 `README.md`：

```markdown
# 📝 note-manager.nvim

一个强大的 Neovim 笔记管理插件，让你在编辑器中轻松创建、组织和管理笔记。

![Demo](https://via.placeholder.com/800x400?text=Note+Manager+Demo)

## ✨ 特性

- 📝 **快速创建笔记** - 使用预定义模板快速创建结构化笔记
- 🔍 **全文搜索** - 在所有笔记中搜索标题和内容
- 🏷️ **标签管理** - 使用标签组织和分类笔记
- 📋 **模板系统** - 内置多种模板，支持自定义模板
- 🪟 **浮动窗口** - 美观的浮动窗口界面
- 📊 **集成日志** - 完整的日志系统，便于调试和监控
- ⚡ **高性能** - 优化的搜索和加载性能
- 🎨 **可定制** - 丰富的配置选项

## 📦 安装

### lazy.nvim (推荐)

```lua
{
  "your-username/note-manager.nvim",
  dependencies = {
    -- 可选依赖
  },
  config = function()
    require("note-manager").setup({
      notes_dir = "~/Documents/notes",
      default_template = "daily",
      log = {
        level = "info"
      }
    })
  end,
  cmd = {
    "NoteNew",
    "NoteSearch", 
    "NoteList",
    "NoteOpen"
  },
  keys = {
    { "<leader>nn", "<cmd>NoteNew<cr>", desc = "New note" },
    { "<leader>ns", "<cmd>NoteSearch<cr>", desc = "Search notes" },
    { "<leader>nl", "<cmd>NoteList<cr>", desc = "List notes" },
  }
}
```

### packer.nvim

```lua
use {
  "your-username/note-manager.nvim",
  config = function()
    require("note-manager").setup({
      notes_dir = "~/notes"
    })
  end
}
```

### vim-plug

```vim
Plug 'your-username/note-manager.nvim'

lua << EOF
require("note-manager").setup({
  notes_dir = "~/notes"
})
EOF
```

## 🚀 快速开始

### 基本使用

```vim
" 创建新笔记
:NoteNew

" 使用特定模板创建笔记
:NoteNew meeting

" 搜索笔记
:NoteSearch project

" 列出所有笔记
:NoteList

" 打开特定笔记
:NoteOpen daily-review
```

### 推荐按键映射

```lua
vim.keymap.set("n", "<leader>nn", "<cmd>NoteNew<cr>", { desc = "New note" })
vim.keymap.set("n", "<leader>ns", "<cmd>NoteSearch<cr>", { desc = "Search notes" })
vim.keymap.set("n", "<leader>nl", "<cmd>NoteList<cr>", { desc = "List notes" })
vim.keymap.set("n", "<leader>no", "<cmd>NoteOpen<cr>", { desc = "Open note" })
```

## ⚙️ 配置

### 默认配置

```lua
require("note-manager").setup({
  -- 基本设置
  notes_dir = "~/notes",           -- 笔记目录
  default_template = "basic",      -- 默认模板
  file_extension = ".md",          -- 文件扩展名
  
  -- 日志设置
  log = {
    level = "info",                -- 日志级别: trace, debug, info, warn, error, fatal
    use_console = true,            -- 控制台输出
    use_file = true,               -- 文件输出
    highlights = true,             -- 语法高亮
  },
  
  -- 搜索设置
  search = {
    ignore_case = true,            -- 忽略大小写
    include_content = true,        -- 搜索文件内容
    include_filename = true,       -- 搜索文件名
    max_results = 50,              -- 最大结果数
  },
  
  -- UI 设置
  ui = {
    width = 80,                    -- 窗口宽度
    height = 20,                   -- 窗口高度
    border = "rounded",            -- 边框样式: "none", "single", "double", "rounded"
    preview = true,                -- 启用预览
  },
  
  -- 模板设置
  templates = {
    -- 内置模板会自动加载
    -- 你可以在这里添加自定义模板
  }
})
```

### 自定义模板

```lua
require("note-manager").setup({
  templates = {
    -- 项目笔记模板
    project = {
      name = "Project Note",
      content = [[
# Project: {title}

**Created**: {date}
**Status**: Planning

## 📋 Overview

## 🎯 Goals
- 

## ✅ Tasks
- [ ] 

## 📝 Notes

## 🔗 Resources

---
Tags: project, {date}
]]
    },
    
    -- 学习笔记模板
    learning = {
      name = "Learning Note",
      content = [[
# 📚 {title}

**Date**: {date}
**Topic**: 
**Source**: 

## 🎯 Learning Objectives
- 

## 📝 Key Points
- 

## 💡 Insights
- 

## 🔄 Review
- [ ] Review in 1 day
- [ ] Review in 1 week
- [ ] Review in 1 month

---
Tags: learning, {date}
]]
    }
  }
})
```

## 📚 模板系统

### 内置模板

| 模板名称 | 描述 | 用途 |
|---------|------|------|
| `basic` | 基础笔记模板 | 通用笔记 |
| `daily` | 日常笔记模板 | 日常规划和总结 |
| `meeting` | 会议笔记模板 | 会议记录 |

### 模板变量

在模板中可以使用以下变量：

- `{title}` - 笔记标题
- `{date}` - 当前日期 (YYYY-MM-DD)
- `{time}` - 当前时间 (HH:MM:SS)
- `{datetime}` - 完整日期时间
- `{cursor}` - 光标位置标记

### 创建自定义模板

```lua
-- 运行时添加模板
local templates = require("note-manager.templates")

templates.set_template("custom", {
  name = "My Custom Template",
  content = [[
# {title}

Created on {date} at {time}

## Content

{cursor}

---
Custom template
]]
})
```

## 🔍 搜索功能

### 搜索语法

```vim
" 基本搜索
:NoteSearch keyword

" 搜索多个关键词
:NoteSearch project planning

" 交互式搜索（无参数时弹出输入框）
:NoteSearch
```

### 搜索结果导航

在搜索结果窗口中：

- `1-9`: 直接打开对应编号的笔记
- `Enter`: 打开当前行的笔记
- `q` 或 `Esc`: 关闭搜索窗口
- `↑/↓`: 上下导航

## 🛠️ 开发

### 环境准备

```bash
# 克隆项目
git clone https://github.com/your-username/note-manager.nvim.git
cd note-manager.nvim

# 安装依赖
luarocks install busted
luarocks install nlua
```

### 运行测试

```bash
# 运行所有测试
busted

# 运行特定测试文件
busted spec/note-manager_spec.lua

# 运行日志相关测试
busted spec/log_spec.lua
```

### 健康检查

```vim
:checkhealth note-manager
```

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [tjdevries/vlog.nvim](https://github.com/tjdevries/vlog.nvim) - 优秀的日志系统
- [base.nvim](https://github.com/your-username/base.nvim) - 插件模板基础

## 📮 支持

如有问题或建议，请：

- 提交 [Issue](https://github.com/your-username/note-manager.nvim/issues)
- 发起 [Discussion](https://github.com/your-username/note-manager.nvim/discussions)
- 查看 [Wiki](https://github.com/your-username/note-manager.nvim/wiki)

---

**⭐ 如果这个项目对你有帮助，请给它一个星标！**
```

## 第七步：本地测试

### 7.1 设置本地开发环境

创建测试配置文件 `test-config.lua`：

```lua
-- test-config.lua
-- 用于本地测试的配置文件

-- 添加本地插件路径
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- 设置测试目录
local test_notes_dir = "/tmp/note_manager_test_" .. os.time()

-- 初始化插件
require("note-manager").setup({
  notes_dir = test_notes_dir,
  default_template = "basic",
  log = {
    level = "debug",  -- 开发时使用 debug 级别
    use_console = true,
    use_file = true
  },
  ui = {
    width = 60,
    height = 15
  }
})

-- 创建测试数据
local notes = require("note-manager.notes")

-- 创建一些测试笔记
notes.create_note("daily", "今日计划")
notes.create_note("meeting", "团队会议")
notes.create_note("basic", "随手记")

print("✅ 测试环境已设置完成")
print("📂 测试目录: " .. test_notes_dir)
print("🔧 可用命令: :NoteList, :NoteSearch, :NoteNew")
```

### 7.2 本地测试流程

```bash
# 1. 启动 Neovim 并加载测试配置
nvim -u test-config.lua

# 2. 测试基本功能
:NoteList              # 应该显示 3 个测试笔记
:NoteSearch 会议       # 应该找到会议笔记
:NoteNew project       # 创建新笔记

# 3. 测试健康检查
:checkhealth note-manager

# 4. 查看日志
:lua print(vim.fn.stdpath('data') .. '/note-manager.nvim.log')
```

### 7.3 运行自动化测试

```bash
# 运行所有测试
busted

# 运行特定模块测试
busted --pattern="notes"

# 运行测试并显示详细输出
busted --verbose

# 生成测试覆盖率报告
busted --coverage
```

### 7.4 性能测试

创建 `perf-test.lua`：

```lua
-- perf-test.lua
-- 性能测试脚本

local function create_test_notes(count)
  local notes = require("note-manager.notes")
  local start_time = vim.loop.hrtime()
  
  for i = 1, count do
    notes.create_note("basic", "Performance Test Note " .. i)
  end
  
  local end_time = vim.loop.hrtime()
  local duration = (end_time - start_time) / 1000000  -- 转换为毫秒
  
  print(string.format("✅ 创建 %d 个笔记耗时: %.2f ms", count, duration))
  print(string.format("📊 平均每个笔记: %.2f ms", duration / count))
end

local function test_search_performance(query)
  local search = require("note-manager.search")
  local start_time = vim.loop.hrtime()
  
  search.search(query)
  
  local end_time = vim.loop.hrtime()
  local duration = (end_time - start_time) / 1000000
  
  print(string.format("🔍 搜索 '%s' 耗时: %.2f ms", query, duration))
end

-- 运行性能测试
print("🚀 开始性能测试...")

create_test_notes(100)
test_search_performance("test")
test_search_performance("performance")

print("✅ 性能测试完成")
```

## 第八步：发布插件

### 8.1 准备发布

#### 更新版本信息

编辑 `note-manager.nvim-scm-1.rockspec`：

```lua
-- 更新为正式版本
local spec = {
  name = "note-manager.nvim",
  version = "1.0.0-1",  -- 版本格式: major.minor.patch-revision
  source = {
    url = "git+https://github.com/your-username/note-manager.nvim.git",
    tag = "v1.0.0",  -- 对应 git tag
  },
  -- ... 其他配置保持不变
}
```

#### 更新 CHANGELOG

创建 `CHANGELOG.md`：

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-07-20

### Added
- Initial release of note-manager.nvim
- Note creation with template system
- Full-text search functionality
- Floating window interface
- Built-in templates (basic, daily, meeting)
- Comprehensive logging system
- Health check support
- Complete test suite

### Features
- 📝 Quick note creation with customizable templates
- 🔍 Full-text search across all notes
- 🪟 Beautiful floating window interface
- 📋 Built-in and custom template support
- 📊 Integrated logging with multiple levels
- ⚙️ Extensive configuration options
- 🧪 Comprehensive test coverage

### Documentation
- Complete usage guide in Chinese
- API reference documentation
- Architecture diagrams (Mermaid)
- Development tutorial
- Best practices guide

### Technical
- Based on base.nvim template
- Integrated vlog.nvim for logging
- Lua 5.1+ compatible
- Neovim 0.10+ required
- Zero external dependencies
```

#### 最终检查清单

创建 `pre-release-checklist.md`：

```markdown
# 发布前检查清单

## 📋 代码质量
- [ ] 所有测试通过 (`busted`)
- [ ] 健康检查正常 (`:checkhealth note-manager`)
- [ ] 代码符合风格指南 (`.editorconfig`)
- [ ] 无未处理的 TODO 或 FIXME
- [ ] 日志级别设置合理

## 📚 文档
- [ ] README.md 完整且准确
- [ ] API 文档更新 (`doc/note-manager.txt`)
- [ ] CHANGELOG.md 记录所有变更
- [ ] 使用指南完整 (`docs/usage-zh.md`)
- [ ] 架构图准确 (`docs/architecture.md`)

## 🔧 配置文件
- [ ] rockspec 文件正确
- [ ] 版本号一致
- [ ] GitHub workflows 配置正确
- [ ] .gitignore 包含必要排除项

## 🧪 测试
- [ ] 单元测试覆盖率 > 80%
- [ ] 集成测试通过
- [ ] 性能测试满意
- [ ] 在不同 Neovim 版本测试

## 📦 发布准备
- [ ] Git tags 创建
- [ ] Release notes 准备
- [ ] LuaRocks 上传准备
- [ ] GitHub release 准备
```

### 8.2 GitHub 发布流程

#### 创建 Git Tag

```bash
# 提交所有更改
git add .
git commit -m "feat: prepare for v1.0.0 release"

# 创建并推送标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main
git push origin v1.0.0
```

#### 创建 GitHub Release

1. 访问 GitHub 仓库
2. 点击 "Releases" → "Create a new release"
3. 选择标签 `v1.0.0`
4. 填写发布信息：

```markdown
# 🎉 Note Manager v1.0.0 - 首次发布

一个强大的 Neovim 笔记管理插件，让你在编辑器中轻松管理笔记！

## ✨ 主要特性

- 📝 **智能模板系统** - 内置多种模板，支持自定义
- 🔍 **全文搜索** - 快速搜索标题和内容
- 🪟 **浮动窗口** - 美观的用户界面
- 📊 **完整日志** - 集成 vlog.nvim 日志系统
- ⚡ **高性能** - 优化的搜索和加载

## 🚀 快速开始

```lua
-- lazy.nvim
{
  "your-username/note-manager.nvim",
  config = function()
    require("note-manager").setup({
      notes_dir = "~/notes"
    })
  end
}
```

## 📖 文档

- [使用指南](docs/usage-zh.md)
- [开发教程](docs/plugin-development-tutorial.md)
- [架构文档](docs/architecture.md)

## 🙏 致谢

感谢所有贡献者和 base.nvim 模板项目！

**完整变更日志请查看 [CHANGELOG.md](CHANGELOG.md)**
```

### 8.3 LuaRocks 发布

#### 准备 LuaRocks 账号

```bash
# 注册 LuaRocks 账号（如果没有）
# 访问 https://luarocks.org/register

# 配置 API key
luarocks config --scope user

# 或直接设置
luarocks config user.api_key "your-api-key"
```

#### 上传到 LuaRocks

```bash
# 验证 rockspec 文件
luarocks lint note-manager.nvim-1.0.0-1.rockspec

# 测试本地安装
luarocks build note-manager.nvim-1.0.0-1.rockspec

# 上传到 LuaRocks
luarocks upload note-manager.nvim-1.0.0-1.rockspec

# 验证上传成功
luarocks search note-manager
```

### 8.4 社区推广

#### 创建推广文档

创建 `promotion-plan.md`：

```markdown
# 插件推广计划

## 🎯 目标社区

### Reddit
- [ ] r/neovim - 主要 Neovim 社区
- [ ] r/vim - Vim/Neovim 用户群体
- [ ] r/programming - 程序员社区

### Discord/Telegram
- [ ] Neovim Discord 服务器
- [ ] Vim/Neovim Telegram 群组

### 中文社区
- [ ] V2EX - 创意工作者社区
- [ ] 知乎 - Neovim 相关话题
- [ ] 掘金 - 技术文章发布

## 📝 推广内容模板

### Reddit 帖子模板
标题: "🎉 Introducing note-manager.nvim - A powerful note management plugin for Neovim"

内容:
- 项目介绍和特性
- GIF 演示
- 安装和使用指南
- 社区反馈邀请

### 博客文章大纲
1. 为什么需要在编辑器中管理笔记
2. note-manager.nvim 的设计理念
3. 主要功能演示
4. 与其他笔记工具的对比
5. 未来发展计划

## 📊 推广时间表

### Week 1: 初期发布
- [ ] GitHub Release
- [ ] LuaRocks 上传
- [ ] Reddit r/neovim 发布
- [ ] 个人博客文章

### Week 2: 扩大影响
- [ ] 中文社区推广
- [ ] 收集反馈和改进
- [ ] 更新文档

### Week 3+: 持续维护
- [ ] 回应 issues
- [ ] 功能改进
- [ ] 社区建设
```

## 第九步：持续维护

### 9.1 版本管理策略

#### 语义化版本控制

遵循 [Semantic Versioning](https://semver.org/) 规范：

- **MAJOR** (1.x.x): 不兼容的 API 更改
- **MINOR** (x.1.x): 向后兼容的功能添加
- **PATCH** (x.x.1): 向后兼容的问题修复

#### 分支管理

```bash
# 主要分支
main          # 稳定版本，对应最新发布
develop       # 开发分支，集成新功能

# 功能分支
feature/xxx   # 新功能开发
bugfix/xxx    # 问题修复
hotfix/xxx    # 紧急修复
```

### 9.2 用户反馈处理

#### Issue 模板

创建 `.github/ISSUE_TEMPLATE/bug_report.md`：

```markdown
---
name: Bug Report
about: 报告插件问题
title: '[BUG] '
labels: bug
assignees: ''
---

## 🐛 问题描述
简洁清晰地描述问题是什么。

## 🔄 复现步骤
1. 执行 '...'
2. 点击 '....'
3. 滚动到 '....'
4. 出现错误

## 💡 期望行为
清晰简洁地描述你期望发生的事情。

## 📱 环境信息
- OS: [例如 macOS 12.6]
- Neovim 版本: [例如 0.10.0]
- 插件版本: [例如 v1.0.0]
- 配置信息: [相关配置]

## 📋 额外信息
添加任何有助于解释问题的其他上下文或截图。

## 🔍 健康检查
请运行 `:checkhealth note-manager` 并粘贴结果:

```
[粘贴健康检查结果]
```

## 📊 日志信息
如果适用，请提供相关的日志信息:

```
[粘贴日志信息]
```
```

#### 功能请求模板

创建 `.github/ISSUE_TEMPLATE/feature_request.md`：

```markdown
---
name: Feature Request
about: 建议新功能
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## 🚀 功能建议
简洁清晰地描述你想要什么功能。

## 🤔 问题背景
清晰简洁地描述这个功能要解决什么问题。例如：我总是对 [...] 感到沮丧

## 💡 解决方案
清晰简洁地描述你想要发生的事情。

## 🔄 替代方案
清晰简洁地描述你考虑过的任何替代解决方案或功能。

## 📋 额外上下文
在这里添加有关功能请求的任何其他上下文或截图。

## ✅ 验收标准
- [ ] 功能要求 1
- [ ] 功能要求 2
- [ ] 文档更新
- [ ] 测试覆盖
```

### 9.3 持续集成改进

#### 更新 GitHub Actions

编辑 `.github/workflows/ci.yml`：

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        neovim-version: ['0.10.0', 'nightly']
        lua-version: ['5.1', '5.4', 'luajit']
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Neovim
      uses: rhysd/action-setup-vim@v1
      with:
        neovim: true
        version: ${{ matrix.neovim-version }}
    
    - name: Setup Lua
      uses: leafo/gh-actions-lua@v10
      with:
        luaVersion: ${{ matrix.lua-version }}
    
    - name: Setup LuaRocks
      uses: leafo/gh-actions-luarocks@v4
    
    - name: Install dependencies
      run: |
        luarocks install busted
        luarocks install nlua
    
    - name: Run tests
      run: busted --verbose
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: matrix.neovim-version == '0.10.0' && matrix.lua-version == '5.1'
```

### 9.4 社区建设

#### 贡献指南

创建 `CONTRIBUTING.md`：

```markdown
# 贡献指南

感谢你对 note-manager.nvim 的兴趣！我们欢迎各种形式的贡献。

## 🤝 贡献方式

### 报告问题
- 使用 Issue 模板报告 bug
- 提供详细的复现步骤
- 包含环境信息和日志

### 建议功能
- 使用功能请求模板
- 解释使用场景和价值
- 考虑实现的复杂度

### 代码贡献
- Fork 项目并创建功能分支
- 遵循代码规范
- 添加测试和文档
- 提交 Pull Request

## 📝 开发规范

### 代码风格
- 使用 2 空格缩进
- 函数命名使用 snake_case
- 变量命名使用 camelCase
- 添加必要的类型注解

### 提交信息
遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范:

```
feat: 添加新功能
fix: 修复问题
docs: 更新文档
style: 代码格式调整
refactor: 重构代码
test: 添加测试
chore: 其他杂项
```

### 测试要求
- 所有新功能必须有测试
- 保持测试覆盖率 > 80%
- 运行 `busted` 确保所有测试通过

## 🔧 开发环境设置

```bash
# 1. Fork 并克隆项目
git clone https://github.com/your-username/note-manager.nvim.git
cd note-manager.nvim

# 2. 安装开发依赖
luarocks install busted
luarocks install nlua

# 3. 运行测试
busted

# 4. 本地测试插件
nvim -u test-config.lua
```

## 📋 Pull Request 流程

1. **创建分支**: `git checkout -b feature/your-feature`
2. **实现功能**: 编写代码和测试
3. **测试验证**: 确保所有测试通过
4. **更新文档**: 更新相关文档
5. **提交 PR**: 使用清晰的标题和描述
6. **代码审查**: 响应审查意见
7. **合并**: 通过审查后合并

## 🎯 开发优先级

### 高优先级
- 性能优化
- 稳定性改进
- 核心功能增强

### 中优先级
- 新模板添加
- UI/UX 改进
- 文档完善

### 低优先级
- 实验性功能
- 代码重构
- 工具链改进

## 🏆 贡献者认可

所有贡献者都会在以下地方获得认可：
- README.md 贡献者列表
- CHANGELOG.md 版本说明
- GitHub Release notes

感谢你的贡献！ 🎉
```

### 9.5 路线图规划

创建 `ROADMAP.md`：

```markdown
# note-manager.nvim 发展路线图

## 🎯 Version 1.1 (Q4 2024)

### 新功能
- [ ] 笔记链接系统 - 支持笔记间的双向链接
- [ ] 标签自动完成 - 智能标签建议和补全
- [ ] 笔记导出功能 - 支持 PDF、HTML 格式导出
- [ ] 快速笔记模式 - 无需模板的快速记录

### 改进
- [ ] 搜索性能优化 - 支持索引和缓存
- [ ] UI 响应性提升 - 异步操作和加载指示
- [ ] 配置热重载 - 无需重启即可应用配置更改
- [ ] 更多内置模板 - 添加更多专业模板

## 🚀 Version 1.2 (Q1 2025)

### 高级功能
- [ ] 笔记同步 - 支持 Git 自动同步
- [ ] 全文索引 - 基于 ripgrep 的高性能搜索
- [ ] 笔记统计 - 字数、阅读时间、创建频率统计
- [ ] 图片支持 - 内联图片显示和管理

### 集成
- [ ] Telescope 集成 - 更强大的搜索体验
- [ ] LSP 集成 - 笔记中的代码块语法支持
- [ ] 外部工具集成 - 支持 Obsidian、Notion 等

## 🌟 Version 2.0 (Q2 2025)

### 架构升级
- [ ] 插件化架构 - 支持第三方扩展
- [ ] 数据库后端 - SQLite 支持，提升性能
- [ ] 多语言支持 - 国际化和本地化
- [ ] 主题系统 - 自定义 UI 主题

### 高级特性
- [ ] AI 集成 - 智能摘要和标签建议
- [ ] 版本控制 - 笔记历史和恢复
- [ ] 协作功能 - 多用户编辑和评论
- [ ] 移动端支持 - 手机 App 同步

## 💡 社区建议

我们欢迎社区的想法和建议！请通过以下方式参与：

- 🗳️ [功能投票](https://github.com/your-username/note-manager.nvim/discussions)
- 💭 [讨论区](https://github.com/your-username/note-manager.nvim/discussions)
- 🐛 [问题报告](https://github.com/your-username/note-manager.nvim/issues)

## 📊 进展跟踪

你可以在以下地方跟踪开发进展：
- [GitHub Projects](https://github.com/your-username/note-manager.nvim/projects)
- [Milestones](https://github.com/your-username/note-manager.nvim/milestones)
- [Release Notes](https://github.com/your-username/note-manager.nvim/releases)

---

*路线图可能根据社区反馈和技术发展进行调整*
```

## 📝 总结

恭喜！你已经完成了一个完整的 Neovim 插件开发流程。这个教程涵盖了：

### ✅ 已完成的内容

1. **项目设置** - 从模板创建新项目
2. **核心开发** - 实现完整的功能模块
3. **测试编写** - 全面的测试覆盖
4. **文档撰写** - 用户和开发者文档
5. **本地测试** - 验证功能正确性
6. **发布流程** - GitHub 和 LuaRocks 发布
7. **社区建设** - 持续维护和改进

### 🎯 核心收获

- **模块化设计** - 清晰的代码组织
- **日志集成** - 专业的调试和监控
- **测试驱动** - 保证代码质量
- **文档优先** - 良好的用户体验
- **社区导向** - 可持续的项目发展

### 🚀 下一步建议

1. **实践项目** - 按照教程创建自己的插件
2. **功能扩展** - 添加更多创新功能
3. **社区参与** - 贡献开源项目
4. **经验分享** - 写博客分享经验

这个完整的教程为你提供了从零开始开发 Neovim 插件的所有必要知识。base.nvim 模板和集成的日志系统为你的开发工作提供了坚实的基础。

Happy coding! 🎉

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"id": "1", "content": "\u521b\u5efa\u4ece\u96f6\u5230\u4e00\u7684\u63d2\u4ef6\u5f00\u53d1\u6559\u7a0b", "status": "completed", "priority": "high"}, {"id": "2", "content": "\u5305\u542b\u6a21\u677f\u4f7f\u7528\u548c\u81ea\u5b9a\u4e49\u6b65\u9aa4", "status": "in_progress", "priority": "high"}, {"id": "3", "content": "\u6dfb\u52a0\u5b9e\u9645\u63d2\u4ef6\u5f00\u53d1\u793a\u4f8b", "status": "pending", "priority": "high"}, {"id": "4", "content": "\u5305\u542b\u53d1\u5e03\u548c\u7ef4\u62a4\u6307\u5357", "status": "pending", "priority": "medium"}]