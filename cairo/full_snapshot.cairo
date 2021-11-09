from starkware.cairo.common.cairo_builtins import (
    HashBuiltin, SignatureBuiltin)
from starkware.cairo.common.math import assert_nn_le
from starkware.cairo.common.dict import dict_squash
from starkware.cairo.common.small_merkle_tree import (
    small_merkle_tree)
from starkware.cairo.common.signature import (
    verify_ecdsa_signature)

# This program takes a snapshot of a store, and proves that the store is a superset of a previous snapshot.
# It also proves that all messages in the snapshot are stored in order.

# Asserts that all the requests in the store are ordered
func all_ordered{range_check_ptr}(curr_request : Request*, n_requests : felt):
    if n_requests == 1:
        return ()
    end

    let next_request = curr_request + 1
    request_le(curr_request, next_request)
    return all_ordered(curr_request + 1, n_requests-1)
end

# Checks a is less than or equal to b. Ordered by requestLinter, then user, then blockNumber, and finally numerically by message (where felts are interpretted as non negative integers)
func request_le{range_check_ptr}(a: Request*, b: Request*):
    assert_nn_le(a.requestLinter, b.requestLinter)
    if a.requestLinter == b.requestLinter:
        assert_nn_le(a.user_pub_key, b.user_pub_key)
        if a.user_pub_key == b.user_pub_key:
            assert_nn_le(a.blockNumber, b.blockNumber)
            if a.blockNumber == b.blockNumber:
                assert_nn_le(a.message1, b.message1)
                if a.message1 == b.message1:
                    assert_nn_le(a.message2, b.message2)
                    if a.message2 == b.message2:
                        assert_nn_le(a.message3, b.message3)
                        if a.message3 == b.message3:
                            assert_nn_le(a.message4, b.message4)
                        end
                    end
                end
            end
        end
    end
    return ()
end

# Read requests from program input
func get_requests() -> (
        requests : Request**, n_requests : felt):
    alloc_locals
    local requests : Request**
    local n_requests : felt
    %{
        requests = [
            [
                request['meta'],
                request['requestLinter'],
                request['user'],
                request['blockNumber'],
                request['message1'],
                request['message2'],
                request['message3'],
                request['message4'],
                # request['signature_r']
                # request['signature_s']
            ]
            for request in program_input['requests']
        ]
        ids.requests = segments.gen_arg(requests)
        ids.n_requests = len(requests)
    %}
    return (
        requests=requests,
        n_requests=n_requests)
end

# TODO: once we have ethereum signatures
func verify_request_signature{
        ecdsa_ptr : SignatureBuiltin*}(
        request : Request*):
    let (hash) = hash_request(request)

    # verify_ecdsa_signature(
    #     message=hash,
    #     public_key=request.user_pub_key,
    #     signature_r=request.signature_r,
    #     signature_s=request.signature_s)
    return ()
end