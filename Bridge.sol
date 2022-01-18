/*
CRYPTOBURGERS
Web: https://cryptoburgers.io
Telegram: https://t.me/cryptoburgersnft
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "hardhat/console.sol";

import "./Oracle.sol";

contract Bridge is
    OwnableUpgradeable,
    ERC20PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;

    bool public isInitialized;

    address public BURGTokenAddress;
    address public backendBridgeWalletAddress1;
    address public backendBridgeWalletAddress2;
    address public oracleContractAddress;
    address public rewardsWallet;
    uint256 public nonce;

    event EventBSCToGameExecuted(
        address indexed walletOfUser,
        uint256 amountInBURG,
        uint256 amountInDollars,
        uint256 nonce,
        uint256 timestamp
    );

    event EventGameToBSCExecuted(
        address indexed walletOfUser,
        uint256 amountInBURG,
        uint256 amountInDollars,
        uint256 nonce,
        uint256 timestamp
    );

    constructor() initializer {}

    function initialize(
        address BURGTokenAddress_,
        address backendBridgeWalletAddress1_,
        address backendBridgeWalletAddress2_,
        address oracleContractAddress_,
        address rewardsWallet_
    ) public initializer {
        __Ownable_init();
        BURGTokenAddress = BURGTokenAddress_;

        backendBridgeWalletAddress1 = backendBridgeWalletAddress1_;
        backendBridgeWalletAddress2 = backendBridgeWalletAddress2_;

        oracleContractAddress = oracleContractAddress_;
        rewardsWallet = rewardsWallet_;
        isInitialized = true;
    }

    function bridgeBSCToGame(uint256 _amountInBURG)
        external
        whenNotPaused
        nonReentrant
        returns (bool)
    {
        // 1.-  Checkear allowance para gastar sus BURG en el front

        uint256 _amountInDollars = (Oracle(oracleContractAddress)
            .priceBURGInDollars() * _amountInBURG) / 1e18;

        IERC20Upgradeable(BURGTokenAddress).safeTransferFrom(
            msg.sender,
            rewardsWallet,
            _amountInBURG
        );

        nonce = nonce + 1;

        emit EventBSCToGameExecuted(
            msg.sender,
            _amountInBURG,
            _amountInDollars,
            nonce,
            block.timestamp
        );

        // 3.-  Escuchar con pastEvents y procesar en el backend para actualizar la información.

        return true;
    }

    function bridgeGameToBSC(
        address[] memory _walletOfUser,
        uint256[] memory _amountInDollars
    ) external whenNotPaused nonReentrant {
        // Only minter wallet can do this
        require(
            msg.sender == owner() || msg.sender == backendBridgeWalletAddress1,
            "Not allowed"
        );

        // 1.-  Descontar en el backend directamente y anotas en la tabla de transacciones

        // 2.-  Transferir
        for (uint256 index = 0; index < _walletOfUser.length; index++) {
            uint256 _amountInBURG = (
                Oracle(oracleContractAddress).getDollarsInBURG(
                    _amountInDollars[index]
                )
            );

            IERC20Upgradeable(BURGTokenAddress).safeTransferFrom(
                rewardsWallet,
                _walletOfUser[index],
                _amountInBURG
            );

            nonce = nonce + 1;

            emit EventGameToBSCExecuted(
                _walletOfUser[index],
                _amountInBURG,
                _amountInDollars[index],
                nonce,
                block.timestamp
            );
        }
    }

    function changeBackendBridgeWalletAddress1(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendBridgeWalletAddress1 = _newAddress;
        return true;
    }

    function changeBackendBridgeWalletAddress2(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendBridgeWalletAddress2 = _newAddress;
        return true;
    }

    function changeOracleContractAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        oracleContractAddress = _newAddress;
        return true;
    }

    function changeRewardsWalletAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        rewardsWallet = _newAddress;
        return true;
    }

    function pauseContract() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }
}
