# ERC20 Token Bank
开发流程：

## 一、需求分析（目的：确定功能、实现方案）

### 1. 功能需求：
   - 显示当前连接钱包在 TokenBank 中的存款余额
   - 支持输入金额并执行存款操作（通过按钮触发）
   - 支持输入金额并执行取款操作（仅合约所有者可操作）
   - 实时更新用户余额和合约总存款金额
   - 交易状态反馈（如"存款中..."、"取款中..."）

### 2. 实现方案：
   - 合约：erc20token、tokenbank
   - 前端及区块链交互：Viem（核心库）、Wagmi（钱包连接与合约调用封装）


## 二、合约开发（目的：编写、测试智能合约）

### 1. MyErc20合约开发
   - 基于OpenZeppelin ERC20标准
   - 实现铸造功能（仅所有者）
   - 代币名称：MyERC20Token (METK)
   - 初始供应量：10,000,000代币

### 2. TokenBank合约开发
   - 实现代币存款功能
   - 实现代币提取功能
   - 用户余额管理
   - 事件记录（Deposited、Withdraw）

## 三、前端开发（目的：用户界面、钱包连接）

### 1. 技术栈：React + Vite + Wagmi + Viem

### 2. 核心组件：
   - WalletInfo：钱包连接和余额显示
   - TransactionForm：存款取款操作表单

### 3. 功能实现：
   - MetaMask钱包连接
   - 实时余额查询
   - 交易状态反馈
   - 网络切换提醒

## 四、与区块链交互（目的：使用库读、写区块链）

### 1. Wagmi配置：支持Sepolia测试网和本地网络

### 2. 合约交互：
   - 读取：余额查询、代币符号
   - 写入：授权、存款、取款

### 3. 交易确认：使用useWaitForTransactionReceipt

## 五、测试（目的：整体功能测试）

### 1. 合约单元测试：
   - MyErc20.t.sol：25个测试用例
   - TokenBank.t.sol：24个测试用例

### 2. 测试覆盖：
   - 成功场景测试
   - 失败场景测试
   - 边界值测试
   - 事件验证测试

## 六、部署与上线（目的：部署上链、维护）

### 1. 本地部署：使用Anvil本地网络

### 2. 测试网部署：Sepolia测试网

### 3. 部署脚本：自动化部署流程

### 4. 前端配置：环境变量管理

## 项目结构

```
3.2/
├── src/                          # 合约源码
│   ├── erc20token.sol           # ERC20代币合约
│   └── tokenbank.sol            # 代币银行合约
├── script/                       # 部署脚本
│   ├── DeployTokenBank.sol      # Foundry部署脚本
│   └── deploy.sh                # 自动化部署脚本
├── test/                         # 单元测试
│   ├── MyErc20.t.sol           # MyErc20合约测试
│   ├── TokenBank.t.sol         # TokenBank合约测试
│   └── tokenbank_result.jpg     # 测试结果截图
├── frontend/                     # React前端应用
│   ├── package.json             # 依赖配置
│   ├── index.html               # HTML入口
│   ├── vite.config.js           # Vite配置
│   ├── src/
│   │   ├── main.jsx             # React入口文件
│   │   ├── App.jsx              # 主应用组件
│   │   ├── config.js            # Wagmi配置和合约地址
│   │   └── components/          # React组件
│   │       ├── WalletInfo.jsx   # 钱包信息和余额显示
│   │       └── TransactionForm.jsx # 存款取款表单
│   └── public/
│       └── contracts/            # 合约ABI文件
│           ├── MyErc20.json     # MyErc20合约ABI
│           └── TokenBank.json   # TokenBank合约ABI
├── lib/                          # Foundry依赖库
│   ├── forge-std/               # Foundry标准库
│   └── openzeppelin-contracts/  # OpenZeppelin合约库
├── out/                          # 编译输出
├── broadcast/                    # 部署记录
├── cache/                        # 缓存文件
├── foundry.toml                  # Foundry配置
├── DEPLOY_SEPOLIA.md            # Sepolia部署指南
└── README.md                    # 项目说明
```

一个基于 Solidity 的代币银行系统，包含 ERC20 代币合约和代币银行合约。

## 快速开始

### 1. 环境准备
```bash
# 安装Foundry依赖
forge install

# 编译合约
forge build

# 安装前端依赖
cd frontend
npm install
```

### 2. 本地测试
```bash
# 启动Anvil本地网络
anvil

# 运行合约测试
forge test -v

# 启动前端开发服务器
cd frontend
npm run dev
```

### 3. 部署到Sepolia测试网
```bash
# 配置环境变量（.env文件）
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=0x...

# 运行自动化部署脚本
./script/deploy.sh
```

### 4. 使用流程
1. 连接MetaMask钱包到Sepolia网络
2. 访问前端应用
3. 点击"连接钱包"
4. 查看余额信息
5. 进行存款操作：
   - 输入金额
   - 点击"授权"
   - 点击"存款"
6. 进行取款操作：
   - 输入金额
   - 点击"取款"

### 5. 测试命令
```bash
# 运行所有测试
forge test

# 运行特定合约测试
forge test --match-contract MyErc20Test
forge test --match-contract TokenBankTest

# 查看测试覆盖率
forge coverage

# 格式化代码
forge fmt

# 前端测试
cd frontend
npm run build
```

## 技术栈

### 智能合约
- Solidity ^0.8.20
- OpenZeppelin Contracts
- Foundry 开发框架

### 前端开发
- React 18
- Vite (构建工具)
- Wagmi v2 (钱包连接)
- Viem (以太坊交互库)
- @tanstack/react-query (状态管理)

### 测试与部署
- Foundry 测试框架
- Anvil (本地网络)
- Sepolia 测试网

## 注意事项

### 合约使用
- 用户存款前需要先调用 `approve()` 授权 TokenBank 合约
- 只有合约所有者可以铸造新代币
- 提取金额不能超过用户存款余额
- 所有金额以 wei 为单位（1 ETH = 10^18 wei）

### 前端使用
- 确保MetaMask连接到正确的网络（Sepolia测试网）
- 确保钱包有足够的ETH支付gas费用
- 交易可能需要等待确认，请耐心等待
- 如果余额未更新，请等待几秒钟或手动刷新

### 开发注意事项
- 部署前请确保私钥和RPC URL配置正确
- 合约地址需要手动更新到前端配置中
- 建议在测试网充分测试后再考虑主网部署

