# 13 · VGA 移动方块 vga_box

`vga_sync + 方块位置逻辑`：屏上一个方块匀速移动并碰壁反弹。

## 这一课学什么
- 在 VGA 时序基础上做“图形”：按 (x,y) 判断当前像素是否落在方块内
- 方块位置每帧更新（场同步沿），碰壁反向
- 动画的本质 = 每帧改坐标 + 实时渲染

> 软件类比：像游戏主循环——每帧更新精灵坐标、检测边界碰撞、再渲染。这里“渲染”是逐像素判断颜色。

## 运行
```bash
make        # 校验方块位置随帧推进且碰壁反弹
make wave
make clean
```

## 上板玩法
- 接 VGA 显示器看一个会动会反弹的方块；改速度/大小/颜色。

## 动手改
1. 加键盘/按键控制方块移动（做成 Pong）。
2. 多方块 + 碰撞检测。

## 对应真实开源项目
- VGA 图形/游戏经典：[fpga4fun Pong](https://www.fpga4fun.com/PongGame.html)、[Project F](https://projectf.io/posts/fpga-graphics/)；时序内核见本仓 `advanced/03_vga`。
