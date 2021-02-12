// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract Token is ERC721, Ownable {
  // The number of tokens each address has currently minted
  mapping (address => uint16) private _mintedTokensPerAddress;

  // Maps a wikidataId to an address
  mapping (uint256 => address) private _wikidataIdToAddress;

  constructor () public ERC721("WikiToken", "WIKI") {
    // TODO(teddywilson) this will be replaced by a homegrown API.
    _setBaseURI("https://en.wikipedia.org/wiki/");
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _setBaseURI(baseURI);
  }

  function getMaxMintableTokensPerAddress() public pure returns (uint8) { 
    return 16;
  }

  function isClaimed(string memory wikidataId) view public returns (bool) {
    bytes memory idBytes = bytes(wikidataId);
    require (idBytes.length > 0, "Page must be specified");

    uint256 idHash = uint256(sha256(abi.encode(idBytes)));
    return _wikidataIdToAddress[idHash] != 0x0000000000000000000000000000000000000000;
  }
  
  function mint(string memory wikidataId) public {
    bytes memory idBytes = bytes(wikidataId);
    require (idBytes.length > 0, "Page must be specified");
    require (!isClaimed(wikidataId), "Page must not be claimed");
    require (
      _mintedTokensPerAddress[msg.sender] < getMaxMintableTokensPerAddress(),
      "Max minted tokens reached"
    );

    
    // hash because wikidata ids are alphanumeric
    uint256 idHash = uint256(sha256(abi.encode(idBytes)));
    _mint(msg.sender, idHash);
    _setTokenURI(idHash, wikidataId);

    _wikidataIdToAddress[idHash] = msg.sender;
    _mintedTokensPerAddress[msg.sender] += 1;
  }
}