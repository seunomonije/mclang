
open Backend.Types;;
open Backend.Utils;;

open Backend.Run;;

open Lacamlext;;
open Lacaml.Z;;

let foobar() = (
  let _ = Some(Qlib.Bases.z_basis, Qlib.Bases.x_basis) in
  let p = (
    (*[Input(0, Zero); PrepList([1; 2])] @
    parse_pattern [J(0.0, 0, 1); J(0.0, 1, 2)];*)
    (*[Input(0, Zero); Prep(1); Measure(0, 0.0, [], []); ZCorrect(1, [])]*)
    [PrepList([0; 1]); Entangle(0, 1);  Measure(0, 0.0, [], []); XCorrect(1, [0])]
  ) in (
    let p' = standardize p in (
      print_prog p';
      Mat.print (rand_eval ~shots:0 ~change_base:None p')
    )
  )
);;

let _ = foobar();;


