# 4A 架构图 draw.io 模板库（Draw.io Diagram Templates）

> **定位**：三架构蓝图需要可视化交付时（评审、汇报、评审会答辩），MUST 参照本文件生成 draw.io 可编辑源文件。
> 所有架构图输出 `.drawio` 可编辑源文件（+ 可选 `.png` 预览图），可在 draw.io / diagrams.net / VS Code 插件（hediet.vscode-drawio）中继续编辑。

---

## 1. 通用规范（Apply to ALL 4A diagrams）

### 1.1 draw.io XML 文件结构模板

生成的 `.drawio` 文件 MUST 包含完整 XML 结构：

```xml
<mxfile host="Claude" modified="YYYY-MM-DD" agent="WorkBuddy" version="24.0.0">
  <diagram name="Page-1" id="Page-1">
    <mxGraphModel dx="1600" dy="1200" grid="1" gridSize="10" guides="1" tooltips="1"
                  connect="1" arrows="1" fold="1" page="1" pageScale="1"
                  pageWidth="1600" pageHeight="1200" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- 所有图形元素（mxCell），ID 从 "2" 起顺序编号 -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### 1.2 三架构专属配色体系（颜色语义化，全局一致）

| 架构层 | 容器底色 | 元素填充 | 边框色 | 语义 |
|--------|---------|---------|--------|------|
| **BA 业务架构** | `#FFF3E0` | `#FFE0B2` | `#F57C00` | 橙系 |
| **DA 数据架构** | `#F3E5F5` | `#E1BEE7` | `#8E24AA` | 紫系 |
| **AA 应用架构** | `#E3F2FD` | `#BBDEFB` | `#1E88E5` | 蓝系 |
| **L4 锚点（BO/服务/流程）** | — | `#FFF9C4` | `#F9A825` | 黄系高亮 |
| **占位/超范围节点** | — | `#FAFAFA` | `#BDBDBD` | 灰系虚线 |

### 1.3 专业制图原则

| 原则 | 说明 |
|------|------|
| **形状词汇表** | 泳道=架构层/价值阶段；圆角矩形=BO/服务/流程节点；圆柱=数据存储；菱形=映射网关 |
| **线型语义化** | 实线=N:1:1 映射主关系；虚线=占位/超范围；粗线=核心推导路径 |
| **最小化调色板** | 核心色 ≤ 5 个色系（三架构各一 + 锚点高亮 + 占位灰），彩色仅用于区分架构层 |
| **网格对齐** | 坐标取 10 的整数倍；同级节点等间距（20-40px） |
| **L4 恒居中** | 三架构总览图中 L4 锚点行水平居中对齐，凸显 N:1:1 推导逻辑 |
| **编号同步** | 图中节点编号（P-x.x.x / BO-xx / S-xx）MUST 与层次表/矩阵完全一致 |

### 1.4 交付规范

- **双文件交付**：`.drawio` 源文件 + `.png` 预览图（若本机安装 draw.io CLI 可自动导出，否则提示用户手动导出）
- **独立目录**：所有图表放 `项目文件夹/diagrams/` 目录
- **命名规范**：`[图表类型]-[场景名]-V[版本号].drawio`（如 `4a总览图-OTD订单交付-V1.0.drawio`）
- **多页结构**：复杂蓝图使用 draw.io 多页（每页一个架构层），页间用节点链接导航
- **完成度预期**：生成的 .drawio 为 90-95% 完成度，建议预留 15-30 分钟人工微调线条避让与间距

### 1.5 图表生成工作流

1. 用户提出可视化需求（或蓝图输出后主动建议）
2. 先以文字/ASCII 确认图型选择与节点范围（重大图型先给草图确认）
3. 生成完整 draw.io XML，写入 `.drawio` 文件
4. 尝试导出 PNG（draw.io CLI 可用则自动导出；否则告知手动导出方式）
5. 告知文件路径，提醒可在 draw.io 中打开微调

---

## 2. 4A 专属图型（7 类标准图）

### 2.1 三架构总览图（4A 分层主图）— 最高频使用

**适用场景**：蓝图评审、高管汇报、架构对齐答辩的第一页总览图。

**结构**：三个纵向泳道（BA/DA/AA），每泳道自上而下 L1→L5；L4 行水平对齐并高亮（N:1:1 推导锚点行）；跨泳道实线连线表达映射关系。

```
┌─────────────────────┬─────────────────────┬─────────────────────┐
│   BA 业务架构(橙)    │   DA 数据架构(紫)    │   AA 应用架构(蓝)    │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ L1 价值链: OTD      │ L1 主题域分组        │ L1 产品             │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ L2 价值阶段          │ L2 主题域           │ L2 子产品           │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ L3 业务环节          │ L3 主题子域         │ L3 应用/微服务       │
├═════════════════════┼═════════════════════┼═════════════════════┤
│ ★ L4 流程 P-…      │ ★ L4 BO（锚点）     │ ★ L4 服务（锚点）    │
├─────────────────────┼─────────────────────┼─────────────────────┤
│ L5 操作             │ L5 逻辑实体         │ L5 功能/接口         │
└─────────────────────┴─────────────────────┴─────────────────────┘
        N 条流程 ────(实线映射)────► 1 个 BO ◄──── 1:1 ──── 1 个服务
```

**关键规则**：
- L4 行用粗边框/高亮底色（`#FFF9C4`）显著区分（N:1:1 推导的核心视觉锚点）
- BA→DA 连线标注映射关系；DA→AA 固定 1:1（可合并为一条粗线）
- 节点过多时 L5 层可折叠（附注"详见层次表"），L1-L4 MUST 全展

### 2.2 BA 价值链图（L1-L3）

**结构**：横向价值流——L2 价值阶段为横向泳道段（左→右按业务时序），L3 业务环节为泳道内节点；上方标注 L1 价值链名称与参照框架（如"从订单到交付（OTD）｜参照 SCOR / APQC PCF Cat.4"）。

```
L1: 从订单到交付 OTD（参照：SCOR 正向循环 / APQC PCF 4.x）
┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ 订单接入  │ 订单计划  │ 寻源与采购│ 制造执行  │ 质量管理  │ 仓储发运  │
│ 与评审    │ 与承诺    │          │          │          │ 与交付    │
├──────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│·技术图纸  │·主生产计划│·外协厂寻源│·工艺路线  │·IQC/IPQC │·入库管理  │
│ 评审      │·排产与外协│·询价与比价│  执行    │·FQC/OQC  │·出口单证  │
│·产能评审  │  分配    │·采购下单  │·外协进度  │          │·交付签收  │
│·交期承诺  │          │  与跟踪  │  跟踪    │          │          │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘
```

**关键规则**：
- 每个节点附注框架编号（SCOR 编号或 PCF 编号），保证可溯源
- 能力线（若需要）画在价值流下方独立泳道，虚线连线指向其支撑的 L3 环节
- 逆向流程（如退货）用红色虚线回流箭头表达（SCOR 逆向循环）

### 2.3 BA 能力地图（Capability Map）

**结构**：三层卡片式——顶部战略能力域、中部核心能力域、底部支撑平台；按"战略-核心-支撑"着色（战略 `#F3E5F5`、核心 `#FFF3E0`、支撑 `#ECEFF1`）。

### 2.4 DA 主题域图（L1-L3 + BO 目录）

**结构**：L1 主题域分组为大容器（紫系），内嵌 L2 主题域子容器，再嵌 L3 主题子域；L4 BO 以黄色高亮圆角矩形挂载在所属 L3 下；BO 之间 ID 引用关系用细虚线（MUST NOT 画对象引用）。

### 2.5 AA 应用架构图（L1-L3 + 服务）

**结构**：L1 产品为顶层标题栏，L2 子产品为分组容器（蓝系），L3 应用为容器内节点，L4 服务黄色高亮；AA-L3 ↔ DA-L3 对齐关系用浅色虚线标注。

### 2.6 N:1:1 映射图（推导关系可视化）

**适用场景**：向评审方直观解释 N:1:1 推导逻辑（为什么多条流程共享同一个 BO 与服务）。

**结构**：左侧 BA-L4 流程节点列（N 个，橙系）→ 中间 DA-L4 BO 节点（1 个，紫系高亮）→ 右侧 AA-L4 服务节点（1 个，蓝系）；多对一连线汇入，右侧 1:1 粗线。

```
 P-4.1.1 标准报价流程 ──────┐
 P-4.1.2 定制报价流程 ──────┼──► [报价单 BO] ◄──1:1──► [报价单服务]
 P-4.1.3 续约报价流程 ──────┘
```

**关键规则**：一组图表达一个 BO 的映射簇；多 BO 场景按 BO 分组（每 BO 一簇）或分页（draw.io 多页）；图上节点数量与 N:1:1 矩阵严格一致。

### 2.7 价值链链属边界分析图（Chain Boundary Analysis）— 边界评审专用

**适用场景**：多链协同结构下的价值链边界评审——直观展示全部 L4 流程的链属分布、各链计数与跨链触发关系；S0-4 边界判定结论的可视化答辩材料。

**结构**：三层横向泳道（主链 / 使能链 / 支撑链，各为一个泳道容器），L4 流程节点按主属链放入对应泳道并标注流程编号；跨链接口用带 IF 编号的实线箭头（触发）+ 虚线箭头（回传）连接；每链泳道头部标注三层计数（BA-L4 数 / DA-L4 BO 数 / AA-L4 服务数）。

```
┌─ 主价值链（编排者）───────── BA:x / DA:y / AA:y ─────────┐
│  [P-{主}-01 接入]   [P-{主}-02 评审]   [P-{主}-03 交付]   │
└────┬──────────────────────────────────────────▲────────┘
     │ IF-1 触发(事件)                  IF-2 回传 │
┌─ 使能价值链（执行者）───────── BA:m / DA:n / AA:n ───────┐
│  [P-{使A}-01 计划]  [P-{使A}-02 执行]  [P-{使A}-03 检验]  │
└─────────────────────────────────────────────────────────┘
┌─ 支撑价值链（记录者）───────── BA:1 / DA:1 / AA:1 ───────┐
│  [P-{支}-01 结算]  （由主链末端事件 IF-3 触发）           │
└─────────────────────────────────────────────────────────┘
```

**关键规则**：
- 泳道从上到下按 主链 → 使能链 → 支撑链 排列；每条使能链一个泳道（可多个）
- **链属配色**：主链 `#FFF3E0`（橙系）、使能链 `#E8F5E9`（绿系）、支撑链 `#ECEFF1`（灰系）；跨链主数据节点用紫系虚线框单独标注"跨链共享"
- 跨链触发箭头标注接口编号与领域事件名（如 `IF-1 订单生效事件`）；回传用虚线；**MUST NOT 画同步强依赖连线**
- 灰色地带流程（判定三问结论冲突者）加黄色高亮边框并在节点旁附一行裁决依据
- 图上流程节点、计数 MUST 与层次表和逐链计数核验表完全一致（图是蓝图的投影）
- 对话式环境（无 draw.io 交付要求）下，可用内联 SVG 简化呈现本图：泳道横条 + 流程色块 + 触发/回传箭头即可，数据一致性规则不变

---

## 3. 常用 mxCell 样式速查

```xml
<!-- 泳道容器（架构层） -->
<mxCell id="n1" value="BA 业务架构" style="swimlane;whiteSpace=wrap;html=1;fillColor=#FFF3E0;strokeColor=#F57C00;fontSize=14;fontStyle=1;startSize=30;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="500" height="600" as="geometry" />
</mxCell>

<!-- L4 锚点节点（黄色高亮） -->
<mxCell id="n2" value="报价单 BO" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FFF9C4;strokeColor=#F9A825;strokeWidth=2;fontSize=13;fontStyle=1;arcSize=10;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="160" height="50" as="geometry" />
</mxCell>

<!-- 普通节点（DA 紫） -->
<mxCell id="n3" value="商机" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#E1BEE7;strokeColor=#8E24AA;fontSize=12;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="140" height="40" as="geometry" />
</mxCell>

<!-- 占位节点（灰系虚线） -->
<mxCell id="n4" value="（占位）超出范围" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#FAFAFA;strokeColor=#BDBDBD;dashed=1;fontSize=11;fontColor=#9E9E9E;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="140" height="40" as="geometry" />
</mxCell>

<!-- 链属泳道（2.7 链属边界分析图）：主链橙 / 使能链绿 / 支撑链灰 -->
<mxCell id="laneMain" value="主价值链（编排者）BA:x / DA:y / AA:y" style="swimlane;horizontal=0;whiteSpace=wrap;html=1;fillColor=#FFF3E0;strokeColor=#F57C00;fontSize=13;fontStyle=1;startSize=30;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="720" height="120" as="geometry" />
</mxCell>
<mxCell id="laneEnab" value="使能价值链（执行者）BA:m / DA:n / AA:n" style="swimlane;horizontal=0;whiteSpace=wrap;html=1;fillColor=#E8F5E9;strokeColor=#43A047;fontSize=13;fontStyle=1;startSize=30;" vertex="1" parent="1">
  <mxGeometry x="40" y="180" width="720" height="120" as="geometry" />
</mxCell>
<mxCell id="laneSupp" value="支撑价值链（记录者）BA:1 / DA:1 / AA:1" style="swimlane;horizontal=0;whiteSpace=wrap;html=1;fillColor=#ECEFF1;strokeColor=#78909C;fontSize=13;fontStyle=1;startSize=30;" vertex="1" parent="1">
  <mxGeometry x="40" y="320" width="720" height="100" as="geometry" />
</mxCell>

<!-- 跨链触发连线（实线+事件标签）与回传连线（虚线） -->
<mxCell id="if1" value="IF-1 触发事件" style="edgeStyle=orthogonalEdgeStyle;html=1;strokeColor=#F57C00;strokeWidth=2;endArrow=classic;fontSize=10;labelBackgroundColor=#FFFFFF;" edge="1" parent="1" source="nMain1" target="nEnab1">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
<mxCell id="if2" value="IF-2 回传" style="edgeStyle=orthogonalEdgeStyle;html=1;strokeColor=#43A047;strokeWidth=1.5;dashed=1;endArrow=classic;fontSize=10;labelBackgroundColor=#FFFFFF;" edge="1" parent="1" source="nEnab1" target="nMain2">
  <mxGeometry relative="1" as="geometry" />
</mxCell>

<!-- N:1 映射连线（实线） -->
<mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;strokeColor=#666666;strokeWidth=1.5;endArrow=classic;fontSize=10;labelBackgroundColor=#FFFFFF;" edge="1" parent="1" source="n2" target="n3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>

<!-- 1:1 绑定粗线 -->
<mxCell id="e2" value="1:1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;strokeColor=#333333;strokeWidth=3;endArrow=classic;fontSize=10;fontStyle=1;labelBackgroundColor=#FFFFFF;" edge="1" parent="1" source="n2" target="n3">
  <mxGeometry relative="1" as="geometry" />
</mxCell>

<!-- 占位/超范围虚线 -->
<mxCell id="e3" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;strokeColor=#BDBDBD;strokeWidth=1;dashed=1;dashPattern=8 8;" edge="1" parent="1" source="n2" target="n4">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

**布局要点**：
1. 坐标取 10 的整数倍（对齐网格 gridSize=10）
2. 同层节点等间距；同层节点横向对齐（相同 y）或纵向对齐（相同 x）
3. 容器内部节点与容器边距 ≥ 30px
4. 连线标签加 `labelBackgroundColor=#FFFFFF` 避免与节点重叠
5. ID 顺序编号（"0"/"1" 保留给 root，从 "2" 起）

---

## 4. 图型选择指南

| 需求 | 图型 |
|------|------|
| 蓝图总览 / 高管汇报第一页 | 2.1 三架构总览图 |
| 价值链评审 / OTD 类流程汇报 | 2.2 BA 价值链图 |
| 能力规划 / 组织对齐 | 2.3 BA 能力地图 |
| 数据治理 / BO 边界评审 | 2.4 DA 主题域图 |
| 应用规划 / 服务落点评审 | 2.5 AA 应用架构图 |
| 解释 N:1:1 推导逻辑 / 架构答辩 | 2.6 N:1:1 映射图 |
| 价值链边界评审 / 多链协同结构答辩 | 2.7 链属边界分析图 |
| 全套交付 | 按需组合，多页 .drawio（每页一图型） |

---

## 相关文件

- [value-chain-frameworks.md](./value-chain-frameworks.md) — 价值链图节点命名所需的多框架参照 + §7 链属分层与边界判定（2.7 图的数据来源）
- [ba-standard.md](./ba-standard.md) — 各层节点命名规范 + 多链协同结构规范（链前缀编号/跨链接口表）
- [da-standard.md](./da-standard.md) · [aa-standard.md](./aa-standard.md) — 各层节点命名规范
- [design-principles.md](./design-principles.md) — 设计红线（原则 15：价值链边界显式化）
- [SKILL.md](../SKILL.md) — Mode D 架构图可视化输出模式
