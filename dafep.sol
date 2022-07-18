// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//@author DAFEP NFT
//@title Ur Title

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract DAFEP is Ownable, ERC721A {
    using Strings for uint;

    enum Step {
        Before,
        WhitelistSale,
        PublicSale,
        SoldOut,
        Reveal
    }

    string public baseURI;

    Step public sellingStep;

    uint private constant MAX_SUPPLY = 2222;
    uint private constant MAX_WHITELIST = 1349;
    uint private constant MAX_PUBLIC = 500;
    uint private constant MAX_GIFT = 373;

    bytes32 public merkleRoot;

    uint public saleStartTime = 1652381201;

    mapping(address => uint) public amountNFTsperWalletWhitelistSale;
    mapping(address => uint) public amountNFTsperWalletPublicSale;

    constructor(bytes32 _merkleRoot, string memory _baseURI) ERC721A("DAFEP", "DAF") {
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function whitelistMint(address _account, uint _quantity, bytes32[] calldata _proof) external payable callerIsUser {
        require(currentTime() >= saleStartTime, "Whitelist Sale has not started yet");
        require(currentTime() < saleStartTime + 1800 minutes, "Whitelist Sale is finished");
        require(sellingStep == Step.WhitelistSale, "Whitelist sale is not activated");
        require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
        require(amountNFTsperWalletWhitelistSale[msg.sender] + _quantity <= 1, "You can only get 1 on the Whitelist Sale");
        require(totalSupply() + _quantity <= MAX_WHITELIST, "Max supply exceeded");
        amountNFTsperWalletWhitelistSale[msg.sender] += _quantity;
        _safeMint(_account, _quantity);
    }

    function publicSaleMint(address _account, uint _quantity) external payable callerIsUser {
        require(sellingStep == Step.PublicSale, "Public sale is not activated");
        require(amountNFTsperWalletPublicSale[msg.sender] + _quantity <= 1, "You can only get 1 on the Public Sale");
        require(totalSupply() + _quantity <= MAX_WHITELIST + MAX_PUBLIC, "Max supply exceeded");
        amountNFTsperWalletPublicSale[msg.sender] += _quantity;
        _safeMint(_account, _quantity);
    }

    function burn(uint256[] calldata _tokens) external onlyOwner {
        for (uint idx = 0; idx < _tokens.length; idx += 1) {
            _burn(_tokens[idx]);
        }
    }

    function gift(address _to, uint _quantity) external onlyOwner {
        require(sellingStep > Step.PublicSale, "Gift is after the public sale");
        require(totalSupply() + _quantity <= MAX_SUPPLY, "Reached max Supply");
        _safeMint(_to, _quantity);
    }

    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    function setStep(uint _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }
}