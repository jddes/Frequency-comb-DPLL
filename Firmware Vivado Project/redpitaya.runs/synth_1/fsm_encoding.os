
 add_fsm_encoding \
       {system_identification_with_dither2.FSM_state} \
       { }  \
       {{000 000} {001 100} {010 001} {011 010} {100 011} }

 add_fsm_encoding \
       {system_identification_vna_with_dither_wrapper.fsm_state_output_serializer} \
       { }  \
       {{0000 00000000001} {0001 00000000010} {0010 00000000100} {0011 00000001000} {0100 00000010000} {0101 00000100000} {0110 00001000000} {0111 00010000000} {1000 00100000000} {1001 01000000000} {1010 10000000000} }

 add_fsm_encoding \
       {FSM_addr_packed.FSM_state} \
       { }  \
       {{0000 0000} {0001 0001} {0010 0010} {0011 0100} {0100 0011} {0110 0101} {0111 0110} {1000 0111} {1001 1000} {1010 1001} }
