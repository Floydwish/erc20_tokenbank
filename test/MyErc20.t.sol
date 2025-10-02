// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/erc20token.sol";

contract MyErc20Test is Test {
    MyErc20 public token;
    
    address public owner;
    address public user1;
    address public user2;
    address public nonOwner;
    
    uint256 public constant INITIAL_SUPPLY = 10000000 * 10**18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nonOwner = makeAddr("nonOwner");
        
        // Deploy contract
        token = new MyErc20();
    }
    
    // ============ 构造函数测试 ============
    
    function test_Constructor_InitialState() public view{
        assertEq(token.name(), "MyERC20Token");
        assertEq(token.symbol(), "METK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.owner(), owner);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }
    
    
    // ============ 铸造功能测试 ============
    
    function test_Mint_Success() public {
        uint256 mintAmount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, mintAmount);
        
        token.mint(user1, mintAmount);
        
        assertEq(token.balanceOf(user1), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }
    
    function test_Mint_SuccessOwnerMintsToSelf() public {
        uint256 mintAmount = 500 * 10**18;
        
        token.mint(owner, mintAmount);
        
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY + mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }
    
    function test_Mint_Failed_NonOwner() public {
        uint256 mintAmount = 1000 * 10**18;
        
        vm.prank(nonOwner);
        vm.expectRevert();
        token.mint(user1, mintAmount);
    }
    
    function test_Mint_Success_ZeroAmount() public {
        // ERC20标准允许铸造0数量的代币
        token.mint(user1, 0);
        assertEq(token.balanceOf(user1), 0);
    }
    
    function test_Mint_Failed_ZeroAddress() public {
        uint256 mintAmount = 1000 * 10**18;
        
        vm.expectRevert();
        token.mint(address(0), mintAmount);
    }
    
    // ============ 转账功能测试 ============
    
    function test_Transfer_Success() public {
        uint256 transferAmount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, transferAmount);
        
        token.transfer(user1, transferAmount);
        
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
    }
    
    function test_Transfer_SuccessFullBalance() public {
        uint256 fullBalance = token.balanceOf(owner);
        
        token.transfer(user1, fullBalance);
        
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(user1), fullBalance);
    }
    
    function test_Transfer_Failed_InsufficientBalance() public {
        uint256 transferAmount = INITIAL_SUPPLY + 1;
        
        vm.expectRevert();
        token.transfer(user1, transferAmount);
    }
    
    function test_Transfer_Failed_ZeroAddress() public {
        uint256 transferAmount = 1000 * 10**18;
        
        vm.expectRevert();
        token.transfer(address(0), transferAmount);
    }
    
    function test_Transfer_Success_ZeroAmount() public {
        // ERC20标准允许0金额转账
        token.transfer(user1, 0);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.balanceOf(user1), 0);
    }
    
    // ============ 授权功能测试 ============
    
    function test_Approve_Success() public {
        uint256 approveAmount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, user1, approveAmount);
        
        token.approve(user1, approveAmount);
        
        assertEq(token.allowance(owner, user1), approveAmount);
    }
    
    function test_Approve_SuccessZeroAmount() public {
        token.approve(user1, 0);
        assertEq(token.allowance(owner, user1), 0);
    }
    
    function test_Approve_SuccessIncreaseAllowance() public {
        uint256 firstAmount = 500 * 10**18;
        uint256 secondAmount = 1000 * 10**18;
        
        token.approve(user1, firstAmount);
        assertEq(token.allowance(owner, user1), firstAmount);
        
        token.approve(user1, secondAmount);
        assertEq(token.allowance(owner, user1), secondAmount);
    }
    
    function test_Approve_Failed_ZeroAddress() public {
        uint256 approveAmount = 1000 * 10**18;
        
        vm.expectRevert();
        token.approve(address(0), approveAmount);
    }
    
    // ============ transferFrom功能测试 ============
    
    function test_TransferFrom_Success() public {
        uint256 approveAmount = 1000 * 10**18;
        uint256 transferAmount = 500 * 10**18;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user2, transferAmount);
        
        token.transferFrom(owner, user2, transferAmount);
        
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(user2), transferAmount);
        assertEq(token.allowance(owner, user1), approveAmount - transferAmount);
    }
    
    function test_TransferFrom_SuccessFullAllowance() public {
        uint256 approveAmount = 1000 * 10**18;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        token.transferFrom(owner, user2, approveAmount);
        
        assertEq(token.allowance(owner, user1), 0);
    }
    
    function test_TransferFrom_Failed_InsufficientAllowance() public {
        uint256 approveAmount = 500 * 10**18;
        uint256 transferAmount = 1000 * 10**18;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, user2, transferAmount);
    }
    
    function test_TransferFrom_Failed_InsufficientBalance() public {
        uint256 approveAmount = 1000 * 10**18;
        uint256 transferAmount = INITIAL_SUPPLY + 1;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, user2, transferAmount);
    }
    
    function test_TransferFrom_Failed_ZeroAddress() public {
        uint256 approveAmount = 1000 * 10**18;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, address(0), approveAmount);
    }
    
    
    // ============ 边界值测试 ============
    
    function test_Transfer_MaxUint256() public {
        // 先铸造最大数量的代币给用户
        token.mint(user1, type(uint256).max - token.totalSupply());
        
        uint256 maxBalance = token.balanceOf(user1);
        
        vm.prank(user1);
        token.transfer(user2, maxBalance);
        
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), maxBalance);
    }
    
    function test_Approve_MaxUint256() public {
        uint256 maxAmount = type(uint256).max;
        
        token.approve(user1, maxAmount);
        assertEq(token.allowance(owner, user1), maxAmount);
    }
    
    // ============ 事件测试 ============
    
    function test_Events_Transfer() public {
        uint256 transferAmount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, transferAmount);
        
        token.transfer(user1, transferAmount);
    }
    
    function test_Events_Approval() public {
        uint256 approveAmount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, user1, approveAmount);
        
        token.approve(user1, approveAmount);
    }
    
    function test_Events_TransferFrom() public {
        uint256 approveAmount = 1000 * 10**18;
        uint256 transferAmount = 500 * 10**18;
        
        token.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user2, transferAmount);
        
        token.transferFrom(owner, user2, transferAmount);
    }
}
