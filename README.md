# ERC20 Token Bank

一个基于 Solidity 的代币银行系统，包含 ERC20 代币合约和代币银行合约。

## 合约介绍

### MyErc20 (`erc20token.sol`)
ERC20 标准代币合约，基于 OpenZeppelin 实现。

**功能特性：**
- 代币名称：MyERC20Token (METK)
- 初始供应量：10,000,000 代币
- 支持代币铸造（仅合约所有者）
- 继承 OpenZeppelin 的 ERC20 和 Ownable 功能

**主要函数：**
- `mint(address to, uint256 amount)` - 铸造新代币

### TokenBank (`tokenbank.sol`)
代币银行合约，用户可以存入和提取 ERC20 代币。

**功能特性：**
- 代币存款和提取
- 内部余额管理
- 事件记录（存款/提取）
- 余额查询功能

**主要函数：**
- `deposit(uint256 amount)` - 存入代币
- `withdraw(uint256 amount)` - 提取代币
- `getBalance(address user)` - 查询用户余额

## 部署和测试流程

### 1. 环境准备
```bash
# 安装依赖
forge install

# 编译合约
forge build
```

### 2. 部署顺序
1. 首先部署 `MyErc20` 合约
2. 使用 MyErc20 合约地址部署 `TokenBank` 合约

### 3. 使用流程
1. 用户需要先调用 MyErc20 的 `approve()` 函数，授权 TokenBank 合约使用其代币
2. 调用 TokenBank 的 `deposit()` 函数存入代币
3. 调用 `withdraw()` 函数提取代币

### 4. 测试命令
```bash
# 运行测试
forge test

# 查看测试覆盖率
forge coverage

# 格式化代码
forge fmt
```

## 技术栈
- Solidity ^0.8.20
- OpenZeppelin Contracts
- Foundry 开发框架

## 注意事项
- 用户存款前需要先授权 TokenBank 合约
- 只有合约所有者可以铸造新代币
- 提取金额不能超过用户存款余额