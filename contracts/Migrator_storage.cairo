%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

@storage_var
func tuto_adds(index : felt) -> (addresses : (felt, felt)):
end

@storage_var
func nb_of_exercises() -> (tutoken_len : felt):
end

@storage_var
func exercises_list(tuto_index : felt, exercise_index : felt) -> (exercise_number : felt):
end

@view
func tuto_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        index : felt) -> (tuto_adds : (felt, felt)):
    let (res : (felt, felt)) = tuto_adds.read(index)
    return (res)
end
