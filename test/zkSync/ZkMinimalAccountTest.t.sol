// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "../../src/zkSync/ZkMinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// Era imports
import {
    Transaction,
    MemoryTransactionHelper
} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {BOOTLOADER_FORMAL_ADDRESS} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {
    ACCOUNT_VALIDATION_SUCCESS_MAGIC
} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";

contract ZkMinimalAccountTest is Test {
    ZkMinimalAccount minimalAccount;
    ERC20Mock usdc;

    uint256 constant AMOUNT = 1e18;
    bytes32 constant EMPTY_BYTES32 = bytes32(0);
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        minimalAccount = new ZkMinimalAccount();
        minimalAccount.transferOwnership(ANVIL_DEFAULT_ACCOUNT); // Set the owner to the Anvil default Account for testing
        usdc = new ERC20Mock();
        vm.deal(address(minimalAccount), AMOUNT); // Fund the minimal account with some ETH for testing
    }

    function testZkOwnerCanExecuteCommands() public {
        // Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        Transaction memory transaction =
            _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);
        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.executeTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testvalidateZkTransaction() public {
        // Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        Transaction memory transaction =
            _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);
        transaction = _signTransaction(transaction); // a signed tx struct
        // Act
        vm.prank(BOOTLOADER_FORMAL_ADDRESS);
        bytes4 magic = minimalAccount.validateTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);

        // Assert
        assertEq(magic, ACCOUNT_VALIDATION_SUCCESS_MAGIC);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    function _signTransaction(Transaction memory transaction) internal view returns (Transaction memory) {
        bytes32 unSignedTransactionHash = MemoryTransactionHelper.encodeHash(transaction);
        // Sign the data, and return it
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; //ANVIL private key
        (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, unSignedTransactionHash);
        Transaction memory signedTransaction = transaction;
        signedTransaction.signature = abi.encodePacked(r, s, v); //getting the signature in the correct order
        return signedTransaction;
    }

    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal view returns (Transaction memory) {
        // Fetch the nonce for the 'minimalAccount' (our smart contract account)
        // Note: vm.getNonce is a Foundry cheatcode. In a real zkSync environment,
        // you'd query the NonceHolder system contract.
        uint256 nonce = vm.getNonce(address(minimalAccount));

        // Initialize an empty array for factory dependencies
        bytes32[] memory factoryDeps = new bytes32[](0);

        Transaction memory transaction;

        transaction.txType = transactionType; // e.g., 113 for zkSync AA
        transaction.from = uint256(uint160(from)); // Cast 'from' address to uint256
        transaction.to = uint256(uint160(to)); // Cast 'to' address to uint256
        transaction.gasLimit = 16777216; // Placeholder value (adjust as needed)
        transaction.gasPerPubdataByteLimit = 16777216; // Placeholder value
        transaction.maxFeePerGas = 16777216; // Placeholder value
        transaction.maxPriorityFeePerGas = 16777216; // Placeholder value
        transaction.paymaster = 0; // No paymaster for this example
        transaction.nonce = nonce; // Use the fetched nonce
        transaction.value = value; // Value to be transferred
        transaction.reserved = [uint256(0), uint256(0), uint256(0), uint256(0)]; // Default empty
        transaction.data = data; // Transaction calldata
        transaction.signature = hex""; // Empty signature for an unsigned transaction
        transaction.factoryDeps = factoryDeps; // Empty factory dependencies
        transaction.paymasterInput = hex""; // No paymaster input
        transaction.reservedDynamic = hex""; // Empty reserved dynamic field

        return transaction;
    }
}
