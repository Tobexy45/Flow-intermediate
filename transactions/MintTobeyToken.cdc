import FungibleToken from 0x05
import TobeyToken from 0x05

transaction(receiver: Address, amount: UFix64) {

    prepare(signer: AuthAccount) {
        // Borrow the TobeyToken Minter reference
        let minter = signer.borrow<&TobeyToken.Minter>(from: /storage/MinterStorage)
            ?? panic("You are not the TobeyToken minter")
        
        // Borrow the receiver's TobeyToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&TobeyToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
            ?? panic("Error: Check your TobeyToken Vault status")
        
        // Minted tokens reference
        let mintedTokens <- minter.mintToken(amount: amount)

        // Deposit minted tokens into the receiver's TobeyToken Vault
        receiverVault.deposit(from: <-mintedTokens)
    }

    execute {
        log("TobeyToken minted and deposited successfully")
        log("Tokens minted and deposited: ".concat(amount.toString()))
    }
}