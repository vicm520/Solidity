//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IBank {
    function withdraw(uint256 amount) external;
    function depositRecord() external payable;
}

contract Bank {
    address public owner;
    // 记录每个地址的累计存款金额
    mapping (address => uint) public deposits;
    // 存储前 3 位存款用户
    address[3] public firstThreeDepositors;
    // 计数器
    uint8 public firstDepositorCount;
    

    constructor() {
        owner = msg.sender;
    }

    // 通过 Metamask 等钱包直接给银行合约地址
    receive() external payable {
        depositRecord();
    }
    fallback() external {

    }

    modifier onlyOwner {
        require(owner == msg.sender, "Illegal permission"); 
        _;
    }
    
    // 记录存款信息
    function depositRecord() public payable virtual { 
        uint256 previousBalance = deposits[msg.sender];
        deposits[msg.sender] += msg.value;
        uint256 newBalance = deposits[msg.sender];
        // 更新排名
        _updateRanking(msg.sender, newBalance, previousBalance);
    }

    // 更新排名内部函数
    function _updateRanking(address depositor, uint256 newBalance, uint256 previousBalance) internal {
        bool isInRanking = false;
        uint256 currentIndex = 3;
        
        // 检查用户是否已经在排名中
        for (uint i = 0; i < 3; i++) {
            if (firstThreeDepositors[i] == depositor) {
                isInRanking = true;
                currentIndex = i;
                break;
            }
        }
        
        // 如果用户已经在排名中
        if (isInRanking) {
            // 如果取款后金额为0，从排名中移除
            if (newBalance == 0) {
                _removeFromRanking(currentIndex);
            } else {
                // 否则重新排序
                _sortRanking();
            }
        } else {
            // 如果用户不在排名中，检查是否能进入前三
            if (newBalance > 0) {
                _addToRanking(depositor, newBalance);
            }
        }
    }
    
    // 从排名中移除指定位置的用户
    function _removeFromRanking(uint256 index) internal {
        require(index < 3, "Index out of bounds");
        
        // 将后面的元素前移
        for (uint i = index; i < 2; i++) {
            firstThreeDepositors[i] = firstThreeDepositors[i + 1];
        }
        firstThreeDepositors[2] = address(0);
    }
    
    // 添加用户到排名
    function _addToRanking(address depositor, uint256 newBalance) internal {
        // 找到可以插入的位置
        int256 insertIndex = -1;
        uint256 minAmount = newBalance;
        uint256 minIndex = 3;
        
        for (uint i = 0; i < 3; i++) {
            if (firstThreeDepositors[i] == address(0)) {
                // 有空位
                firstThreeDepositors[i] = depositor;
                _sortRanking();
                return;
            }
            
            uint256 currentAmount = deposits[firstThreeDepositors[i]];
            if (currentAmount < minAmount) {
                minIndex = i;
                minAmount = currentAmount;
            }
        }
        
        // 如果新金额大于排名中的最小值，替换它
        if (minIndex < 3) {
            firstThreeDepositors[minIndex] = depositor;
            _sortRanking();
        }
    }
    
    // 对排名进行排序（从大到小）
    function _sortRanking() internal {
        for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2 - i; j++) {
                address addr1 = firstThreeDepositors[j];
                address addr2 = firstThreeDepositors[j + 1];
                
                // 处理空地址情况
                uint256 amount1 = addr1 == address(0) ? 0 : deposits[addr1];
                uint256 amount2 = addr2 == address(0) ? 0 : deposits[addr2];
                
                if (amount1 < amount2) {
                    // 交换位置
                    address temp = firstThreeDepositors[j];
                    firstThreeDepositors[j] = firstThreeDepositors[j + 1];
                    firstThreeDepositors[j + 1] = temp;
                }
            }
        }
    }


    // 取款方法 - 管理员从合约余额中取款
    function withdraw(uint256 amount) public onlyOwner{
        // 数据处理
        require(amount > 0, "The amount is illegal");
        require(address(this).balance >= amount, "Insufficient balance");

        // 直接从合约余额中取款，不影响任何用户的存款记录
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send Ether");
    }


    // 查询指定地址在银行合约中的存款余额
    function balanceOf(address user) external view returns (uint) {
        return deposits[user];
    }

    // 查询前三位用户列表
    function getFirstThreeDepositors() external view returns (address[3] memory) {
        return firstThreeDepositors;
    }

    // 获取完整的排名信息（地址和金额）
    function getTopThreeWithAmounts() external view returns (address[3] memory addresses, uint256[3] memory amounts) {
        for (uint i = 0; i < 3; i++) {
            addresses[i] = firstThreeDepositors[i];
            if (addresses[i] != address(0)) {
                amounts[i] = deposits[addresses[i]];
            }
        }
    }

}


contract BigBank is Bank {
    uint256 public constant MIN_DEPOSIT = 1000000000000000;

    modifier VerifyTheAmount{
        require(msg.value > MIN_DEPOSIT, "Amount must be > 0.001 ether"); 
        _;
    }

    // 限制支付最小金额
    function depositRecord() public payable override VerifyTheAmount {
        super.depositRecord();
    }

    // 转移管理员
    function transferOwner(address toAddress) public onlyOwner {
        require(toAddress != address(0), "cannot be an empty address"); 
        require(toAddress != owner, "Cannot be transferred to oneself"); 
        owner = toAddress;
    } 

}


