# ollie —— OpenCode V2 侧栏宠物

养在 OpenCode 侧栏里的一只猫。会眨眼、会摇尾巴、会左右溜达；鼠标移到左半/右半它会朝那边招手，点它会跳，发消息、切换对话它也会跳一下。按累计 token 算 `abil`。

---

## ⚠️ 请用 git clone 安装，不要用 npm

**npm 包（`opencode-pet-v2`）装上去能用，但是坏的。**

具体表现：

- 猫能画出来，但**完全静止**：不眨眼、不招手、不摇尾巴，点了也不跳
- 永远贴在侧栏**最底部**，还会挡住别的侧栏内容

原因在 OpenCode 加载 TUI 插件的那条路径上：以 npm 包形式加载时，插件用的是**包自己 `node_modules` 里的 `solid-js` / `@opentui/solid` 副本**；而放在配置目录里被自动发现时，OpenCode 会把这些 import 重写到它自己的运行时。两份运行时不互通，信号变了画面也不刷新，所以是一只植物猫。

排查过的情况：

| 加载方式 | 会不会动 |
|---|---|
| `<配置目录>/plugins/pet/` 自动发现 | ✅ 正常 |
| `cli.json` 里写本地路径 | ✅ 正常（但排侧栏最后） |
| npm 包（自带 peer 依赖） | ❌ 静止 |
| npm 包（去掉自带依赖） | ❌ 直接加载失败 |
| npm 包（编译成 dist/tui.js） | ❌ 仍然静止 |

结论：目前只有**把源码放进配置目录**这条路是好的。所以安装方式就是 `git clone`。

---

## 安装

```bash
git clone git@github.com:linxuan-sys/opencode-pet-v2.git ~/.config/opencode/plugins/pet
```

用 HTTPS 也行：

```bash
git clone https://github.com/linxuan-sys/opencode-pet-v2.git ~/.config/opencode/plugins/pet
```

然后**完全退出并重开 OpenCode**，猫就出现在侧栏。

> 目录必须放在 `~/.config/opencode/plugins/<任意名字>/` 下，OpenCode 会自动发现，不需要写进 `opencode.json` 或 `cli.json`。

### 如果之前用 npm 装过

先清掉，否则会出现两只猫或者一只植物猫：

```bash
opencode plugin remove opencode-pet-v2
rm -rf ~/.cache/opencode/npm/opencode-pet-v2@latest
```

（`cli.json` 的 `plugins` 里如果还留着 `opencode-pet-v2`，一并删掉。）

---

## 文件结构

```text
pet/
├── pets.ts    # 只放美术：帧、眼睛位置、名字
├── tui.tsx    # 只放逻辑：动画、鼠标、走路、token 升级
├── LICENSE    # MIT
└── README.md
```

### pets.ts

```ts
export const CAT: PetArt = {
  id: "cat",
  name: "ollie",                      // 显示的名字
  eye: { row: 1, col: 4, width: 3 },  // 眼睛在第 1 行、第 4 列、占 3 格
  waveRight: 2,   // 鼠标在右半边用哪帧
  waveLeft: 3,    // 鼠标在左半边用哪帧
  jump: 4,        // 点击 / 发消息用哪帧
  walkRight: 5,   // 往右迈步用哪帧
  walkLeft: 6,    // 往左迈步用哪帧
  tail: [7, 8],   // 摇尾巴的两帧，交替
  frames: [ /* ... */ ],
}
```

改图只有三条规矩：

1. **一帧 5 行，每行必须等宽**（现在都是 12 格）
2. **别用中文和 emoji**，它们占 2 格会把整行推歪
3. 索引是顺序，改了帧的顺序记得同步改 `waveRight` 这些数字

查宽度：

```bash
cd ~/.config/opencode/plugins/pet
bun -e 'import { CAT } from "./pets.ts"; CAT.frames.forEach((f, i) => console.log(i, f.map((l) => l.length).join(",")))'
```

### tui.tsx 顶部常量

```ts
const TICK_MS = 150        // 动画心跳，所有节奏的基准
const POLL_MS = 15_000     // 查 token 间隔
const XP_PER_LEVEL = 20_000
const JUMP_HEIGHT = 3      // 跳多高（也决定上方预留多少空行）
```

节奏相关的几处：

- 眨眼：`t() % 20 < 2` —— 每 3 秒闭眼 0.3 秒（`-.-`）
- 摇尾巴：每 4 秒一次，两帧各 0.3 秒，共 0.9 秒
- 走路：每 5 秒一格，范围 ±6，走到边界掉头
- 招手：悬停先 0.75 秒往上看（`^^`），再转圈

等级公式（`levelOf`）：

```text
abil = floor(log2(tokens / 20000 + 1)) + 1
```

不封顶。3.15B ≈ `abil.18`。

数据存在 OpenCode 的插件存储里，只记录见过的最大 token 数，删了就回到 1 级。

---

## 已知限制

- token 统计依赖 `session.stats` 接口，上游改了会静默失败（等级不动，不崩）
- 走路的横移靠 `position: relative` + `left`，如果哪天侧栏特别窄，猫走到 ±6 会贴边
- 切换对话时猫会跳一下：这是故意的（组件重新挂载就触发一次跳跃）

## 许可

MIT，见 [LICENSE](./LICENSE)。
