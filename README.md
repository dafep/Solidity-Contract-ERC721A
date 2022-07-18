# Smart Contract ERC721A

The Smart Contract ERC721A was written by the NFT Azuki project. It's a contract that allows to reduce the cost by about 5 times compared to the ERC721 contract, the contract that I wrote was tested in real condition and the cost of the fees was around 5 to 18 dollars depending on the day and the activity of the block

The first two files "ERC721A.sol" and "IERC721A.sol" are files that I imported to write my contract and the code I wrote is in the file "dafep.sol"

Concerning the faults of this contract there is a protection which was made it is the function :

> callerIsUser() line 44

This function allows another smart contract not to attack you

As there is always a but in a good story a security that I have not managed to solve although I tried and that in "public mint" if a person mint the NFT he can send his NFT on another wallet and mint again

you can see that in line 62 I tried to avoid this flaw without success:

> require(amountNFTsperWalletPublicSale[msg.sender] + _quantity <= 1, "You can only get 1 on the Public Sale");