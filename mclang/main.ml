(*
 *  Measurement Calculus Programming Language
 *
 *  Date: May 2021
 *  Authors: Aidan Evans and Seun Omonije
 *)

module H = Hashtbl;;

(**********************************************************************************
 *                                                                                *
 *                              Data Type Declarations                            *
 *                                                                                *
 **********************************************************************************)

type qubit = int

type prep = 
  | Init of qubit * float
  | Init0 of qubit
  | Init1 of qubit
  | InitPlus of qubit
  | InitMinus of qubit
  | InitNonInput of qubit list

type cmd =
  | Entangle of qubit * qubit
  | Measure of qubit * float * qubit list * qubit list
  | XCorrect of qubit * qubit list
  | ZCorrect of qubit * qubit list

type prog = prep list * cmd list


(**********************************************************************************
 *                                                                                *
 *                                Utility Functions                               *
 *                                                                                *
 **********************************************************************************)

(*
 *  Converts numbers to a strings
 *)
let to_string = Int.to_string;;
let float_to_string x = Printf.sprintf "%.5f" x;;

(*
 *  Converts a preperation to a friendly, human-readable string.
 *)
let prep_to_string p = (
  match p with
  | Init (qubit, base_angle) -> 
    "Init[" ^ to_string qubit ^ ", " ^ float_to_string base_angle ^ "]"
  | Init0 (qubit) -> 
    "Init0[" ^ to_string qubit ^ "]"
  | Init1 (qubit) ->
    "Init1[" ^ to_string qubit ^ "]"
  | InitPlus (qubit) ->
    "Init+[" ^ to_string qubit ^ "]"
  | InitMinus (qubit) ->
    "Init-[" ^ to_string qubit ^ "]"
  | InitNonInput (qubits) ->
    "InitNonInput[" ^ (String.concat ", " (List.map to_string qubits)) ^ "]"
);;
  
(*
 *  Converts a command to a friendly, human-readable string.
 *)
let cmd_to_string c = (
  match c with 
  | Entangle (left, right) ->
    "E[" ^ to_string left ^ ", " ^ to_string right ^ "]"
  | Measure (qubit, angle, parity1, parity2) ->
    "M[" ^ String.concat ", " [to_string qubit; 
                              float_to_string angle; 
                              "[" ^ String.concat ", " List.map to_string parity1 ^ "]"; 
                              "[" ^ String.concat ", " List.map to_string parity2 ^ "]"] ^ "]"
  | XCorrect (qubit, signals) ->
    "X[" ^ to_string qubit ^ ", [" ^ String.concat ", " List.map to_string signals ^ "]]"
  | ZCorrect (qubit, signals) ->
    "Z[" ^ to_string qubit ^ ", [" ^ String.concat ", " List.map to_string signals ^ "]]"
);;

(*
 *  Prints out the program in a friendly, human-readable format.
 *)
let print_prog ((preps, cmds) : prog) = (
  List.iter (fun x -> print_endline(prep_to_string(x))) preps;
  List.iter (fun x -> print_endline(cmd_to_string(x))) cmds
);;

(*
 *  Prints an error messgae to stdout noting the command and violation.
 *)
let print_err (cmd, msg) = (
  print_endline ("Error: " ^ cmd_to_string cmd ^ " : " ^ msg ^ ".")
);;


(*
 *  Utility used for `well_formed` below.
 *)
let check_prep (comp_space_tbl, in_tbl) p = (
  let insertInit q = (
    H.add comp_space_tbl q ();
    H.add in_tbl q ()
  ) 
  in (
    match p with
    | Init (qubit, _)   -> insertInit(qubit)
    | Init0 (qubit)     -> insertInit(qubit)
    | Init1 (qubit)     -> insertInit(qubit)
    | InitPlus (qubit)  -> insertInit(qubit)
    | InitMinus (qubit) -> insertInit(qubit)
    | InitNonInput (qubits) -> (
      List.iter (fun x -> H.add comp_space_tbl x ()) qubits
    )
  )
);;


(*
 *  Utility used for `well_formed` below.
 *)
let check_cmd (err, comp_space_tbl, in_tbl, out_tbl) c = (
  match c with 
  | Entangle (left, right) -> (

  )
  | Measure (qubit, angle, parity1, parity2) -> (

  )
  | XCorrect (qubit, signals) -> (

  )
  | ZCorrect (qubit, signals) -> (

  )
);;

(*
 *  Utility used for `well_formed` below.
 *
 *  D2 (see below) is violated if any command acts on an unprepared, non-input qubit.
 *  `input_or_prepared_tbl` contains all prepared or input qubits; thus, an error
 *  has occured if a command acts on a qubit not in `input_or_prepared_tbl`.
 *)
let check_D2 (err, input_or_prepared_tbl) c = (
  let check q msg = (
    if not (H.mem input_or_prepared_tbl q) then (
      err := true;
      print_err (c, "Invalid use of unprepared, non-input qubit " ^ to_string q)
    )
  ) 
  in (
    match c with 
    | Entangle (left, right)    -> (check left; check right)
    | Measure (qubit, _, _, _)  -> (check qubit)
    | XCorrect (qubit, _)       -> (check qubit)
    | ZCorrect (qubit, _)       -> (check qubit)
  )
);;


(*
 *  Checks whether a program is well formed, i.e., whether it satisfies
 *  the following conditions:
 *    From the paper:
 *      (D0) No command depends on an outcome not yet measured.
 *      (D1) No command acts on a qubit already measured.
 *      (D2) No command acts on a qubit not yet prepared, unless it is an input qubit.
 *      (D3) A qubit i is measured if and only if i is not an output.
 *           Equivalently, a qubit i is an output iff i is not measured. 
 *    Additioinal contraints per the current implementation:
 *      (D5) The "qubit integers" must start at 0 and increase without skipping an integer.
 *
 *  Returns 0 on failure.
 *  On success, returns the number of qubits used in the program.
 *)
let well_formed ((preps, cmds) : prog) : int = (
  let err = ref false in
  let comp_space_tbl = H.create 12 in
  let in_tbl = H.create 12 in
  let out_tbl = H.create 12 in (
    List.iter (check_prep (comp_space_tbl, in_tbl)) preps;
    (* At this point in the computation, comp_space_tbl contains all qubits used  *
     * and in_tbl contains all input qubits                                       *)
    List.iter (check_D2 (err, comp_space_tbl)) cmds;

  );
  if (!err) then 0 else H.length comp_space_tbl
);;


(*
 *  Initializes global matrix stored in memory given the number of qubits to be simulated.
 *  Returns true on success; false on failure.
 *)
 let init_matrix (x : int) : bool = (
   if (x > 0) then (
     true
   ) else false
 );;


(**********************************************************************************
 *                                                                                *
 *                              Evaluation Functions                              *
 *                                                                                *
 **********************************************************************************)

(* Randomized *)
(*
(*
 *  Performs appropriate operations to initialize qubits.
 *  Matrix stored in memory changed as a side-effect.
 *)
let rec eval_prep (p : prep) : unit = (
  match p with
  | Init (qubit, base_angle) -> (
    (* Initalizes a qubit with angle base_angle *)
    
  )
  | Init0 (qubit) -> (

  )
  | Init1 (qubit) -> (

  )
  | InitPlus (qubit) -> (

  )
  | InitMinus (qubit) -> (

  )
  | InitNonInput (qubits) -> (
    (* Non-input qubits are all initialized to |+> *)
    List.iter (fun x -> eval_prep(InitPlus(x))) qubits 
  )
);;

(*
 *  Performs appropriate operations to execute command.
 *  Matrix stored in memory changed as a side-effect.
 *)
let eval_cmd (c : cmd) : unit = (
  match c with 
  | Entangle (left, right) -> (

  )
  | Measure (qubit, angle, parity1, parity2) -> (

  )
  | XCorrect (qubit, signals) -> (

  )
  | ZCorrect (qubit, signals) -> (

  )
);;

(* 
 *  Runs a program, evaluating the quantum measurements using random functions.
 *  First eval checks if the function is well formed. It then initializes the
 *  global matrix used to store state information. After, it runs the program
 *  and returns the result extracted from the state matrix.
 *)
let eval ((preps, cmds) as p : prog) : bool list = (
  let
    qubit_num = well_formed(p)
  in (
    if init_matrix(qubit_num) then (
      List.iter eval_prep preps;
      List.iter eval_cmd cmds;
      [] (* Will pull bool list from vector stored in memory *)
    ) else []
  )
);;
*)

print_prog ([Init(1, 0.375324); InitNonInput([2; 3])], [Entangle(1, 2)]);;

