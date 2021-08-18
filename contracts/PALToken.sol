// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;


abstract contract ERC20Interface {
    function totalSupply() virtual public view returns(uint);
    function balanceOf(address tokenOwner) virtual public view returns(uint balance);
    function transfer(address to, uint tokens) virtual public returns(bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns(bool success);
    function allowance(address tokenOwner, address spender) virtual public view returns(uint remaining);
    function approve(address spender, uint tokens) virtual public returns(bool sucess);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address tokenOwner, address spender, uint tokens);
}

abstract contract AppoveAndCallFallBack {
    function recieveApproval(address from, uint tokens, address token, bytes memory data) virtual public;
}


contract Owned {
    
    address public tokenOwner;

    constructor() {
        tokenOwner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == tokenOwner);
        _;
    }

}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract PALToken is ERC20Interface,Owned, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    
    mapping(address=>uint) balances;
    mapping(address => mapping(address=>uint)) allowed;
    
    constructor() {
        symbol = "PAL";
        name ="PALToken";
        decimals = 0;
        _totalSupply = 100000000;
        
        balances[msg.sender] = _totalSupply;        
    }

    function totalSupply() public override view returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    //Get the balance of account token owner
    function balanceOf(address tokenOwner) public override view returns(uint balance) {
        return balances[tokenOwner];
    }

    //Transfer the balance from token owners account to to account
    function transfer(address to, uint tokens) public override returns(bool success) {

        if(balances[msg.sender] >= tokens && tokens > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender],tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;
        } else {
            return false;
        }
    }

    //Token owner can approve for spender to transer tokens from his account
    function approve(address spender, uint tokens) public override returns(bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from,address to, uint tokens) public override returns(bool success) {
        if(balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0) {
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender],tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(from, to, tokens);
            return true;
        } else {
            return false;
        }
    }

    //Returns the amount of tokens approved by the owner
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        AppoveAndCallFallBack(spender).recieveApproval(msg.sender,tokens,address(this),data);
        return true;
    }
}    