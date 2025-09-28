// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 ERC20 实现
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// 导入权限管理
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MyErc20 is ERC20, Ownable{

    constructor() ERC20("MyERC20Token", "METK") Ownable(msg.sender) {
        _mint(msg.sender, 10000000 * 10 ** 18);
    }

    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to, amount);
    }
}