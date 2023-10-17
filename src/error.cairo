#[starknet::interface]
trait IErrorContract<TContractState> {
    fn error(ref self: TContractState);
    fn success(ref self: TContractState);
}

#[starknet::contract]
mod error_contract {
    use super::IErrorContract;
    use starknet::{ContractAddress, get_execution_info};

    #[storage]
    struct Storage {
        caller: ContractAddress
    }

    #[external(v0)]
    impl ErrorContract of IErrorContract<ContractState> {
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
    }
}

#[cfg(test)]
mod tests {
    use super::{error_contract, IErrorContractDispatcher, IErrorContractDispatcherTrait};

    use starknet::{
        ContractAddress, contract_address_const, syscalls::deploy_syscall,
        testing::set_caller_address, testing::set_contract_address,
    };

    fn setup() -> IErrorContractDispatcher {
        let account_address: ContractAddress = contract_address_const::<1>();
        set_caller_address(account_address);

        let mut calldata = ArrayTrait::new();
        let (contract_address, _) = deploy_syscall(
            error_contract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        IErrorContractDispatcher { contract_address: contract_address }
    }

    #[test]
    #[available_gas(20000000)]
    fn test_error_contract() {
        let calling_user = contract_address_const::<1>();
        set_contract_address(calling_user);
        let error_contract = setup();

        error_contract.success();
        error_contract.error();
    }
}
