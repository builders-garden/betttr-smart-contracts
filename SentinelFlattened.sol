// Sources flattened with hardhat v2.22.18 https://hardhat.org

// SPDX-License-Identifier: BUSL-1.1 AND GPL-2.0-or-later AND GPL-3.0 AND MIT

pragma abicoder v2;

// File @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC165.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC20.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;


// File @openzeppelin/contracts/interfaces/IERC1363.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;


/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;


/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC-721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/utils/Context.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/utils/Pausable.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/azuro-protocol/IOwnable.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;

interface IOwnable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function owner() external view returns (address);

    function checkOwner(address account) external view;

    function transferOwnership(address newOwner) external;
}


// File contracts/azuro-protocol/IAzuroBet.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;


interface IAzuroBet is IOwnable, IERC721EnumerableUpgradeable {
    function initialize(address core) external;

    function burn(uint256 id) external;

    function mint(address account) external returns (uint256);

    error OnlyCore();
}


// File contracts/azuro-protocol/IBet.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;

interface IBet {
    struct BetData {
        address affiliate; // address indicated as an affiliate when placing bet
        uint64 minOdds;
        bytes data; // core-specific customized bet data
    }

    error BetNotExists();
    error SmallOdds();

    /**
     * @notice Register new bet.
     * @param  bettor wallet for emitting bet token
     * @param  amount amount of tokens to bet
     * @param  betData customized bet data
     */
    function putBet(
        address bettor,
        uint128 amount,
        BetData calldata betData
    ) external returns (uint256 tokenId);

    function resolvePayout(
        uint256 tokenId
    ) external returns (address account, uint128 payout);

    function viewPayout(uint256 tokenId) external view returns (uint128 payout);
}


// File contracts/azuro-protocol/ICondition.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;

interface ICondition {
    enum ConditionState {
        CREATED,
        RESOLVED,
        CANCELED,
        PAUSED
    }

    struct Condition {
        uint256 gameId;
        uint128[] payouts;
        uint128[] virtualFunds;
        uint128 totalNetBets;
        uint128 reinforcement;
        uint128 fund;
        uint64 margin;
        uint64 endsAt;
        uint48 lastDepositId;
        uint8 winningOutcomesCount;
        ConditionState state;
        address oracle;
        bool isExpressForbidden;
    }
}


// File contracts/azuro-protocol/ILP.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;



interface ILP is IOwnable, IERC721EnumerableUpgradeable {
    enum FeeType {
        DAO,
        DATA_PROVIDER,
        AFFILIATES
    }

    enum CoreState {
        UNKNOWN,
        ACTIVE,
        INACTIVE
    }

    struct Condition {
        address core;
        uint256 conditionId;
    }

    struct CoreData {
        CoreState state;
        uint64 reinforcementAbility;
        uint128 minBet;
        uint128 lockedLiquidity;
    }

    struct Game {
        bytes32 unusedVariable;
        uint128 lockedLiquidity;
        uint64 startsAt;
        bool canceled;
    }

    struct Reward {
        int128 amount;
        uint64 claimedAt;
    }

    event CoreSettingsUpdated(
        address indexed core,
        CoreState state,
        uint64 reinforcementAbility,
        uint128 minBet
    );

    event AffiliateChanged(address newAffilaite);
    event BettorWin(
        address indexed core,
        address indexed bettor,
        uint256 tokenId,
        uint256 amount
    );
    event ClaimTimeoutChanged(uint64 newClaimTimeout);
    event DataProviderChanged(address newDataProvider);
    event FeeChanged(FeeType feeType, uint64 fee);
    event GameCanceled(uint256 indexed gameId);
    event GameShifted(uint256 indexed gameId, uint64 newStart);
    event LiquidityAdded(
        address indexed account,
        uint48 indexed depositId,
        uint256 amount
    );
    event LiquidityDonated(
        address indexed account,
        uint48 indexed depositId,
        uint256 amount
    );
    event LiquidityManagerChanged(address newLiquidityManager);
    event LiquidityRemoved(
        address indexed account,
        uint48 indexed depositId,
        uint256 amount
    );
    event MinBetChanged(address core, uint128 newMinBet);
    event MinDepoChanged(uint128 newMinDepo);
    event NewGame(uint256 indexed gameId, uint64 startsAt, bytes data);
    event ReinforcementAbilityChanged(uint128 newReinforcementAbility);
    event WithdrawTimeoutChanged(uint64 newWithdrawTimeout);

    error OnlyFactory();

    error SmallDepo();
    error SmallDonation();

    error BetExpired();
    error CoreNotActive();
    error ClaimTimeout(uint64 waitTime);
    error DepositDoesNotExist();
    error GameAlreadyCanceled();
    error GameAlreadyCreated();
    error GameCanceled_();
    error GameNotExists();
    error IncorrectCoreState();
    error IncorrectFee();
    error IncorrectGameId();
    error IncorrectMinBet();
    error IncorrectMinDepo();
    error IncorrectReinforcementAbility();
    error IncorrectTimestamp();
    error LiquidityNotOwned();
    error LiquidityIsLocked();
    error NoLiquidity();
    error NotEnoughLiquidity();
    error SmallBet();
    error UnknownCore();
    error WithdrawalTimeout(uint64 waitTime);

    function initialize(
        address access,
        address dataProvider,
        address affiliate,
        address token,
        uint128 minDepo,
        uint64 daoFee,
        uint64 dataProviderFee,
        uint64 affiliateFee
    ) external;

    function addCore(address core) external;

    function addLiquidity(
        uint128 amount,
        bytes calldata data
    ) external returns (uint48);

    function withdrawLiquidity(
        uint48 depositId,
        uint40 percent
    ) external returns (uint128);

    function viewPayout(
        address core,
        uint256 tokenId
    ) external view returns (uint128 payout);

    function betFor(
        address bettor,
        address core,
        uint128 amount,
        uint64 expiresAt,
        IBet.BetData calldata betData
    ) external returns (uint256 tokenId);

    /**
     * @notice Make new bet.
     * @notice Emits bet token to `msg.sender`.
     * @param  core address of the Core the bet is intended
     * @param  amount amount of tokens to bet
     * @param  expiresAt the time before which bet should be made
     * @param  betData customized bet data
     */
    function bet(
        address core,
        uint128 amount,
        uint64 expiresAt,
        IBet.BetData calldata betData
    ) external returns (uint256 tokenId);

    function changeDataProvider(address newDataProvider) external;

    function claimReward() external returns (uint128);

    function getReserve() external view returns (uint128);

    function addReserve(
        uint256 gameId,
        uint128 lockedReserve,
        uint128 profitReserve,
        uint48 depositId
    ) external;

    function addCondition(uint256 gameId) external view returns (uint64);

    function withdrawPayout(
        address core,
        uint256 tokenId
    ) external returns (uint128);

    function changeLockedLiquidity(
        uint256 gameId,
        int128 deltaReserve
    ) external;

    /**
     * @notice Indicate the game `gameId` as canceled.
     * @param  gameId the game ID
     */
    function cancelGame(uint256 gameId) external;

    /**
     * @notice Create new game.
     * @param  gameId the match or condition ID according to oracle's internal numbering
     * @param  startsAt timestamp when the game starts
     * @param  data the additional data to emit in the `NewGame` event
     */
    function createGame(
        uint256 gameId,
        uint64 startsAt,
        bytes calldata data
    ) external;

    /**
     * @notice Set `startsAt` as new game `gameId` start time.
     * @param  gameId the game ID
     * @param  startsAt new timestamp when the game starts
     */
    function shiftGame(uint256 gameId, uint64 startsAt) external;

    function getGameInfo(
        uint256 gameId
    ) external view returns (uint64 startsAt, bool canceled);

    function getLockedLiquidityLimit(
        address core
    ) external view returns (uint128);

    function isGameCanceled(
        uint256 gameId
    ) external view returns (bool canceled);

    function checkAccess(
        address account,
        address target,
        bytes4 selector
    ) external;

    function checkCore(address core) external view;

    function getLastDepositId() external view returns (uint48 depositId);

    function isDepositExists(uint256 depositId) external view returns (bool);

    function token() external view returns (address);

    function fees(uint256) external view returns (uint64);
}


// File contracts/azuro-protocol/ICoreBase.sol

// Original license: SPDX_License_Identifier: GPL-3.0

pragma solidity ^0.8.9;





interface ICoreBase is ICondition, IOwnable, IBet {
    struct Bet {
        uint256 conditionId;
        uint128 amount;
        uint128 payout;
        uint64 outcome;
        uint64 timestamp;
        bool isPaid;
    }

    struct CoreBetData {
        uint256 conditionId; // The match or game ID
        uint64 outcomeId; // ID of predicted outcome
    }

    event ConditionCreated(
        uint256 indexed gameId,
        uint256 indexed conditionId,
        uint64[] outcomes
    );
    event ConditionResolved(
        uint256 indexed conditionId,
        uint8 state,
        uint64[] winningOutcomes,
        int128 lpProfit
    );
    event ConditionStopped(uint256 indexed conditionId, bool flag);

    event ReinforcementChanged(
        uint256 indexed conditionId,
        uint128 newReinforcement
    );
    event MarginChanged(uint256 indexed conditionId, uint64 newMargin);
    event OddsChanged(uint256 indexed conditionId, uint256[] newOdds);

    error OnlyLp();

    error AlreadyPaid();
    error DuplicateOutcomes(uint64 outcome);
    error IncorrectConditionId();
    error IncorrectMargin();
    error IncorrectReinforcement();
    error NothingChanged();
    error IncorrectTimestamp();
    error IncorrectWinningOutcomesCount();
    error IncorrectOutcomesCount();
    error NoPendingReward();
    error OnlyOracle(address);
    error OutcomesAndOddsCountDiffer();
    error StartOutOfRange(uint256 pendingRewardsCount);
    error WrongOutcome();
    error ZeroOdds();

    error CantChangeFlag();
    error ConditionAlreadyCreated();
    error ConditionAlreadyResolved();
    error ConditionNotFinished();
    error ConditionNotExists();
    error ConditionNotRunning();
    error GameAlreadyStarted();
    error InsufficientFund();
    error ResolveTooEarly(uint64 waitTime);

    function lp() external view returns (ILP);

    function azuroBet() external view returns (IAzuroBet);

    function initialize(address azuroBet, address lp) external;

    function calcOdds(
        uint256 conditionId,
        uint128 amount,
        uint64 outcome
    ) external view returns (uint64 odds);

    /**
     * @notice Change the current condition `conditionId` margin.
     */
    function changeMargin(uint256 conditionId, uint64 newMargin) external;

    /**
     * @notice Change the current condition `conditionId` odds.
     */
    function changeOdds(
        uint256 conditionId,
        uint256[] calldata newOdds
    ) external;

    /**
     * @notice Change the current condition `conditionId` reinforcement.
     */
    function changeReinforcement(
        uint256 conditionId,
        uint128 newReinforcement
    ) external;

    function getCondition(
        uint256 conditionId
    ) external view returns (Condition memory);

    /**
     * @notice Indicate the condition `conditionId` as canceled.
     * @notice The condition creator can always cancel it regardless of granted access tokens.
     */
    function cancelCondition(uint256 conditionId) external;

    /**
     * @notice Indicate the status of condition `conditionId` bet lock.
     * @param  conditionId the match or condition ID
     * @param  flag if stop receiving bets for the condition or not
     */
    function stopCondition(uint256 conditionId, bool flag) external;

    /**
     * @notice Register new condition.
     * @param  gameId the game ID the condition belongs
     * @param  conditionId the match or condition ID according to oracle's internal numbering
     * @param  odds start odds for [team 1, ..., team N]
     * @param  outcomes unique outcomes for the condition [outcome 1, ..., outcome N]
     * @param  reinforcement maximum amount of liquidity intended to condition reinforcement
     * @param  margin bookmaker commission
     * @param  winningOutcomesCount the number of winning outcomes of the Condition
     * @param  isExpressForbidden true - not allowed to use in express bets
     */
    function createCondition(
        uint256 gameId,
        uint256 conditionId,
        uint256[] calldata odds,
        uint64[] calldata outcomes,
        uint128 reinforcement,
        uint64 margin,
        uint8 winningOutcomesCount,
        bool isExpressForbidden
    ) external;

    function getOutcomeIndex(
        uint256 conditionId,
        uint64 outcome
    ) external view returns (uint256);

    function isOutcomeWinning(
        uint256 conditionId,
        uint64 outcome
    ) external view returns (bool);

    function isConditionCanceled(
        uint256 conditionId
    ) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.20;

/**
 * @title ERC-721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC-721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/utils/IQuoter.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IQuoter {
    function quoteExactInput(bytes memory path, uint256 amountIn) external view returns (uint256 amountOut);
}


// File contracts/utils/ISwapRouter.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
// Original pragma directive: pragma abicoder v2


/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        //uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}


// File contracts/utils/V3SpokePoolInterface.sol

// Original license: SPDX_License_Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// Contains structs and functions used by SpokePool contracts to facilitate universal settlement.
interface V3SpokePoolInterface {
    /**************************************
     *              ENUMS                 *
     **************************************/

    // Fill status tracks on-chain state of deposit, uniquely identified by relayHash.
    enum FillStatus {
        Unfilled,
        RequestedSlowFill,
        Filled
    }
    // Fill type is emitted in the FilledRelay event to assist Dataworker with determining which types of
    // fills to refund (e.g. only fast fills) and whether a fast fill created a sow fill excess.
    enum FillType {
        FastFill,
        // Fast fills are normal fills that do not replace a slow fill request.
        ReplacedSlowFill,
        // Replaced slow fills are fast fills that replace a slow fill request. This type is used by the Dataworker
        // to know when to send excess funds from the SpokePool to the HubPool because they can no longer be used
        // for a slow fill execution.
        SlowFill
        // Slow fills are requested via requestSlowFill and executed by executeSlowRelayLeaf after a bundle containing
        // the slow fill is validated.
    }

    /**************************************
     *              STRUCTS               *
     **************************************/

    // This struct represents the data to fully specify a **unique** relay submitted on this chain.
    // This data is hashed with the chainId() and saved by the SpokePool to prevent collisions and protect against
    // replay attacks on other chains. If any portion of this data differs, the relay is considered to be
    // completely distinct.
    struct V3RelayData {
        // The address that made the deposit on the origin chain.
        address depositor;
        // The recipient address on the destination chain.
        address recipient;
        // This is the exclusive relayer who can fill the deposit before the exclusivity deadline.
        address exclusiveRelayer;
        // Token that is deposited on origin chain by depositor.
        address inputToken;
        // Token that is received on destination chain by recipient.
        address outputToken;
        // The amount of input token deposited by depositor.
        uint256 inputAmount;
        // The amount of output token to be received by recipient.
        uint256 outputAmount;
        // Origin chain id.
        uint256 originChainId;
        // The id uniquely identifying this deposit on the origin chain.
        uint32 depositId;
        // The timestamp on the destination chain after which this deposit can no longer be filled.
        uint32 fillDeadline;
        // The timestamp on the destination chain after which any relayer can fill the deposit.
        uint32 exclusivityDeadline;
        // Data that is forwarded to the recipient.
        bytes message;
    }

    // Contains parameters passed in by someone who wants to execute a slow relay leaf.
    struct V3SlowFill {
        V3RelayData relayData;
        uint256 chainId;
        uint256 updatedOutputAmount;
    }

    // Contains information about a relay to be sent along with additional information that is not unique to the
    // relay itself but is required to know how to process the relay. For example, "updatedX" fields can be used
    // by the relayer to modify fields of the relay with the depositor's permission, and "repaymentChainId" is specified
    // by the relayer to determine where to take a relayer refund, but doesn't affect the uniqueness of the relay.
    struct V3RelayExecutionParams {
        V3RelayData relay;
        bytes32 relayHash;
        uint256 updatedOutputAmount;
        address updatedRecipient;
        bytes updatedMessage;
        uint256 repaymentChainId;
    }

    // Packs together parameters emitted in FilledV3Relay because there are too many emitted otherwise.
    // Similar to V3RelayExecutionParams, these parameters are not used to uniquely identify the deposit being
    // filled so they don't have to be unpacked by all clients.
    struct V3RelayExecutionEventInfo {
        address updatedRecipient;
        bytes updatedMessage;
        uint256 updatedOutputAmount;
        FillType fillType;
    }

    /**************************************
     *              EVENTS                *
     **************************************/

    event V3FundsDeposited(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed destinationChainId,
        uint32 indexed depositId,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address indexed depositor,
        address recipient,
        address exclusiveRelayer,
        bytes message
    );

    event RequestedSpeedUpV3Deposit(
        uint256 updatedOutputAmount,
        uint32 indexed depositId,
        address indexed depositor,
        address updatedRecipient,
        bytes updatedMessage,
        bytes depositorSignature
    );

    event FilledV3Relay(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 repaymentChainId,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address indexed relayer,
        address depositor,
        address recipient,
        bytes message,
        V3RelayExecutionEventInfo relayExecutionInfo
    );

    event RequestedV3SlowFill(
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 indexed originChainId,
        uint32 indexed depositId,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        address exclusiveRelayer,
        address depositor,
        address recipient,
        bytes message
    );

    /**************************************
     *              FUNCTIONS             *
     **************************************/

    function depositV3(
        address depositor,
        address recipient,
        address inputToken,
        address outputToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 destinationChainId,
        address exclusiveRelayer,
        uint32 quoteTimestamp,
        uint32 fillDeadline,
        uint32 exclusivityDeadline,
        bytes calldata message
    ) external payable;

    function speedUpV3Deposit(
        address depositor,
        uint32 depositId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function fillV3Relay(V3RelayData calldata relayData, uint256 repaymentChainId) external;

    function fillV3RelayWithUpdatedDeposit(
        V3RelayData calldata relayData,
        uint256 repaymentChainId,
        uint256 updatedOutputAmount,
        address updatedRecipient,
        bytes calldata updatedMessage,
        bytes calldata depositorSignature
    ) external;

    function requestV3SlowFill(V3RelayData calldata relayData) external;

    function executeV3SlowRelayLeaf(
        V3SlowFill calldata slowFillLeaf,
        uint32 rootBundleId,
        bytes32[] calldata proof
    ) external;

    /**************************************
     *              ERRORS                *
     **************************************/

    error DisabledRoute();
    error InvalidQuoteTimestamp();
    error InvalidFillDeadline();
    error InvalidExclusiveRelayer();
    error InvalidExclusivityDeadline();
    error MsgValueDoesNotMatchInputAmount();
    error NotExclusiveRelayer();
    error NoSlowFillsInExclusivityWindow();
    error RelayFilled();
    error InvalidSlowFillRequest();
    error ExpiredFillDeadline();
    error InvalidMerkleProof();
    error InvalidChainId();
    error InvalidMerkleLeaf();
    error ClaimedMerkleLeaf();
    error InvalidPayoutAdjustmentPct();
}


// File contracts/Sentinel.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

//TODO: change factory address as const, only factory modifier
//TODO: deploy quoter contract on worldchain

// ======================== Imports ========================













// ======================== Contract Definition ========================
/**
 * @title Sentinel
 * @notice This contract handles cross-chain sports betting operations using Azuro Protocol and Across Bridge
 * @dev Acts as a destination chain contract that receives bets and processes withdrawals
 */
contract Sentinel is ReentrancyGuard, Pausable, IERC721Receiver {
  using SafeERC20 for IERC20;

  // ======================== Events ========================
  event BetPlaced(uint256 indexed idBet);
  event WithdrawBet(uint256 indexed idBet);
  event OperatorChanged(
    address indexed oldOperator,
    address indexed newOperator
  );
  event ProtocolFeeRecipientChanged(
    address indexed oldRecipient,
    address indexed newRecipient
  );
  event ProtocolFeePercentageChanged(uint256 oldFee, uint256 newFee);
  event ReferralFeePercentageChanged(uint256 oldFee, uint256 newFee);
  event CoreBaseChanged(
    address indexed oldCoreBase,
    address indexed newCoreBase
  );
  event QuoterChanged(address indexed oldQuoter, address indexed newQuoter);
  event PoolFeeChanged(uint24 oldFee, uint24 newFee);
  event DestinationChainIdChanged(uint256 oldChainId, uint256 newChainId);
  event ProtocolInitialized();
  event CoreInitialized();
  event EmergencyWithdraw(address indexed token, uint256 amount);

  // ======================== Custom Errors ========================
  error AlreadyInitialized(address controller);
  error AlreadyProtocolInitialized();
  error NotAcrossHandler(address acrossGenericHandler);
  error NotOperator(address operator);
  error NotController(address controller);
  error NotSentinel();
  error NotControllerOrOperator(address controller);
  error NotFactory(address factory);
  error InvalidControllerAddress();
  error InvalidAmountOutMin();
  error InvalidAmountForAcross();
  error InvalidExpressAddress();
  error InvalidOperatorAddress();
  error InvalidSwapRouterAddress();
  error InvalidLPAddress();
  error InvalidAzuroBetAddress();
  error InvalidUSDCAddress();
  error InvalidUSDTAddress();
  error InvalidAcrossHandlerAddress();
  error InvalidAcrossSpokePoolAddress();
  error InvalidQuoterAddress();
  error InvalidPoolFee();
  error InvalidDestinationChainId();
  error InvalidProtocolFeePercentage();
  error InvalidProtocolFeeRecipientAddress();
  error InvalidReferralFeePercentage();
  error InvalidCoreBaseAddress();
  error InvalidTokenAddress();
  error InvalidAmount();
  error PausedState();
  error InvalidSignature();
  error ArrayLengthsMismatch();
  error EmptyBetArrays();
  error DuplicateConditionIds();

  // ======================== Constants ========================
  uint256 private constant BASIS_POINTS = 10000; // 100% (100 * 100 = 10000)
  uint256 private constant USDC_DECIMALS = 6; // 1 USDC = 10^6 USDC
  address private constant FACTORY = 0x0000000000000000000000000000000000000000; //TODO

  // ======================== State Variables ========================
  // Access Control
  address public operator; // Operator address for privileged operations
  address public controller; // Controller address for privileged operations

  // Protocol Configuration
  address public protocolFeeRecipient; // Address receiving protocol fees
  uint256 public protocolFeePercentage; // Fee percentage in basis points
  uint256 public referralFeePercentage; // Referral fee percentage in basis points
  uint256 public destinationChainId; // Target chain ID for cross-chain operations

  // Protocol Addresses
  address public acrossGenericHandler; // Across bridge handler address
  address public acrossSpokePool; // Across spoke pool address
  address public coreBase; // Azuro core contract address
  address public azuroBet; // Azuro bet interface
  address public expressAddress; // Express address for multiple bets
  address public quoter; // Uniswap quoter address
  address public usdcAddress; // USDC token address
  address public usdcAddressDestination; // USDC token address on destination chain
  address public usdtAddress; // USDT token address
  uint24 public poolFee; // Uniswap pool fee

  // Protocol Interfaces
  ISwapRouter public swapRouter; // Uniswap router interface
  ILP public lp; // Azuro liquidity pool interface
  bool public initialized; // Initialization status
  bool public protocolInitialized; // Protocol initialization status

  // ======================== Modifiers ========================

  /**
   * @notice Ensures caller is either owner or operator
   */
  modifier onlyControllerOrOperator() {
    if (msg.sender != controller && msg.sender != operator) {
      revert NotControllerOrOperator(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures caller is operator
   */
  modifier onlyOperator() {
    if (msg.sender != operator) {
      revert NotOperator(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures caller is controller
   */
  modifier onlyController() {
    if (msg.sender != controller) {
      revert NotController(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures caller is factory
   */
  modifier onlyFactory() {
    if (msg.sender != FACTORY) {
      revert NotFactory(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures contract is not paused
   */
  modifier whenNotPausedOverride() {
    if (paused()) {
      revert PausedState();
    }
    _;
  }

  // ======================== Initialization Functions ========================

  /**
   * @notice First phase initialization with core parameters
   */
  function initializeCore(
    address _owner,
    address _operator,
    ISwapRouter _swapRouter,
    ILP _lp,
    address _azuroBet,
    address _usdcAddress,
    address _usdcAddressDestination,
    address _usdtAddress
  ) external /*onlyFactory*/ {
    _initializeCore(
      _owner,
      _operator,
      _swapRouter,
      _lp,
      _azuroBet,
      _usdcAddress,
      _usdcAddressDestination,
      _usdtAddress
    );
  }

  /**
   * @notice Second phase initialization with protocol parameters
   */
  function initializeProtocol(
    address _acrossGenericHandler,
    address _acrossSpokePool,
    address _protocolFeeRecipient,
    uint256 _protocolFeePercentage,
    uint256 _referralFeePercentage,
    address _coreBase,
    address _expressAddress,
    address _quoter,
    uint24 _poolFee,
    uint256 _destinationChainId
  ) external /*onlyFactory*/ {
    _initializeProtocol(
      _acrossGenericHandler,
      _acrossSpokePool,
      _protocolFeeRecipient,
      _protocolFeePercentage,
      _referralFeePercentage,
      _coreBase,
      _expressAddress,
      _quoter,
      _poolFee,
      _destinationChainId
    );
  }

  /**
   * @dev Internal function to initialize core contract state
   */
  function _initializeCore(
    address _controller,
    address _operator,
    ISwapRouter _swapRouter,
    ILP _lp,
    address _azuroBet,
    address _usdcAddress,
    address _usdcAddressDestination,
    address _usdtAddress
  ) private {
    if (initialized) {
      revert AlreadyInitialized(controller);
    }
    if (_controller == address(0)) revert InvalidControllerAddress();
    if (_operator == address(0)) revert InvalidOperatorAddress();
    if (address(_swapRouter) == address(0)) revert InvalidSwapRouterAddress();
    if (address(_lp) == address(0)) revert InvalidLPAddress();
    if (address(_azuroBet) == address(0)) revert InvalidAzuroBetAddress();
    if (_usdcAddress == address(0)) revert InvalidUSDCAddress();
    if (_usdcAddressDestination == address(0)) revert InvalidUSDCAddress();
    if (_usdtAddress == address(0)) revert InvalidUSDTAddress();

    operator = _operator;
    controller = _controller;
    swapRouter = _swapRouter;
    lp = _lp;
    azuroBet = _azuroBet;
    usdcAddress = _usdcAddress;
    usdcAddressDestination = _usdcAddressDestination;
    usdtAddress = _usdtAddress;
    initialized = true;

    emit CoreInitialized();
  }

  /**
   * @dev Internal function to initialize protocol parameters
   */
  function _initializeProtocol(
    address _acrossGenericHandler,
    address _acrossSpokePool,
    address _protocolFeeRecipient,
    uint256 _protocolFeePercentage,
    uint256 _referralFeePercentage,
    address _coreBase,
    address _expressAddress,
    address _quoter,
    uint24 _poolFee,
    uint256 _destinationChainId
  ) private {
    if (protocolInitialized) {
      revert AlreadyProtocolInitialized();
    }
    if (_protocolFeePercentage == 0) revert InvalidProtocolFeePercentage();

    if (_acrossGenericHandler == address(0))
      revert InvalidAcrossHandlerAddress();
    if (_acrossSpokePool == address(0)) revert InvalidAcrossSpokePoolAddress();
    if (_protocolFeeRecipient == address(0))
      revert InvalidProtocolFeeRecipientAddress();
    if (_referralFeePercentage == 0) revert InvalidReferralFeePercentage();
    if (_coreBase == address(0)) revert InvalidCoreBaseAddress();
    if (_expressAddress == address(0)) revert InvalidExpressAddress();
    if (_quoter == address(0)) revert InvalidQuoterAddress();
    if (_poolFee == 0) revert InvalidPoolFee();
    if (_destinationChainId == 0) revert InvalidDestinationChainId();

    acrossGenericHandler = _acrossGenericHandler;
    acrossSpokePool = _acrossSpokePool;
    protocolFeeRecipient = _protocolFeeRecipient;
    protocolFeePercentage = _protocolFeePercentage;
    referralFeePercentage = _referralFeePercentage;
    coreBase = _coreBase;
    expressAddress = _expressAddress;
    quoter = _quoter;
    poolFee = _poolFee;
    destinationChainId = _destinationChainId;
    protocolInitialized = true;

    emit ProtocolInitialized();
  }

  // ======================== Setter Functions ========================

  /**
   * @notice Sets a new operator address
   * @dev Only callable by the current operator
   * @param _operator New operator address
   */
  function setOperator(
    address _operator
  ) external onlyController whenNotPausedOverride {
    if (_operator == address(0)) revert InvalidOperatorAddress();
    address oldOperator = operator;
    operator = _operator;
    emit OperatorChanged(oldOperator, _operator);
  }

  /**
   * @notice Sets the protocol fee recipient address
   * @dev Only callable by the operator
   * @param _protocolFeeRecipient New fee recipient address
   */
  function setProtocolFeeRecipient(
    address _protocolFeeRecipient
  ) external onlyController whenNotPausedOverride {
    if (_protocolFeeRecipient == address(0))
      revert InvalidProtocolFeeRecipientAddress();
    address oldRecipient = protocolFeeRecipient;
    protocolFeeRecipient = _protocolFeeRecipient;
    emit ProtocolFeeRecipientChanged(oldRecipient, _protocolFeeRecipient);
  }

  /**
   * @notice Sets the protocol fee percentage
   * @dev Only callable by the operator
   * @param _protocolFeePercentage New fee percentage in basis points (max 1000 = 10%)
   */
  function setProtocolFeePercentage(
    uint256 _protocolFeePercentage
  ) external onlyController whenNotPausedOverride {
    if (_protocolFeePercentage == 0) revert InvalidProtocolFeePercentage();
    uint256 oldFee = protocolFeePercentage;
    protocolFeePercentage = _protocolFeePercentage;
    emit ProtocolFeePercentageChanged(oldFee, _protocolFeePercentage);
  }

  /**
   * @notice Sets the referral fee percentage
   * @dev Only callable by the operator
   * @param _referralFeePercentage New fee percentage in basis points (max 1000 = 10%)
   */
  function setReferralFeePercentage(
    uint256 _referralFeePercentage
  ) external onlyController whenNotPausedOverride {
    if (_referralFeePercentage > 1000) revert InvalidReferralFeePercentage();
    uint256 oldFee = referralFeePercentage;
    referralFeePercentage = _referralFeePercentage;
    emit ReferralFeePercentageChanged(oldFee, _referralFeePercentage);
  }

  /**
   * @notice Updates the CoreBase address
   * @dev Only callable by the operator
   * @param _coreBase New CoreBase address
   */
  function setCoreBase(
    address _coreBase
  ) external onlyController whenNotPausedOverride {
    if (_coreBase == address(0)) revert InvalidCoreBaseAddress();
    address oldCoreBase = coreBase;
    coreBase = _coreBase;
    emit CoreBaseChanged(oldCoreBase, _coreBase);
  }

  /**
   * @notice Updates the Quoter address
   * @dev Only callable by the operator
   * @param _quoter New Quoter address
   */
  function setQuoter(
    address _quoter
  ) external onlyController whenNotPausedOverride {
    if (_quoter == address(0)) revert InvalidQuoterAddress();
    address oldQuoter = quoter;
    quoter = _quoter;
    emit QuoterChanged(oldQuoter, _quoter);
  }

  /**
   * @notice Updates the Uniswap pool fee
   * @dev Only callable by the operator
   * @param _poolFee New pool fee
   */
  function setPoolFee(
    uint24 _poolFee
  ) external onlyController whenNotPausedOverride {
    if (_poolFee == 0) revert InvalidPoolFee();
    uint24 oldFee = poolFee;
    poolFee = _poolFee;
    emit PoolFeeChanged(oldFee, _poolFee);
  }

  /**
   * @notice Updates the destination chain ID
   * @dev Only callable by the operator
   * @param _destinationChainId New destination chain ID
   */
  function setDestinationChainId(
    uint256 _destinationChainId
  ) external onlyController whenNotPausedOverride {
    if (_destinationChainId == 0) revert InvalidDestinationChainId();
    uint256 oldChainId = destinationChainId;
    destinationChainId = _destinationChainId;
    emit DestinationChainIdChanged(oldChainId, _destinationChainId);
  }

  // ======================== Core Functions ========================

  /**
   * @notice Handles incoming bets from the source chain
   * @dev Only callable by the Across handler
   * @param tokenIn Source token address
   * @param tokenOut Destination token address
   * @param amountIn Amount of tokens being sent
   * @param bet Encoded bet data (array of condition, outcome, referrer)
   */
  function handleBet(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    bytes memory bet
  ) external nonReentrant whenNotPausedOverride {
    if (msg.sender != acrossGenericHandler) {
      revert NotAcrossHandler(acrossGenericHandler);
    }
    if (tokenIn == address(0) || tokenOut == address(0)) {
      revert InvalidTokenAddress();
    }
    if (amountIn == 0) {
      revert InvalidAmount();
    }

    IERC20(tokenIn).safeTransferFrom(
      acrossGenericHandler,
      address(this),
      amountIn
    );

    // handle protocol fee function
    uint256 amountInAfterProtocolFee = _handleProtocolFee(amountIn);

    // Decode bet data
    (
      uint256[] memory conditions,
      uint64[] memory outcomes,
      address referrer
    ) = abi.decode(bet, (uint256[], uint64[], address));

    // Validate array lengths match
    require(conditions.length == outcomes.length, "Array lengths mismatch");
    require(conditions.length > 0, "Empty bet arrays");

    uint256 referralFees = 0;

    if (referrer != address(0)) {
      referralFees = _calculatePercentage(
        amountInAfterProtocolFee,
        referralFeePercentage
      );
      IERC20(tokenIn).safeTransfer(referrer, referralFees);
    }

    uint256 amountInAfterReferralFees = amountInAfterProtocolFee - referralFees;

    // Approve swapRouter to spend tokens
    IERC20(tokenIn).forceApprove(
      address(swapRouter),
      amountInAfterReferralFees
    );

    uint256 amountOut = _swap(tokenIn, tokenOut, amountInAfterReferralFees);

    // Approve LP to spend swapped tokens
    IERC20(tokenOut).forceApprove(address(lp), amountOut);

    // Place bets for the player
    uint256 idBet = _bet(
      uint128(amountOut),
      conditions,
      outcomes,
      conditions.length > 1 // isExpress = true if multiple bets
    );
    emit BetPlaced(idBet);
  }

  /**
   * @notice Processes bet withdrawals and sends funds back across the bridge
   * @dev Only callable by the owner or operator
   * @param idBet Bet ID to withdraw
   * @param totalFeeAmount Amount to withdraw
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
   */
  function handleWithdraw(
    uint256 idBet,
    uint256 totalFeeAmount,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw
  ) external onlyController nonReentrant whenNotPausedOverride {
    _handleWithdraw(
      idBet,
      totalFeeAmount,
      quoteTimestamp,
      exclusivityDeadline,
      exclusivityRelayer,
      isMultipleBet,
      onlyWithdraw
    );
    emit WithdrawBet(idBet);
  }

  /**
   * @notice Processes bet withdrawals and sends funds back across the bridge
   * @dev Only callable by the owner or operator
   * @param idBet Bet ID to withdraw
   * @param totalFeeAmount Amount to withdraw
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
   */
  function handleWithdrawOperator(
    uint256 idBet,
    uint256 totalFeeAmount,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw,
    bytes memory controllerSignature
  ) external onlyOperator nonReentrant whenNotPausedOverride {
    // Verify controller signature
    _verifyControllerSignature(
      idBet,
      totalFeeAmount,
      quoteTimestamp,
      exclusivityDeadline,
      exclusivityRelayer,
      isMultipleBet,
      onlyWithdraw,
      controllerSignature
    );
    _handleWithdraw(
      idBet,
      totalFeeAmount,
      quoteTimestamp,
      exclusivityDeadline,
      exclusivityRelayer,
      isMultipleBet,
      onlyWithdraw
    );
    emit WithdrawBet(idBet);
  }

  // ======================== Emergency Functions ========================

  /**
   * @notice Allows owner or operator to withdraw tokens to owner's wallet
   * @dev Only callable by the owner or operator
   * @param token Token address
   * @param amount Amount of tokens to withdraw
   */
  function emergencyWithdraw(
    address token,
    uint256 amount
  ) external onlyController {
    if (token == address(0)) {
      revert InvalidTokenAddress();
    }
    IERC20(token).safeTransfer(controller, amount);
    emit EmergencyWithdraw(token, amount);
  }

  // ======================== Pausable Functions ========================

  /**
   * @notice Pauses the contract, disabling certain functions
   * @dev Only callable by the owner or operator
   */
  function pause() external onlyOperator {
    _pause();
    emit Paused(msg.sender);
  }

  /**
   * @notice Unpauses the contract, enabling previously disabled functions
   * @dev Only callable by the owner or operator
   */
  function unpause() external onlyOperator {
    _unpause();
    emit Unpaused(msg.sender);
  }

  // ======================== Internal Helper Functions ========================

  /**
   * @notice Performs token swap using Uniswap V3
   * @dev Uses the quoter to determine minimum output amount
   * @param tokenIn Input token address
   * @param tokenOut Output token address
   * @param amountIn Amount of input tokens
   * @return amountOut Amount of output tokens received
   */
  function _swap(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) internal returns (uint256 amountOut) {
    bytes memory path = abi.encodePacked(tokenIn, poolFee, tokenOut);
    uint256 amountOutMin = IQuoter(quoter).quoteExactInput(path, amountIn);
    if (amountOutMin == 0) {
      revert InvalidAmountOutMin();
    }

    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        fee: poolFee,
        recipient: address(this),
        //deadline: block.timestamp + 1800, // 30 minutes
        amountIn: amountIn,
        amountOutMinimum: amountOutMin,
        sqrtPriceLimitX96: 0
      });

    // Execute the swap
    amountOut = swapRouter.exactInputSingle(params);
  }

  /**
   * @notice Places a bet on the Azuro protocol
   * @dev Constructs and submits bet data to the Azuro LP
   * @param amountOut Amount of tokens to bet
   * @param conditions Bet conditions
   * @param outcomes Bet outcomes
   * @param isMultiple Whether this is part of an express bet
   * @return idBet ID of the placed bet
   */
  function _bet(
    uint128 amountOut,
    uint256[] memory conditions,
    uint64[] memory outcomes,
    bool isMultiple
  ) internal returns (uint256 idBet) {
    uint64 minOdds = 1;
    uint64 expiresAt = uint64(block.timestamp + 1800); // 30 minutes

    if (conditions.length != outcomes.length) {
      revert ArrayLengthsMismatch();
    }
    if (conditions.length == 0) {
      revert EmptyBetArrays();
    }

    if (isMultiple) {
      // Create array of CoreBetData for multiple bets
      ICoreBase.CoreBetData[] memory subBets = new ICoreBase.CoreBetData[](
        conditions.length
      );

      // Fill the array with bet data
      for (uint256 i = 0; i < conditions.length; i++) {
        // Validate unique condition IDs
        for (uint256 j = 0; j < i; j++) {
          if (conditions[i] == conditions[j]) {
            revert DuplicateConditionIds();
          }
        }

        subBets[i] = ICoreBase.CoreBetData({
          conditionId: conditions[i],
          outcomeId: outcomes[i]
        });
      }

      // Encode the CoreBetData array
      bytes memory encodedBetData = abi.encode(subBets);

      // Create the BetData struct
      IBet.BetData memory betData = IBet.BetData({
        affiliate: address(0),
        minOdds: 1,
        data: encodedBetData
      });

      // Place the bet directly without try-catch
      idBet = lp.bet(expressAddress, amountOut, expiresAt, betData);
    } else {
      // Single bet case remains unchanged
      IBet.BetData memory betData = IBet.BetData({
        affiliate: address(0), // affiliate
        minOdds: minOdds,
        data: abi.encode(conditions[0], outcomes[0])
      });
      idBet = lp.bet(address(coreBase), amountOut, expiresAt, betData);
    }
  }

  /**
   * @notice Calculates percentage of an amount using basis points
   * @dev Used for fee calculations
   * @param amount The amount to calculate the percentage of
   * @param basisPoints The basis points representing the percentage
   * @return The calculated percentage of the amount
   */
  function _calculatePercentage(
    uint256 amount,
    uint256 basisPoints
  ) internal pure returns (uint256) {
    if (basisPoints == 0) {
      return 0;
    }
    if (basisPoints > BASIS_POINTS) {
      revert InvalidReferralFeePercentage();
    }
    return (amount * basisPoints) / BASIS_POINTS;
  }

  /**
   * @notice Handles protocol fee deduction and approval for Across
   * @param amount Amount to process
   * @return Amount after fee deduction
   */
  function _handleProtocolFee(uint256 amount) internal returns (uint256) {
    uint256 protocolFee = _calculatePercentage(amount, protocolFeePercentage);
    IERC20(usdcAddress).safeTransfer(protocolFeeRecipient, protocolFee);
    uint256 amountAfterFee = amount - protocolFee;
    return amountAfterFee;
  }

  /**
   * @notice Initiates the cross-chain transfer via Across bridge
   * @param amountIn Amount of tokens to send
   * @param amountOut Amount of tokens expected on the destination chain
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   */
  function _sendToAcross(
    uint256 amountIn,
    uint256 amountOut,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer
  ) internal {
    V3SpokePoolInterface(acrossSpokePool).depositV3(
      address(this),
      controller,
      usdcAddress,
      usdcAddressDestination,
      amountIn,
      amountOut, //amount out is amount - total relayer fees
      destinationChainId,
      exclusivityRelayer,
      quoteTimestamp,
      uint32(block.timestamp + 18000), // 5 hours
      exclusivityDeadline,
      ""
    );
  }

  /**
   * @notice Internal function to process bet withdrawals
   * @dev Handles payout retrieval, swaps, and bridge transfer
   * @param idBet Bet ID to withdraw
   * @param totalFeeAmount Amount to withdraw
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
   */
  function _handleWithdraw(
    uint256 idBet,
    uint256 totalFeeAmount,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw
  ) internal {
    // Step 1: Handle payout based on bet type
    uint256 amountPayout;
    if (isMultipleBet) {
      // Multiple bet case
      if (IERC721(expressAddress).ownerOf(idBet) != address(this)) {
        revert NotSentinel();
      }
      amountPayout = lp.withdrawPayout(expressAddress, idBet);
    } else {
      // Single bet case
      if (IERC721(azuroBet).ownerOf(idBet) != address(this)) {
        revert NotSentinel();
      }
      amountPayout = lp.withdrawPayout(coreBase, idBet);
    }

    if (!onlyWithdraw) {
      // Continue with swap and bridge operations
      IERC20(usdtAddress).forceApprove(address(swapRouter), amountPayout);
      uint256 amountOutAfterSwap = _swap(
        usdtAddress,
        usdcAddress,
        amountPayout
      );

      // Step 2: Handle protocol fee and prepare for Across
      uint256 amountForAcross = _handleProtocolFee(amountOutAfterSwap);

      IERC20(usdcAddress).forceApprove(acrossSpokePool, amountForAcross);

      // Check on the amount for across
      if (totalFeeAmount >= amountForAcross) {
        revert InvalidAmountForAcross();
      }
      uint256 amountOut = amountForAcross - totalFeeAmount;

      
      // Step 3: Call Across
      _sendToAcross(
        amountForAcross,
        amountOut,
        quoteTimestamp,
        exclusivityDeadline,
        exclusivityRelayer
      );
      
    }
  }

  // Add this function to verify signatures
  function _verifyControllerSignature(
    uint256 idBet,
    uint256 amountOut,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw,
    bytes memory signature
  ) internal view {
    // Create message hash that matches what controller signed
    bytes32 messageHash = keccak256(
      abi.encodePacked(
        idBet,
        amountOut,
        quoteTimestamp,
        exclusivityDeadline,
        exclusivityRelayer,
        isMultipleBet,
        onlyWithdraw,
        address(this)
      )
    );
    // Create ethereum signed message hash
    bytes32 ethSignedMessageHash = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );

    // Extract v, r, s from signature using assembly
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    // Recover signer address
    address signer = ecrecover(ethSignedMessageHash, v, r, s);

    // Verify signer is controller
    if (signer != controller) {
      revert InvalidSignature();
    }
  }

  /**
   * @notice Implementation of IERC721Receiver
   */
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
