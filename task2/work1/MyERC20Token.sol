// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MyERC20Token {
    // 名称
    string name;
    // 符号
    string symbol;
    // 小数位数
    uint256 decimals = 18;
    // 发行总数
    uint256 totalSupply;
    // 余额
    mapping(address => uint256) balanceOf;
    // 允许
    mapping(address => mapping(address => uint256)) public allowance;

    // 合约所有者
    address owner;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferFrom(address indexed spender,address indexed from, address indexed to, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier notZeroAddress(address addr) {
        require(addr != address(0), "invalid address");
        _;
    }

    // 查询账户余额
    function getBalance(address _addr) public view returns (uint256) {
        return balanceOf[_addr];
    }

    // 查询当前账户余额
    function getMyBalance() public view returns (uint256) {
        return getBalance(msg.sender);
    }

    //转账
    function transfer(address _to, uint256 _value) public notZeroAddress(_to) returns (bool) {
        require(balanceOf[msg.sender] >= _value, "insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    // 授权
    function approve(address _to, uint256 _amout) public notZeroAddress(_to) returns (bool) {
        allowance[msg.sender][_to] = _amout;
        // 触发授权事件
        emit Approval(msg.sender, _to, _amout);

        return true;
    }

    // 代扣转帐
    function transferFrom(address _from, address _to, uint256 _amont) public notZeroAddress(_from) notZeroAddress(_to) returns (bool) {
        require(balanceOf[_from] >= _amont, "insufficient balance");
        require(allowance[_from][_to] >= _amont, "insufficient allowance");
        balanceOf[_from] -= _amont;
        balanceOf[_to] += _amont;
        allowance[_from][_to] -= _amont;
        // 触发转账事件
        emit TransferFrom(msg.sender,_from, _to, _amont);
        
        return true;
    }

    //增发代币
    function mint(address _arrd,uint256 _amout) public onlyOwner notZeroAddress(_arrd) {
        uint256 mintAmount = _amout * (10** uint256(decimals));
        balanceOf[_arrd] += mintAmount;
        totalSupply+=mintAmount;
    }
}