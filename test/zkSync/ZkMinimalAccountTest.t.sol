// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "../../src/zkSync/ZkMinimalAccount.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Transaction} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";

contract ZkMinimalAccountTest is Test {
    ZkMinimalAccount minimalAccount;
    ERC20Mock usdc;

    uint256 constant AMOUNT = 1e18;
    bytes32 constant EMPTY_BYTES32 = bytes32(0);

    function setUp() public {
        minimalAccount = new ZkMinimalAccount();
        usdc = new ERC20Mock();
 
    }

    function testZkOwnerCanExecuteCommands() public {
        // Arrange
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        Transaction memory transaction = _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value,functionData);
        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.executeTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

        /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    function _createUnsignedTransaction(address from, uint8 transactionType, address to, uint256 value, bytes memory data) internal returns (Transaction memory){
        uint256 nonce = vm.getNonce(address(minimalAccount));
        bytes32[] memory factoryDeps = new bytes32[](0);
        return Transaction({
            txType: transactionType, //type 113
            from: uint256(uint160(from)), //addresses are really smaller & dont fill up the 32 bytes of  uint256 so we can just cast them to uint256
            to: uint256(uint160(to)),
            gasLimit: 16777216,
            gasPerPubdataByteLimit: 16777216, //max amount of gas user is willing to pay for a byte of pubdata(public data to the L1), we set it to max for simplicity
            maxFeePerGas: 16777216,                         
            maxPriorityFeePerGas: 16777216,                 //max fee per gas the user is willing to pay as a priority fee to the miner
            paymaster: 0,
            nonce:nonce,
            value: value,
            reserved:[uint256(0), uint256(0), uint256(0), uint256(0)],
            data: data,
            signature: hex"",
            factoryDeps: factoryDeps,
            paymasterInput: hex"",
            reservedDynamic: hex""
        });
    }

}