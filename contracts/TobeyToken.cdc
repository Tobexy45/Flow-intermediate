// Import the FungibleToken library from version 0x05
import FungibleToken from 0x05

// TobeyToken contract: Implements a fungible token on the Flow blockchain
pub contract TobeyToken: FungibleToken {

    // Total supply of TobeyToken
    pub var totalSupply: UFix64

    // Array to store vault UUIDs
    pub var vaults: [UInt64]

    // Events to track token operations
    pub event TokensInitialized(initialSupply: UFix64)
    pub event TokensWithdrawn(amount: UFix64, from: Address?)
    pub event TokensDeposited(amount: UFix64, to: Address?)

    // Vault resource interface
    pub resource interface VaultInterface {
        pub var balance: UFix64
        pub fun deposit(from: @FungibleToken.Vault)
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault
        access(contract) fun adminWithdraw(amount: UFix64): @FungibleToken.Vault
    }

    // Vault resource
    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, VaultInterface {
        pub var balance: UFix64

        // Initialize the vault balance
        init(balance: UFix64) {
            self.balance = balance
        }

        // Withdraw tokens from the vault
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount            
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // Deposit tokens into the vault
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @TobeyToken.Vault
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        // Admin access: Forcefully withdraw tokens
        access(contract) fun adminWithdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        // Destroy the vault
        destroy() {
            TobeyToken.totalSupply = TobeyToken.totalSupply - self.balance
        }
    }

    // Admin resource
    pub resource Admin {
        // Admin function: Withdraw tokens from the sender's vault
        pub fun adminGetCoin(senderVault: &Vault{VaultInterface}, amount: UFix64): @FungibleToken.Vault {
            return <-senderVault.adminWithdraw(amount: amount)
        }
    }

    // Minter resource
    pub resource Minter {
        // Admin function: Mint new tokens
        pub fun mintToken(amount: UFix64): @FungibleToken.Vault {
            TobeyToken.totalSupply = TobeyToken.totalSupply + amount
            return <-create Vault(balance: amount)
        }
    }

    // Contract initializer
    init() {
        // Initialize the total supply and resources
        self.totalSupply = 0.0
        self.account.save(<-create Minter(), to: /storage/MinterStorage)
        self.account.link<&TobeyToken.Minter>(/public/Minter, target: /storage/MinterStorage)
        self.account.save(<-create Admin(), to: /storage/AdminStorage)
        self.vaults = []
        emit TokensInitialized(initialSupply: self.totalSupply)
    }

    // Create an empty vault
    pub fun createEmptyVault(): @FungibleToken.Vault {
        let instance <- create Vault(balance: 0.0)
        self.vaults.append(instance.uuid)
        return <-instance
    }
}