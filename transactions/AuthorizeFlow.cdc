import FungibleToken from 0x05
import FlowToken from 0x05

transaction (allowedAmount: UFix64){
    // Reference to the FlowToken Administrator resource
    let admin: &FlowToken.Administrator
    
    // Signer's AuthAccount
    let signer: AuthAccount

    // Prepare step: Borrow the Administrator resource from signer's storage
    prepare(signerRef: AuthAccount) {
        // Assign the signer reference
        self.signer = signerRef
        
        // Borrow the Administrator resource from storage
        self.admin = self.signer.borrow<&FlowToken.Administrator>(from: /storage/newflowTokenAdmin)
            ?? panic("You are not the admin")
    }

    // Execute step: Create a new minter and save it to storage
    execute {
        // Create a new minter
        let newMinter <- self.admin.createNewMinter(allowedAmount: allowedAmount)

        // Save the new minter resource to the correct storage path
        self.signer.save(<-newMinter, to: /storage/FlowMinter)

        // Log a success message
        log("Flow Minter created successfully")
    }
}
