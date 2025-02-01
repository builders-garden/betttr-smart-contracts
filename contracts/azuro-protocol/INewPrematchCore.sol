// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the New Prematch Core contract, which extends the CoreBase interface.
import "./ICoreBase.sol";

interface INewPrematchCore is ICoreBase {
    event NewBet(
        address indexed bettor,
        address indexed affiliate,
        uint256 indexed conditionId,
        uint256 tokenId,
        uint64 outcomeId,
        uint128 amount,
        uint64 odds,
        uint128[2] funds
    );

    function resolveCondition(uint256 conditionId, uint64 outcomeWin) external;
    function bets(uint256 key) external view returns (Bet memory);
    function conditions(uint256 key) external view returns (Condition memory);
}
