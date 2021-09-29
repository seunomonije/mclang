
open Types

val print_prog : prog -> unit

val calc_qubit_num : prog -> int

val well_formed : prog -> bool

val parse_pattern : pattern -> prog
val print_pattern : pattern -> unit

val get_output_qubits : prog -> (qubit, unit) Hashtbl.t

val standardize : prog -> prog

