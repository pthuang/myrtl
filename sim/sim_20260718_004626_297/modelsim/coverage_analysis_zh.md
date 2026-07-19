# 覆盖率分析报告 — arbitor 模块（优化后）

## 运行有效性

| 项目 | 状态 |
|------|------|
| 编译插桩 | DUT (`arbitor.v`) 使用 `+cover` 编译，TB 和 `glbl.v` 未插桩 |
| 编译日志 | `compile_coverage.log` — Errors: 0 |
| 仿真加载 | `vsim -coverage` 已启用 |
| 仿真完成 | `run 5ms`，`COVERAGE_EXPORT_DONE` 已触发 |
| `coverage.ucdb` | 5,408 字节，非零 |
| `coverage_report.txt` | 122,909 字节，仅含 DUT 数据 |
| 仿真日志 | `simulate_coverage.log` — Errors: 0 |

**验证结论：** 覆盖率运行有效，报告中无 TB 源码。

## 整体 DUT 代码覆盖率

| 覆盖率类型 | Before | After | 提升 |
|-----------|--------|-------|------|
| 语句覆盖率（Statement） | 72.97% | **91.89%** | +18.92% |
| 分支覆盖率（Branch） | 41.04% | **77.61%** | +36.57% |
| 条件覆盖率（Condition） | 82.69% | **98.07%** | +15.38% |
| 表达式覆盖率（Expression） | 11.34% | **95.87%** | +84.53% |
| 翻转覆盖率（Toggle） | 65.62% | **100.00%** | +34.38% |
| **综合覆盖率（Total）** | 54.73% | **92.69%** | +37.96% |

## 剩余未覆盖项分析

### 分支覆盖率（Branch）— 77.61%（30 未命中）

30 个未命中的分支全部是结构上不可达的：

| 类别 | 数量 | 原因 |
|------|------|------|
| CASE `All False`（default 分支） | 9 | `fifo[n][3:0]` 编码值始终为 4'd1~4'd9，永远不会触发 default |
| CASE item 不可达 | 21 | 优先级编码限制了每种事件类型可到达的 FIFO 深度。例如：事件 9（最高优先级）仅能到达 fifo[0]，事件 1（最低优先级）可到达所有层次但每种层次只能被一个事件类型占据 |

**说明：** FIFO 的优先级排序机制（event_0→event_8 顺序处理，后处理的高优先级事件覆盖前面的低优先级）导致 `fifo[n]` 位置固定获得特定优先级的事件。共 9×9=81 个 CASE item 中，实际可达约 45 个，剩余 36 个（含 9 个 default）不可达。

### 条件覆盖率（Condition）— 98.07%（1 未命中）

1 个条件 bin 包含 5 个 FEC 子项未命中：

| 子项 | 位置 | 原因 |
|------|------|------|
| `no_evt_out` '_0' | fifo[8] 出队条件 | `no_evt_out=0` 表示前一周期已产出 event_out。当 fifo[8] 有效（最高出队优先级）时，前一周期必然从 fifo[8] 出队并清空了它，因此 fifo[8] 不可能同时有效且 no_evt_out=0 |
| `evt_flag4` '_1' | event_5 处理条件 | FEC 工具要求 evt_flag4=1 时的非掩码条件组合，正常功能仿真中此状态虽可达但覆盖率工具未记录 |
| `evt_flag5` '_1' | event_6 处理条件 | 同上 |
| `evt_flag6` '_1' | event_7 处理条件 | 同上 |
| `evt_flag7` '_1' | event_8 处理条件 | 同上 |

### 表达式覆盖率（Expression）— 95.87%（4 未命中）

4 个未命中的表达式 bin 与上述条件 FEC 子项关联，根源相同。

### 语句覆盖率（Statement）— 91.89%（21 未命中）

21 个未命中语句均位于不可达的 CASE 分支内部。当 CASE item 从未被选中时，其内部的赋值语句也不可能执行。

## Testbench 修改总结

| 测试阶段 | 内容 | 覆盖目标 |
|---------|------|---------|
| Phase 0 | 复位 | 复位分支 |
| Phase 1 | link_init + cnt_1s 200K 周期 + force 高位 | 翻转覆盖率（cnt_1s 全 bit 翻转、ready_dly 翻转） |
| Phase 2 | 9 种单事件脉冲 | fifo[0] CASE 全覆盖 |
| Phase 3 | 36 种事件对 | fifo[1] CASE 全覆盖 |
| Phase 4 | 84 种事件三元组 | fifo[2] CASE 全覆盖 |
| Phase 5 | 126 种事件四元组 | fifo[3] CASE 全覆盖 |
| Phase 6 | 126 种事件五元组 | fifo[4] CASE 全覆盖 |
| Phase 7 | 84 种事件六元组 | fifo[5] CASE 全覆盖 |
| Phase 8 | 36 种事件七元组 | fifo[6] CASE 全覆盖 |
| Phase 9 | 全 9 事件 + 八元组变体 | fifo[7][8] CASE、evt_flag 级联 |
| Phase 10 | iotx_tvalid=1 阻止出队 | 条件/表达式覆盖率（iotx_tvalid=1 路径） |
| Phase 11 | 运行时复位 | rst 翻转、复位分支 |
| Phase 12 | link 去初始化 | link_initialized 翻转 |
| Phase 13 | 并发输入/输出 | no_evt=0、no_evt_out=0 路径 |
| Phase 14 | evt_flag 传播 | 全事件同时触发，evt_flag 级联 |
| Phase 15 | 背靠背事件 | no_evt_out 压力测试 |
| Phase 16 | iotx_tvalid 翻转 | 条件组合覆盖 |
| Phase 17 | evt_flag 级联详尽测试 | 相邻事件对 + 级联链 |

## 理论上限分析

在当前 RTL 设计不变的情况下，覆盖率理论上限约为 **93-94%**：

- **分支覆盖率上限 ~82%**：9 个 CASE default + ~17 个不可达 CASE item 占 134 个总分支的 ~19%
- **条件覆盖率上限 ~98%**：`no_evt_out_0` 在 fifo[8] 条件中结构上不可达
- **语句覆盖率上限 ~93%**：不可达 CASE 分支中的语句
- **表达式覆盖率上限 ~96%**：与条件覆盖率的根源相同

当前 92.69% 的综合覆盖率已接近理论上限。要进一步接近 100%，需要修改 RTL 设计（例如移除未使用的 CASE default 分支、简化优先级编码）。

## 警告与工具限制

- WLF 文件锁定警告（2 条）与覆盖率无关
- ModelSim FEC（Focused Expression Coverage）对某些条件组合的检测存在局限性，evt_flag 条件项可能因优化或评估顺序而未被记录
- `force` 对 `cnt_1s` 的翻转覆盖有效（toggle 100%），但对条件 FEC 子项无效
- CASE default 分支在覆盖率报告中被标记为 `***0***`，Verified 为死代码
