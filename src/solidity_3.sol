// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InsuranceOptions is Ownable, IERC721Receiver {
    using SafeMath for uint256;

    ISuperfluid private _superfluid;
    ISuperToken private _acceptedToken;

    struct Option {
        uint256 tokenId;
        address owner;
        uint256 strikePrice;
        uint256 expiration;
        bool exercised;
    }

    mapping(uint256 => Option) public options;
    uint256 public optionCounter = 0;

    event OptionCreated(
        uint256 indexed optionId,
        uint256 tokenId,
        address indexed owner,
        uint256 strikePrice,
        uint256 expiration
    );
    event OptionExercised(uint256 indexed optionId, uint256 indexed payout);
    event OptionExpired(uint256 indexed optionId);

    constructor(address superfluid, address acceptedToken) {
        _superfluid = ISuperfluid(superfluid);
        _acceptedToken = ISuperToken(acceptedToken);
    }

    function createOption(
        uint256 tokenId,
        uint256 strikePrice,
        uint256 expiration
    ) external {
        require(
            _acceptedToken.allowance(msg.sender, address(this)) >= strikePrice,
            "Option premium not approved"
        );
        require(
            _acceptedToken.transferFrom(msg.sender, address(this), strikePrice),
            "Option premium transfer failed"
        );
        require(
            IERC721(msg.sender).ownerOf(tokenId) == msg.sender,
            "Only token owner can create option"
        );

        options[optionCounter] = Option(
            tokenId,
            msg.sender,
            strikePrice,
            expiration,
            false
        );
        emit OptionCreated(
            optionCounter,
            tokenId,
            msg.sender,
            strikePrice,
            expiration
        );

        optionCounter++;
    }

    function exerciseOption(uint256 optionId) external {
        require(
            block.timestamp < options[optionId].expiration,
            "Option expired"
        );
        require(
            IERC721(msg.sender).ownerOf(options[optionId].tokenId) ==
                msg.sender,
            "Only token owner can exercise option"
        );
        require(!options[optionId].exercised, "Option already exercised");

        uint256 payout = 0;
        if (block.timestamp < options[optionId].expiration / 2) {
            payout = options[optionId].strikePrice * 2;
        } else {
            payout = options[optionId].strikePrice;
        }

        options[optionId].exercised = true;
        require(
            _acceptedToken.transfer(msg.sender, payout),
            "Payout transfer failed"
        );
        emit OptionExercised(optionId, payout);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function expireOption(uint256 optionId) external onlyOwner {
        require(!options[optionId].exercised, "Option already exercised");
        require(
            block.timestamp >= options[optionId].expiration,
            "Option not expired"
        );

        uint256 premiumRefund = options[optionId].strikePrice;
        options[optionId].exercised = true;
        require(
            _acceptedToken.transfer(options[optionId].owner, premiumRefund),
            "Premium refund transfer failed"
        );
        emit OptionExpired(optionId);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
        _acceptedToken.approve(newOwner, type(uint256).max);
    }

    function withdrawTokens(address to, uint256 amount) external onlyOwner {
        require(_acceptedToken.transfer(to, amount), "Token transfer failed");
    }

    function changeAcceptedToken(address newAcceptedToken) external onlyOwner {
        _acceptedToken = ISuperToken(newAcceptedToken);
    }
}
