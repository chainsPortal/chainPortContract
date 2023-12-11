// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {IAny2EVMMessageReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
contract routerTest {
    uint64 public id;
    address fee;
    constructor(){

    }
    function ccipSend(uint64 destinationChainSelector,Client.EVM2AnyMessage memory message ) public returns (bytes32){
        id = destinationChainSelector;
        return  keccak256(abi.encodePacked(destinationChainSelector  , message.feeToken));
    }

    //  function getFee(uint64 destinationChainSelector, Client.EVM2AnyMessage memory message ) public pure returns (uint256){
        
    //     return 0;
    //  }

     function sendData(string memory messageText ) public  view returns ( Client.EVM2AnyMessage memory message){
       message = Client.EVM2AnyMessage({
            receiver: abi.encode(address(this)),
            data: abi.encode(messageText),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(0)
        });
      
     }
}