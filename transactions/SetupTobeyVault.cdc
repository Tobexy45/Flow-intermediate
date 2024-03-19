// Import FungibleToken and TobeyToken contracts from version 0x05
import FungibleToken from 0x05
import TobeyToken from 0x05

// Create Nft Token Vault Transaction
transaction () {

    // Define references
    let userVault: &TobeyToken.Vault{FungibleToken.Balance, 
        FungibleToken.Provider, 
        FungibleToken.Receiver, 
        TobeyToken.VaultInterface}?
    let account: AuthAccount

    prepare(acct: AuthAccount) {

        // Borrow the vault capability and set the account reference
        self.userVault = acct.getCapability(/public/Vault)
            .borrow<&TobeyToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, TobeyToken.VaultInterface}>()
        self.account = acct
    }

    execute {
        if self.userVault == nil {
            // Create and link an empty vault if none exists
            let emptyVault <- TobeyToken.createEmptyVault()
            self.account.save(<-emptyVault, to: /storage/VaultStorage)
            self.account.link<&TobeyToken.Vault{FungibleToken.Balance, 
                FungibleToken.Provider, 
                FungibleToken.Receiver, 
                TobeyToken.VaultInterface}>(/public/Vault, target: /storage/VaultStorage)
            log("Empty vault created and linked")
        } else {
            log("Vault already exists and is properly linked")
        }
    }
}