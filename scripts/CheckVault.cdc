import FungibleToken from 0x05
import TobeyToken from 0x05

pub fun main(account: Address) {

    // Borrow the public vault capability, specializing it for balance
    let publicVault = getAccount(account)
        .getCapability(/public/Vault)
        .borrow<&TobeyToken.Vault{FungibleToken.Balance}>()
        ?? panic("Unable to access the vault. Please check the setup.")

    log("Vault setup verified successfully.")
}
