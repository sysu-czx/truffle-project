pragma solidity ^0.4.17;
import "./ManufacturersManager.sol";

contract ProductsManager {
    enum ProductStatus {Shipped, Owned, Disposed}
    
    struct ProductInfo {
        address owner;
        address recipient;
        ProductStatus status;
        uint creationTime;
        uint8 nTransferred;
    }
    
    mapping (uint96 => ProductInfo) products;
    
    address public manufacturer;
    
    constructor() {
        manufacturer = msg.sender;
    }
    
    modifier onlyManufacturer() {
        if (msg.sender != manufacturer) throw;
        _;
    }
    
    modifier onlyNotExist(uint96 EPC) {
        if (products[EPC].creationTime != 0) throw;
        _;
    }
    
    modifier onlyExist(uint96 EPC) {
        if (products[EPC].creationTime == 0) throw;
        _;
    }
    
    modifier onlyOwner(uint96 EPC) {
        if (msg.sender != products[EPC].owner) throw;
        _;
    }
    
    modifier onlyStatusIs(uint96 EPC, ProductStatus status) {
        if (products[EPC].status != status) throw;
        _;
    }
    
    modifier onlyRecipient(uint96 EPC) {
        if (msg.sender != products[EPC].recipient) throw;
        _;
    }
    
    function getBalance() returns (uint) {
        return address(this).balance;
    }
    
    function enrollProduct(address mmAddr, uint96 EPC) 
    onlyNotExist(EPC)
    onlyManufacturer returns (bool) {
        ManufacturersManager mm = ManufacturersManager(mmAddr);
        
        if (mm.checkAuthorship(EPC, manufacturer)) {
            products[EPC].owner = manufacturer;
            products[EPC].status = ProductStatus.Owned;
            products[EPC].creationTime = now;
            products[EPC].nTransferred = 0;
            return true;
        }
        return false;
    }
    
    function shipProduct(address recipient, uint96 EPC)
    onlyExist(EPC) onlyOwner(EPC) onlyStatusIs(EPC, ProductStatus.Owned) {
        if (recipient == products[EPC].owner) {
            throw;
        } else {
            products[EPC].status = ProductStatus.Shipped;
            products[EPC].recipient = recipient;
        }
    }
    
    function receiveProduct(uint96 EPC)
    onlyExist(EPC) onlyRecipient(EPC) onlyStatusIs(EPC, ProductStatus.Shipped) {
        products[EPC].owner = msg.sender;
        products[EPC].status = ProductStatus.Owned;
        products[EPC].nTransferred = products[EPC].nTransferred + 1;
    }
    
    function getCurrentOwner(uint96 EPC)
    onlyExist(EPC) returns (address) {
        return products[EPC].owner;
    }
    
    function getRecipient(uint96 EPC)
    onlyExist(EPC) onlyStatusIs(EPC, ProductStatus.Shipped) returns(address) {
        return products[EPC].recipient;
    }
    
    function getProductStatus(uint96 EPC)
    onlyExist(EPC) returns (ProductStatus) {
        return products[EPC].status;
    }
    
    function () public payable {}
}
