// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title UBIRevenueDistribution
 * @dev Universal Basic Income收益分配智能合约
 * 基于人类尊严和基本保障原则的UBI经济系统
 */
contract UBIRevenueDistribution is AccessControl, ReentrancyGuard {
    using SafeMath for uint256;

    // 角色定义
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    // UBI类型枚举
    enum UBIType {
        BasicUBI,      // 基础UBI - 无条件基本收入
        IdentityUBI,   // 身份UBI - 基于身份验证
        ActivityUBI    // 活动UBI - 基于贡献活动
    }

    // 用户状态结构
    struct UserStatus {
        bool isRegistered;
        bool isVerified;
        uint256 identityScore;     // 身份验证分数
        uint256 activityScore;     // 活动贡献分数
        uint256 specialStatus;     // 特殊身份状态 (0: 普通, 1: 失业, 2: 学生, 3: 老年人, 4: 残障人士)
        uint256 lastUBITime;       // 上次领取UBI时间
        uint256 totalReceived;     // 总接收金额
        uint256 basicUBIAmount;    // 基础UBI金额
        uint256 identityUBIAmount;  // 身份UBI金额
        uint256 activityUBIAmount;  // 活动UBI金额
    }

    // UBI分配周期结构
    struct DistributionCycle {
        uint256 cycleId;
        uint256 startTime;
        uint256 endTime;
        uint256 totalRevenue;      // 周期总收入
        uint256 basicPool;         // 基础UBI池
        uint256 identityPool;      // 身份UBI池
        uint256 activityPool;      // 活动UBI池
        uint256 welfarePool;       // 社会福利池
        uint256 distributedAmount; // 已分配金额
        uint256 participantCount;  // 参与用户数
        bool isActive;
        bool isCompleted;
    }

    // 系统参数结构
    struct SystemParams {
        uint256 basicUBIRatio;     // 基础UBI占比 (百分比)
        uint256 identityUBIRatio;  // 身份UBI占比
        uint256 activityUBIRatio;  // 活动UBI占比
        uint256 welfareRatio;      // 社会福利占比
        uint256 basicUBIAmount;    // 基础UBI金额
        uint256 distributionInterval; // 分配间隔 (秒)
        uint256 verificationThreshold; // 验证阈值
        uint256 specialMultiplier; // 特殊群体倍数
    }

    // 状态变量
    IERC20 public immutable ubiToken;
    mapping(address => UserStatus) public userStatus;
    mapping(uint256 => DistributionCycle) public distributionCycles;
    mapping(address => mapping(uint256 => bool)) public hasReceivedUBI;
    mapping(address => mapping(UBIType => uint256)) public lastUBIReceipt;

    SystemParams public systemParams;
    uint256 public currentCycleId;
    uint256 public totalDistributed;
    uint256 public totalUsers;
    uint256 public verifiedUsers;

    // 事件定义
    event UserRegistered(address indexed user, uint256 timestamp);
    event UserVerified(address indexed user, uint256 identityScore);
    event UBIDistributed(address indexed user, UBIType ubiType, uint256 amount, uint256 cycleId);
    event CycleStarted(uint256 indexed cycleId, uint256 startTime, uint256 totalRevenue);
    event CycleCompleted(uint256 indexed cycleId, uint256 distributedAmount, uint256 participantCount);
    event RevenueDeposited(uint256 amount, uint256 cycleId);
    event SystemParamsUpdated(string paramName, uint256 oldValue, uint256 newValue);
    event SpecialStatusUpdated(address indexed user, uint256 status);

    /**
     * @dev 构造函数
     * @param _ubiToken UBI代币地址
     * @param _admin 管理员地址
     */
    constructor(address _ubiToken, address _admin) {
        require(_ubiToken != address(0), "Invalid token address");
        require(_admin != address(0), "Invalid admin address");

        ubiToken = IERC20(_ubiToken);
        
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(DISTRIBUTOR_ROLE, _admin);
        _setupRole(ORACLE_ROLE, _admin);

        // 初始化系统参数 (基于UBI原则)
        systemParams = SystemParams({
            basicUBIRatio: 50,      // 50% 基础UBI
            identityUBIRatio: 20,   // 20% 身份UBI
            activityUBIRatio: 20,   // 20% 活动UBI
            welfareRatio: 10,       // 10% 社会福利
            basicUBIAmount: 1000 * 10**18, // 基础UBI金额 (1000代币)
            distributionInterval: 30 days,  // 30天分配周期
            verificationThreshold: 80,    // 验证阈值80分
            specialMultiplier: 150        // 特殊群体1.5倍
        });
    }

    /**
     * @dev 用户注册
     */
    function registerUser() external {
        require(!userStatus[msg.sender].isRegistered, "Already registered");
        
        userStatus[msg.sender] = UserStatus({
            isRegistered: true,
            isVerified: false,
            identityScore: 0,
            activityScore: 0,
            specialStatus: 0,
            lastUBITime: 0,
            totalReceived: 0,
            basicUBIAmount: 0,
            identityUBIAmount: 0,
            activityUBIAmount: 0
        });
        
        totalUsers++;
        emit UserRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev 用户身份验证
     * @param _user 用户地址
     * @param _identityScore 身份分数
     * @param _specialStatus 特殊状态
     */
    function verifyUser(
        address _user, 
        uint256 _identityScore, 
        uint256 _specialStatus
    ) external onlyRole(ORACLE_ROLE) {
        require(userStatus[_user].isRegistered, "User not registered");
        require(_identityScore <= 100, "Invalid identity score");
        require(_specialStatus <= 4, "Invalid special status");
        
        userStatus[_user].isVerified = true;
        userStatus[_user].identityScore = _identityScore;
        userStatus[_user].specialStatus = _specialStatus;
        
        if (_identityScore >= systemParams.verificationThreshold) {
            verifiedUsers++;
        }
        
        emit UserVerified(_user, _identityScore);
        if (_specialStatus > 0) {
            emit SpecialStatusUpdated(_user, _specialStatus);
        }
    }

    /**
     * @dev 更新用户活动分数
     * @param _user 用户地址
     * @param _activityScore 活动分数
     */
    function updateActivityScore(address _user, uint256 _activityScore) 
        external 
        onlyRole(ORACLE_ROLE) 
    {
        require(userStatus[_user].isRegistered, "User not registered");
        require(_activityScore <= 100, "Invalid activity score");
        
        userStatus[_user].activityScore = _activityScore;
    }

    /**
     * @dev 存入收益
     * @param _amount 存入金额
     */
    function depositRevenue(uint256 _amount) external {
        require(_amount > 0, "Invalid amount");
        
        ubiToken.transferFrom(msg.sender, address(this), _amount);
        
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        if (!cycle.isActive || block.timestamp > cycle.endTime) {
            _startNewCycle(_amount);
        } else {
            cycle.totalRevenue = cycle.totalRevenue.add(_amount);
            _updatePoolDistribution();
        }
        
        emit RevenueDeposited(_amount, currentCycleId);
    }

    /**
     * @dev 领取UBI
     * @param _ubiType UBI类型
     */
    function claimUBI(UBIType _ubiType) external nonReentrant {
        require(userStatus[msg.sender].isRegistered, "Not registered");
        require(distributionCycles[currentCycleId].isActive, "No active cycle");
        
        uint256 eligibleAmount = _calculateUBIAmount(msg.sender, _ubiType);
        require(eligibleAmount > 0, "No UBI available");
        
        require(
            block.timestamp >= lastUBIReceipt[msg.sender][_ubiType].add(systemParams.distributionInterval),
            "Distribution interval not met"
        );
        
        // 更新用户状态
        userStatus[msg.sender].lastUBITime = block.timestamp;
        userStatus[msg.sender].totalReceived = userStatus[msg.sender].totalReceived.add(eligibleAmount);
        lastUBIReceipt[msg.sender][_ubiType] = block.timestamp;
        
        // 更新周期状态
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        cycle.distributedAmount = cycle.distributedAmount.add(eligibleAmount);
        cycle.participantCount++;
        
        // 更新用户UBI金额记录
        if (_ubiType == UBIType.BasicUBI) {
            userStatus[msg.sender].basicUBIAmount = userStatus[msg.sender].basicUBIAmount.add(eligibleAmount);
        } else if (_ubiType == UBIType.IdentityUBI) {
            userStatus[msg.sender].identityUBIAmount = userStatus[msg.sender].identityUBIAmount.add(eligibleAmount);
        } else if (_ubiType == UBIType.ActivityUBI) {
            userStatus[msg.sender].activityUBIAmount = userStatus[msg.sender].activityUBIAmount.add(eligibleAmount);
        }
        
        // 转账
        ubiToken.transfer(msg.sender, eligibleAmount);
        totalDistributed = totalDistributed.add(eligibleAmount);
        
        emit UBIDistributed(msg.sender, _ubiType, eligibleAmount, currentCycleId);
    }
    
    /**
     * @dev 批量领取所有UBI类型
     */
    function claimAllUBI() external nonReentrant {
        require(userStatus[msg.sender].isRegistered, "Not registered");
        require(distributionCycles[currentCycleId].isActive, "No active cycle");
        
        uint256 totalAmount = 0;
        
        // 计算所有UBI类型
        for (uint8 i = 0; i < 3; i++) {
            UBIType ubiType = UBIType(i);
            uint256 amount = _calculateUBIAmount(msg.sender, ubiType);
            
            if (amount > 0 && 
                block.timestamp >= lastUBIReceipt[msg.sender][ubiType].add(systemParams.distributionInterval)) {
                
                totalAmount = totalAmount.add(amount);
                lastUBIReceipt[msg.sender][ubiType] = block.timestamp;
                
                // 更新用户UBI金额记录
                if (ubiType == UBIType.BasicUBI) {
                    userStatus[msg.sender].basicUBIAmount = userStatus[msg.sender].basicUBIAmount.add(amount);
                } else if (ubiType == UBIType.IdentityUBI) {
                    userStatus[msg.sender].identityUBIAmount = userStatus[msg.sender].identityUBIAmount.add(amount);
                } else if (ubiType == UBIType.ActivityUBI) {
                    userStatus[msg.sender].activityUBIAmount = userStatus[msg.sender].activityUBIAmount.add(amount);
                }
            }
        }
        
        require(totalAmount > 0, "No UBI available");
        
        // 更新用户状态
        userStatus[msg.sender].lastUBITime = block.timestamp;
        userStatus[msg.sender].totalReceived = userStatus[msg.sender].totalReceived.add(totalAmount);
        
        // 更新周期状态
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        cycle.distributedAmount = cycle.distributedAmount.add(totalAmount);
        cycle.participantCount++;
        
        // 转账
        ubiToken.transfer(msg.sender, totalAmount);
        totalDistributed = totalDistributed.add(totalAmount);
        
        emit UBIDistributed(msg.sender, UBIType.BasicUBI, totalAmount, currentCycleId);
    }
    
    /**
     * @dev 计算UBI金额
     * @param _user 用户地址
     * @param _ubiType UBI类型
     * @return 可领取的UBI金额
     */
    function _calculateUBIAmount(address _user, UBIType _ubiType) 
        internal 
        view 
        returns (uint256) 
    {
        UserStatus storage user = userStatus[_user];
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        
        if (!user.isVerified) {
            if (_ubiType == UBIType.BasicUBI) {
                // 未验证用户只能领取基础UBI的50%
                return systemParams.basicUBIAmount.div(2);
            }
            return 0;
        }
        
        uint256 multiplier = user.specialStatus > 0 ? systemParams.specialMultiplier : 100;
        
        if (_ubiType == UBIType.BasicUBI) {
            return systemParams.basicUBIAmount.mul(multiplier).div(100);
        } else if (_ubiType == UBIType.IdentityUBI) {
            if (user.identityScore >= systemParams.verificationThreshold) {
                return systemParams.basicUBIAmount.mul(user.identityScore).mul(multiplier).div(10000);
            }
        } else if (_ubiType == UBIType.ActivityUBI) {
            if (user.activityScore > 0) {
                return systemParams.basicUBIAmount.mul(user.activityScore).mul(multiplier).div(10000);
            }
        }
        
        return 0;
    }
    
    /**
     * @dev 开始新周期
     * @param _initialRevenue 初始收益
     */
    function _startNewCycle(uint256 _initialRevenue) internal {
        // 完成当前周期
        if (currentCycleId > 0) {
            DistributionCycle storage oldCycle = distributionCycles[currentCycleId];
            oldCycle.isCompleted = true;
            emit CycleCompleted(currentCycleId, oldCycle.distributedAmount, oldCycle.participantCount);
        }
        
        // 开始新周期
        currentCycleId++;
        DistributionCycle storage newCycle = distributionCycles[currentCycleId];
        newCycle.cycleId = currentCycleId;
        newCycle.startTime = block.timestamp;
        newCycle.endTime = block.timestamp.add(systemParams.distributionInterval);
        newCycle.totalRevenue = _initialRevenue;
        newCycle.isActive = true;
        
        _updatePoolDistribution();
        
        emit CycleStarted(currentCycleId, block.timestamp, _initialRevenue);
    }
    
    /**
     * @dev 更新池分配
     */
    function _updatePoolDistribution() internal {
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        
        cycle.basicPool = cycle.totalRevenue.mul(systemParams.basicUBIRatio).div(100);
        cycle.identityPool = cycle.totalRevenue.mul(systemParams.identityUBIRatio).div(100);
        cycle.activityPool = cycle.totalRevenue.mul(systemParams.activityUBIRatio).div(100);
        cycle.welfarePool = cycle.totalRevenue.mul(systemParams.welfareRatio).div(100);
    }
    
    /**
     * @dev 更新系统参数
     */
    function updateSystemParams(
        uint256 _basicUBIRatio,
        uint256 _identityUBIRatio,
        uint256 _activityUBIRatio,
        uint256 _welfareRatio,
        uint256 _basicUBIAmount,
        uint256 _distributionInterval,
        uint256 _verificationThreshold,
        uint256 _specialMultiplier
    ) external onlyRole(ADMIN_ROLE) {
        require(_basicUBIRatio.add(_identityUBIRatio).add(_activityUBIRatio).add(_welfareRatio) == 100, "Ratios must sum to 100");
        require(_basicUBIAmount > 0, "Invalid basic UBI amount");
        require(_distributionInterval > 0, "Invalid distribution interval");
        require(_verificationThreshold <= 100, "Invalid verification threshold");
        require(_specialMultiplier >= 100, "Invalid special multiplier");
        
        SystemParams memory oldParams = systemParams;
        
        systemParams.basicUBIRatio = _basicUBIRatio;
        systemParams.identityUBIRatio = _identityUBIRatio;
        systemParams.activityUBIRatio = _activityUBIRatio;
        systemParams.welfareRatio = _welfareRatio;
        systemParams.basicUBIAmount = _basicUBIAmount;
        systemParams.distributionInterval = _distributionInterval;
        systemParams.verificationThreshold = _verificationThreshold;
        systemParams.specialMultiplier = _specialMultiplier;
        
        emit SystemParamsUpdated("all", 0, 1); // 简化事件，实际使用时应分别记录每个参数
    }
    
    /**
     * @dev 紧急暂停
     */
    function emergencyPause() external onlyRole(ADMIN_ROLE) {
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        cycle.isActive = false;
    }
    
    /**
     * @dev 恢复系统
     */
    function resumeSystem() external onlyRole(ADMIN_ROLE) {
        DistributionCycle storage cycle = distributionCycles[currentCycleId];
        cycle.isActive = true;
    }
    
    /**
     * @dev 获取用户状态
     */
    function getUserStatus(address _user) external view returns (UserStatus memory) {
        return userStatus[_user];
    }
    
    /**
     * @dev 获取当前周期信息
     */
    function getCurrentCycle() external view returns (DistributionCycle memory) {
        return distributionCycles[currentCycleId];
    }
    
    /**
     * @dev 获取用户可领取UBI金额
     */
    function getClaimableUBI(address _user, UBIType _ubiType) external view returns (uint256) {
        return _calculateUBIAmount(_user, _ubiType);
    }
    
    /**
     * @dev 获取用户所有可领取UBI金额
     */
    function getAllClaimableUBI(address _user) external view returns (uint256) {
        uint256 total = 0;
        for (uint8 i = 0; i < 3; i++) {
            UBIType ubiType = UBIType(i);
            if (block.timestamp >= lastUBIReceipt[_user][ubiType].add(systemParams.distributionInterval)) {
                total = total.add(_calculateUBIAmount(_user, ubiType));
            }
        }
        return total;
    }
    
    /**
     * @dev 获取系统统计信息
     */
    function getSystemStats() external view returns (
        uint256 _totalUsers,
        uint256 _verifiedUsers,
        uint256 _totalDistributed,
        uint256 _currentCycleId,
        uint256 _cycleStartTime,
        uint256 _cycleEndTime
    ) {
        DistributionCycle memory cycle = distributionCycles[currentCycleId];
        return (
            totalUsers,
            verifiedUsers,
            totalDistributed,
            currentCycleId,
            cycle.startTime,
            cycle.endTime
        );
    }
}