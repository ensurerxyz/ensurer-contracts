// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../../interface/IFactory.sol";
import "./Pair.sol";

contract Factory is IFactory {
    bool public override isPaused;
    address public pauser;
    address public pendingPauser;
    address public immutable override treasury;

    mapping(address => mapping(address => mapping(bool => address)))
        public
        override getPair;
    address[] public allPairs;
    /// @dev Simplified check if its a pair, given that `stable` flag might not be available in peripherals
    mapping(address => bool) public override isPair;

    address internal _temp0;
    address internal _temp1;
    bool internal _temp;

    /// swap fee = SWAP_FEE / DOMINATOR * 100
    uint public override SWAP_FEE = 25;
    /// treasury fee = (swap fee) * TREASURY_FEE / DOMINATOR * 100
    uint public override TREASURY_FEE = 50_000;
    uint public override DOMINATOR = 100_000;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        bool stable,
        address pair,
        uint allPairsLength
    );

    modifier onlyPauser() {
        require(msg.sender == pauser, "Factory: Not pauser");
        _;
    }

    constructor(address _treasury) {
        pauser = msg.sender;
        isPaused = false;
        treasury = _treasury;
        SWAP_FEE = 0;
    }

    function updateFees(
        uint _swap_fee,
        uint _treasury_fee,
        uint _dominator
    ) external override onlyPauser {
        require(
            _swap_fee < _dominator && _treasury_fee < _dominator,
            "Factory: invalid fee"
        );
        require(
            _swap_fee * 100 <= _dominator,
            "Factory: swap fee must less than 1%"
        );
        SWAP_FEE = _swap_fee;
        TREASURY_FEE = _treasury_fee;
        DOMINATOR = _dominator;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function setPauser(address _pauser) external onlyPauser {
        pendingPauser = _pauser;
    }

    function acceptPauser() external {
        require(msg.sender == pendingPauser, "Factory: Not pending pauser");
        pauser = pendingPauser;
    }

    function setPause(bool _state) external onlyPauser {
        isPaused = _state;
    }

    function pairCodeHash() external pure override returns (bytes32) {
        return keccak256(type(Pair).creationCode);
    }

    function getInitializable()
        external
        view
        override
        returns (address, address, bool)
    {
        return (_temp0, _temp1, _temp);
    }

    function createPair(
        address tokenA,
        address tokenB,
        bool stable
    ) external override returns (address pair) {
        require(!isPaused, "Factory: Factory PAUSED");
        require(tokenA != tokenB, "Factory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Factory: ZERO_ADDRESS");
        require(
            getPair[token0][token1][stable] == address(0),
            "Factory: PAIR_EXISTS"
        );
        // notice salt includes stable as well, 3 parameters
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, stable));
        (_temp0, _temp1, _temp) = (token0, token1, stable);
        pair = address(new Pair{salt: salt}());
        getPair[token0][token1][stable] = pair;
        // populate mapping in the reverse direction
        getPair[token1][token0][stable] = pair;
        allPairs.push(pair);
        isPair[pair] = true;
        emit PairCreated(token0, token1, stable, pair, allPairs.length);
    }
}
