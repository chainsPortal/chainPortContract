// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;


import "./interface/Icontroller.sol";


contract Settings {
     IController public controller;
     mapping(uint256 => uint256) public networkFee;
   
     address payable public   feeRemitance;
     uint256 public railRegistrationFee = 5000 * 10**18;
     uint256 public railOwnerFeeShare = 20;
     uint256 public minWithdrawableFee = 1 * 10**17;
     uint256 public constant minValidationPercentage = 51;
     uint256 public maxFeeThreshold = 300 * 10**18;
     uint256 public ValidationPercentage = minValidationPercentage;
     bool public onlyOwnableRail = true;
     bool public updatableAssetState = true;
     address public brgToken;
     uint256[] public networkSupportedChains;

     uint256 public baseFeePercentage = 10;
     bool public baseFeeEnable; 
     mapping(uint256 =>  bool) public isNetworkSupportedChain;
     mapping(address => mapping(address => bool)) public approvedToAdd;
     mapping(uint256 => uint64) public chainSelector;
     mapping(uint256 => address) public chainRegistry;
     
    error UnAthourizedAccess();
    error NotsupporttedChain();
    error ZeroAddressNotSupported();
    error AboveLimit(uint256 value, uint256 limit);
    error NoneZeroInputReqiured();
    error InputLengthMisMatched();
    error AlreadySet();
     event  ApprovedToAdd(address indexed token,address indexed user ,bool status);
     event MinValidationPercentageUpdated( uint256 prevMinValidationPercentage, uint256 newMinValidationPercentage);
     event BrdgTokenUpdated(address indexed prevValue, address indexed newValue);
     event minWithdrawableFeeUpdated(uint256 prevValue, uint256 newValue);
     event FeeRemitanceAddressUpdated(address indexed prevValue, address indexed newValue);
     event RailRegistrationFeeUpdated(uint256 prevValue, uint256 newValue);
     event RailOwnerFeeShareUpdated(uint256 prevValue, uint256 newValue);
     event NetworkFeeUpdated(uint256 chainId, uint256 prevValue, uint256 newValue);
     event BaseFeePercentageUpdated(uint256 prevValue, uint256 newValue);
     event NetworkSupportedChainsUpdated(uint256[] chains , bool isadded);
     event UpdatableAssetStateChanged(bool status);
     event OnlyOwnableRailStateEnabled(bool status);
     event BaseFeeStatusChanged(bool baseFeeEnable);
     constructor (IController _controller , address payable _feeRemitance) {
        controller = _controller;
        feeRemitance = _feeRemitance;
    }
    

    function setApprovedToAdd(address user , address token , bool status) external {
        onlyAdmin();
        if(approvedToAdd[token][user] == status ) revert AlreadySet();
        emit ApprovedToAdd( token, user , status);
        approvedToAdd[token][user] = status;
    }


    function setMinValidationPercentage(uint256 _ValidationPercentage) external{
        if(msg.sender != controller.owner() ) revert UnAthourizedAccess();
        if(_ValidationPercentage == ValidationPercentage ) revert AlreadySet();
        if(!(_ValidationPercentage > minValidationPercentage )) revert AboveLimit(_ValidationPercentage , minValidationPercentage);
        if((_ValidationPercentage >100))  revert AboveLimit(_ValidationPercentage , 100);
        emit MinValidationPercentageUpdated( ValidationPercentage, _ValidationPercentage);
        ValidationPercentage = _ValidationPercentage;
    }
    
    function setbaseFeePercentage(uint256 _base) external{
        if(msg.sender != controller.owner() ) revert UnAthourizedAccess();
        if(!(_base  < 1000)) revert AboveLimit(_base ,  1000);
        emit BaseFeePercentageUpdated(baseFeePercentage , _base);
        baseFeePercentage = _base;
    }

    function enableBaseFee() external{
        if(msg.sender != controller.owner() ) revert  UnAthourizedAccess();
        baseFeeEnable = !baseFeeEnable;
        emit BaseFeeStatusChanged(baseFeeEnable);
    }

    function setbrgToken(address token) external {
       onlyAdmin();
       if(token == address(0)) revert ZeroAddressNotSupported();
       emit BrdgTokenUpdated(token , token);
       brgToken = token;
   }


    function setminWithdrawableFee(uint256 _minWithdrawableFee) external {
        onlyAdmin();
        if(!(_minWithdrawableFee > 0)) revert NoneZeroInputReqiured();
        emit minWithdrawableFeeUpdated(minWithdrawableFee , _minWithdrawableFee);
        minWithdrawableFee = _minWithdrawableFee;
   }


   function setNetworkSupportedChains(
       uint256[] memory chains,
       address[] memory chainRegistries,
       uint64[] memory chainSelectors,
       uint256[] memory fees,
       bool addchain
    )  
       external 
    {
        onlyAdmin();
        uint256 id = getChainId();
        
        uint256 chainLenght = chains.length;
        uint256 feeLenght = fees.length;
        uint256 selectorLenght = chainSelectors.length;
        uint256 registryLenght = chainRegistries.length;
        if (addchain) {

          if(!(chainLenght == feeLenght && chainLenght == selectorLenght && chainLenght == registryLenght)) revert InputLengthMisMatched();
          for (uint256 index ; index < chainLenght; index++) {
              if(!(fees[index] < maxFeeThreshold)) revert AboveLimit(fees[index] ,maxFeeThreshold  );
              if (!isNetworkSupportedChain[chains[index]]  && chains[index] != id) {
                  networkSupportedChains.push(chains[index]);
                  chainSelector[chains[index]] = chainSelectors[index];
                  networkFee[chains[index]] = fees[index];
                  chainRegistry[chains[index]] = chainRegistries[index];
                  isNetworkSupportedChain[chains[index]] = true;

                }
           } 
         } else {
             for (uint256 index ; index < chainLenght ; index++){
                 if(isNetworkSupportedChain[chains[index]]){
                     for(uint256 index1; index1 < networkSupportedChains.length ; index1++){
                         if(networkSupportedChains[index1] == chains[index]){
                             networkSupportedChains[index1] = networkSupportedChains[networkSupportedChains.length - 1];
                             networkSupportedChains.pop();   
                             
                          }
                      }
                      networkFee[chains[index]] = 0;
                      chainSelector[chains[index]] = 0;
                      chainRegistry[chains[index]] =address(0);
                      isNetworkSupportedChain[chains[index]] = false;
                 } 
            } 
        }
        emit NetworkSupportedChainsUpdated(chains , addchain);
       
   }


   function updateNetworkFee(uint256 chainId , uint256 fee) external {
       onlyAdmin();
       if(!(fee > 0)) revert NoneZeroInputReqiured();
       if( (fee > maxFeeThreshold)) revert AboveLimit(fee , maxFeeThreshold);
       if(fee == networkFee[chainId] ) revert AlreadySet();
       if(!isNetworkSupportedChain[chainId]) revert NotsupporttedChain();
       emit NetworkFeeUpdated( chainId, networkFee[chainId], fee);
       networkFee[chainId] = fee;
    }


    function setRailOwnerFeeShare(uint256 share) external {
        onlyAdmin();
        if(railOwnerFeeShare == share) revert AlreadySet();
        if(!(share > 1  && share < 100 )) revert AboveLimit(share , 100);
       emit  RailOwnerFeeShareUpdated(railOwnerFeeShare , share);
        railOwnerFeeShare = share;
    }


    function setUpdatableAssetState(bool status) external  {
        onlyAdmin();
        if(status == updatableAssetState ) revert AlreadySet();
        emit UpdatableAssetStateChanged(status);
        updatableAssetState = status;
    }


    function setOnlyOwnableRailState(bool status) external  {
        onlyAdmin();
        if(status == onlyOwnableRail ) revert AlreadySet();
        emit OnlyOwnableRailStateEnabled(status);
        onlyOwnableRail = status;
    }


    function setrailRegistrationFee(uint256 registrationFee) external {
        onlyAdmin();
        if(railRegistrationFee == registrationFee) revert AlreadySet();
        emit RailRegistrationFeeUpdated(railRegistrationFee , registrationFee);
        railRegistrationFee = registrationFee;
   }


   function setFeeRemitanceAddress(address payable account) external  {
       if(msg.sender != controller.owner()) revert UnAthourizedAccess();
       if(account == address(0) ) revert ZeroAddressNotSupported();
       if(account == feeRemitance) revert AlreadySet();
       emit FeeRemitanceAddressUpdated(feeRemitance , account);
       feeRemitance = account;
   }


   function onlyAdmin() internal view {
       if(!(controller.isAdmin(msg.sender) || msg.sender == controller.owner())) revert UnAthourizedAccess();
    }


    function  minValidations() external view returns(uint256 minvalidation){
        uint256 excludablePercentage = 100 - ValidationPercentage;
        uint256 excludableValidators = controller.validatorsCount() * excludablePercentage / 100;
        minvalidation = controller.validatorsCount() -  excludableValidators;
    }


    function getNetworkSupportedChains() external view returns(uint256[] memory){
         return networkSupportedChains;
    }
    function getChainId() internal view returns(uint256 id){
        assembly {
        id := chainid()
        }
    }
}
