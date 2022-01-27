//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract Claim is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bool public isInitialized;

    mapping(address => uint256) public tokensToClaim;
    mapping(address => uint256) public claimedTokens;

    address public tokenAddress;

    bool public claimActive;

    event Claimed(address indexed addressClaim, uint256 amount);
    event ChangedClaimState(bool newState);

    constructor() initializer {}

    function initialize(address tokenAddress_) public initializer {
        __Ownable_init();
        tokenAddress = tokenAddress_;
        claimActive = false;
        isInitialized = true;
    }

    /*
    function to claim _amountToClaim tokens asigned to a user with function addAddresses.  Tokens are stored in this contract.
    */
    function claim(uint256 _amountToClaim)
        external
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        require(claimActive, "Claim not active");
        uint256 _maxTokensAmountToClaim = tokensToClaim[msg.sender];

        require(
            _amountToClaim + claimedTokens[msg.sender] <=
                _maxTokensAmountToClaim,
            "Amount exceeded"
        );

        claimedTokens[msg.sender] = claimedTokens[msg.sender] + _amountToClaim;
        IERC20Upgradeable(tokenAddress).safeTransfer(
            msg.sender,
            _amountToClaim
        );
        emit Claimed(msg.sender, _amountToClaim);
        return true;
    }

    /*
    function get user amount of tokens to be claimed for _address
    */
    function remainingTokensUser(address _address)
        public
        view
        returns (uint256)
    {
        return tokensToClaim[_address] - claimedTokens[_address];
    }

    /*
    function set the amount of tokens that each wallet can claim
    */
    function addAddresses(
        address[] memory _addresses,
        uint256[] memory _amountTokens
    ) external onlyOwner {
        require(
            _addresses.length == _amountTokens.length,
            "Not equal dimensions"
        );

        for (uint256 index = 0; index < _addresses.length; index++) {
            tokensToClaim[_addresses[index]] =
                tokensToClaim[_addresses[index]] +
                _amountTokens[index];
        }
    }

    /*
    function to remove addresses from mapping
    */
    function removeAddresses(address[] memory _addresses) external onlyOwner {
        for (uint256 index = 0; index < _addresses.length; index++) {
            tokensToClaim[_addresses[index]] = 0;
        }
    }

    /*
    function to set the token address to be claimed
    */
    function changeTokenAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        tokenAddress = _newAddress;
        return true;
    }

    /*
    function to enable or disable the claim function
    */
    function changeClaimState(bool _newState)
        external
        onlyOwner
        returns (bool)
    {
        claimActive = _newState;
        emit ChangedClaimState(_newState);
        return true;
    }

    /*
    function to pause contract
    */    function pause() external onlyOwner returns (bool) {
        _pause();
        return true;
    }
    /*
    function to unpause contract
    */
    function unpause() external onlyOwner returns (bool) {
        _unpause();
        return true;
    }

    /*
    function withdraw() external onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        (bool sent, ) = owner().call{value: balance}("");
        return sent;
    }

    function withdrawRemainingTokens(uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Upgradeable(tokenAddress).safeTransfer(msg.sender, _amount);
        return true;
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Upgradeable(_tokenAddress).safeTransfer(msg.sender, _amount);
        return (true);
    }
    */
}
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract Claim is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bool public isInitialized;

    mapping(address => uint256) public tokensToClaim;
    mapping(address => uint256) public claimedTokens;

    address public tokenAddress;

    bool public claimActive;

    event Claimed(address indexed addressClaim, uint256 amount);
    event ChangedClaimState(bool newState);

    constructor() initializer {}

    function initialize(address tokenAddress_) public initializer {
        __Ownable_init();
        tokenAddress = tokenAddress_;
        claimActive = false;
        isInitialized = true;
    }

    /*
    function to claim _amountToClaim tokens asigned to a user with function addAddresses.  Tokens are stored in this contract.
    */
    function claim(uint256 _amountToClaim)
        external
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        require(claimActive, "Claim not active");
        uint256 _maxTokensAmountToClaim = tokensToClaim[msg.sender];

        require(
            _amountToClaim + claimedTokens[msg.sender] <=
                _maxTokensAmountToClaim,
            "Amount exceeded"
        );

        claimedTokens[msg.sender] = claimedTokens[msg.sender] + _amountToClaim;
        IERC20Upgradeable(tokenAddress).safeTransfer(
            msg.sender,
            _amountToClaim
        );
        emit Claimed(msg.sender, _amountToClaim);
        return true;
    }

    /*
    function get user amount of tokens to be claimed for _address
    */
    function remainingTokensUser(address _address)
        public
        view
        returns (uint256)
    {
        return tokensToClaim[_address] - claimedTokens[_address];
    }

    /*
    function set the amount of tokens that each wallet can claim
    */
    function addAddresses(
        address[] memory _addresses,
        uint256[] memory _amountTokens
    ) external onlyOwner {
        require(
            _addresses.length == _amountTokens.length,
            "Not equal dimensions"
        );

        for (uint256 index = 0; index < _addresses.length; index++) {
            tokensToClaim[_addresses[index]] =
                tokensToClaim[_addresses[index]] +
                _amountTokens[index];
        }
    }

    /*
    function to remove addresses from mapping
    */
    function removeAddresses(address[] memory _addresses) external onlyOwner {
        for (uint256 index = 0; index < _addresses.length; index++) {
            tokensToClaim[_addresses[index]] = 0;
        }
    }

    /*
    function to set the token address to be claimed
    */
    function changeTokenAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        tokenAddress = _newAddress;
        return true;
    }

    /*
    function to enable or disable the claim function
    */
    function changeClaimState(bool _newState)
        external
        onlyOwner
        returns (bool)
    {
        claimActive = _newState;
        emit ChangedClaimState(_newState);
        return true;
    }

    /*
    function to pause contract
    */    function pause() external onlyOwner returns (bool) {
        _pause();
        return true;
    }
    /*
    function to unpause contract
    */
    function unpause() external onlyOwner returns (bool) {
        _unpause();
        return true;
    }

    /*
    function withdraw() external onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        (bool sent, ) = owner().call{value: balance}("");
        return sent;
    }

    function withdrawRemainingTokens(uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Upgradeable(tokenAddress).safeTransfer(msg.sender, _amount);
        return true;
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Upgradeable(_tokenAddress).safeTransfer(msg.sender, _amount);
        return (true);
    }
    */
}
