// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/erc20token.sol";
import "../src/tokenbank.sol";

contract DeployTokenBank is Script {
    function run() external {
        // Read private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("=== TokenBank Deployment Script ===");
        console.log("Deployer Address:", deployer);
        console.log("Deployer Balance:", deployer.balance / 1e18, "ETH");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ERC20 token first
        MyErc20 token = new MyErc20();
        console.log("MyErc20 Contract Address:", address(token));
        
        // Deploy TokenBank with ERC20 token address
        TokenBank tokenBank = new TokenBank(address(token));
        console.log("TokenBank Contract Address:", address(tokenBank));
        
        vm.stopBroadcast();
        
        // Output contract information
        console.log("\n=== Contract Information ===");
        console.log("MyErc20:");
        console.log("  Name:", token.name());
        console.log("  Symbol:", token.symbol());
        console.log("  Total Supply:", token.totalSupply() / 1e18, "tokens");
        console.log("  Deployer Balance:", token.balanceOf(deployer) / 1e18, "tokens");
        
        console.log("\nTokenBank:");
        console.log("  Owner:", tokenBank.owner());
        console.log("  Token Address:", address(tokenBank.token()));
        
        console.log("\n=== Frontend Configuration ===");
        console.log("Update your frontend config with these addresses:");
        console.log("TOKEN_BANK_ADDRESS = '", address(tokenBank), "';");
        console.log("MY_ERC20_ADDRESS = '", address(token), "';");
        
        console.log("\nDeployment completed successfully!");
    }
}
