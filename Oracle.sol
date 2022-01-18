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
    uint256 public priceBURGInDollars;
    uint256 public priceBNBInDollars;
    address public backendOracleWalletAddress;

    event PriceBURGChanged(uint256 newPrice);
    event PriceBNBChanged(uint256 newPrice);
    event PriceBURGAndBNBChanged(uint256 newPriceBURG, uint256 newPriceBNB);

    constructor() initializer {}

    function initialize()
        public
        initializer
    {
        __Ownable_init();
        priceBURGInDollars = 5 * 1e17;
        priceBNBInDollars = 500 * 1e18;
        backendOracleWalletAddress = 0xe384b4F158a633EF600246B3Ee6Ee4Da9d99B829;
        isInitialized = true;
    }

    function setBURGPriceInDollars(uint256 _newPriceDollars) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceBURGInDollars = _newPriceDollars;
        emit PriceBURGChanged(_newPriceDollars);
    }

    function getDollarsInBURG(uint256 _amountBURG)
        external
        view
        returns (uint256)
    {
        return (_amountBURG * 1e18) / priceBURGInDollars;
    }

    function setBNBPriceInDollars(uint256 _newPriceDollars) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceBNBInDollars = _newPriceDollars;
        emit PriceBNBChanged(_newPriceDollars);
    }

    function getDollarsInBNB(uint256 _amountBURG)
        external
        view
        returns (uint256)
    {
        return (_amountBURG * 1e18) / priceBNBInDollars;
    }

    function setBURGAndBNBPriceInDollars(
        uint256 _newPriceBURG,
        uint256 _newPriceBNB
    ) external {
        require(
            msg.sender == owner() || msg.sender == backendOracleWalletAddress,
            "Not allowed"
        );
        priceBURGInDollars = _newPriceBURG;
        priceBNBInDollars = _newPriceBNB;
        emit PriceBURGAndBNBChanged(_newPriceBURG, _newPriceBNB);
    }

    function changebackendOracleWalletAddress(address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        backendOracleWalletAddress = _newAddress;
        return true;
    }
}
