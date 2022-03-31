%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_le, uint256_lt, uint256_add

from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.token.ERC20.IERC20 import IERC20
from contracts.util import (
    fill_tuto_adds_from_array, fill_exercise_list_from_array, uint_assert_equality, uint_assert_le,
    migrate_validated_exercises, perform_checks)
from contracts.Migrator_storage import tuto_adds, nb_of_exercises, rug_pulled

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _players_registry_add_len : felt, _players_registry_add : felt*, tutoken_add_len : felt,
        tutoken_add : felt*):
    with_attr error_message("Player registry should have the same length as tuto addr"):
        assert _players_registry_add_len = tutoken_add_len
    end
    fill_tuto_adds_from_array(tutoken_add_len, tutoken_add, _players_registry_add)
    nb_of_exercises.write(tutoken_add_len)
    return ()
end

@external
func safely_migrate_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        tuto_index : felt, to_address : felt) -> (points_not_migrated : Uint256):
    alloc_locals
    let (caller_address : felt) = get_caller_address()
    let (tuto_adds_var : (felt, felt)) = tuto_adds.read(tuto_index)
    let (own_add : felt) = get_contract_address()

    let (balance_to_migrate : Uint256) = perform_checks(
        from_add=caller_address, token_add=tuto_adds_var[0], own_add=own_add, to_add=to_address)

    migrate_validated_exercises(
        from_user=caller_address,
        to_user=to_address,
        tuto_index=tuto_index,
        players_registry_add=tuto_adds_var[1],
        exercise_index=0)

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=1)

    IERC20.transferFrom(
        contract_address=tuto_adds_var[0],
        sender=caller_address,
        recipient=own_add,
        amount=balance_to_migrate)

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=0)
    let (rp : Uint256) = rug_pulled.read(user=caller_address, tuto_index=tuto_index)
    let (final_rp : Uint256, _) = uint256_add(rp, balance_to_migrate)
    rug_pulled.write(user=caller_address, tuto_index=tuto_index, value=final_rp)
    return (balance_to_migrate)
end

@external
func redemption{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        tuto_index : felt, to_address : felt) -> (points_migrated : Uint256):
    let (caller_address : felt) = get_caller_address()

    let (balance : Uint256) = rug_pulled.read(caller_address, tuto_index)
    let (tuto_adds_var : (felt, felt)) = tuto_adds.read(tuto_index)

    rug_pulled.write(user=caller_address, tuto_index=tuto_index, value=Uint256(0, 0))

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=1)

    IERC20.transfer(contract_address=tuto_adds_var[0], recipient=to_address, amount=balance)

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=0)
    return (balance)
end
# creer un workshop pour distribuer les points et pareil pour le nft

# product sync parler de nule et présenter les outils
@external
func migrate_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        tuto_index : felt, to_address : felt) -> (points_migrated : Uint256):
    alloc_locals
    let (caller_address : felt) = get_caller_address()
    let (tuto_adds_var : (felt, felt)) = tuto_adds.read(tuto_index)
    let (own_add : felt) = get_contract_address()

    let (balance_to_migrate : Uint256) = perform_checks(
        from_add=caller_address, token_add=tuto_adds_var[0], own_add=own_add, to_add=to_address)

    migrate_validated_exercises(
        from_user=caller_address,
        to_user=to_address,
        tuto_index=tuto_index,
        players_registry_add=tuto_adds_var[1],
        exercise_index=0)

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=1)

    IERC20.transferFrom(
        contract_address=tuto_adds_var[0],
        sender=caller_address,
        recipient=to_address,
        amount=balance_to_migrate)

    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=0)

    return (balance_to_migrate)
end

@external
func fill_exercise_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        exercise_list_len : felt, exercise_list : felt*, tuto_nb : felt) -> ():
    fill_exercise_list_from_array(
        exercise_list_len=exercise_list_len, exercise_list=exercise_list, tuto_nb=tuto_nb)
    return ()
end
