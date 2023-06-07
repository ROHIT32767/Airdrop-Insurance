// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Superfluid contracts
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/IConstantFlowAgreementV1.sol";

contract AirdropInsurance {

    // Declare Superfluid interfaces
    ISuperfluid private superfluid;
    IConstantFlowAgreementV1 private cfa;

    // Declare variables for Superfluid flow
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    bytes32 private constant SUPERFLUID_APP_ID = keccak256("org.superfluid-finance.insurance");
    uint256 private premiumFlowRate;
    address private premiumRecipient;
    uint256 private payoutFlowRate;
    address private payoutRecipient;

    // Declare variables for insurance options
    uint256 private constant OPTION_EXPIRATION_TIME = 30 days;
    uint256 private constant OPTION_STRIKE_PRICE = 1000; // 1 token per premium token
    uint256 private constant OPTION_COLLATERAL_RATIO = 150; // 150% of premium tokens as collateral
    uint256 private constant OPTION_COLLATERAL_EXPIRATION_TIME = 1 days;
    mapping(address => uint256) private optionBalances;
    mapping(address => uint256) private optionExpirationTimes;
    mapping(address => bool) private optionHolders;

    // Declare variables for treasury wallet
    address private treasuryWallet;
    mapping(address => uint256) private treasuryBalances;

    // Declare variables for risk management
    uint256 private totalRisk;
    uint256 private constant RISK_TO_PREMIUM_RATIO = 10; // 10% of premium as risk
    uint256 private constant RISK_TO_COLLATERAL_RATIO = 50; // 50% of collateral as risk
    uint256 private constant RISK_TO_TREASURY_RATIO = 5; // 5% of risk as treasury fee

    // Declare events
    event PremiumFlowRateUpdated(uint256 premiumFlowRate);
    event PremiumRecipientUpdated(address premiumRecipient);
    event PayoutFlowRateUpdated(uint256 payoutFlowRate);
    event PayoutRecipientUpdated(address payoutRecipient);
    event OptionPurchased(address indexed buyer, uint256 amount);
    event OptionSold(address indexed seller, uint256 amount);
    event OptionExercised(address indexed holder, uint256 amount);
    event TreasuryFeeCharged(address indexed holder, uint256 amount);

    constructor(address _superfluid, address _cfa, address _treasuryWallet) {
        superfluid = ISuperfluid(_superfluid);
        cfa = IConstantFlowAgreementV1(_cfa);
        treasuryWallet = _treasuryWallet; 
        
    }

    // Set premium flow rate and recipient
    function setPremiumFlow(uint256 _premiumFlowRate, address _premiumRecipient) external {
        require(msg.sender == owner(), "Only owner can set premium flow");
    // Stop existing flow
    if (premiumFlowRate != 0) {
        cfa.deleteFlow(superfluid.host(), superfluid.agreements(), address(this), premiumRecipient, SUPERFLUID_APP_ID, new bytes(0));
    }

    // Start new flow
    if (_premiumFlowRate != 0) {
        // Create new super token
        ISuperToken premiumToken = superfluid.createERC20Wrapper(superfluid.getERC20(address(this)), SUPERFLUID_APP_ID);

        // Approve super token transfer
        premiumToken.approve(address(cfa), MAX_UINT256);

        // Create new flow
        cfa.createFlow(
            premiumToken,
            _premiumRecipient,
            _premiumFlowRate,
            new bytes(0)
        );
    }

    premiumFlowRate = _premiumFlowRate;
    premiumRecipient = _premiumRecipient;
    emit PremiumFlowRateUpdated(premiumFlowRate);
    emit PremiumRecipientUpdated(premiumRecipient);
}

// Set payout flow rate and recipient
function setPayoutFlow(uint256 _payoutFlowRate, address _payoutRecipient) external {
    require(msg.sender == owner(), "Only owner can set payout flow");

    // Stop existing flow
    if (payoutFlowRate != 0) {
        cfa.deleteFlow(superfluid.host(), superfluid.agreements(), address(this), payoutRecipient, SUPERFLUID_APP_ID, new bytes(0));
    }

    // Start new flow
    if (_payoutFlowRate != 0) {
        // Create new super token
        ISuperToken payoutToken = superfluid.createERC20Wrapper(superfluid.getERC20(address(this)), SUPERFLUID_APP_ID);

        // Approve super token transfer
        payoutToken.approve(address(cfa), MAX_UINT256);

        // Create new flow
        cfa.createFlow(
            payoutToken,
            _payoutRecipient,
            _payoutFlowRate,
            new bytes(0)
        );
    }

    payoutFlowRate = _payoutFlowRate;
    payoutRecipient = _payoutRecipient;
    emit PayoutFlowRateUpdated(payoutFlowRate);
    emit PayoutRecipientUpdated(payoutRecipient);
}

// Purchase insurance option
function purchaseOption(uint256 _amount) external {
    require(optionHolders[msg.sender] == false, "Option already owned by buyer");
    require(optionExpirationTimes[msg.sender] == 0, "Option already expired");

    // Calculate premium tokens needed
    uint256 premiumTokens = _amount * OPTION_STRIKE_PRICE;
    uint256 collateralTokens = premiumTokens * OPTION_COLLATERAL_RATIO / 100;
    uint256 collateralExpirationTime = block.timestamp + OPTION_COLLATERAL_EXPIRATION_TIME;

    // Transfer premium tokens from buyer to this contract
    require(superfluid.getERC20(address(this)).transferFrom(msg.sender, address(this), premiumTokens), "Failed to transfer premium tokens");

    // Transfer collateral tokens from buyer to this contract
    require(superfluid.getERC20(address(this)).transferFrom(msg.sender, address(this), collateralTokens), "Failed to transfer collateral tokens");

    // Add option balance and expiration time
    optionBalances[msg.sender] = _amount;
    optionExpirationTimes[msg.sender] = block.timestamp + OPTION_EXPIRATION_TIME;
    optionHolders[msg.sender] = true;

    // Update total risk
    uint256 risk = _amount * OPTION_STRIKE_PRICE * RISK_TO_PREMIUM_RATIO / 100;
    risk += collateralTokens * RISK_TO_COLLATERAL_RATIO / 100;
    totalRisk += risk;

    emit OptionPurchased(msg.sender, _amount);
}

// Sell insurance option
function sellOption(uint256 _amount, address _buyer, uint256 _price) external {
    require(optionHolders[msg.sender] == true, "Option not owned by seller");
    require(optionBalances[msg.sender] >= _amount, "Not enough options to sell");

    // Calculate premium tokens to return to buyer
    uint256 premiumTokens = _amount * OPTION_STRIKE_PRICE;

    // Transfer premium tokens to buyer
    require(superfluid.getERC20(address(this)).transfer(_buyer, premiumTokens), "Failed to transfer premium tokens to buyer");

    // Subtract option balance
    optionBalances[msg.sender] -= _amount;

    // If seller sold all options, remove from option holders
    if (optionBalances[msg.sender] == 0) {
        optionHolders[msg.sender] = false;
    }

    // Update total risk
    uint256 risk = _amount * OPTION_STRIKE_PRICE * RISK_TO_PREMIUM_RATIO / 100;
    totalRisk -= risk;

    emit OptionSold(msg.sender, _amount, _buyer, _price);
}

// Exercise insurance option
function exerciseOption() external {
    require(optionHolders[msg.sender] == true, "Option not owned by buyer");
    require(optionExpirationTimes[msg.sender] > 0, "Option already expired");
    require(block.timestamp >= optionExpirationTimes[msg.sender], "Option not yet expired");

    // Calculate payout tokens to receive
    uint256 payoutTokens = optionBalances[msg.sender] * OPTION_STRIKE_PRICE;

    // Transfer payout tokens from this contract to buyer
    require(superfluid.getERC20(address(this)).transfer(msg.sender, payoutTokens), "Failed to transfer payout tokens");

    // Stop premium flow
    if (premiumFlowRate != 0) {
        cfa.deleteFlow(superfluid.host(), superfluid.agreements(), address(this), premiumRecipient, SUPERFLUID_APP_ID, new bytes(0));
        premiumFlowRate = 0;
        emit PremiumFlowRateUpdated(premiumFlowRate);
    }

    // Stop payout flow
    if (payoutFlowRate != 0) {
        cfa.deleteFlow(superfluid.host(), superfluid.agreements(), address(this), payoutRecipient, SUPERFLUID_APP_ID, new bytes(0));
        payoutFlowRate = 0;
        emit PayoutFlowRateUpdated(payoutFlowRate);
    }

    // Remove option balance and expiration time
    optionBalances[msg.sender] = 0;
    optionExpirationTimes[msg.sender] = 0;
    optionHolders[msg.sender] = false;

    // Update total risk
    uint256 risk = optionBalances[msg.sender] * OPTION_STRIKE_PRICE * RISK_TO_PREMIUM_RATIO / 100;
    totalRisk -= risk;

    emit OptionExercised(msg.sender);
}

// // Withdraw collateral
// function withdrawCollateral() external {
//     require(optionHolders[msg.sender] == true, "Option not owned by buyer");
//     require(optionExpirationTimes[msg.sender] > 0, "Option already expired");
//     require(block.timestamp < optionExpirationTimes[msg.sender], "Option already expired");

//     // Transfer collateral tokens from this contract to buyer
//     require(superfluid.getERC20(address(this)).transfer(msg.sender, optionBalances[msg.sender] * OPTION_COLLATERAL_RATIO / 100), "Failed to transfer collateral tokens");

//     emit CollateralWithdrawn
// }

// Claim payout for expired option
function claimPayout() external {
    require(optionHolders[msg.sender] == true, "Option not owned by buyer");
    require(optionExpirationTimes[msg.sender] <= block.timestamp, "Option not expired");
    require(optionPayouts[msg.sender] == false, "Option payout already claimed");

    // Calculate payout tokens
    uint256 payoutTokens = optionBalances[msg.sender] * OPTION_STRIKE_PRICE * OPTION_PAYOUT_RATIO / 100;

    // Transfer payout tokens from this contract to buyer
    require(superfluid.getERC20(address(this)).transfer(msg.sender, payoutTokens), "Failed to transfer payout tokens");

    // Mark option payout as claimed
    optionPayouts[msg.sender] = true;

    emit PayoutClaimed(msg.sender);
}

    // Get option balance
    function getOptionBalance(address _holder) external view returns (uint256) {
        return optionBalances[_holder];
    }

    // Get option expiration time
    function getOptionExpirationTime(address _holder) external view returns (uint256) {
        return optionExpirationTimes[_holder];
    }

    // Get option payout status
    function getOptionPayoutStatus(address _holder) external view returns (bool) {
        return optionPayouts[_holder];
    }

    // Get total risk
    function getTotalRisk() external view returns (uint256) {
        return totalRisk;
    }

}