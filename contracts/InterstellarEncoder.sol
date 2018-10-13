pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IInterstellarEncoder.sol";

contract InterstellarEncoder is IInterstellarEncoder, Ownable {
    // [magic_number, chain_id, contract_id <2>, origin_chain_id, origin_contract_id<2>, object_class, convert_type, <6>, land, <128>]

    mapping(uint16 => address) public contractId2Address;
    mapping(address => uint16) public contractAddress2Id;

    uint16 lastContractId = 0;

    function encodeTokenId(address _tokenAddress, uint8 _objectClass, uint128 _objectIndex) public view returns (uint256 _tokenId) {
        uint16 contractId = contractAddress2Id[_tokenAddress];
        require(contractAddress2Id[_tokenAddress] > 0, "Contract address does not exist");

        _tokenId = (MAGIC_NUMBER << 248) + (CHAIN_ID << 240) + (uint256(contractId) << 224) 
            + (CHAIN_ID << 216) + (uint256(contractId) << 200) + (uint256(_objectClass) << 192) + (CURRENT_LAND << 128) + uint256(_objectIndex);
    }

    function registerNewTokenContract(address _tokenAddress) public onlyOwner {
        require(contractAddress2Id[_tokenAddress] == 0, "Contract address already exist");
        require(lastContractId < 65535, "Contract Id already reach maximum.");

        lastContractId += 1;

        contractAddress2Id[_tokenAddress] = lastContractId;
        contractId2Address[lastContractId] = _tokenAddress;
    }

    function getContractAddress(uint256 _tokenId) public view returns (address) {
        return contractId2Address[uint16((_tokenId << 16) >> 30)];
    }
}