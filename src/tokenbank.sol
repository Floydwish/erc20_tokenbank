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