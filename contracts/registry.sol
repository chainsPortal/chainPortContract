// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import "./interface/Ibridge.sol";
import "./interface/Icontroller.sol";
import "./interface/Isettings.sol";
import "./interface/IERCOwnable.sol";


contract  Registry is Ownable, CCIPReceiver {
     using EnumerableSet for EnumerableSet.Bytes32Set;

    
    struct Transaction{
       uint256 chainId;
       address assetAddress;
       uint256 id;
       address receiver;
       uint256 nounce;
       bool  isCompleted;
   }
   
  
   enum transactionType {send , burn , mint ,claim}

   mapping (address => uint256) public assetTotalTransactionCount;
   mapping (address => mapping( uint256 => uint256 )) public assetTransactionTypeCount;
   mapping(address => mapping( uint256 => uint256 )) public assetChainBalance;
   mapping(address => uint256) public getUserNonce; 
   mapping (bytes32 => bool)  public isSendTransaction;
   mapping (bytes32 => Transaction)  public sendTransactions;
   mapping (bytes32 => bool)  public isClaimTransaction;
   mapping (bytes32 => Transaction)  public claimTransactions;
   mapping(bytes32 => Transaction) public mintTransactions;
   mapping(bytes32 => bool) public isMintTransaction;
   mapping(bytes32 => Transaction) public burnTransactions;
   mapping(bytes32 => bool) public isburnTransaction;
   mapping (bytes32  => bool) public isPendingTransaction;
   mapping (bytes32  => uint64) public sourceChainSelector;
   EnumerableSet.Bytes32Set private pendingTransactions;
   uint256 public totalTransactions;
   address public link_router;


   error UnAthourizedAccess();
   error NotRegisteredByChainLink();
   error TransactionRegistered();
   error NotsupporttedChain();
   error ZeroAddressNotSupported();
   error  InvalidTransactionID(bytes32 transactionID ,  bytes32 expectedID);
   error  InvalidTransaction();
   error IndexOutOfBound();
   event TransactionValidated(bytes32 indexed transactionID);
   event SendTransactionCompleted(bytes32 indexed transactionID);
   event BurnTransactionCompleted(bytes32 indexed transactionID);
   event MintTransactionCompleted(bytes32 indexed transactionID);
   event ClaimTransactionCompleted(bytes32 indexed transactionID);
   event MessageReceived(uint64 chainSelector,bytes32 latestMessage);
   constructor(address router) Ownable(msg.sender) CCIPReceiver(router) {
     link_router = router;
     
   }
  

  function completeSendTransaction(bytes32 transactionID) external {
      if(!isSendTransaction[transactionID]) revert InvalidTransaction();
      emit SendTransactionCompleted(transactionID);
      sendTransactions[transactionID].isCompleted = true;
  }


  function completeBurnTransaction(bytes32 transactionID) external {
       if(!isburnTransaction[transactionID] ) revert InvalidTransaction();
       emit BurnTransactionCompleted(transactionID);
       burnTransactions[transactionID].isCompleted = true ;
  }


  function completeMintTransaction(bytes32 transactionID) external {
       if(!isMintTransaction[transactionID] ) revert InvalidTransaction();
       emit MintTransactionCompleted(transactionID);
       mintTransactions[transactionID].isCompleted = true;
  }


  function completeClaimTransaction(bytes32 transactionID) external {
      if(! isClaimTransaction[transactionID] ) revert InvalidTransaction();
      emit ClaimTransactionCompleted(transactionID);
       claimTransactions[transactionID].isCompleted = true;
  }


   


  function registerTransaction(
       uint256 chainTo,
       address assetAddress,
       uint256 id,
       address receiver,
       transactionType _transactionType
  ) 
        public 
        onlyOwner 
        returns (bytes32 transactionID ,uint256 nounce ) 
  {
      if (_transactionType  == transactionType.send) {

           nounce = getUserNonce[receiver];
            transactionID =  keccak256(abi.encodePacked(
                getChainId(),
                chainTo,
                assetAddress ,
                id,
                receiver,
                nounce 
            ));
      
          sendTransactions[transactionID] = Transaction(chainTo , assetAddress ,id , receiver ,nounce, false);
          isSendTransaction[transactionID] = true;
          getUserNonce[receiver]++;
          
      } else if (_transactionType  == transactionType.burn) {
          nounce = getUserNonce[receiver];
            transactionID =  keccak256(abi.encodePacked(
                getChainId(),
                chainTo,
                assetAddress ,
                id,
                receiver,
                nounce 
            ));
      
          burnTransactions[transactionID] = Transaction(chainTo , assetAddress ,id , receiver ,nounce, false);
          isburnTransaction[transactionID] = true;
          getUserNonce[receiver]++;
      }
      assetTotalTransactionCount[assetAddress]++;
      totalTransactions++;

      
  }
  
  
  function _registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       transactionType _transactionType
  ) 
      internal
  {
      if (_transactionType  == transactionType.mint) {
          mintTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isMintTransaction[transactionID] = true;
      } else if (_transactionType  == transactionType.claim) {
          claimTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isClaimTransaction[transactionID] = true;
      }
  }
  
  
  function registerClaimTransaction(
      bytes32 claimID,
      uint256 chainFrom,
      address assetAddress,
      uint256 amount,
      address receiver,
      uint256 nounce
    ) 
      external 
    {
        if(!IController(Ibridge(owner()).controller()).isOracle(msg.sender)) revert UnAthourizedAccess();
        if(!(isPendingTransaction[claimID] && pendingTransactions.contains(claimID))) revert NotRegisteredByChainLink();
        if(isClaimTransaction[claimID]) revert TransactionRegistered();
        if(!Ibridge(owner()).isAssetSupportedChain(assetAddress ,chainFrom)) revert NotsupporttedChain();
        bytes32 requiredClaimID = keccak256(abi.encodePacked(
            chainFrom,
            getChainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));

        if(claimID  != requiredClaimID) revert InvalidTransactionID(claimID , requiredClaimID);
        _registerTransaction(claimID ,chainFrom , assetAddress, amount , receiver ,nounce, transactionType.claim );
        Ibridge(owner()).claim(claimID);
         isClaimTransaction[claimID] = false;
         isPendingTransaction[claimID] = false;
        pendingTransactions.remove(claimID);
   }


   function registerMintTransaction(
       bytes32 mintID,
       uint256 chainFrom,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce
    ) 
       external 
    {
        if(!IController(Ibridge(owner()).controller()).isOracle(msg.sender)) revert UnAthourizedAccess();
        if(!(isPendingTransaction[mintID] && pendingTransactions.contains(mintID))) revert NotRegisteredByChainLink();
        if(isMintTransaction[mintID]) revert TransactionRegistered();
        Ibridge  bridge = Ibridge(owner());
        address wrappedAddress = bridge.wrappedForiegnPair(assetAddress ,chainFrom);
        if(wrappedAddress == address(0)) revert ZeroAddressNotSupported();
            if(bridge.foriegnAssetChainID(wrappedAddress) != chainFrom ) revert NotsupporttedChain();
        
        bytes32 requiredmintID = keccak256(abi.encodePacked(
            chainFrom,
            bridge.chainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));
        if(mintID  != requiredmintID) revert InvalidTransactionID(mintID ,  requiredmintID);
        _registerTransaction(mintID ,chainFrom , wrappedAddress, amount , receiver ,nounce, transactionType.mint);
        Ibridge(owner()).mint(mintID);
        isPendingTransaction[mintID] = false;
        isMintTransaction[mintID] = false;
        pendingTransactions.remove(mintID);

   }



 


  
  function getChainId() internal view returns(uint256 id){
        assembly {
        id := chainid()
        }
    }
   function getID(
       uint256 chainFrom,
       uint256 chainTo,
       address assetAddress,
       uint256 id,
       address receiver,
       uint256 nounce
   )
       public
       pure
       returns (bytes32)  
  {
       return  keccak256(abi.encodePacked(chainFrom, chainTo , assetAddress , id, receiver, nounce));
  }
function pendingTransactionCount() external view returns (uint256) {
        return pendingTransactions.length();
    }

function pendingTransactionAt(uint256 index) external view returns (bytes32) {
        if(!(index < pendingTransactions.length())) revert IndexOutOfBound();
        return pendingTransactions.at(index);
    }

function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        
        bytes32 transactionID = abi.decode(message.data, (bytes32));
        isPendingTransaction[transactionID] = true;
        sourceChainSelector[transactionID] =  message.sourceChainSelector;
        pendingTransactions.add(transactionID);

        emit MessageReceived(
            message.sourceChainSelector,
            transactionID
        );
    }


}

  
