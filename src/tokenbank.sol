//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./erc20token.sol";

contract TokenBank is Ownable{
    IERC20 public token; // 符合 ERC20 标准的 token

    // 维护用户余额
    mapping(address => uint256) public balances;

    // 定义事件
    event Deposited(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 部署时传入 token 地址
    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    // 存款
    function deposit(uint256 amount) public {
        // 检查存款金额
        require(amount > 0, "Deposit value must greater than 0");
        
        // 检查用户转移金额到本合约是否成功
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // bank 账户更新
        balances[msg.sender] += amount;

        // 记录存款事件
        emit Deposited(msg.sender, amount);
    }

    // 取款
    function withdraw(uint256 amount) public {
        // 检查取款金额
        require(amount > 0, "Withdraw value must greater than 0");

        // 检查用户余额是否足够取款
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 先更新状态
        balances[msg.sender] -= amount;

        // 再取款，并检查是否成功
        require(token.transfer(msg.sender, amount), "Withdraw failed");

        // 记录取款事件
        emit Withdraw(msg.sender, amount);
    }

    // 查询某个用户的余额
    function getBalance(address user) public view returns (uint256){
        require(user != address(0), "Invalid address");

        return balances[user];
    }
}

/*
// function tokenReceived(address from, address to, uint256 amount, bytes calldata data) external returns (bool);
contract TokenBank_V2 is Ownable{
    IERC20 public token; // 符合 ERC20 标准的 token

    // 维护用户余额
    mapping(address => uint256) public balances;

    // 定义事件
    event Deposited(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 部署时传入 token 地址
    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    // 存款
    function deposit(uint256 amount) public {
        // 检查存款金额
        require(amount > 0, "Deposit value must greater than 0");
        
        // 检查用户转移金额到本合约是否成功
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // bank 账户更新
        balances[msg.sender] += amount;

        // 记录存款事件
        emit Deposited(msg.sender, amount);
    }

    // 取款
    function withdraw(uint256 amount) public {
        // 检查取款金额
        require(amount > 0, "Withdraw value must greater than 0");

        // 检查用户余额是否足够取款
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 先更新状态
        balances[msg.sender] -= amount;

        // 再取款，并检查是否成功
        require(token.transfer(msg.sender, amount), "Withdraw failed");

        // 记录取款事件
        emit Withdraw(msg.sender, amount);
    }

    // 查询某个用户的余额
    function getBalance(address user) public view returns (uint256){
        require(user != address(0), "Invalid address");

        return balances[user];
    }

    function tokenReceived(address from, address to, uint256 amount, bytes calldata data) external returns (bool) {
        // 验证调用者是否为支持的 ERC20 Token 合约
        // 当前仅检查调用方是否为 我的 ERC20 合约地址
        require(msg.sender == address(token), "Unsupported token");

        // 验证目标地址是否为本合约
        require(to == address(this), "Invalid address");

        // 以下为类似 deposit 的功能
        // 检查存款金额
        require(amount > 0, "Deposit value must greater than 0");
        
        // 注意：这里不需要 transferFrom，因为代币已经通过 transfer 转到了本合约
        // 只需要更新内部余额记录
        balances[from] += amount;

        // 记录存款事件
        emit Deposited(from, amount);

        // 返回成功状态
        return true;
    }

}
*/

/*
整理 3 种用于与 RPC 接口交互的方式：
1.调用方式1：HTTP 层调用，通过 RPC 接口（http-post） 实现
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://127.0.0.1:8545
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "latest"],"id":1}' http://127.0.0.1:8545

2.调用方式2：工具层调用（基于 RPC 接口的封装），通过 cast 命令查询
cast block-number --rpc-url http://127.0.0.1:8545
cast balance 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://127.0.0.1:8545

3.调用方式3：应用层调用 (VIEM， RPC 接口封装)
常用的库:viem.js / ethers.js / Web3J / Web3Py / go-ethereum / alloy-rs
*/


/*
基于 myBank 合约开发的 TokenBank 前端界面，用于与智能合约交互，支持钱包连接、余额查询、存款及取款功能。

功能说明
显示当前连接钱包在 TokenBank 中的存款余额
支持输入金额并执行存款操作（通过按钮触发）
支持输入金额并执行取款操作（仅合约所有者可操作）
实时更新用户余额和合约总存款金额
交易状态反馈（如"存款中..."、"取款中..."）

核心功能：与 myBank 智能合约交互（存款、取款、余额查询）

*/



