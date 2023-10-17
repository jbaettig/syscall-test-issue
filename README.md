# Issue Description

The code within this repository demonstrates an issue I am currently having.

```
fn success(ref self: ContractState) {
    let old_address = self.caller.read();
    let caller_address: ContractAddress = get_execution_info().unbox().caller_address;
    self.caller.write(caller_address);
}

fn error(ref self: ContractState) {
    let caller_address: ContractAddress = get_execution_info().unbox().caller_address;
    let old_address = self.caller.read();
    self.caller.write(caller_address);
}
```

The success function executes successfully. The error function does not. The only difference is that within the error method I read something from the contract state right after reading the `caller_address`. That line fails with the following error:

```
Internal runner error.: CairoRunError(VirtualMachine(FailedToComputeOperands(("op1", Relocatable { segment_index: 12, offset: 15 }))))
```

I am using Scarb version `2.3.0-rc1` which uses cairo `2.3.0-rc0`.
