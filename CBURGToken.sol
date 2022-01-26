// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract CBURGToken is ERC20Capped, Ownable {
    // Antiwhale
    uint256 public startDate;
    uint256 public endDate;
    uint256 public limitWhale;
    bool public antiWhaleActivated;
    address public rewardsWallet;

    // Whitelist Addresses
    mapping(address => bool) public whitelistAddresses;

    constructor(address rewardsWallet_, address tokensWallet_)
        ERC20("CBURG Token", "CBURG")
        ERC20Capped(100 * 1e6 * 1e18)
    {
        _mint(tokensWallet_, 100 * 1e6 * 1e18);

        // AntiWhale 2021-01-01 to 2100-01-01
        setAntiWhale(1641028005, 4102477605, 0 * 1e3 * 1e18);

        rewardsWallet = rewardsWallet_;

        changeWhitelistAddress(tokensWallet_, true);
    }

    /*
    Openzeppelin hook to check if is a whale or not
    */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        super._beforeTokenTransfer(_from, _to, _amount);

        require(!isWhale(_from, _to, _amount), "AntiWhale");
    }

    /*
    function to activate antiWhale
    */
    function activateAntiWhale() public onlyOwner {
        require(antiWhaleActivated == false);
        antiWhaleActivated = true;
    }

    /*
    function to deactivate antiWhale
    */
    function deActivateAntiWhale() public onlyOwner {
        require(antiWhaleActivated == true);
        antiWhaleActivated = false;
    }

    /*
    function to set antiWhale.  Requires startDate, endDate, limitWhale (amount)
    and sets antiWhaleActivated to true
    */
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

    /*
    function to change rewardsWallet variable
    */
    function changeRewardsWalletAddress(address _newAddress)
        external
        onlyOwner
    {
        rewardsWallet = _newAddress;
    }

    /*
    function that checks if a transfer can be done.
    If antiWhale is activated, only allow tranfers if an address is whiteListed, or if the amount is less than limitWhale, or any transfer from the rewardsWallet.
    */
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

    /*
    function to enable or disable an address of the whitelistAddresses mapping
    */
    function changeWhitelistAddress(address _address, bool _allowed)
        public
        onlyOwner
    {
        whitelistAddresses[_address] = _allowed;
    }
}
