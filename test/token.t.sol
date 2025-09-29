// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/erc20token.sol";
import "../src/tokenbank.sol";

contract TokenTest is Test {
    MyErc20 public token;
    MyErc20_V2 public tokenV2;
    TokenBank public bank;
    TokenBank_V2 public bankV2;
    
    address public owner;
    address public user1;
    address public user2;
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // 部署合约
        token = new MyErc20();
        tokenV2 = new MyErc20_V2();
        bank = new TokenBank(address(token));
        bankV2 = new TokenBank_V2(address(tokenV2));
        
        // 给用户分配代币
        token.mint(user1, 10000 * 10**18);
        tokenV2.mint(user1, 10000 * 10**18);
        tokenV2.mint(user2, 5000 * 10**18);
        
        console.log("Setup completed");
        console.log("User1 token balance:", tokenV2.balanceOf(user1));
        console.log("User2 token balance:", tokenV2.balanceOf(user2));
    }
    
    // 测试1：基本的 transferWithCallback 功能
    function testTransferWithCallbackToEOA() public {
        uint256 amount = 1000;
        uint256 initialBalance = tokenV2.balanceOf(user2);
        
        vm.prank(user1);
        tokenV2.transferWithCallback(user2, amount, new bytes(0));
        
        // 验证转账成功
        assertEq(tokenV2.balanceOf(user2), initialBalance + amount);
        console.log("Transfer to EOA successful");
    }
    
    // 测试2：transferWithCallback 到合约地址（应该成功）
    function testTransferWithCallbackToContract() public {
        uint256 amount = 1000;
        uint256 initialBalance = bankV2.getBalance(user1);
        
        vm.prank(user1);
        tokenV2.transferWithCallback(address(bankV2), amount, new bytes(0));
        
        // 验证存款成功
        assertEq(bankV2.getBalance(user1), initialBalance + amount);
        assertEq(tokenV2.balanceOf(address(bankV2)), amount);
        console.log("Transfer to contract successful");
    }
    
    // 测试3：测试余额不足的情况
    function testTransferWithCallbackInsufficientBalance() public {
        uint256 amount = 20000 * 10**18; // 超过用户余额
        
        vm.prank(user1);
        vm.expectRevert(); // 使用新的错误格式
        tokenV2.transferWithCallback(user2, amount, new bytes(0));
        
        console.log("Insufficient balance test passed");
    }
    
    // 测试4：测试零地址转账
    function testTransferWithCallbackToZeroAddress() public {
        uint256 amount = 1000;
        
        vm.prank(user1);
        vm.expectRevert(); // 使用新的错误格式
        tokenV2.transferWithCallback(address(0), amount, new bytes(0));
        
        console.log("Zero address test passed");
    }
    
    // 测试5：测试零金额转账
    function testTransferWithCallbackZeroAmount() public {
        uint256 amount = 0;
        uint256 initialBalance = tokenV2.balanceOf(user2);
        
        vm.prank(user1);
        // 零金额转账应该成功
        tokenV2.transferWithCallback(user2, amount, new bytes(0));
        
        // 验证余额没有变化
        assertEq(tokenV2.balanceOf(user2), initialBalance);
        console.log("Zero amount test passed");
    }
    
    // 测试6：测试带数据的转账
    function testTransferWithCallbackWithData() public {
        uint256 amount = 1000;
        bytes memory data = abi.encode("test data");
        
        vm.prank(user1);
        tokenV2.transferWithCallback(user2, amount, data);
        
        // 验证转账成功
        assertEq(tokenV2.balanceOf(user2), 5000 * 10**18 + amount);
        console.log("Transfer with data successful");
    }
    
    // 测试7：测试传统存款方式
    function testTraditionalDeposit() public {
        uint256 amount = 1000;
        
        // 先授权
        vm.prank(user1);
        token.approve(address(bank), amount);
        
        // 再存款
        vm.prank(user1);
        bank.deposit(amount);
        
        // 验证存款成功
        assertEq(bank.getBalance(user1), amount);
        assertEq(token.balanceOf(address(bank)), amount);
        console.log("Traditional deposit successful");
    }
    
    // 测试8：测试 TokenBank_V2 的 tokenReceived 函数
    function testTokenBankV2TokenReceived() public {
        uint256 amount = 1000;
        
        // 直接调用 tokenReceived 函数
        vm.prank(address(tokenV2));
        bool success = bankV2.tokenReceived(user1, address(bankV2), amount, new bytes(0));
        
        // 验证调用成功
        assertTrue(success);
        assertEq(bankV2.getBalance(user1), amount);
        console.log("TokenBank_V2 tokenReceived test successful");
    }
    
    // 测试9：测试 TokenBank_V2 的 tokenReceived 函数失败情况
    function testTokenBankV2TokenReceivedFailure() public {
        uint256 amount = 1000;
        
        // 使用错误的调用者地址
        vm.prank(user1); // 不是合约地址
        vm.expectRevert("Unsupported token");
        bankV2.tokenReceived(user1, address(bankV2), amount, new bytes(0));
        
        console.log("TokenBank_V2 tokenReceived failure test passed");
    }
    
    // 测试10：测试合约地址判断
    function testContractAddressDetection() public {
        // 测试 EOA 地址
        assertEq(address(user1).code.length, 0);
        console.log("EOA address detection correct");
        
        // 测试合约地址
        assertGt(address(bankV2).code.length, 0);
        console.log("Contract address detection correct");
    }
    
    // 测试11：调试 transferWithCallback 的具体问题
    function testDebugTransferWithCallback() public {
        uint256 amount = 1000;
        
        console.log("=== Debug Information ===");
        console.log("User1 balance:", tokenV2.balanceOf(user1));
        console.log("BankV2 address:", address(bankV2));
        console.log("BankV2 code length:", address(bankV2).code.length);
        console.log("Is BankV2 a contract:", address(bankV2).code.length > 0);
        console.log("TokenV2 address:", address(tokenV2));
        
        // 检查接口匹配问题
        console.log("Expected interface: tokenReceived");
        console.log("Actual interface in MyErc20_V2: tokenReceived");
        
        vm.prank(user1);
        // 现在应该成功
        tokenV2.transferWithCallback(address(bankV2), amount, new bytes(0));
        
        // 验证结果
        assertEq(bankV2.getBalance(user1), amount);
        console.log("Debug test completed successfully");
    }
}
