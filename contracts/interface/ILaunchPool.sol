// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILaunchPool {
    event PresaleCreated(address, address);
    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);

    enum SaleType {
        PUBLIC,
        WHITELIST
    }

    struct LaunchInfo {
        uint256 buy_rate; // 1 base token = ? s_tokens, fixed price
        uint256 list_rate; // 1 base token = ? s_tokens, fixed price
        uint256 buy_min; // Maximum base token BUY amount per buyer
        uint256 buy_max; // The amount of presale tokens up for presale
        uint256 softcap; // Minimum raise amount
        uint256 hardcap; // Maximum raise amount
        bool isBurnRefund; // refund type when presale not filled 100%
        uint256 liquidity_percent; // percent of raised fund for liquidity, min 51%
        uint256 liquidity_lock; // lock days from presale end
        uint256 presale_start;
        uint256 presale_end;
        SaleType presale_type;
        uint256 public_time;
        bool canceled;
    }

    struct LaunchStatus {
        bool force_failed; // Set this flag to force fail the presale
        uint256 raised_amount; // Total base currency raised (usually ETH)
        uint256 sold_amount; // Total presale tokens sold
        uint256 token_withdraw; // Total tokens withdrawn post successful presale
        uint256 base_withdraw; // Total base tokens withdrawn on presale failure
        uint256 num_buyers; // Number of unique participants
        bool can_claim;
    }

    struct BuyerInfo {
        uint256 base; // Total base token (usually ETH) deposited by user, can be withdrawn on presale failure
        uint256 sale; // Num presale tokens a user owned, can be withdrawn on presale success
    }

    struct TokenInfo {
        address sale_token; // Sale token
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    function getLaunchInfo() external view returns (LaunchInfo memory);

    function getLaunchStatus() external view returns (LaunchStatus memory);

    function getTokenInfo() external view returns (TokenInfo memory);

    function metadata() external view returns (string memory);

    function tags(uint256 index) external view returns (string memory);

    function getBuyerInfo(
        address account
    ) external view returns (BuyerInfo memory);

    function whitelistInfo(address) external view returns (bool);

    function currentPair() external view returns (address);

    function admin_update_tags(uint256 num, string memory stt) external;

    function updateMetadata(string memory metadata_) external;

    function presaleStatus() external view returns (uint256);

    function userContribute() external payable;

    function userWithdrawTokens() external;

    function userWithdrawETH() external;

    function owner_finalize() external;

    function getTimestamp() external view returns (uint256);

    function setLockDelay(uint256 delay) external;

    function setWhitelist() external;

    function setWhitelistInfo(address[] memory user) external;

    function deleteWhitelistInfo(address[] memory user) external;

    function setPublic(uint256 time) external;

    function setCancel() external;

    function getSaleType() external view returns (bool);
}
