// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./Oracle.sol";

contract Bridge is
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bool public isInitialized;

    address public CBURGTokenAddress;
    address public backendBridgeWalletAddress1;
    address public backendBridgeWalletAddress2;
    address public oracleContractAddress;
    address public rewardsWallet;
    uint256 public nonce;

    event EventBSCToGameExecuted(
        address indexed walletOfUser,
        uint256 amountInCBURG,
        uint256 amountInDollars,
        uint256 nonce,
        uint256 timestamp
    );

    event EventGameToBSCExecuted(
        address indexed walletOfUser,
        uint256 amountInCBURG,
        uint256 amountInDollars,
        uint256 nonce,
        uint256 timestamp
    );

    constructor() initializer {}

    /*
    function to initialize contract
    */
    function initialize(
        address CBURGTokenAddress_,
        address backendBridgeWalletAddress1_,
        address backendBridgeWalletAddress2_,
        address oracleContractAddress_,
        address rewardsWallet_
    ) public initializer {
        __Ownable_init();
        CBURGTokenAddress = CBURGTokenAddress_;

        backendBridgeWalletAddress1 = backendBridgeWalletAddress1_;
        backendBridgeWalletAddress2 = backendBridgeWalletAddress2_;

        oracleContractAddress = oracleContractAddress_;
        rewardsWallet = rewardsWallet_;
        isInitialized = true;
    }

    /*
    function to send tokens from msg.sender to rewardsWallet
    */
    function bridgeBSCToGame(uint256 _amountInCBURG)
        external
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        uint256 _amountInDollars = (Oracle(oracleContractAddress)
            .priceCBURGInDollars() * _amountInCBURG) / 1e18;

        IERC20Upgradeable(CBURGTokenAddress).safeTransferFrom(
            msg.sender,
            rewardsWallet,
            _amountInCBURG
        );

        nonce = nonce + 1;

        emit EventBSCToGameExecuted(
            msg.sender,
            _amountInCBURG,
            _amountInDollars,
            nonce,
            block.timestamp
        );

        return true;
    }

    /*
    function to send tokens rewardsWallet to _walletOfUser
    */
    function bridgeGameToBSC(
        address[] memory _walletOfUser,
        uint256[] memory _amountInDollars
    ) external whenNotPaused nonReentrant {
        // Only minter wallet can do this
        require(
            msg.sender == owner() || msg.sender == backendBridgeWalletAddress1,
            "Not allowed"
        );

        for (uint256 index = 0; index < _walletOfUser.length; index++) {
            uint256 _amountInCBURG = (
                Oracle(oracleContractAddress).getDollarsInCBURG(
                    _amountInDollars[index]
                )
            );

            IERC20Upgradeable(CBURGTokenAddress).safeTransferFrom(
                rewardsWallet,
                _walletOfUser[index],
                _amountInCBURG
            );

            nonce = nonce + 1;

            emit EventGameToBSCExecuted(
                _walletOfUser[index],
                _amountInCBURG,
                _amountInDollars[index],
                nonce,
                block.timestamp
            );
        }
    }

    /*
    function to change address of the CBURG token
    */
    function changeCBURGTokenAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        CBURGTokenAddress = _newAddress;
        return true;
    }

    /*
    function to change backend wallet address 1
    */
    function changeBackendBridgeWalletAddress1(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendBridgeWalletAddress1 = _newAddress;
        return true;
    }

    /*
    function to change backend wallet address 2
    */
    function changeBackendBridgeWalletAddress2(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendBridgeWalletAddress2 = _newAddress;
        return true;
    }

    /*
    function to change Oracle contract address
    */
    function changeOracleContractAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        oracleContractAddress = _newAddress;
        return true;
    }

    /*
    function to change rewards wallet address
    */
    function changeRewardsWalletAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        rewardsWallet = _newAddress;
        return true;
    }

    /*
    function to pause the contract
    */
    function pauseContract() external onlyOwner {
        _pause();
    }

    /*
    function to unpause the contract
    */
    function unpauseContract() external onlyOwner {
        _unpause();
    }
}
