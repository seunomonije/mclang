
open Backend.Run;;

open Lacamlext;;
open Lacaml.Z;;

let () = List.iter (fun p -> Mat.print (rand_eval p)) Programs.programs

