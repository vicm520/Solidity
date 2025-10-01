// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {BaseDeployScript} from "./BaseDeployScript.sol";
import {MyToken} from "../src/MyToken.sol";
import {console} from "forge-std/Script.sol";


contract DeployMyToken is BaseDeployScript {
    
    /**
     * @dev 实现基类的抽象函数，执行 MyToken 合约部署
     */
    function deployContract() internal override returns (DeploymentResult memory result) {
        // 获取代币配置
        string memory tokenName = vm.envOr("TOKEN_NAME", string("MyToken"));
        string memory tokenSymbol = vm.envOr("TOKEN_SYMBOL", string("MTK"));
        
        console.log("Deploying MyToken with:");
        console.log("  Name:", tokenName);
        console.log("  Symbol:", tokenSymbol);
        
        // 部署 MyToken 合约
        MyToken token = new MyToken(tokenName, tokenSymbol);
        
        // 返回部署结果
        result.contractAddress = address(token);
        result.contractName = "MyToken";
        
        // 输出额外的代币信息
        console.log("MyToken deployed successfully!");
        console.log("  Address:", address(token));
        console.log("  Name:", token.name());
        console.log("  Symbol:", token.symbol());
        console.log("  Decimals:", token.decimals());
        console.log("  Total Supply:", token.totalSupply());
        console.log("  Deployer:", msg.sender);
    }
    
    /**
     * @dev 重写基类的 JSON 创建函数，添加 MyToken 特定信息
     */
    function _createDeploymentJson(DeploymentResult memory result, DeployConfig memory config) 
        internal 
        view 
        override 
        returns (string memory) 
    {
        // 获取代币信息
        MyToken token = MyToken(result.contractAddress);
        
        return string(abi.encodePacked(
            '{\n',
            '  "contractName": "', result.contractName, '",\n',
            '  "contractAddress": "', vm.toString(result.contractAddress), '",\n',
            '  "deployerAddress": "', vm.toString(result.deployerAddress), '",\n',
            '  "network": "', config.network, '",\n',
            '  "chainId": ', vm.toString(result.chainId), ',\n',
            '  "blockNumber": ', vm.toString(result.blockNumber), ',\n',
            '  "timestamp": "', vm.toString(result.timestamp), '",\n',
            '  "verified": ', config.verifyContract ? 'true' : 'false', ',\n',
            '  "tokenInfo": {\n',
            '    "name": "', token.name(), '",\n',
            '    "symbol": "', token.symbol(), '",\n',
            '    "decimals": ', vm.toString(token.decimals()), ',\n',
            '    "totalSupply": "', vm.toString(token.totalSupply()), '",\n',
            '    "deployer": "', vm.toString(result.deployerAddress), '"\n',
            '  },\n',
            '  "constructorArgs": {\n',
            '    "name": "', token.name(), '",\n',
            '    "symbol": "', token.symbol(), '"\n',
            '  },\n',
            '  "compiler": {\n',
            '    "version": "0.8.25",\n',
            '    "optimizer": true\n',
            '  }\n',
            '}'
        ));
    }
    
    /**
     * @dev 重写验证函数，提供 MyToken 特定的验证信息
     */
    function _verifyContract(DeploymentResult memory result, DeployConfig memory config) internal override {
        MyToken token = MyToken(result.contractAddress);
        
        console.log("=== Contract Verification Info ===");
        console.log("Contract Address:", result.contractAddress);
        console.log("Constructor Arguments:");
        console.log("  name:", token.name());
        console.log("  symbol:", token.symbol());
        console.log("================================");
        console.log("You can verify this contract using:");
        console.log("forge verify-contract", vm.toString(result.contractAddress));
        console.log("  --constructor-args $(cast abi-encode \"constructor(string,string)\"");
        console.log("    \"", token.name(), "\"");
        console.log("    \"", token.symbol(), "\")");
        console.log("  --etherscan-api-key $ETHERSCAN_API_KEY");
        console.log("  src/MyToken.sol:MyToken");
    }
}