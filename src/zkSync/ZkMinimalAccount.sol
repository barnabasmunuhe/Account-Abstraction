// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

// zksync era imports
import {IAccount, ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {Transaction, MemoryTransactionHelper} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT, BOOTLOADER_FORMAL_ADDRESS} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {INonceHolder} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
import {Utils} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/Utils.sol";
// Oz imports
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ZkMinimalAccount is IAccount, Ownable{
    using MemoryTransactionHelper for Transaction;

    error ZkMinimalAccount__NotEnoughBalance();
    error ZkMininimalAccount__NotFromBootLoader();
    error ZkMinimalAccount__ExecutionFailed();
    error ZkMininimalAccount__NotFromBootLoaderOrOwner();

    modifier requireFromBootLoader(){
        if(msg.sender != BOOTLOADER_FORMAL_ADDRESS){
            revert ZkMininimalAccount__NotFromBootLoader();
        }
        _;
    }
    
    modifier requireFromBootLoaderOrOwner(){
        if(msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner()){
            revert ZkMininimalAccount__NotFromBootLoaderOrOwner();
        }
        _;
    }

    constructor()Ownable(msg.sender) {
    }
// phase 1 Validation
// -users send the transacton to the "zkSymc API client" sort of "light node"
// - zkSync API client checks to see the nonce is unique by quering the NounceHolder system contract(off-chain)
// -zkSync API client simulates what would happen on-chain and calls validateTransaction() 0r 
// validateAndPayForPaymasterTransaction() *these calls are executed as if the bootloader is calling them*
// - On-chain Reality when included later during execution - BOOTLOADER becomes msg.sender & calls validateTransaction() then 
// updates the nonce via the Nonce system contract, also ensures payment logic is valid
// ////////////////////////////////TRANSACTION IS READY & VALID ////////////////////////////////////////////////////////////////////

// Phase 2 Execution
// - API client sends the validated transaction to the sequencer/main node 
// -As the sequencer includes the transaction in the block, the BOOTLOADER calls 
// executeTransaction() on our contract (happens inside the block construction process)

    /**
     * @notice  . MUST increase the nonce
     * @notice  . MUST validate the transaction(check owner signed the tx
     * @notice  . MUST validate the payment (if the transaction is sponsored by a paymaster) or ensure the sender has enough funds to pay for the transaction
     * @dev     . 
     * @param     .
     * @param     .
     * @param   _transaction  .
     * @return  magic  .
     */
    function validateTransaction(bytes32 /*_txHash*/, bytes32 /*_suggestedSignedHash*/, Transaction memory _transaction)
        external
        payable
        requireFromBootLoader
        returns (bytes4 magic)
        {
            // call nonce holder
            // incement nonce
            SystemContractsCaller.systemCallWithPropagatedRevert(
                uint32(gasleft()),
                address(NONCE_HOLDER_SYSTEM_CONTRACT),
                0,
                abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
            );

            // check for fees to pay (IMPLEMENT PAYMASTER CUSTOMIZATION!!!!)
            uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
            if(totalRequiredBalance > address(this).balance){
                revert ZkMinimalAccount__NotEnoughBalance();
                }

            // check signature
            bytes32 txHash = _transaction.encodeHash(); //the hash that is signed by the user is the EIP-712 version of the transaction hash, and not the regular keccak256 hash of the transaction, so we don't need MessageHashUtils.toMessageHash() here because the encodeHash() function already returns the EIP-712 version of the hash, so we can just use it directly for signature verification
            address actualSigner = ECDSA.recover(txHash, _transaction.signature);
            bool isValidSignature = actualSigner == owner();
            if(isValidSignature){
            magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
            } else {
                magic = bytes4(0);
            }
            return magic;
        }

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction calldata _transaction)
        external
        payable
        requireFromBootLoaderOrOwner
        {
            address to = address(uint160(_transaction.to)); // to is the callee, we need to convert it back to an address from uint256
            uint128 value = Utils.safeCastToU128(_transaction.value); 
            bytes32 memory data = _transaction.data; 

            if( to == address(DEPLOYER_SYSTEM_CONTRACT)){
                uint32 gas = Utils.safeCastToU32(gasleft());
                SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
            } else {
                bool success;
            assembly {
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)

            }  
            if(!success) {
                revert ZkMinimalAccount__ExecutionFailed();
            }
            }

        }

    function executeTransactionFromOutside(Transaction memory _transaction) external payable
    {}

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
        {}

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
        external
        payable
        {}
}