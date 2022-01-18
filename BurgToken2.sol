/*
CRYPTOBURGERS
Web: https://cryptoburgers.io
Telegram: https://t.me/cryptoburgersnft
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract BurgToken2 is ERC20Capped, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    // Antiwhale
    uint256 public startDate;
    uint256 public endDate;
    uint256 public limitWhale;
    bool public antiWhaleActivated;
    address public rewardsWallet;

    // Whitelist Addresses
    mapping(address => bool) public whitelistAddresses;

    constructor(address rewardsWallet_)
        ERC20("BURG2 Token", "BURG2")
        ERC20Capped(100 * 1e6 * 1e18)
    {
        _mint(0x2C260699603E31593fB66E6D6Cd0De5D8148c7c5, 50 * 1e6 * 1e18); // 50M Play to earn
        //!!! _mint(0x62Eb4E8C1629feD1eF5f93f15e69233157B64E1A, 50 * 1e6 * 1e18); // 50M Play to earn
        _mint(0xeBb7e8B99D4C7f0d20370fA4325B0d5506aDd665, 12 * 1e6 * 1e18); // Team
        _mint(0xeF884E379dB4121E44998875075a232149da3461, 10 * 1e6 * 1e18); // Public Sale
        _mint(0x3043a13DF5d6D4350279Ea75b561C47D769d18DA, 8 * 1e6 * 1e18); // Liquidity
        _mint(0x95763B49E631Ce798aA34efB07654618E850d2Ce, 7 * 1e6 * 1e18); // Advisors
        _mint(0x5eA8639E7a7b47184b0f8f136aE280b0186C18CC, 5 * 1e6 * 1e18); // Marketing
        _mint(0xc1F6e12F3A56766DA16191e03D124Fc197940f2f, 5 * 1e6 * 1e18); // Platform Development
        _mint(0x3429a4069DD2666bD857B0be74180f64fF67f1aF, 2 * 1e6 * 1e18); // Private Sale
        _mint(0x7C8449230A7D1857619612F9B0C00169732b524f, 1 * 1e6 * 1e18); // Airdrop

        // AntiWhale 2021-01-01 to 2100-01-01
        setAntiWhale(1641028005, 4102477605, 0 * 1e3 * 1e18);

        rewardsWallet = rewardsWallet_;

        setPermissions();
    }

    function setPermissions() internal {
        changeWhitelistAddress(
            0xeBb7e8B99D4C7f0d20370fA4325B0d5506aDd665, //OK
            true
        );
        changeWhitelistAddress(
            0xeF884E379dB4121E44998875075a232149da3461,
            true
        );
        changeWhitelistAddress(
            0x3043a13DF5d6D4350279Ea75b561C47D769d18DA,
            true
        );
        changeWhitelistAddress(
            0x95763B49E631Ce798aA34efB07654618E850d2Ce,
            true
        );
        changeWhitelistAddress(
            0x5eA8639E7a7b47184b0f8f136aE280b0186C18CC,
            true
        );
        changeWhitelistAddress(
            0xc1F6e12F3A56766DA16191e03D124Fc197940f2f,
            true
        );
        changeWhitelistAddress(
            0x3429a4069DD2666bD857B0be74180f64fF67f1aF,
            true
        );
        changeWhitelistAddress(
            0x7C8449230A7D1857619612F9B0C00169732b524f,
            true
        );

    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        super._beforeTokenTransfer(_from, _to, _amount);

        require(!isWhale(_from, _to, _amount), "AntiWhale");
    }

    // ANTIWHALE MAX TRANSACTION
    function activateAntiWhale() public onlyOwner {
        require(antiWhaleActivated == false);
        antiWhaleActivated = true;
    }

    function deActivateAntiWhale() public onlyOwner {
        require(antiWhaleActivated == true);
        antiWhaleActivated = false;
    }

    function setAntiWhale(
        uint256 _startDate,
        uint256 _endDate,
        uint256 _limitWhale
    ) public onlyOwner {
        startDate = _startDate;
        endDate = _endDate;
        limitWhale = _limitWhale;
        antiWhaleActivated = true;
    }

    function changeRewardsWalletAddress(address _newAddress)
        external
        onlyOwner
    {
        rewardsWallet = _newAddress;
    }

    function isWhale(
        address _from,
        address _to,
        uint256 _amount
    ) public view returns (bool) {
        if (
            msg.sender == owner() ||
            whitelistAddresses[_from] == true ||
            antiWhaleActivated == false ||
            _amount <= limitWhale ||
            _from == rewardsWallet ||
            _to == rewardsWallet
        ) {
            return false;
        }

        if (block.timestamp >= startDate && block.timestamp <= endDate) {
            return true;
        }

        return false;
    }

    function changeWhitelistAddress(address _address, bool _allowed)
        public
        onlyOwner
    {
        whitelistAddresses[_address] = _allowed;
    }
}
