// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "account-abstraction/core/Helpers.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MinimalAccount is IAccount, Ownable, ReentrancyGuard {

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MinimalAccount__NotCalledByEntryPoint();
    error MinimalAccount__NotCalledByEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);
    error MinimalAccount__PayPreFundFailed();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // entrypoint -> gonna call this contract
    IEntryPoint immutable i_entryPoint; // IEntryPoint also helps us to get some getter functions to our contract like getNonce and getSenderAddress

        /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) 
        {
            revert MinimalAccount__NotCalledByEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) 
        {
            revert MinimalAccount__NotCalledByEntryPointOrOwner();
        }
        _;  
    }
    
    /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor(address entryPoint) Ownable(msg.sender){
        i_entryPoint = IEntryPoint(entryPoint); //making our contract callerable by the EntryPoint.sol.....
        //telling the compiler "Treat this entryPoint address as a contract that follows the IEntryPoint interface"
    }

    receive() external payable {} //we need this receive function to be able to receive funds inorder to pay for tx(s)

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // This is the function that is gonna be called by the entryPoint to validate the userOperation, 
    // and the function that will validate the signature of the userOperation and also pay the prefund to the entryPoint if needed
    // A signature is valid if it's the minimalAccount owner
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external requireFromEntryPoint returns (uint256 validationData) 
    {
        validationData = _validateSignature(userOp, userOpHash);
        //_validationNounce is not needed in this case because we are using the nonce from the entryPoint contract and not from our account contract, so we can just return 0 for the nonce part of the validationData
        _payPrefund(missingAccountFunds); //we must pay back money to the entryPoint
    }

        /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    //This is the function that whenever we send a userOperation to the entryPoint, the entryPoint will call the execute function 
    // on our contract to run intended transactions eg interacting with uniswap, after the signature is validated and the prefund is paid
    function execute(address dest, uint256 value, bytes calldata functionData) external  requireFromEntryPointOrOwner{
        (bool success, bytes memory result) = dest.call{value: value}(functionData);
        if(!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    //The userOpHash is the EIP-191 version of the signed hash so it's not in the correct format for the signature verification,
    //  we need to convert it back to the original hash that was signed by the user using messageHash utils from openzeppelin
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash) internal view returns (uint256 validationData) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash); //converting userOpHash back to the original hash that was signed by the user using messageHash utils from openzeppelin
        address whoSigned = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (whoSigned != owner()) {
            return SIG_VALIDATION_FAILED; // 0
        }
        return SIG_VALIDATION_SUCCESS; // 1
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
           if (!success) {
                revert MinimalAccount__PayPreFundFailed();
            }
        }
    }


    /////////Getter Functions/////////
    function getEntrypoint() external view returns (address) {
        return address(i_entryPoint);
    }

    function getNonce() external view returns (uint256) {
        return i_entryPoint.getNonce(address(this), 0);
    }

}