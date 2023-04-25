//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
contract Consumer{
    function deposit() payable public{

    }
}
contract Wallet2 {
    address payable owner;
    mapping(address => uint256) public allowance;
    mapping(address => bool) public isAllowedToSend;
    mapping(address => bool) public guardians;
    mapping(address =>mapping(address=>bool)) nextOwnerGuardianVotedBool;
    address payable nextOwner;
    uint guardiansResetCount;
    uint public constant confirmartionsFromGuardiansForReset = 3; 

    constructor() {
        owner = payable(msg.sender);
    }
  function setGuardian(address _guardian,bool _isGuardian) public {
        require(msg.sender == owner, "you are not the owner of this wallet");
        guardians[_guardian] = _isGuardian;
    }

    function proposeNewOwner(address payable _newOwner) public {
         require(guardians[msg.sender],"you are not guardian of this wallet");
         require(nextOwnerGuardianVotedBool[_newOwner][msg.sender]==false,"you already Voted");
         if(_newOwner!=nextOwner){
             nextOwner=_newOwner;
             guardiansResetCount = 0;
         }
         guardiansResetCount++;

         if(guardiansResetCount>=confirmartionsFromGuardiansForReset){
             owner=nextOwner;
             nextOwner = payable(address(0));
         }

    }
    
    function setAllowance(address _for, uint _amount) public{
        require(msg.sender==owner,"you are not the owner of this wallet");
        allowance[_for]=_amount;
        if(_amount>0){
            isAllowedToSend[_for]=true;
        }
        else{
            isAllowedToSend[_for]=false;
        }
    }

    function sendMoney(address payable _to,uint256 _amount,bytes memory _payload) public returns (bytes memory) {
        //require(msg.sender==owner,"you are not the owner of this wallet");
        if (msg.sender != owner) {
            require(isAllowedToSend[msg.sender],"you are not allowed to send from this smart Contract!");
            require(allowance[msg.sender] >= _amount,"DONT BITE WHAT YOU CANT CHEW");
            allowance[msg.sender]-=_amount;
        }
        (bool success, bytes memory returnData) = _to.call{value: _amount}(_payload);
        require(success, "Aborting Call was not Successful");
        return returnData;
    }
    receive() external payable {}

    fallback() external payable {}
}
