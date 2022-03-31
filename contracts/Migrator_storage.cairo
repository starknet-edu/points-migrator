%lang starknet

from starkware.cairo.common.uint256 import Uint256

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

@storage_var
func rug_pulled(user : felt, tuto_index : felt) -> (amount : Uint256):
end

@view
func tuto_addresses{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        index : felt) -> (tuto_adds : (felt, felt)):
    let (res : (felt, felt)) = tuto_adds.read(index)
    return (res)
end

@view
func rugpulled{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user : felt, tuto_index : felt) -> (balance : Uint256):
    let (balance : Uint256) = rug_pulled.read(user, tuto_index)
    return (balance)
end
