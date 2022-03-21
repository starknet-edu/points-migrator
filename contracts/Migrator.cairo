%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from starkware.cairo.common.uint256 import Uint256, uint256_eq
from contracts.token.ERC20.ITDERC20 import ITDERC20
from contracts.token.ERC20.IERC20 import IERC20
from contracts.util import (
    fill_tuto_adds_from_array, fill_exercise_list_from_array, uint_assert_equality,
    migrate_validated_exercises)
from contracts.Migrator_storage import tuto_adds, nb_of_exercises

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _players_registry_add_len : felt, _players_registry_add : felt*, tutoken_add_len : felt,
        tutoken_add : felt*):
    with_attr error_message("Player registry should have the same length as tuto addr"):
        assert _players_registry_add_len = tutoken_add_len
    end
    %{ print("constructing") %}
    fill_tuto_adds_from_array(tutoken_add_len, tutoken_add, _players_registry_add)
    nb_of_exercises.write(tutoken_add_len)
    return ()
end

@external
func migrate_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        tuto_index : felt, to_address : felt) -> (points_migrate : Uint256):
    alloc_locals
    let (caller_address : felt) = get_caller_address()
    %{ print("a") %}
    let zero_as_uint256 : Uint256 = Uint256(0, 0)
    let (tuto_adds_var : (felt, felt)) = tuto_adds.read(tuto_index)
    let (own_add : felt) = get_contract_address()

    let (allowance : Uint256) = IERC20.allowance(
        contract_address=tuto_adds_var[0], owner=caller_address, spender=own_add)
    # TODO: check with greater than
    with_attr error_message("You have to approve the migrator contract"):
        uint_assert_equality(allowance, zero_as_uint256, 0)
    end

    let (balance_from_address : Uint256) = IERC20.balanceOf(
        contract_address=tuto_adds_var[0], account=caller_address)
    with_attr error_message("No points to migrate on this tutorial"):
        uint_assert_equality(balance_from_address, zero_as_uint256, 0)
    end

    let (balance_to_address : Uint256) = IERC20.balanceOf(
        contract_address=tuto_adds_var[0], account=to_address)
    with_attr error_message("This account already has points"):
        uint_assert_equality(balance_to_address, zero_as_uint256, 1)
    end
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
        amount=balance_from_address)
    ITDERC20.set_transferable(contract_address=tuto_adds_var[0], permission=0)

    return (balance_from_address)
end

@external
func fill_exercise_list{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        exercise_list_len : felt, exercise_list : felt*, tuto_nb : felt) -> ():
    fill_exercise_list_from_array(
        exercise_list_len=exercise_list_len, exercise_list=exercise_list, tuto_nb=tuto_nb)
    return ()
end
