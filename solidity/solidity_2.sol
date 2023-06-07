// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISuperfluid {
    function getERC20(address token) external view returns (IERC20);
}

contract AirdropInsurance {
    address public admin;
    address public treasuryWallet;
    ISuperfluid public superfluid;

    uint256 public constant OPTION_STRIKE_PRICE = 1 ether;
    uint256 public constant OPTION_COLLATERAL_RATIO = 150;
    uint256 public constant OPTION_PAYOUT_RATIO = 200;
    uint256 public constant RISK_TO_PREMIUM_RATIO = 500;

    mapping(address => uint256) public optionBalances;
    mapping(address => bool) public optionHolders;
    mapping(address => uint256) public optionExpirationTimes;
    mapping(address => bool) public optionPayouts;

    uint256 public totalRisk;

    event OptionPurchased(
        address buyer,
        uint256 amount,
        uint256 expirationTime
    );
    event OptionSold(address seller, uint256 amount);
    event PayoutClaimed(address buyer);
    event CollateralWithdrawn(address buyer);

    constructor(address _admin, address _treasuryWallet, address _superfluid) {
        admin = _admin;
        treasuryWallet = _treasuryWallet;
        superfluid = ISuperfluid(_superfluid);
    }

    // Purchase option tokens
    function purchaseOptions(
        uint256 _amount,
        uint256 _expirationTime
    ) external {
        require(
            superfluid.getERC20(address(this)).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "Failed to transfer option tokens"
        );

        // Calculate premium tokens buyer will pay
        uint256 premiumTokens = (_amount *
            OPTION_STRIKE_PRICE *
            OPTION_COLLATERAL_RATIO) / 100;

        // Transfer premium tokens from buyer to this contract
        require(
            superfluid.getERC20(address(this)).transferFrom(
                msg.sender,
                address(this),
                premiumTokens
            ),
            "Failed to transfer premium tokens"
        );

        // Add option balance and expiration time
        optionBalances[msg.sender] += _amount;
        optionHolders[msg.sender] = true;
        optionExpirationTimes[msg.sender] = _expirationTime;

        // Update total risk
        uint256 risk = (_amount * OPTION_STRIKE_PRICE * RISK_TO_PREMIUM_RATIO) /
            100;
        totalRisk += risk;

        emit OptionPurchased(msg.sender, _amount, _expirationTime);
    }

    // Sell option tokens
    function sellOptions(uint256 _amount) external {
        require(
            optionHolders[msg.sender] == true,
            "Option not owned by seller"
        );
        require(
            optionExpirationTimes[msg.sender] > block.timestamp,
            "Option already expired"
        );

        // Calculate premium tokens seller will receive
        uint256 premiumTokens = _amount * OPTION_STRIKE_PRICE;

        // Transfer option tokens to buyer
        require(
            superfluid.getERC20(address(this)).transfer(msg.sender, _amount),
            "Failed to transfer option tokens"
        );

        // Transfer premium tokens from buyer to seller
        require(
            superfluid.getERC20(address(this)).transferFrom(
                msg.sender,
                msg.sender,
                premiumTokens
            ),
            "Failed to transfer premium tokens"
        );

        // Remove option balance and expiration time
        optionBalances[msg.sender] -= _amount;
        if (optionBalances[msg.sender] == 0) {
            optionHolders[msg.sender] = false;
            optionExpirationTimes[msg.sender] = 0;
        }

        // Update total risk
        uint256 risk = (_amount * OPTION_STRIKE_PRICE * RISK_TO_PREMIUM_RATIO) /
            100;
        totalRisk -= risk;

        emit OptionSold(msg.sender, _amount);
    }

    // Claim payout for option
    function claimPayout() external {
        require(optionHolders[msg.sender] == true, "Option not owned by buyer");
        require(
            optionExpirationTimes[msg.sender] <= block.timestamp,
            "Option has not expired"
        );
        require(optionPayouts[msg.sender] == false, "Payout already claimed");

        // Calculate payout tokens
        uint256 payoutTokens = (optionBalances[msg.sender] *
            OPTION_STRIKE_PRICE *
            OPTION_PAYOUT_RATIO) / 100;

        // Transfer payout tokens from this contract to buyer
        require(
            superfluid.getERC20(address(this)).transfer(
                msg.sender,
                payoutTokens
            ),
            "Failed to transfer payout tokens"
        );

        // Mark option as claimed
        optionPayouts[msg.sender] = true;

        emit PayoutClaimed(msg.sender);
    }

    // Withdraw collateral
    function withdrawCollateral() external {
        require(optionHolders[msg.sender] == true, "Option not owned by buyer");
        require(
            optionExpirationTimes[msg.sender] > 0,
            "Option already expired"
        );
        require(
            block.timestamp < optionExpirationTimes[msg.sender],
            "Option already expired"
        );

        // Transfer collateral tokens from this contract to buyer
        require(
            superfluid.getERC20(address(this)).transfer(
                msg.sender,
                (optionBalances[msg.sender] * OPTION_COLLATERAL_RATIO) / 100
            ),
            "Failed to transfer collateral tokens"
        );

        emit CollateralWithdrawn(msg.sender);
    }
}
