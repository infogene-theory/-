// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title SocialWelfareSystem
 * @dev 社会福利系统智能合约
 * 基于UBI三层保障理念的社会福利分配机制
 */
contract SocialWelfareSystem is AccessControl, ReentrancyGuard {
    using SafeMath for uint256;

    // 角色定义
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SOCIAL_WORKER_ROLE = keccak256("SOCIAL_WORKER_ROLE");
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    // 社会福利类型枚举
    enum WelfareType {
        SurvivalSupport,    // 生存支持
        EducationSupport,     // 教育支持
        MedicalSupport,       // 医疗支持
        HousingSupport,       // 住房支持
        EmergencySupport,     // 紧急支持
        DisabilitySupport,    // 残障支持
        ElderlySupport,       // 老年人支持
        ChildSupport          // 儿童支持
    }

    // 申请状态枚举
    enum ApplicationStatus {
        Pending,      // 待审核
        Approved,     // 已批准
        Rejected,     // 已拒绝
        Disbursed,    // 已发放
        Completed,    // 已完成
        Cancelled     // 已取消
    }

    // 用户社会福利档案结构
    struct UserWelfareProfile {
        bool isRegistered;
        uint256 welfareScore;         // 福利评分
        uint256 familySize;           // 家庭规模
        uint256 incomeLevel;          // 收入水平 (1-10, 1为最低)
        uint256 specialNeeds;         // 特殊需求标志
        uint256 disabilityLevel;      // 残障等级 (0-10)
        uint256 ageGroup;             // 年龄组 (0:儿童,1:青年,2:中年,3:老年)
        uint256 totalReceived;        // 总接收金额
        uint256 applicationCount;     // 申请次数
        uint256 successfulApplications; // 成功申请次数
        mapping(uint256 => bool) hasReceivedType; // 福利类型接收记录
    }

    // 福利申请结构
    struct WelfareApplication {
        uint256 applicationId;
        address applicant;
        WelfareType welfareType;
        ApplicationStatus status;
        uint256 requestedAmount;
        uint256 approvedAmount;
        uint256 applicationTime;
        uint256 approvalTime;
        uint256 disbursementTime;
        string reason;
        string reviewNotes;
        address socialWorker;
        uint256 priorityScore;        // 优先级评分
        bool isEmergency;             // 是否为紧急申请
    }

    // 福利预算结构
    struct WelfareBudget {
        uint256 totalBudget;          // 总预算
        uint256 allocatedBudget;      // 已分配预算
        uint256 disbursedBudget;      // 已发放预算
        uint256 remainingBudget;      // 剩余预算
        uint256 monthlyAllocation;    // 月度分配
        mapping(WelfareType => uint256) typeBudgets; // 各类型预算
    }

    // 系统参数结构
    struct SystemParams {
        uint256 maxApplicationAmount;     // 最大申请金额
        uint256 approvalThreshold;        // 批准阈值
        uint256 emergencyThreshold;       // 紧急阈值
        uint256 reviewPeriod;             // 审核周期 (秒)
        uint256 disbursementDelay;        // 发放延迟 (秒)
        uint256 welfareMultiplier;        // 福利倍数 (特殊群体)
        uint256 educationBonus;           // 教育奖励
        uint256 medicalBonus;             // 医疗奖励
    }

    // 状态变量
    IERC20 public immutable welfareToken;
    mapping(address => UserWelfareProfile) public userWelfareProfiles;
    mapping(uint256 => WelfareApplication) public welfareApplications;
    mapping(address => uint256[]) public userApplications;
    mapping(WelfareType => uint256) public typeSuccessRates;
    mapping(uint256 => mapping(WelfareType => uint256)) public monthlyStats;

    WelfareBudget public welfareBudget;
    SystemParams public systemParams;
    
    uint256 public totalApplications;
    uint256 public totalApproved;
    uint256 public totalDisbursed;
    uint256 public currentMonth;
    uint256 public applicationCounter;

    // 事件定义
    event UserRegistered(address indexed user, uint256 timestamp);
    event WelfareApplicationSubmitted(uint256 indexed applicationId, address indexed user, WelfareType welfareType, uint256 amount);
    event WelfareApplicationReviewed(uint256 indexed applicationId, address indexed socialWorker, ApplicationStatus status, uint256 amount);
    event WelfareDisbursed(uint256 indexed applicationId, address indexed user, uint256 amount, WelfareType welfareType);
    event BudgetAllocated(WelfareType welfareType, uint256 amount, uint256 month);
    event EmergencySupportActivated(address indexed user, uint256 amount, uint256 timestamp);
    event SystemParamsUpdated(string paramName, uint256 oldValue, uint256 newValue);

    /**
     * @dev 构造函数
     * @param _welfareToken 福利代币地址
     * @param _admin 管理员地址
     */
    constructor(address _welfareToken, address _admin) {
        require(_welfareToken != address(0), "Invalid token address");
        require(_admin != address(0), "Invalid admin address");

        welfareToken = IERC20(_welfareToken);
        
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(SOCIAL_WORKER_ROLE, _admin);
        _setupRole(ORACLE_ROLE, _admin);

        // 初始化系统参数
        systemParams = SystemParams({
            maxApplicationAmount: 10000 * 10**18,  // 最大申请金额 10000代币
            approvalThreshold: 70,                 // 批准阈值 70分
            emergencyThreshold: 90,                  // 紧急阈值 90分
            reviewPeriod: 7 days,                    // 审核周期 7天
            disbursementDelay: 1 days,               // 发放延迟 1天
            welfareMultiplier: 150,                  // 福利倍数 1.5倍
            educationBonus: 20,                    // 教育奖励 20%
            medicalBonus: 30                         // 医疗奖励 30%
        });

        currentMonth = block.timestamp / 30 days; // 当前月份
    }

    /**
     * @dev 注册用户社会福利档案
     * @param _familySize 家庭规模
     * @param _incomeLevel 收入水平 (1-10)
     * @param _disabilityLevel 残障等级 (0-10)
     * @param _ageGroup 年龄组
     */
    function registerUserWelfareProfile(
        uint256 _familySize,
        uint256 _incomeLevel,
        uint256 _disabilityLevel,
        uint256 _ageGroup
    ) external {
        require(!userWelfareProfiles[msg.sender].isRegistered, "Already registered");
        require(_familySize > 0 && _familySize <= 20, "Invalid family size");
        require(_incomeLevel >= 1 && _incomeLevel <= 10, "Invalid income level");
        require(_disabilityLevel <= 10, "Invalid disability level");
        require(_ageGroup <= 3, "Invalid age group");

        UserWelfareProfile storage profile = userWelfareProfiles[msg.sender];
        profile.isRegistered = true;
        profile.familySize = _familySize;
        profile.incomeLevel = _incomeLevel;
        profile.disabilityLevel = _disabilityLevel;
        profile.ageGroup = _ageGroup;
        profile.welfareScore = _calculateInitialWelfareScore(_familySize, _incomeLevel, _disabilityLevel, _ageGroup);
        
        // 计算特殊需求标志
        profile.specialNeeds = _calculateSpecialNeeds(_disabilityLevel, _incomeLevel, _ageGroup);

        emit UserRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev 提交福利申请
     * @param _welfareType 福利类型
     * @param _requestedAmount 申请金额
     * @param _reason 申请原因
     * @param _isEmergency 是否为紧急申请
     */
    function submitWelfareApplication(
        WelfareType _welfareType,
        uint256 _requestedAmount,
        string memory _reason,
        bool _isEmergency
    ) external nonReentrant {
        require(userWelfareProfiles[msg.sender].isRegistered, "User not registered");
        require(_requestedAmount > 0 && _requestedAmount <= systemParams.maxApplicationAmount, "Invalid amount");
        require(bytes(_reason).length > 10, "Reason too short");

        UserWelfareProfile storage profile = userWelfareProfiles[msg.sender];
        require(profile.applicationCount < 10 || profile.successfulApplications > 0, "Application limit exceeded");

        applicationCounter++;
        uint256 applicationId = applicationCounter;

        // 计算优先级评分
        uint256 priorityScore = _calculatePriorityScore(msg.sender, _welfareType, _requestedAmount, _isEmergency);

        welfareApplications[applicationId] = WelfareApplication({
            applicationId: applicationId,
            applicant: msg.sender,
            welfareType: _welfareType,
            status: ApplicationStatus.Pending,
            requestedAmount: _requestedAmount,
            approvedAmount: 0,
            applicationTime: block.timestamp,
            approvalTime: 0,
            disbursementTime: 0,
            reason: _reason,
            reviewNotes: "",
            socialWorker: address(0),
            priorityScore: priorityScore,
            isEmergency: _isEmergency
        });

        userApplications[msg.sender].push(applicationId);
        profile.applicationCount++;
        totalApplications++;

        emit WelfareApplicationSubmitted(applicationId, msg.sender, _welfareType, _requestedAmount);

        // 如果是紧急申请，自动触发快速审核
        if (_isEmergency && priorityScore >= systemParams.emergencyThreshold) {
            _emergencySupport(msg.sender, applicationId);
        }
    }

    /**
     * @dev 审核福利申请
     * @param _applicationId 申请ID
     * @param _status 审核状态
     * @param _approvedAmount 批准金额
     * @param _reviewNotes 审核意见
     */
    function reviewWelfareApplication(
        uint256 _applicationId,
        ApplicationStatus _status,
        uint256 _approvedAmount,
        string memory _reviewNotes
    ) external onlyRole(SOCIAL_WORKER_ROLE) {
        WelfareApplication storage application = welfareApplications[_applicationId];
        require(application.applicationId > 0, "Invalid application");
        require(application.status == ApplicationStatus.Pending, "Already reviewed");
        require(block.timestamp >= application.applicationTime.add(systemParams.reviewPeriod), "Review period not met");

        if (_status == ApplicationStatus.Approved) {
            require(_approvedAmount > 0 && _approvedAmount <= application.requestedAmount, "Invalid approved amount");
            require(welfareBudget.remainingBudget >= _approvedAmount, "Insufficient budget");
            
            application.approvedAmount = _approvedAmount;
            application.approvalTime = block.timestamp;
            welfareBudget.allocatedBudget = welfareBudget.allocatedBudget.add(_approvedAmount);
            welfareBudget.remainingBudget = welfareBudget.remainingBudget.sub(_approvedAmount);
            
            userWelfareProfiles[application.applicant].successfulApplications++;
            totalApproved++;
        }

        application.status = _status;
        application.reviewNotes = _reviewNotes;
        application.socialWorker = msg.sender;

        emit WelfareApplicationReviewed(_applicationId, msg.sender, _status, _approvedAmount);
    }

    /**
     * @dev 发放福利
     * @param _applicationId 申请ID
     */
    function disburseWelfare(uint256 _applicationId) external nonReentrant {
        WelfareApplication storage application = welfareApplications[_applicationId];
        require(application.applicationId > 0, "Invalid application");
        require(application.status == ApplicationStatus.Approved, "Not approved");
        require(block.timestamp >= application.approvalTime.add(systemParams.disbursementDelay), "Disbursement delay not met");

        application.status = ApplicationStatus.Disbursed;
        application.disbursementTime = block.timestamp;
        
        welfareBudget.disbursedBudget = welfareBudget.disbursedBudget.add(application.approvedAmount);
        welfareBudget.allocatedBudget = welfareBudget.allocatedBudget.sub(application.approvedAmount);
        
        userWelfareProfiles[application.applicant].totalReceived = 
            userWelfareProfiles[application.applicant].totalReceived.add(application.approvedAmount);
        
        userWelfareProfiles[application.applicant].hasReceivedType[uint256(application.welfareType)] = true;
        
        totalDisbursed = totalDisbursed.add(application.approvedAmount);

        // 转账
        welfareToken.transfer(application.applicant, application.approvedAmount);

        emit WelfareDisbursed(_applicationId, application.applicant, application.approvedAmount, application.welfareType);
    }

    /**
     * @dev 紧急支持
     * @param _user 用户地址
     * @param _applicationId 申请ID
     */
    function _emergencySupport(address _user, uint256 _applicationId) internal {
        WelfareApplication storage application = welfareApplications[_applicationId];
        UserWelfareProfile storage profile = userWelfareProfiles[_user];
        
        uint256 emergencyAmount = application.requestedAmount.div(2); // 紧急支持50%的申请金额
        if (emergencyAmount > welfareBudget.remainingBudget) {
            emergencyAmount = welfareBudget.remainingBudget;
        }
        
        application.status = ApplicationStatus.Approved;
        application.approvedAmount = emergencyAmount;
        application.approvalTime = block.timestamp;
        application.reviewNotes = "Emergency support - fast track approval";
        
        welfareBudget.allocatedBudget = welfareBudget.allocatedBudget.add(emergencyAmount);
        welfareBudget.remainingBudget = welfareBudget.remainingBudget.sub(emergencyAmount);
        
        profile.successfulApplications++;
        totalApproved++;
        
        emit EmergencySupportActivated(_user, emergencyAmount, block.timestamp);
        emit WelfareApplicationReviewed(_applicationId, address(this), ApplicationStatus.Approved, emergencyAmount);
    }

    /**
     * @dev 分配月度预算
     * @param _totalBudget 总预算
     * @param _typeBudgets 各类型预算分配
     */
    function allocateMonthlyBudget(
        uint256 _totalBudget,
        uint256[] memory _typeBudgets
    ) external onlyRole(ADMIN_ROLE) {
        require(_totalBudget > 0, "Invalid total budget");
        require(_typeBudgets.length == 8, "Invalid budget array length");
        
        uint256 sum = 0;
        for (uint8 i = 0; i < _typeBudgets.length; i++) {
            sum = sum.add(_typeBudgets[i]);
        }
        require(sum == _totalBudget, "Budget sum mismatch");
        
        uint256 month = block.timestamp / 30 days;
        
        welfareBudget.totalBudget = welfareBudget.totalBudget.add(_totalBudget);
        welfareBudget.remainingBudget = welfareBudget.remainingBudget.add(_totalBudget);
        
        for (uint8 i = 0; i < _typeBudgets.length; i++) {
            welfareBudget.typeBudgets[WelfareType(i)] = welfareBudget.typeBudgets[WelfareType(i)].add(_typeBudgets[i]);
            monthlyStats[month][WelfareType(i)] = monthlyStats[month][WelfareType(i)].add(_typeBudgets[i]);
            emit BudgetAllocated(WelfareType(i), _typeBudgets[i], month);
        }
        
        currentMonth = month;
    }

    /**
     * @dev 计算初始福利评分
     */
    function _calculateInitialWelfareScore(
        uint256 _familySize,
        uint256 _incomeLevel,
        uint256 _disabilityLevel,
        uint256 _ageGroup
    ) internal pure returns (uint256) {
        // 基础评分 = 100 - 收入等级 * 8 + 家庭规模 * 3 + 残障等级 * 5 + 年龄调整
        uint256 baseScore = 100;
        uint256 incomeScore = (11 - _incomeLevel).mul(8); // 收入越低分数越高
        uint256 familyScore = _familySize.mul(3); // 家庭规模调整
        uint256 disabilityScore = _disabilityLevel.mul(5); // 残障等级调整
        uint256 ageScore = _ageGroup == 3 ? 10 : (_ageGroup == 0 ? 8 : 0); // 老年人和儿童额外分数
        
        return incomeScore.add(familyScore).add(disabilityScore).add(ageScore);
    }

    /**
     * @dev 计算特殊需求标志
     */
    function _calculateSpecialNeeds(
        uint256 _disabilityLevel,
        uint256 _incomeLevel,
        uint256 _ageGroup
    ) internal pure returns (uint256) {
        uint256 specialFlag = 0;
        
        if (_disabilityLevel >= 5) specialFlag |= 1; // 重度残障
        if (_incomeLevel <= 2) specialFlag |= 2; // 极低收入
        if (_ageGroup == 3) specialFlag |= 4; // 老年人
        if (_ageGroup == 0) specialFlag |= 8; // 儿童
        
        return specialFlag;
    }

    /**
     * @dev 计算优先级评分（增强版）
     */
    function _calculatePriorityScore(
        address _user,
        WelfareType _welfareType,
        uint256 _requestedAmount,
        bool _isEmergency
    ) internal view returns (uint256) {
        UserWelfareProfile storage profile = userWelfareProfiles[_user];
        
        // 基础评分
        uint256 baseScore = profile.welfareScore;
        
        // 福利类型权重（基于社会重要性）
        uint256 typeWeight = _getWelfareTypeWeight(_welfareType);
        uint256 typeScore = typeWeight.mul(8);
        
        // 申请金额权重（考虑实际需求）
        uint256 normalizedAmount = _normalizeRequestAmount(_requestedAmount, _welfareType);
        uint256 amountScore = normalizedAmount.div(100).mul(3);
        
        // 紧急情况评分
        uint256 emergencyScore = _isEmergency ? 35 : 0;
        
        // 特殊需求综合评分
        uint256 specialNeedsScore = _calculateSpecialNeedsScore(profile);
        
        // 收入影响评分（考虑家庭规模）
        uint256 incomeImpactScore = _calculateIncomeImpactScore(profile);
        
        // 历史记录评分（鼓励合理使用）
        uint256 historyScore = _calculateUsageHistoryScore(profile);
        
        // 时间敏感性评分
        uint256 timeSensitivityScore = _calculateTimeSensitivityScore(_welfareType, profile);
        
        return baseScore
            .add(typeScore)
            .add(amountScore)
            .add(emergencyScore)
            .add(specialNeedsScore)
            .add(incomeImpactScore)
            .add(historyScore)
            .add(timeSensitivityScore);
    }

    /**
     * @dev 获取福利类型权重
     */
    function _getWelfareTypeWeight(WelfareType _welfareType) internal pure returns (uint256) {
        // 基于社会重要性和紧急程度的权重分配
        if (_welfareType == WelfareType.SurvivalSupport) return 12;     // 生存支持最高
        if (_welfareType == WelfareType.EmergencySupport) return 11;  // 紧急支持
        if (_welfareType == WelfareType.MedicalSupport) return 10;    // 医疗支持
        if (_welfareType == WelfareType.DisabilitySupport) return 9;    // 残障支持
        if (_welfareType == WelfareType.ChildSupport) return 8;       // 儿童支持
        if (_welfareType == WelfareType.ElderlySupport) return 7;     // 老年人支持
        if (_welfareType == WelfareType.HousingSupport) return 6;     // 住房支持
        if (_welfareType == WelfareType.EducationSupport) return 5;   // 教育支持
        return 1;
    }

    /**
     * @dev 标准化申请金额
     */
    function _normalizeRequestAmount(uint256 _amount, WelfareType _welfareType) internal pure returns (uint256) {
        // 基于福利类型的合理金额范围标准化
        uint256 maxReasonableAmount = _getMaxReasonableAmount(_welfareType);
        if (_amount <= maxReasonableAmount) {
            return _amount;
        }
        return maxReasonableAmount.add(_amount.sub(maxReasonableAmount).div(3)); // 超出部分降低权重
    }

    /**
     * @dev 获取福利类型的合理最大金额
     */
    function _getMaxReasonableAmount(WelfareType _welfareType) internal pure returns (uint256) {
        if (_welfareType == WelfareType.SurvivalSupport) return 2000 * 10**18;
        if (_welfareType == WelfareType.EmergencySupport) return 5000 * 10**18;
        if (_welfareType == WelfareType.MedicalSupport) return 8000 * 10**18;
        if (_welfareType == WelfareType.HousingSupport) return 10000 * 10**18;
        if (_welfareType == WelfareType.EducationSupport) return 3000 * 10**18;
        if (_welfareType == WelfareType.DisabilitySupport) return 4000 * 10**18;
        if (_welfareType == WelfareType.ElderlySupport) return 2500 * 10**18;
        if (_welfareType == WelfareType.ChildSupport) return 2000 * 10**18;
        return 1000 * 10**18;
    }

    /**
     * @dev 计算特殊需求综合评分
     */
    function _calculateSpecialNeedsScore(UserWelfareProfile storage profile) internal view returns (uint256) {
        uint256 score = 0;
        
        // 残障等级评分
        if (profile.disabilityLevel >= 8) score += 25;
        else if (profile.disabilityLevel >= 5) score += 15;
        else if (profile.disabilityLevel >= 3) score += 8;
        
        // 家庭特殊情况评分
        if (profile.familySize >= 5) score += 10;
        if (profile.familySize >= 8) score += 15;
        
        // 年龄特殊需求评分
        if (profile.ageGroup == 3) score += 12; // 老年人
        if (profile.ageGroup == 0) score += 10; // 儿童
        
        // 综合特殊需求标志评分
        if (profile.specialNeeds & 1 != 0) score += 8;  // 重度残障
        if (profile.specialNeeds & 2 != 0) score += 12; // 极低收入
        if (profile.specialNeeds & 4 != 0) score += 8;  // 老年人
        if (profile.specialNeeds & 8 != 0) score += 6;  // 儿童
        
        return score;
    }

    /**
     * @dev 计算收入影响评分
     */
    function _calculateIncomeImpactScore(UserWelfareProfile storage profile) internal pure returns (uint256) {
        // 考虑家庭规模的人均收入影响
        uint256 incomeImpact = (11 - profile.incomeLevel).mul(4);
        uint256 familyImpact = profile.familySize > 4 ? (profile.familySize - 4).mul(3) : 0;
        
        return incomeImpact.add(familyImpact);
    }

    /**
     * @dev 计算使用历史评分
     */
    function _calculateUsageHistoryScore(UserWelfareProfile storage profile) internal pure returns (uint256) {
        if (profile.applicationCount == 0) return 10; // 首次申请鼓励
        
        uint256 successRate = profile.successfulApplications.mul(100).div(profile.applicationCount);
        
        if (successRate >= 80) return 8;   // 高成功率用户
        if (successRate >= 60) return 5;   // 中等成功率
        if (successRate >= 40) return 2;   // 较低成功率
        return 0; // 低成功率用户
    }

    /**
     * @dev 计算时间敏感性评分
     */
    function _calculateTimeSensitivityScore(WelfareType _welfareType, UserWelfareProfile storage profile) internal view returns (uint256) {
        uint256 score = 0;
        
        // 福利类型时间敏感性
        if (_welfareType == WelfareType.EmergencySupport) score += 15;
        if (_welfareType == WelfareType.MedicalSupport) score += 10;
        if (_welfareType == WelfareType.SurvivalSupport) score += 8;
        
        // 用户年龄时间敏感性
        if (profile.ageGroup == 3) score += 5; // 老年人
        if (profile.ageGroup == 0) score += 3; // 儿童
        
        // 残障等级时间敏感性
        if (profile.disabilityLevel >= 7) score += 8;
        else if (profile.disabilityLevel >= 4) score += 5;
        
        return score;
    }

    /**
     * @dev 更新系统参数
     */
    function updateSystemParams(
        uint256 _maxApplicationAmount,
        uint256 _approvalThreshold,
        uint256 _emergencyThreshold,
        uint256 _reviewPeriod,
        uint256 _disbursementDelay,
        uint256 _welfareMultiplier,
        uint256 _educationBonus,
        uint256 _medicalBonus
    ) external onlyRole(ADMIN_ROLE) {
        require(_approvalThreshold <= 100, "Invalid approval threshold");
        require(_emergencyThreshold <= 100, "Invalid emergency threshold");
        require(_reviewPeriod > 0, "Invalid review period");
        require(_disbursementDelay > 0, "Invalid disbursement delay");
        require(_welfareMultiplier >= 100, "Invalid welfare multiplier");
        
        SystemParams memory oldParams = systemParams;
        
        systemParams.maxApplicationAmount = _maxApplicationAmount;
        systemParams.approvalThreshold = _approvalThreshold;
        systemParams.emergencyThreshold = _emergencyThreshold;
        systemParams.reviewPeriod = _reviewPeriod;
        systemParams.disbursementDelay = _disbursementDelay;
        systemParams.welfareMultiplier = _welfareMultiplier;
        systemParams.educationBonus = _educationBonus;
        systemParams.medicalBonus = _medicalBonus;
        
        emit SystemParamsUpdated("all", 0, 1); // 简化事件
    }

    /**
     * @dev 获取用户福利档案
     */
    function getUserWelfareProfile(address _user) external view returns (
        bool isRegistered,
        uint256 welfareScore,
        uint256 familySize,
        uint256 incomeLevel,
        uint256 specialNeeds,
        uint256 disabilityLevel,
        uint256 ageGroup,
        uint256 totalReceived,
        uint256 applicationCount,
        uint256 successfulApplications
    ) {
        UserWelfareProfile storage profile = userWelfareProfiles[_user];
        return (
            profile.isRegistered,
            profile.welfareScore,
            profile.familySize,
            profile.incomeLevel,
            profile.specialNeeds,
            profile.disabilityLevel,
            profile.ageGroup,
            profile.totalReceived,
            profile.applicationCount,
            profile.successfulApplications
        );
    }

    /**
     * @dev 获取用户申请列表
     */
    function getUserApplications(address _user) external view returns (uint256[] memory) {
        return userApplications[_user];
    }

    /**
     * @dev 获取申请详情
     */
    function getApplicationDetails(uint256 _applicationId) external view returns (WelfareApplication memory) {
        return welfareApplications[_applicationId];
    }

    /**
     * @dev 获取系统统计信息
     */
    function getSystemStats() external view returns (
        uint256 _totalApplications,
        uint256 _totalApproved,
        uint256 _totalDisbursed,
        uint256 _currentMonth,
        uint256 _remainingBudget
    ) {
        return (
            totalApplications,
            totalApproved,
            totalDisbursed,
            currentMonth,
            welfareBudget.remainingBudget
        );
    }

    /**
     * @dev 获取月度统计
     */
    function getMonthlyStats(uint256 _month, WelfareType _welfareType) external view returns (uint256) {
        return monthlyStats[_month][_welfareType];
    }

    /**
     * @dev 检查用户是否有资格申请特定福利类型
     */
    function checkEligibility(address _user, WelfareType _welfareType) external view returns (bool) {
        UserWelfareProfile storage profile = userWelfareProfiles[_user];
        
        if (!profile.isRegistered) return false;
        
        // 基于用户档案和福利类型的资格检查逻辑
        if (_welfareType == WelfareType.DisabilitySupport && profile.disabilityLevel < 3) return false;
        if (_welfareType == WelfareType.ElderlySupport && profile.ageGroup != 3) return false;
        if (_welfareType == WelfareType.ChildSupport && profile.ageGroup != 0) return false;
        
        return true;
    }
}