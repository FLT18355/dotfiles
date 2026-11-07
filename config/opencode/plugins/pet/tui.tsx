/** @jsxImportSource @opentui/solid */
import { For, createEffect, createMemo, createSignal, onCleanup, onMount, untrack } from "solid-js"
import { CAT } from "./pets"

// 侧栏猫。图在 pets.ts，这里全是逻辑。
// 点它 → 跳 + 星星眼；鼠标在左半/右半 → 朝那边招手 + 眼睛转圈；按累计 token 升级。

const TICK_MS = 150 // 动画心跳
const POLL_MS = 15_000 // 查 token 间隔
const XP_PER_LEVEL = 20_000
const JUMP_HEIGHT = 3 // 跳多高（行），也给上方预留等量空格
const SPIN = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]

// level = floor(log2(xp / 2e4 + 1)) + 1，永不封顶
const levelOf = (xp: number) => {
  const points = Math.log2(Math.max(0, xp) / XP_PER_LEVEL + 1)
  return { level: Math.floor(points) + 1, progress: points % 1 }
}

const formatTokens = (n: number) => {
  if (n >= 1e9) return `${(n / 1e9).toFixed(2)}B`
  if (n >= 1e6) return `${(n / 1e6).toFixed(1)}M`
  if (n >= 1e3) return `${Math.round(n / 1e3)}k`
  return String(n)
}

const totalTokens = (t: any) =>
  !t ? 0 : (t.input ?? 0) + (t.output ?? 0) + (t.reasoning ?? 0) + (t.cache?.read ?? 0) + (t.cache?.write ?? 0)

// 把一行拆成「左 / 眼睛 / 右」，只给眼睛那段换颜色
function segments(line: string, row: number, pupil: string) {
  const { eye } = CAT
  // pupil 为空 = 用图里自带的眼睛（跳跃帧的 *.*）
  if (row !== eye.row || pupil === "")
    return [{ text: line, eye: false }]
  const chars = [...line]
  return [
    { text: chars.slice(0, eye.col).join(""), eye: false },
    { text: `${pupil}.${pupil}`, eye: true },
    { text: chars.slice(eye.col + eye.width).join(""), eye: false },
  ]
}

function Pet(props: {
  context: any
  xp: () => number
  tick: () => number
  poke: () => number
  pos: () => number
  walking: () => number
  hover: () => boolean
  setHover: (v: boolean) => void
  wag: () => number
}) {
  const theme = props.context.theme
  const [hoverAt, setHoverAt] = createSignal(-99)
  const [lastMove, setLastMove] = createSignal(-99)
  const [jumpAt, setJumpAt] = createSignal(-99)
  const [side, setSide] = createSignal<"left" | "right">("right")

  const t = () => props.tick()
  const sinceJump = () => t() - jumpAt()
  const jumping = () => sinceJump() >= 0 && sinceJump() < 5

  // 跳跃高度曲线：1 2 3 2 1
  const lift = () => {
    if (!jumping()) return 0
    const d = sinceJump()
    return d === 0 || d === 4 ? 1 : d === 1 || d === 3 ? 2 : 3
  }

  const pupil = () => {
    if (props.walking() !== 0) return "" // 走路用图里自带的 -.-

    if (props.hover()) {
      const held = t() - hoverAt()
      if (held < 13) return "^" // 先往上看 2 秒（每格 150ms）
      return SPIN[(held - 13) % SPIN.length] // 再转圈
    }
    // 不碰也眨眼：每 3 秒 o -> - -> o（20 格 × 150ms）
    if (t() % 20 < 2) return "-"
    return "o"
  }

  // 帧优先级：跳 > 悬停招手 > 走路 > 待机
  const frame = createMemo(() => {
    if (jumping() && CAT.jump !== undefined) return CAT.frames[CAT.jump]
    if (props.hover()) {
      const idx = side() === "left" ? CAT.waveLeft : CAT.waveRight
      if (idx !== undefined) return CAT.frames[idx]
    }
    const walk = props.walking()
    if (walk !== 0) {
      const idx = walk > 0 ? CAT.walkRight : CAT.walkLeft
      if (idx !== undefined) return CAT.frames[idx]
    }
    // 摇尾巴：4 秒一次，两帧来回甩 0.9 秒（每半摆 0.3 秒）
    const since = t() - props.wag()
    if (CAT.tail && since >= 0 && since < 6) {
      const idx = CAT.tail[Math.floor(since / 2) % CAT.tail.length]
      if (idx !== undefined) return CAT.frames[idx]
    }
    return CAT.frames[0]
  })

  const level = () => levelOf(props.xp())
  const bar = () => {
    const filled = Math.round(level().progress * 16)
    return { on: "=".repeat(filled), off: "-".repeat(16 - filled) }
  }

  const pickSide = (event: any) => {
    // event.x 与 screenX 都是绝对坐标，比中线就知道在左半还是右半
    const self = event.currentTarget
    const half = (self?.screenX ?? 0) + (self?.width ?? 0) / 2
    setSide(event.x < half ? "left" : "right")
  }

  const enter = (event: any) => {
    setLastMove(t())
    pickSide(event)
    if (props.hover()) return
    setHoverAt(t())
    props.setHover(true)
  }

  // 每次挂载（切换对话/打开侧栏）和每发一条消息都跳一下
  createEffect(() => {
    props.poke()
    setJumpAt(untrack(() => props.tick()))
  })

  // 鼠标快速移出终端时收不到 mouseout，靠“多久没有鼠标事件”兜底清掉悬停
  createEffect(() => {
    if (props.hover() && t() - lastMove() > 13) props.setHover(false)
  })

  return (
    <box flexDirection="column" paddingTop={JUMP_HEIGHT}>
      <box alignSelf="center" flexDirection="column" alignItems="center">
        {/* 只有猫本身左右移动，名字和等级条保持居中 */}
        <box
          flexDirection="column"
          position="relative"
          left={props.pos()}
          onMouseMove={enter}
          onMouseOver={enter}
          onMouseOut={() => props.setHover(false)}
          onMouseDown={() => {
            if (!jumping()) setJumpAt(t())
          }}
        >
          {/* 负 margin 把猫往上顶，正的抵回来 → 只动猫，下面的文字不动 */}
          <box flexDirection="column" marginTop={-lift()} marginBottom={lift()}>
          <For each={frame()}>
            {(line, row) => (
              <box flexDirection="row">
                <For each={segments(line, row(), jumping() ? "" : pupil())}>
                  {(seg) => (
                    <text fg={seg.eye ? theme.text.feedback.warning.base : theme.text.base} selectable={false}>
                      {seg.text}
                    </text>
                  )}
                </For>
              </box>
            )}
          </For>
          </box>
        </box>
        <text fg={theme.text.base} selectable={false}>
          {CAT.name}
        </text>
        <text fg={theme.text.feedback.success.base} selectable={false}>
          {`abil.${level().level}  ${formatTokens(props.xp())}`}
        </text>
        <box flexDirection="row">
          <text fg={theme.text.feedback.success.base} selectable={false}>
            {bar().on}
          </text>
          <text fg={theme.text.muted} selectable={false}>
            {bar().off}
          </text>
        </box>
      </box>
    </box>
  )
}

export default {
  id: "opencode-pet",
  setup(context: any) {
    const [pet, updatePet] = context.storage.store("opencode-pet", { initial: { best: 0 } })
    const [tick, setTick] = createSignal(0)
    const [poke, setPoke] = createSignal(0)
    const [hover, setHover] = createSignal(false)
    const [wag, setWag] = createSignal(-99)
    const [pos, setPos] = createSignal(0) // 离中线的格子数
    const [walking, setWalking] = createSignal(0) // 0 停 / 1 右 / -1 左

    // 每 5 秒走一格，范围 ±6，来回循环
    // 脑袋先歪过去 0.2s，身子再跟上，看起来才像迈步
    let dir = 1
    let leanTimer: ReturnType<typeof setTimeout> | undefined
    let settleTimer: ReturnType<typeof setTimeout> | undefined
    const walk = setInterval(() => {
      if (hover()) return // 鼠标在猫身上/附近时停下脚步
      let step = dir
      let next = pos() + step
      if (next > 6 || next < -6) {
        dir = -dir
        step = dir
        next = pos() + step
      }
      setWalking(step)
      clearTimeout(leanTimer)
      clearTimeout(settleTimer)
      leanTimer = setTimeout(() => setPos(next), 200)
      settleTimer = setTimeout(() => setWalking(0), 500)
    }, 5_000)

    let count = 0
    const beat = setInterval(() => setTick(++count), TICK_MS)

    // 每 4 秒甩一次尾巴
    const wagTimer = setInterval(() => setWag(count), 4_000)

    let timer: ReturnType<typeof setTimeout> | undefined
    const refresh = async () => {
      try {
        const result: any = await context.client.session.stats({})
        const total = totalTokens((result?.data ?? result)?.tokens)
        if (!total || total <= pet.best) return
        const before = levelOf(pet.best).level
        const seen = pet.best > 0
        await updatePet((draft: any) => {
          draft.best = total
        })
        const after = levelOf(total).level
        if (seen && after > before) {
          context.ui.toast.show({
            title: "宠物升级",
            message: `abil.${before} -> abil.${after}`,
            variant: "success",
            duration: 3000,
          })
        }
      } catch {
        // 统计接口不可用时保持上次等级
      }
    }

    const schedule = () => {
      clearTimeout(timer)
      timer = setTimeout(() => void refresh(), 800)
    }

    void refresh()
    const poll = setInterval(() => void refresh(), POLL_MS)
    const stopEvents = [
      context.data.on("session.execution.succeeded", schedule),
      context.data.on("session.execution.failed", schedule),
      // 用户每发一次消息就逗猫一下
      context.data.on("session.inbox.enqueued", () => setPoke((n: number) => n + 1)),
    ]

    const disposeSlot = context.ui.slot({
      append: "sidebar.content",
      render: () => (
        <Pet
          context={context}
          xp={() => pet.best}
          tick={tick}
          poke={poke}
          pos={pos}
          walking={walking}
          hover={hover}
          setHover={setHover}
          wag={wag}
        />
      ),
    })

    return () => {
      disposeSlot()
      for (const stop of stopEvents) stop()
      clearInterval(poll)
      clearInterval(beat)
      clearInterval(wagTimer)
      clearInterval(walk)
      clearTimeout(leanTimer)
      clearTimeout(settleTimer)
      clearTimeout(timer)
    }
  },
}
