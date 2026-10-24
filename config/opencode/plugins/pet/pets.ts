// 猫的 5 帧。改图只动这个文件。
// 规矩：一帧里每行必须等宽；别用中文/emoji（占 2 格）。
// eye 的 row / col 都从 0 数：眼睛在第 row 行、从第 col 个字符开始、占 width 格。

export type EyeSpot = { row: number; col: number; width: number }

export type PetArt = {
  id: string
  name: string
  frames: string[][]
  eye: EyeSpot
  waveRight?: number
  waveLeft?: number
  jump?: number
  walkRight?: number
  walkLeft?: number
  tail?: number[]
}

export const CAT: PetArt = {
  id: "cat",
  name: "ollie",
  eye: { row: 1, col: 4, width: 3 },
  waveRight: 2,
  waveLeft: 3,
  jump: 4,
  walkRight: 5,
  walkLeft: 6,
  tail: [7, 8],
  frames: [
    // 0 待机
    [
      "   /\\_/\\    ",
      "  ( o.o )   ",
      "   > ^ <    ",
      "  /|   |\\  *",
      " (_|   |_)* ",
    ],
    // 1 眨眼
    [
      "   /\\_/\\    ",
      "  ( O.O )   ",
      "   > ^ <    ",
      "  /|   |\\  *",
      " (_|   |_)* ",
    ],
    // 2 右招手
    [
      "   /\\_/\\    ",
      "  ( o.o ) / ",
      "   > ^ < /  ",
      "  /|    \\  *",
      " (_|    _)* ",
    ],
    // 3 左招手
    [
      "   /\\_/\\    ",
      "\\ ( o.o )   ",
      " \\ > ^ <    ",
      "  /    |\\  *",
      " (_    |_)* ",
    ],
    // 4 跳跃（星星眼）
    [
      "   /\\_/\\    ",
      "  ( *.* )   ",
      "   > v <    ",
      "  /|   |\\  *",
      " (_|   |_)* ",
    ],
    // 5 往右迈一步（脑袋先右）
    [
      "    /\\_/\\   ",
      "   ( -.- )  ",
      "   > ^  <   ",
      "  /|   |\\  *",
      " (_|   |_)* ",
    ],
    // 6 往左迈一步（脑袋先左）
    [
      "  /\\_/\\     ",
      " ( -.- )    ",
      "  >  ^ <    ",
      "  /|   |\\  *",
      " (_|   |_)* ",
    ],
    // 7 摇尾巴（垂着）
    [
      "   /\\_/\\    ",
      "  ( o.o )   ",
      "   > ^ <    ",
      "  /|   |\\   ",
      " (_|   |_) *",
    ],
    // 8 摇尾巴（翘起来）
    [
      "   /\\_/\\    ",
      "  ( o.o )  *",
      "   > ^ <  * ",
      "  /|   |\\   ",
      " (_|   |_)  ",
    ],
  ],
}
