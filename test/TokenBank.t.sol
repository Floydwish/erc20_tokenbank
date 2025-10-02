// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/erc20token.sol";
import "../src/tokenbank.sol";

contract TokenBankTest is Test {
    MyErc20 public token;
    TokenBank public bank;
    
    address public owner;
    address public user1;
    address public user2;
    address public nonOwner;
    
    uint256 public constant INITIAL_SUPPLY = 10000000 * 10**18;
    uint256 public constant DEPOSIT_AMOUNT = 1000 * 10**18;
    uint256 public constant WITHDRAW_AMOUNT = 500 * 10**18;
    
    event Deposited(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nonOwner = makeAddr("nonOwner");
        
        // Deploy token first
        token = new MyErc20();
        
        // Deploy TokenBank with token address
        bank = new TokenBank(address(token));
        
        // Mint tokens to users for testing
        token.mint(user1, DEPOSIT_AMOUNT * 10);
        token.mint(user2, DEPOSIT_AMOUNT * 10);
        token.mint(nonOwner, DEPOSIT_AMOUNT * 10);
    }
    
    // ============ 构造函数测试 ============
    
    function test_Constructor_InitialState() public {
        assertEq(bank.owner(), owner);
        assertEq(address(bank.token()), address(token));
    }
    
    
    
    // ============ 存款功能测试 ============
    
    function test_Deposit_Success() public {
        vm.startPrank(user1);
        
        // Approve bank to spend tokens
        token.approve(address(bank), DEPOSIT_AMOUNT);
        
        vm.expectEmit(true, true, false, true);
        emit Deposited(user1, DEPOSIT_AMOUNT);
        
        bank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT);
        assertEq(token.balanceOf(user1), DEPOSIT_AMOUNT * 9); // 10 * DEPOSIT_AMOUNT - DEPOSIT_AMOUNT
        assertEq(token.balanceOf(address(bank)), DEPOSIT_AMOUNT);
    }
    
    function test_Deposit_SuccessMultipleUsers() public {
        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // User2 deposits
        vm.startPrank(user2);
        token.approve(address(bank), DEPOSIT_AMOUNT * 2);
        bank.deposit(DEPOSIT_AMOUNT * 2);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT);
        assertEq(bank.getBalance(user2), DEPOSIT_AMOUNT * 2);
        assertEq(token.balanceOf(address(bank)), DEPOSIT_AMOUNT * 3);
    }
    
    function test_Deposit_SuccessMultipleDeposits() public {
        vm.startPrank(user1);
        
        // First deposit
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        
        // Second deposit
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT * 2);
        assertEq(token.balanceOf(address(bank)), DEPOSIT_AMOUNT * 2);
    }
    
    function test_Deposit_Failed_ZeroAmount() public {
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        
        vm.expectRevert("Deposit value must greater than 0");
        bank.deposit(0);
        
        vm.stopPrank();
    }
    
    function test_Deposit_Failed_InsufficientAllowance() public {
        vm.startPrank(user1);
        
        vm.expectRevert();
        bank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_Deposit_Failed_InsufficientBalance() public {
        vm.startPrank(user1);
        
        // Approve more than balance
        token.approve(address(bank), DEPOSIT_AMOUNT * 20);
        
        vm.expectRevert();
        bank.deposit(DEPOSIT_AMOUNT * 20);
        
        vm.stopPrank();
    }
    
    function test_Deposit_Failed_PartialAllowance() public {
        vm.startPrank(user1);
        
        // Approve less than deposit amount
        token.approve(address(bank), DEPOSIT_AMOUNT / 2);
        
        vm.expectRevert();
        bank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
    }
    
    // ============ 取款功能测试 ============
    
    function test_Withdraw_Success() public {
        // First deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // Then withdraw
        vm.startPrank(user1);
        
        vm.expectEmit(true, true, false, true);
        emit Withdraw(user1, WITHDRAW_AMOUNT);
        
        bank.withdraw(WITHDRAW_AMOUNT);
        
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT);
        assertEq(token.balanceOf(user1), DEPOSIT_AMOUNT * 9 + WITHDRAW_AMOUNT);
        assertEq(token.balanceOf(address(bank)), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT);
    }
    
    function test_Withdraw_SuccessFullBalance() public {
        // First deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // Withdraw full balance
        vm.startPrank(user1);
        bank.withdraw(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), 0);
        assertEq(token.balanceOf(user1), DEPOSIT_AMOUNT * 10);
        assertEq(token.balanceOf(address(bank)), 0);
    }
    
    function test_Withdraw_SuccessMultipleWithdraws() public {
        // First deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // Multiple withdrawals
        vm.startPrank(user1);
        bank.withdraw(WITHDRAW_AMOUNT);
        bank.withdraw(WITHDRAW_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT * 2);
        assertEq(token.balanceOf(user1), DEPOSIT_AMOUNT * 9 + WITHDRAW_AMOUNT * 2);
        assertEq(token.balanceOf(address(bank)), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT * 2);
    }
    
    function test_Withdraw_Failed_ZeroAmount() public {
        vm.startPrank(user1);
        
        vm.expectRevert("Withdraw value must greater than 0");
        bank.withdraw(0);
        
        vm.stopPrank();
    }
    
    function test_Withdraw_Failed_InsufficientBalance() public {
        vm.startPrank(user1);
        
        vm.expectRevert("Insufficient balance");
        bank.withdraw(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_Withdraw_Failed_MoreThanBalance() public {
        // First deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // Try to withdraw more than balance
        vm.startPrank(user1);
        
        vm.expectRevert("Insufficient balance");
        bank.withdraw(DEPOSIT_AMOUNT + 1);
        
        vm.stopPrank();
    }
    
    
    // ============ 余额查询测试 ============
    
    function test_GetBalance_Success() public {
        // Initial balance should be zero
        assertEq(bank.getBalance(user1), 0);
        
        // After deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT);
        
        // After withdrawal
        vm.startPrank(user1);
        bank.withdraw(WITHDRAW_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT);
    }
    
    function test_GetBalance_Failed_ZeroAddress() public {
        vm.expectRevert("Invalid address");
        bank.getBalance(address(0));
    }
    
    function test_GetBalance_SuccessDifferentUsers() public {
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        vm.startPrank(user2);
        token.approve(address(bank), DEPOSIT_AMOUNT * 2);
        bank.deposit(DEPOSIT_AMOUNT * 2);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT);
        assertEq(bank.getBalance(user2), DEPOSIT_AMOUNT * 2);
        assertEq(bank.getBalance(nonOwner), 0);
    }
    
    // ============ 完整流程测试 ============
    
    function test_CompleteFlow_Success() public {
        uint256 initialBalance = token.balanceOf(user1);
        
        // Step 1: Deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT);
        assertEq(token.balanceOf(user1), initialBalance - DEPOSIT_AMOUNT);
        
        // Step 2: Withdraw
        vm.startPrank(user1);
        bank.withdraw(WITHDRAW_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), DEPOSIT_AMOUNT - WITHDRAW_AMOUNT);
        assertEq(token.balanceOf(user1), initialBalance - DEPOSIT_AMOUNT + WITHDRAW_AMOUNT);
        
        // Step 3: Final withdrawal
        vm.startPrank(user1);
        bank.withdraw(DEPOSIT_AMOUNT - WITHDRAW_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), 0);
        assertEq(token.balanceOf(user1), initialBalance);
        assertEq(token.balanceOf(address(bank)), 0);
    }
    
    // ============ 边界值测试 ============
    
    function test_Deposit_MinimumAmount() public {
        uint256 minAmount = 1;
        
        vm.startPrank(user1);
        token.approve(address(bank), minAmount);
        bank.deposit(minAmount);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), minAmount);
    }
    
    function test_Withdraw_MinimumAmount() public {
        uint256 minAmount = 1;
        
        vm.startPrank(user1);
        token.approve(address(bank), minAmount);
        bank.deposit(minAmount);
        bank.withdraw(minAmount);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), 0);
    }
    
    function test_Deposit_MaximumAmount() public {
        uint256 maxAmount = token.balanceOf(user1);
        
        vm.startPrank(user1);
        token.approve(address(bank), maxAmount);
        bank.deposit(maxAmount);
        vm.stopPrank();
        
        assertEq(bank.getBalance(user1), maxAmount);
        assertEq(token.balanceOf(user1), 0);
    }
    
    // ============ 事件测试 ============
    
    function test_Events_Deposit() public {
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        
        vm.expectEmit(true, true, false, true);
        emit Deposited(user1, DEPOSIT_AMOUNT);
        
        bank.deposit(DEPOSIT_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_Events_Withdraw() public {
        // First deposit
        vm.startPrank(user1);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        // Then withdraw
        vm.startPrank(user1);
        
        vm.expectEmit(true, true, false, true);
        emit Withdraw(user1, WITHDRAW_AMOUNT);
        
        bank.withdraw(WITHDRAW_AMOUNT);
        
        vm.stopPrank();
    }
    
    // ============ 权限测试 ============
    
    function test_Owner_Functions() public {
        assertEq(bank.owner(), owner);
        
        // Test that non-owner can still deposit and withdraw their own funds
        vm.startPrank(nonOwner);
        token.approve(address(bank), DEPOSIT_AMOUNT);
        bank.deposit(DEPOSIT_AMOUNT);
        bank.withdraw(DEPOSIT_AMOUNT);
        vm.stopPrank();
        
        assertEq(bank.getBalance(nonOwner), 0);
    }
    
}
