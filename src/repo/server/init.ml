(* Init script for OPAM server repositories *)

let _ =
  if Array.length Sys.argv <> 2 then (
    Printf.eprintf "Usage: opam-git-init <remote-address>";
    exit 1
  )

open Types
open Protocol
open Unix

let local_path = Path.R.of_path (Dirname.of_string (Run.cwd ()))
let remote_address =
  try inet_addr_of_string Sys.argv.(1)
  with _ ->
    (gethostbyname Sys.argv.(1)).h_addr_list.(0)

let () =
  let s = Client.get_list remote_address in
  let opams =
    NV.Set.fold (fun nv accu ->
      (nv, Client.get_opam remote_address nv) :: accu
    ) s [] in
  let descrs =
    NV.Set.fold (fun nv accu ->
      (nv, Client.get_descr remote_address nv) :: accu
    ) s [] in
  List.iter (fun (nv,c) ->
    File.OPAM.write (Path.R.opam local_path nv) c
  ) opams;
  List.iter (fun (nv,c) ->
    File.Descr.write (Path.R.descr local_path nv) c
  ) descrs