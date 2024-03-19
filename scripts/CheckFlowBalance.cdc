import FungibleToken from 0x05
import FlowToken from 0x05

// Retrieves the balance of a FlowToken vault for a given account
pub fun getFlowVaultBalance(account: Address): UFix64? {

    // Borrow the public FlowToken vault capability from the given account
    let publicFlowVault: &FlowToken.Vault{FungibleToken.Balance}?
        = getAccount(account)
            .getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            
    // Check if the borrowing was successful
    if let balance = publicFlowVault?.balance {
        return balance
    } else {
        // Return an error message if borrowing failed or the Flow vault does not exist
        return nil
    }
}

// Entry point of the script
pub fun main(_account: Address): UFix64? {
    // Call the getFlowVaultBalance function and return the result
    return getFlowVaultBalance(account: _account)
}
