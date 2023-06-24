// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/ILaunchpadStorage.sol";
import "../../lib/AccessControl.sol";

contract LaunchpadStorage is AccessControl {
    LaunchpadLib.LaunchpadItem[] private launchpads;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    receive() external payable {}

    function claimETH() external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = payable(ultimateAdmin()).call{
            value: address(this).balance
        }("");
        require(success, "can not transfer fund");
    }

    function getAllLaunchpads()
        public
        view
        returns (LaunchpadLib.LaunchpadItem[] memory)
    {
        return launchpads;
    }

    function addLaunchpad(
        LaunchpadLib.LaunchpadItem memory agrs
    ) external onlyRole(MODERATOR_ROLE) {
        launchpads.push(
            LaunchpadLib.LaunchpadItem(
                agrs.launch,
                agrs.sale_token,
                agrs.buy_rate,
                agrs.list_rate,
                agrs.buy_min,
                agrs.buy_max,
                agrs.softcap,
                agrs.hardcap,
                agrs.isBurnRefund,
                agrs.liquidity_percent,
                agrs.liquidity_lock,
                agrs.pool_type,
                // agrs.whitelist,
                agrs.presale_start,
                agrs.presale_end,
                agrs.metadata
            )
        );
    }

    function findLaunchpadIndex(
        address launchAddress
    ) internal view returns (uint256) {
        for (uint i = 0; i < launchpads.length; i++) {
            if (launchpads[i].launch == launchAddress) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function removeLaunchpadByIndex(uint256 index) internal {
        if (index >= launchpads.length) return;

        for (uint256 i = index; i < launchpads.length - 1; i++) {
            launchpads[i] = launchpads[i + 1];
        }
        delete launchpads[launchpads.length - 1];
        launchpads.pop();
    }

    function countLaunchpadsByToken(
        address tokenAddress
    ) internal view returns (uint256) {
        uint256 total;
        for (uint i = 0; i < launchpads.length; i++) {
            if (launchpads[i].launch == tokenAddress) {
                total++;
            }
        }
        return total;
    }

    function removeLaunchpadbyLaunchAddress(
        address launchaddress_
    ) external onlyRole(MODERATOR_ROLE) {
        uint256 index = findLaunchpadIndex(launchaddress_);
        if (index == type(uint256).max) {
            return;
        }
        removeLaunchpadByIndex(index);
    }

    function removeLaunchpadbyToken(
        address token_
    ) external onlyRole(MODERATOR_ROLE) {
        uint256 total = countLaunchpadsByToken(token_);

        for (uint256 i = 0; i < total; i++) {
            uint256 index = type(uint256).max;
            for (uint x = 0; x < launchpads.length; x++) {
                if (launchpads[x].sale_token == token_) {
                    index = x;
                    break;
                }
            }
            if (index == type(uint256).max) {
                break;
            }
            removeLaunchpadByIndex(index);
        }
    }

    function clearAllLaunchpad() external onlyRole(MODERATOR_ROLE) {
        for (uint256 i = 0; i < launchpads.length - 1; i++) {
            launchpads.pop();
        }
    }
}
