---
name: catppuccin-palette
description: 提供 Catppuccin 配色方案的完整色值参考，无需联网即可查询。当用户询问 catppuccin、mocha、latte、frappé、macchiato 配色方案、色值、颜色表、颜色代码、十六进制颜色、catppuccin 颜色、theme palette、某颜色名称（如 rosewater、flamingo、mauve、peach 等）时，无论用户是否明确提及"技能"或"配色"，都应使用此技能。
---

# Catppuccin 配色表技能

本技能提供 Catppuccin 四种风味（Latte、Frappé、Macchiato、Mocha）的完整配色数据，供 AI 直接读取使用，无需联网查询。

## 工作流程

### 1. 判断用户询问的风味

根据用户提示中出现的词汇确定是哪种风味：

| 用户关键词 | 对应文件 |
|-----------|---------|
| mocha、Mocha、默认深色 | `references/mocha.md` |
| latte、Latte、浅色 | `references/latte.md` |
| frappé、Frappé | `references/frappe.md` |
| macchiato、Macchiato | `references/macchiato.md` |
| 未指定（通用询问） | 以 `references/mocha.md` 为默认，同时提供四种风味概览 |

### 2. 读取对应配色文件

根据步骤 1 的判断，读取 `references/` 目录下对应的 `.md` 文件。

- 读取单个文件：使用 Read 工具
- 对比多个风味（如"frappé 和 mocha 有什么区别"）：并行读取多个文件

### 3. 输出格式

回答配色查询时，按以下规则组织输出：

**简单颜色值查询**（如"猫草绿是什么颜色"）：
直接给出该颜色的 Hex 值和 RGB 值即可。

**完整配色表查询**（如"ctp mocha 的配色表"）：
输出完整的 Markdown 表格，包含以下列：

| 角色 | Hex | RGB |
|------|-----|-----|
| Rosewater | #f5e0dc | rgb(245, 224, 220) |

表格行顺序固定为：Rosewater → Flamingo → Pink → Mauve → Red → Maroon → Peach → Yellow → Green → Teal → Sky → Sapphire → Blue → Lavender → Text → Subtext 1 → Subtext 0 → Overlay 2 → Overlay 1 → Overlay 0 → Surface 2 → Surface 1 → Surface 0 → Base → Mantle → Crust（共 26 行）。

**特别说明：**
- Surface 0 是多数组件的背景色
- Base 是主要背景色
- Text 是主要文本色
- 回答时可以不展示 HSL 和 OKLCH 值，除非用户明确要求；它们仅作为参考数据存在于文件中

### 4. 主题搭配建议

用户询问配色用途或建议时：
- 强调 Red/Flamingo 用于错误和警告
- Green/Teal 用于成功和确认
- Yellow/Peach 用于提示信息
- Mauve/Blue/Pink 用于语法高亮关键字
- Surface 系列用于 UI 面板、侧边栏、弹窗
- Text 和 Subtext X 用于不同层级的文本

### 5. 关于未来版本

如果用户询问 Catppuccin 新版本或更新，告知他们配色表数据来自版本定义文件，当前已收录的数据是最新的。

## 彩蛋

Mocha 是最常用的风味，也是 Catppuccin 的"原版"风味——最深、色彩最丰富的变体。用户提到 Mocha 时若无特别说明，直接提供 mocha 配色数据即可。
