// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IFactory {
    function SWAP_FEE() external view returns (uint256);

    function TREASURY_FEE() external view returns (uint256);

    function DOMINATOR() external view returns (uint256);

    function treasury() external view returns (address);

    function isPair(address pair) external view returns (bool);

    function getInitializable() external view returns (address, address, bool);

    function isPaused() external view returns (bool);

    function pairCodeHash() external pure returns (bytes32);

    function getPair(
        address tokenA,
        address token,
        bool stable
    ) external view returns (address);

    function createPair(
        address tokenA,
        address tokenB,
        bool stable
    ) external returns (address pair);

    function updateFees(
        uint256 _swap_fee,
        uint256 _treasury_fee,
        uint256 _dominator
    ) external;
}
