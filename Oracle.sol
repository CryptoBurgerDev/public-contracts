/*
CRYPTOBURGERS
Web: https://cryptoburgers.io
Telegram: https://t.me/cryptoburgersnft
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Oracle is OwnableUpgradeable {
    bool public isInitialized;
    uint256 public priceCBURGInDollars;
    uint256 public priceBNBInDollars;
    address public backendOracleWalletAddress;

    event PriceCBURGChanged(uint256 newPrice);
    event PriceBNBChanged(uint256 newPrice);
    event PriceCBURGAndBNBChanged(uint256 newPriceCBURG, uint256 newPriceBNB);

    constructor() initializer {}

    /*
    function to initialize contract
    */
    function initialize() public initializer {
        __Ownable_init();
        priceCBURGInDollars = 5 * 1e17;
        priceBNBInDollars = 500 * 1e18;
        backendOracleWalletAddress = 0xe384b4F158a633EF600246B3Ee6Ee4Da9d99B829;
        isInitialized = true;
    }

    /*
    function to set the price of the CBURG in dollars
    */
    function setCBURGPriceInDollars(uint256 _newPriceDollars) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceCBURGInDollars = _newPriceDollars;
        emit PriceCBURGChanged(_newPriceDollars);
    }

    /*
    function to get how many CBURG are _amountInDollars amount
    */
    function getDollarsInCBURG(uint256 _amountInDollars)
        external
        view
        returns (uint256)
    {
        return (_amountInDollars * 1e18) / priceCBURGInDollars;
    }

    /*
    function to set BNB price in dollars
    */
    function setBNBPriceInDollars(uint256 _newPriceDollars) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceBNBInDollars = _newPriceDollars;
        emit PriceBNBChanged(_newPriceDollars);
    }

    /*
    function to get how many BNB are _amountDollars amount
    */
    function getDollarsInBNB(uint256 _amountDollars)
        external
        view
        returns (uint256)
    {
        return (_amountDollars * 1e18) / priceBNBInDollars;
    }

    /*
    function to set CBURG and BNB price in dollars
    */
    function setCBURGAndBNBPriceInDollars(
        uint256 _newPriceCBURG,
        uint256 _newPriceBNB
    ) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceCBURGInDollars = _newPriceCBURG;
        priceBNBInDollars = _newPriceBNB;
        emit PriceCBURGAndBNBChanged(_newPriceCBURG, _newPriceBNB);
    }

    /*
    function to change the address of backendOracleWalletAddress
    */
    function changebackendOracleWalletAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendOracleWalletAddress = _newAddress;
        return true;
    }
}
