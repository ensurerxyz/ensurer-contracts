// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicToken is ERC20, Ownable {
    bool public mintable;

    constructor(
        string memory name__,
        string memory symbol__,
        uint256 sypply__,
        bool mintable__
    ) ERC20(name__, symbol__) {
        mintable = mintable__;
        _mint(msg.sender, sypply__ * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(mintable, "can not mint token");
        _mint(to, amount);
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            (bool success, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(success);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }
}
