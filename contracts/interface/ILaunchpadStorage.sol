// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAccessControl.sol";

library LaunchpadLib {
    struct LaunchpadItem {
        address launch;
        address sale_token;
        uint256 buy_rate;
        uint256 list_rate;
        uint256 buy_min;
        uint256 buy_max;
        uint256 softcap;
        uint256 hardcap;
        bool isBurnRefund;
        uint256 liquidity_percent;
        uint256 liquidity_lock;
        uint256 pool_type;
        uint256 presale_start;
        uint256 presale_end;
        string metadata;
    }
}

interface ILaunchpadStorage is IAccessControl {
    function claimETH() external;

    function getAllLaunchpads()
        external
        view
        returns (LaunchpadLib.LaunchpadItem[] memory);

    function addLaunchpad(LaunchpadLib.LaunchpadItem memory) external;

    function removeLaunchpadbyLaunchAddress(address launchaddress_) external;

    function removeLaunchpadbyToken(address token_) external;

    function clearAllLaunchpad() external;
}
