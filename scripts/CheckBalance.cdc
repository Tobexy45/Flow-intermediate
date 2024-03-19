import FungibleToken from 0x05
import TobeyToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &TobeyToken.Vault{FungibleToken.Balance, 
    FungibleToken.Receiver, TobeyToken.VaultInterface}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&TobeyToken.Vault{FungibleToken.Balance, 
            FungibleToken.Receiver, TobeyToken.VaultInterface}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- TobeyToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&TobeyToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, TobeyToken.VaultInterface}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created and linked")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &TobeyToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&TobeyToken.Vault{FungibleToken.Balance}>()
        log("Balance of the new vault: ")
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &TobeyToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, TobeyToken.VaultInterface} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&TobeyToken.Vault{FungibleToken.Balance, 
                FungibleToken.Receiver, TobeyToken.VaultInterface}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if TobeyToken.vaults.contains(checkVault.uuid) {     
            log("Balance of the existing vault:")       
            log(publicVault?.balance)
            log("This is a TobeyToken vault")
        } else {
            log("This is not a TobeyToken vault")
        }
    }
}
