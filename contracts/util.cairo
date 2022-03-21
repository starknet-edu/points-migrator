%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from contracts.Migrator_storage import tuto_adds, exercises_list, nb_of_exercises
from contracts.utils.Iplayers_registry import Iplayers_registry

func uint_assert_equality{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        val1 : Uint256, val2 : Uint256, equality : felt) -> ():
    let (uint_equality : felt) = uint256_eq(val1, val2)
    assert uint_equality = equality
    return ()
end

func migrate_validated_exercises{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_user : felt, to_user : felt, tuto_index : felt, players_registry_add : felt,
        exercise_index : felt) -> ():
    alloc_locals
    let (ex : felt) = exercises_list.read(tuto_index, exercise_index)
    if ex == 0:
        return ()
    end
    let (has_val : felt) = Iplayers_registry.has_validated_exercice(
        contract_address=players_registry_add,
        account=from_user,
        workshop=tuto_index,
        exercise=ex - 1)

    if has_val == 1:
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
    migrate_validated_exercises(
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
