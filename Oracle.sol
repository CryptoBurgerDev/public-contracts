// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Oracle is OwnableUpgradeable {
    bool public isInitialized;
    address routerAddress;
    address[] public path_BURG_BNB_BUSD;

    constructor() initializer {}

    /*
    function to initialize contract
    */
    function initialize(
        address routerAddress_,
        address[] memory path_BURG_BNB_BUSD_
    ) public initializer {
        __Ownable_init();

        path_BURG_BNB_BUSD = path_BURG_BNB_BUSD_;
        routerAddress = routerAddress_;
        isInitialized = true;
    }

    /*
    function to get price of BURG in BSUD from router
    */
    function priceCBURGInDollars() public view returns (uint256) {
        uint256[] memory amounts = IUniswapV2Router02(routerAddress)
            .getAmountsOut(1000000000000000000, path_BURG_BNB_BUSD);
        return amounts[2];
    }

    /*
    function to get how many CBURG are _amountInDollars amount
    */
    function getDollarsInCBURG(uint256 _amountInDollars)
        external
        view
        returns (uint256)
    {
        return (_amountInDollars * 1e18) / priceCBURGInDollars();
    }
}
