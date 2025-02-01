// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuoter {
    function quoteExactInput(bytes memory path, uint256 amountIn) external view returns (uint256 amountOut);
}