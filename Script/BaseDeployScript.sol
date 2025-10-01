// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";

/**
 * @title BaseDeployScript
 * @dev 通用部署脚本基类，提供标准的部署流程和工具函数
 */
abstract contract BaseDeployScript is Script {
    
    // 部署配置结构体
    struct DeployConfig {
        uint256 deployerPrivateKey;
        string network;
        bool saveDeployment;
        bool verifyContract;
    }
    
    // 部署结果结构体
    struct DeploymentResult {
        address contractAddress;
        address deployerAddress;
        uint256 blockNumber;
        uint256 timestamp;
        uint256 chainId;
        string contractName;
    }
    
    /**
     * @dev 子类必须实现的部署逻辑
     * @return result 部署结果
     */
    function deployContract() internal virtual returns (DeploymentResult memory result);
    
    /**
     * @dev 获取部署配置
     * @return config 部署配置
     */
    function getDeployConfig() internal view virtual returns (DeployConfig memory config) {
        config.deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        config.network = vm.envOr("NETWORK", string("localhost"));
        config.saveDeployment = vm.envOr("SAVE_DEPLOYMENT", true);
        config.verifyContract = vm.envOr("VERIFY_CONTRACT", false);
    }
    
    /**
     * @dev 主要的运行函数
     */
    function run() public {
        DeployConfig memory config = getDeployConfig();
        
        // 开始广播交易
        vm.startBroadcast(config.deployerPrivateKey);
        
        // 执行部署
        DeploymentResult memory result = deployContract();
        
        // 停止广播
        vm.stopBroadcast();
        
        // 填充部署结果的通用信息
        result.deployerAddress = vm.addr(config.deployerPrivateKey);
        result.blockNumber = block.number;
        result.timestamp = block.timestamp;
        result.chainId = block.chainid;
        
        // 输出部署信息
        _logDeploymentInfo(result, config);
        
        // 保存部署信息
        if (config.saveDeployment) {
            _saveDeploymentInfo(result, config);
        }
        
        // 验证合约（如果需要）
        if (config.verifyContract) {
            _verifyContract(result, config);
        }
    }
    
    /**
     * @dev 输出部署信息到控制台
     */
    function _logDeploymentInfo(DeploymentResult memory result, DeployConfig memory config) internal view {
        console.log("=== Deployment Successful ===");
        console.log("Contract Name:", result.contractName);
        console.log("Contract Address:", result.contractAddress);
        console.log("Deployer Address:", result.deployerAddress);
        console.log("Network:", config.network);
        console.log("Chain ID:", result.chainId);
        console.log("Block Number:", result.blockNumber);
        console.log("Timestamp:", result.timestamp);
        console.log("=============================");
    }
    
    /**
     * @dev 保存部署信息到 JSON 文件
     */
    function _saveDeploymentInfo(DeploymentResult memory result, DeployConfig memory config) internal {
        // 创建 JSON 格式的部署信息
        string memory json = _createDeploymentJson(result, config);
        
        // 生成文件名
        string memory fileName = string(abi.encodePacked(
            "deployments/",
            config.network,
            "_",
            result.contractName,
            "_",
            vm.toString(result.timestamp),
            ".json"
        ));
        
        // 写入文件
        vm.writeFile(fileName, json);
        console.log("Deployment info saved to:", fileName);
    }
    
    /**
     * @dev 创建部署信息的 JSON 字符串
     */
    function _createDeploymentJson(DeploymentResult memory result, DeployConfig memory config) 
        internal 
        view 
        virtual 
        returns (string memory) 
    {
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
            '  "compiler": {\n',
            '    "version": "0.8.25",\n',
            '    "optimizer": true\n',
            '  }\n',
            '}'
        ));
    }
    
    /**
     * @dev 验证合约（占位符函数，子类可以重写）
     */
    function _verifyContract(DeploymentResult memory result, DeployConfig memory config) internal virtual {
        console.log("Contract verification not implemented for:", result.contractName);
        console.log("You can manually verify at:", result.contractAddress);
    }
}