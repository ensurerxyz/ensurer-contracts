## Ensurer

Ensurer allows low cost, near 0 slippage trades on uncorrelated or tightly correlated assets. The protocol incentivizes fees instead of liquidity. Liquidity providers (LPs) are given incentives in the form of `token`, the amount received is calculated as follows;

* 100% of weekly distribution weighted on votes from ve-token holders

The above is distributed to the `gauge` (see below), however LPs will earn between 40% and 100% based on their own ve-token balance.

LPs with 0 ve* balance, will earn a maximum of 40%.

## AMM

What differentiates Ensurer's AMM;

Ensurer AMMs are compatible with all the standard features as popularized by Uniswap V2, these include;

* Lazy LP management
* Fungible LP positions
* Chained swaps to route between pairs
* priceCumulativeLast that can be used as external TWAP
* Flashloan proof TWAP
* Direct LP rewards via `skim`
* xy>=k

Ensurer adds on the following features;

* 0 upkeep 30 minute TWAPs. This means no additional upkeep is required, you can quote directly from the pair
* Fee split. Fees do not auto accrue, this allows external protocols to be able to profit from the fee claim
* New curve: x3y+y3x, which allows efficient stable swaps
* Curve quoting: `y = (sqrt((27 a^3 b x^2 + 27 a b^3 x^2)^2 + 108 x^12) + 27 a^3 b x^2 + 27 a b^3 x^2)^(1/3)/(3 2^(1/3) x) - (2^(1/3) x^3)/(sqrt((27 a^3 b x^2 + 27 a b^3 x^2)^2 + 108 x^12) + 27 a^3 b x^2 + 27 a b^3 x^2)^(1/3)`
* Routing through both stable and volatile pairs
* Flashloan proof reserve quoting

## token

**TBD**

## ve-token

Vested Escrow (ve), this is the core voting mechanism of the system, used by `BaseV1Factory` for gauge rewards and gauge voting.

This is based off of ve(3,3)

* `deposit_for` deposits on behalf of
* `emit Transfer` to allow compatibility with third party explorers
* balance is moved to `tokenId` instead of `address`
* Locks are unique as NFTs, and not on a per `address` basis

```
function balanceOfNFT(uint) external returns (uint)
```

## BaseV1Pair

Base V1 pair is the base pair, referred to as a `pool`, it holds two (2) closely correlated assets (example MIM-UST) if a stable pool or two (2) uncorrelated assets (example FTM-SPELL) if not a stable pool, it uses the standard UniswapV2Pair interface for UI & analytics compatibility.

```
function mint(address to) external returns (uint liquidity)
function burn(address to) external returns (uint amount0, uint amount1)
function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external
```

Functions should not be referenced directly, should be interacted with via the BaseV1Router

Fees are not accrued in the base pair themselves, but are transfered to `BaseV1Fees` which has a 1:1 relationship with `BaseV1Pair`

### BaseV1Factory

Base V1 factory allows for the creation of `pools` via ```function createPair(address tokenA, address tokenB, bool stable) external returns (address pair)```

Base V1 factory uses an immutable pattern to create pairs, further reducing the gas costs involved in swaps

Anyone can create a pool permissionlessly.

### BaseV1Router

Base V1 router is a wrapper contract and the default entry point into Stable V1 pools.

```

function addLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external ensure(deadline) returns (uint amountA, uint amountB, uint liquidity)

function removeLiquidity(
    address tokenA,
    address tokenB,
    bool stable,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) public ensure(deadline) returns (uint amountA, uint amountB)

function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    route[] calldata routes,
    address to,
    uint deadline
) external ensure(deadline) returns (uint[] memory amounts)

```

## Gauge

Gauges distribute arbitrary `token(s)` rewards to BaseV1Pair LPs based on voting weights as defined by `ve` voters.

Arbitrary rewards can be added permissionlessly via ```function notifyRewardAmount(address token, uint amount) external```

Gauges are completely overhauled to separate reward calculations from deposit and withdraw. This further protect LP while allowing for infinite token calculations.

Previous iterations would track rewardPerToken as a shift everytime either totalSupply, rewardRate, or time changed. Instead we track each individually as a checkpoint and then iterate and calculation.

## Bribe

Gauge bribes are natively supported by the protocol, Bribes inherit from Gauges and are automatically adjusted on votes.

Users that voted can claim their bribes via calling ```function getReward(address token) public```

Fees accrued by `Gauges` are distributed to `Bribes`

### BaseV1Voter

Gauge factory permissionlessly creates gauges for `pools` created by `BaseV1Factory`. Further it handles voting for 100% of the incentives to `pools`.

```
function vote(address[] calldata _poolVote, uint[] calldata _weights) external
function distribute(address token) external
```


### Goerli deployment

| Name   | Address                                                                                                                                |
|:-------|:---------------------------------------------------------------------------------------------------------------------------------------|
| USDT   | [0x57b0D492cC702980a1f823aBB5fF02F503e6DA8D](https://goerli.etherscan.com/address/0x57b0D492cC702980a1f823aBB5fF02F503e6DA8D)          |
| USDC   | [0xe62F6611d70b28C1daeC95d0d5b9EC766850A68a](https://goerli.etherscan.com/address/0xe62F6611d70b28C1daeC95d0d5b9EC766850A68a)          |
| Doge   | [0xBA9F24A693CADaf44B6dCbc29B625A7b1D5711f8](https://goerli.etherscan.com/address/0xBA9F24A693CADaf44B6dCbc29B625A7b1D5711f8)          |

| Name                 | Address                                                                                                                        |
|:---------------------|:-------------------------------------------------------------------------------------------------------------------------------|
| WETH                 | [0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6](https://goerli.etherscan.com/address/0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6)  |
| Factory              | [0x2e3CF93067d3a4d5c2Bd593d797638427e7a6B94](https://goerli.etherscan.com/address/0x2e3CF93067d3a4d5c2Bd593d797638427e7a6B94)  |
| Router01             | [0xD9b9298EcFbbfBf489b70842058d2C33692725Ce](https://goerli.etherscan.com/address/0xD9b9298EcFbbfBf489b70842058d2C33692725Ce)  |
| GovernanceTreasury   | [0x30AA34e515587F455723c9ce683ec43f9a62E4dc](https://goerli.etherscan.com/address/0x30AA34e515587F455723c9ce683ec43f9a62E4dc)  |
| Locker               | [0x8e004406d4070083837F0733cD74a9e0F93Fa411](https://goerli.etherscan.com/address/0x8e004406d4070083837F0733cD74a9e0F93Fa411)  |
| LaunchpadStorage     | [0xB9Ca3bdb3E18B8b0BE8f3Bc68C435793C9C48bBA](https://goerli.etherscan.com/address/0xB9Ca3bdb3E18B8b0BE8f3Bc68C435793C9C48bBA)  |
| LaunchpadFactory     | [0xA99fb369D15409135f1984A40723688Beb46B3E6](https://goerli.etherscan.com/address/0xA99fb369D15409135f1984A40723688Beb46B3E6)  |


### opBNB Testnet deployment

| Name   | Address                                                                                                                                |
|:-------|:---------------------------------------------------------------------------------------------------------------------------------------|
| USDT   | [0xe62F6611d70b28C1daeC95d0d5b9EC766850A68a](https://opbnbscan.com/address/0xe62F6611d70b28C1daeC95d0d5b9EC766850A68a)          |
| USDC   | [0xBA9F24A693CADaf44B6dCbc29B625A7b1D5711f8](https://opbnbscan.com/address/0xBA9F24A693CADaf44B6dCbc29B625A7b1D5711f8)          |
| Doge   | [0xD2eAF39A849ef58BDbe9Ffd473b721B0a6075A5c](https://opbnbscan.com/address/0xD2eAF39A849ef58BDbe9Ffd473b721B0a6075A5c)          |

| Name                 | Address                                                                                                                        |
|:---------------------|:-------------------------------------------------------------------------------------------------------------------------------|
| WETH                 | [0x30AA34e515587F455723c9ce683ec43f9a62E4dc](https://opbnbscan.com/address/0x30AA34e515587F455723c9ce683ec43f9a62E4dc)  |
| Factory              | [0xD9b9298EcFbbfBf489b70842058d2C33692725Ce](https://opbnbscan.com/address/0xD9b9298EcFbbfBf489b70842058d2C33692725Ce)  |
| Router01             | [0x8e004406d4070083837F0733cD74a9e0F93Fa411](https://opbnbscan.com/address/0x8e004406d4070083837F0733cD74a9e0F93Fa411)  |
| GovernanceTreasury   | [0x2e3CF93067d3a4d5c2Bd593d797638427e7a6B94](https://opbnbscan.com/address/0x2e3CF93067d3a4d5c2Bd593d797638427e7a6B94)  |
| Locker               | [0xB9Ca3bdb3E18B8b0BE8f3Bc68C435793C9C48bBA](https://opbnbscan.com/address/0xB9Ca3bdb3E18B8b0BE8f3Bc68C435793C9C48bBA)  |
| LaunchpadStorage     | [0xA99fb369D15409135f1984A40723688Beb46B3E6](https://opbnbscan.com/address/0xA99fb369D15409135f1984A40723688Beb46B3E6)  |
| LaunchpadFactory     | [0x57b0D492cC702980a1f823aBB5fF02F503e6DA8D](https://opbnbscan.com/address/0x57b0D492cC702980a1f823aBB5fF02F503e6DA8D)  |
