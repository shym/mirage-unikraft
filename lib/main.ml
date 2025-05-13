(* SPDX-License-Identifier: MIT *)
(*
 * Copyright (c) 2009 Jérémie Dimino
 * Copyright (c) 2010 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2024-2025 Fabrice Buoro <fabrice@tarides.com>
 * Copyright (c) 2024-2025 Samuel Hym <samuel@tarides.com>
 *)

(* Net: device_id; Block: device_id * token_id *)
type key = Net of int | Block of int * int | Nothing

external uk_yield : int64 -> key = "uk_yield"

external uk_netdev_is_queue_ready : int -> bool = "uk_netdev_is_queue_ready"
[@@noalloc]

module Pending_map = Hashtbl.Make(struct
  type t = key
  let equal = (=)
  let hash = Hashtbl.hash
end)

module Uk_engine : sig
  val iter : bool -> unit
  val data_on_netdev : int -> bool
  val wait_for_work_netdev : int -> unit Lwt.t
  val wait_for_work_blkdev : int -> int -> unit Lwt.t
end = struct
  let wait_device_ready = Pending_map.create 10
  let data_on_netdev devid = uk_netdev_is_queue_ready devid

  let iter nonblocking =
    let timeout =
      if nonblocking then Int64.zero
      else
        match Time.select_next () with
        | None -> Duration.of_day 1
        | Some time ->
            let now = Time.time () in
            if time < now then 0L else Int64.(sub time now)
    in
    match uk_yield timeout with
    | Nothing -> ()
    | io -> (
        match Pending_map.find_opt wait_device_ready io with
        | Some cond -> Lwt_condition.broadcast cond ()
        | _ -> assert false)

  let pending_cond key =
    match Pending_map.find_opt wait_device_ready key with
    | None ->
        let cond = Lwt_condition.create () in
        Pending_map.add wait_device_ready key cond;
        cond
    | Some cond -> cond

  let wait_for_work_netdev devid =
    let cond = pending_cond (Net devid) in
    Lwt_condition.wait cond

  let wait_for_work_blkdev devid tokid =
    let cond = pending_cond (Block (devid, tokid)) in
    Lwt_condition.wait cond
end

(* From lwt/src/unix/lwt_main.ml *)
let rec run t =
  (* Wakeup paused threads now. *)
  Lwt.wakeup_paused ();
  Time.restart_threads Time.time;
  match Lwt.poll t with
  | Some () -> ()
  | None ->
      (* Call enter hooks. *)
      Mirage_runtime.run_enter_iter_hooks ();
      (* Do the main loop call. *)
      Uk_engine.iter (Lwt.paused_count () > 0);
      (* Wakeup paused threads again. *)
      Lwt.wakeup_paused ();
      (* Call leave hooks. *)
      Mirage_runtime.run_leave_iter_hooks ();
      run t

(* If the platform doesn't have SIGPIPE, then Sys.set_signal will
   raise an Invalid_argument exception. If the signal does not exist
   then we don't need to ignore it, so it's safe to continue. *)
let ignore_sigpipe () =
  try Sys.(set_signal sigpipe Signal_ignore) with Invalid_argument _ -> ()

(* Main runloop, which registers a callback so it can be invoked
   when timeouts expire. Thus, the program may only call this function
   once and once only. *)
let run t =
  ignore_sigpipe ();
  run t

(* Hopefully we are the first call to [at_exit], since all functions registered
   previously will not be triggered since we are forcing the unikernel shutdown
   here *)
let () =
  at_exit (fun () ->
      Lwt.abandon_wakeups ();
      run (Mirage_runtime.run_exit_hooks ()))
