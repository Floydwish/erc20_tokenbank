#!/bin/bash

# TokenBank Sepolia 部署脚本

echo "=== TokenBank Sepolia 部署脚本 ==="

# 检查并加载 .env 文件
if [ -f ".env" ]; then
    echo "发现 .env 文件，正在加载环境变量..."
    # 安全地加载 .env 文件，忽略注释和空行
    set -a  # 自动导出所有变量
    source .env
    set +a  # 关闭自动导出
    echo "✅ 环境变量加载完成"
else
    echo "⚠️  警告: 未发现 .env 文件，将使用系统环境变量"
fi

# 检查环境变量
if [ -z "$SEPOLIA_RPC_URL" ]; then
    echo "错误: 请设置 SEPOLIA_RPC_URL 环境变量"
    echo "可以在 .env 文件中设置: SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID"
    echo "或者通过命令行设置: export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo "错误: 请设置 PRIVATE_KEY 环境变量"
    echo "可以在 .env 文件中设置: PRIVATE_KEY=0x..."
    echo "或者通过命令行设置: export PRIVATE_KEY=0x..."
    exit 1
fi

echo "使用 RPC URL: $SEPOLIA_RPC_URL"
echo "使用私钥地址: $(cast wallet address --private-key $PRIVATE_KEY)"

# 检查余额
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
BALANCE=$(cast balance $DEPLOYER_ADDRESS --rpc-url $SEPOLIA_RPC_URL)
echo "部署者余额: $(cast to-unit $BALANCE ether) ETH"

if [ "$(cast to-unit $BALANCE ether)" = "0" ]; then
    echo "警告: 部署者余额为0，请先获取Sepolia测试ETH"
    echo "可以从以下水龙头获取:"
    echo "  - https://sepoliafaucet.com/"
    echo "  - https://faucet.sepolia.dev/"
fi

# 编译合约
echo "编译合约..."
forge build

# 部署合约
echo "部署合约到 Sepolia..."
forge script script/DeployTokenBank.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify

echo "部署完成！"
echo "请将合约地址更新到前端配置文件中。"
