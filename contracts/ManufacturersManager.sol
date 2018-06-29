pragma solidity ^0.4.17;

contract ManufacturersManager {
    struct ManufacturerInfo {
        uint40 companyPrefix;
        bytes32 companyName;
        uint expireTime;
    }
    
    mapping (address => ManufacturerInfo) manufacturers;
    mapping (uint40 => address) companyPrefixToAddress;
    
    address public admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        if (msg.sender != admin) throw;
        _;
    }
    
    function enrollManufacturer(address m, uint40 companyPrefix,
    bytes32 companyName, uint validDurationInYear) onlyAdmin {
        manufacturers[m].companyPrefix = companyPrefix;
        manufacturers[m].companyName = companyName;
        manufacturers[m].expireTime = now + validDurationInYear;
        
        companyPrefixToAddress[companyPrefix] = m;
    }
    
    function getManufacturerAddress(uint96 EPC) returns (address) {
        uint40 cp = getCompanyPrefixFrom(EPC);
        
        return companyPrefixToAddress[cp];
    }
    
    function getCompanyPrefixFrom(uint96 EPC) returns (uint40){
        uint96 temp = EPC >> 42;
        return uint40(temp);
    }
    
    function checkAuthorship(uint96 EPC, address manufacturer) returns (bool){
        if (getManufacturerAddress(EPC) == manufacturer)
        return true;
        return false;
    }
}
