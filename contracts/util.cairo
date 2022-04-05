%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_le
from contracts.Migrator_storage import tuto_adds, exercises_list, nb_of_exercises
from contracts.utils.Iplayers_registry import Iplayers_registry
from contracts.token.ERC20.IERC20 import IERC20

func perform_checks{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_add : felt, token_add : felt, own_add : felt, to_add : felt) -> (
        balance_to_migrate : Uint256):
    alloc_locals
    let zero_as_uint256 : Uint256 = Uint256(0, 0)
    # Gets how much you approved the migrator contract
    let (allowance : Uint256) = IERC20.allowance(
        contract_address=token_add, owner=from_add, spender=own_add)

    # Gets how many points you have for this tutorial
    let (balance_from_address : Uint256) = IERC20.balanceOf(
        contract_address=token_add, account=from_add)

    with_attr error_message("No points to migrate on this tutorial"):
        uint_assert_equality(balance_from_address, zero_as_uint256, 0)
    end

    with_attr error_message("You have to approve the migrator contract"):
        uint_assert_le(balance_from_address, allowance)
    end

    # Checks that you don't have tutorial's points on the new account
    let (balance_to_address : Uint256) = IERC20.balanceOf(
        contract_address=token_add, account=to_add)

    with_attr error_message("This account already has points"):
        uint_assert_equality(balance_to_address, zero_as_uint256, 1)
    end
    return (balance_from_address)
end

func uint_assert_equality{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        val1 : Uint256, val2 : Uint256, equality : felt) -> ():
    let (uint_equality : felt) = uint256_eq(val1, val2)
    assert uint_equality = equality
    return ()
end

func uint_assert_le{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        val1 : Uint256, val2 : Uint256) -> ():
    let (res : felt) = uint256_le(val1, val2)
    assert res = 1
    return ()
end

# Duplicate function because of type in players registry function name
func migrate_validated_exercises{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_user : felt, to_user : felt, tuto_index : felt, players_registry_add : felt,
        exercise_index : felt) -> ():
    alloc_locals
    let (ex : felt) = exercises_list.read(tuto_index, exercise_index)
    if ex == 0:
        return ()
    end

    # Gets if you validated this exercise on the old account
    let (has_val : felt) = Iplayers_registry.has_validated_exercise(
        contract_address=players_registry_add,
        account=from_user,
        workshop=tuto_index,
        exercise=ex - 1)

    if has_val == 1:
        # If you validated the exercise on the old acc validates it on the new
        Iplayers_registry.validate_exercise(
            contract_address=players_registry_add,
            account=to_user,
            workshop=tuto_index,
            exercise=ex - 1)
        tempvar syscall_ptr = syscall_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar range_check_ptr = range_check_ptr
    end
    # calls this function recursively to validate all the exercises
    migrate_validated_exercises(
        from_user=from_user,
        to_user=to_user,
        tuto_index=tuto_index,
        players_registry_add=players_registry_add,
        exercise_index=exercise_index + 1)
    return ()
end

# Duplicate function because of typo in players registry function name
func migrate_validated_exercices{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_user : felt, to_user : felt, tuto_index : felt, players_registry_add : felt,
        exercise_index : felt) -> ():
    alloc_locals
    let (ex : felt) = exercises_list.read(tuto_index, exercise_index)
    if ex == 0:
        return ()
    end

    # Gets if you validated this exercise on the old account
    let (has_val : felt) = Iplayers_registry.has_validated_exercice(
        contract_address=players_registry_add,
        account=from_user,
        workshop=tuto_index,
        exercise=ex - 1)

    if has_val == 1:
        # If you validated the exercise on the old acc validates it on the new
        Iplayers_registry.validate_exercice(
            contract_address=players_registry_add,
            account=to_user,
            workshop=tuto_index,
            exercise=ex - 1)
        tempvar syscall_ptr = syscall_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    # calls this function recursively to validate all the exercises
    migrate_validated_exercices(
        from_user=from_user,
        to_user=to_user,
        tuto_index=tuto_index,
        players_registry_add=players_registry_add,
        exercise_index=exercise_index + 1)
    return ()
end

func fill_tuto_adds_from_array{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        len : felt, tutoken : felt*, players_registry : felt*) -> ():
    if len == 0:
        return ()
    end

    fill_tuto_adds_from_array(
        len=len - 1, tutoken=tutoken + 1, players_registry=players_registry + 1)
    tuto_adds.write(len, ([tutoken], [players_registry]))
    return ()
end

func fill_exercise_list_from_array{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        exercise_list_len : felt, exercise_list : felt*, tuto_nb : felt) -> ():
    if exercise_list_len == 0:
        return ()
    end

    fill_exercise_list_from_array(
        exercise_list_len=exercise_list_len - 1, exercise_list=exercise_list + 1, tuto_nb=tuto_nb)
    exercises_list.write(tuto_nb, exercise_list_len - 1, [exercise_list] + 1)
    return ()
end
