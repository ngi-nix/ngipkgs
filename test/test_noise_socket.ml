open OUnit2

let noise_name = 	"Noise_XK_25519_ChaChaPoly_BLAKE2b"
let noise_pattern = 	Noise.Pattern.XK
let noise_dh = 		Noise.Dh.Curve_25519
let noise_cipher = 	Noise.Cipher.Chacha_poly
let noise_hash = 	Noise.Hash.BLAKE2b

let in_nego = Cstruct.of_string "negotiate"
let re_nego = Cstruct.of_string "accepted"
let in_msg = Cstruct.of_string "hello\nresponder!\n"
let re_msg = Cstruct.of_string "hello\ninitiator!\n"

let padded_len = 128

let init =
  Noise_socket.init
    ~name: noise_name
    ~pattern: noise_pattern
    ~dh: noise_dh
    ~cipher: noise_cipher
    ~hash: noise_hash

let crypto_random_bytes n =
  let ic = Pervasives.open_in_bin "/dev/urandom" in
  let s = Pervasives.really_input_string ic n in
  close_in ic;
  Cstruct.of_string s

let generate_private_key () =
  Noise.Dh.len noise_dh
  |> crypto_random_bytes
  |> Noise.Private_key.of_bytes

let write_handshake oc sock nego msg id =
  let%lwt _ = Lwt_io.eprintf "# %s write_handshake\n" id in
  match Noise_socket.write_handshake sock nego msg padded_len with
  | Ok hmsg ->
     let hmsg_len = Cstruct.len hmsg in
     let hmsg_b = Cstruct.to_bytes hmsg in
     let%lwt _ = Lwt_io.eprintf "# write_handshake: %d bytes\n" hmsg_len in
     let%lwt len = Lwt_io.write_from oc hmsg_b 0 hmsg_len in
     let%lwt _ = Lwt_io.flush oc in
     Lwt.return len
  | Error err ->
     Lwt.fail_with err

let write_msg oc sock msg id =
  let%lwt _ = Lwt_io.eprintf "# %s write_msg\n" id in
  match Noise_socket.write_msg sock msg padded_len with
  | Ok tmsg ->
     let tmsg_len = Cstruct.len tmsg in
     let tmsg_b = Cstruct.to_bytes tmsg in
     let%lwt _ = Lwt_io.eprintf "# %s write_msg: %d bytes\n" id tmsg_len in
     let%lwt len = Lwt_io.write_from oc tmsg_b 0 tmsg_len in
     let%lwt _ = Lwt_io.flush oc in
     Lwt.return len
  | Error err ->
     Lwt.fail_with err

let read_handshake ic sock id =
  let%lwt _ = Lwt_io.eprintf "# %s read_handshake\n" id in
  let%lwt (uncons, res) =
    Angstrom_lwt_unix.parse Noise_socket.Parser.handshake_msg ic in
  let%lwt _ = Lwt_io.eprintf "# %s read_handshake: unconsumed = %d / %d / %d\n"
                id (Bigarray.Array1.dim uncons.buf) uncons.off uncons.len in
  match res with
  | Ok (nego_a, pmsg_a') ->
     (match Noise_socket.read_handshake sock nego_a pmsg_a' with
      | Ok (nego, msg) ->
         Lwt.return (nego, msg)
      | Error err ->
         Lwt.fail_with err)
  | Error err ->
     Lwt.fail_with err

let read_msg ic sock id =
  let%lwt _ = Lwt_io.eprintf "# %s read_msg\n" id in
  let%lwt (uncons, res) =
    Angstrom_lwt_unix.parse Noise_socket.Parser.transport_msg ic in
  let%lwt _ = Lwt_io.eprintf "# %s read_msg: unconsumed = %d / %d / %d\n"
                id (Bigarray.Array1.dim uncons.buf) uncons.off uncons.len in
  match res with
  | Ok pmsg_a' ->
     (match Noise_socket.read_msg sock pmsg_a' with
      | Ok (msg) ->
         Lwt.return msg
      | Error err ->
         Lwt.fail_with err)
  | Error err ->
     Lwt.fail_with err

let initiator ~s ~rs ?psk ~pre_pub_keys ic oc =
  let e = generate_private_key () in
  let sock =
    init
      ~is_initiator: true
      ~s: (Some s)
      ~rs: (Some rs)
      ~e: (Some e)
      ~psk
      ~pre_pub_keys
  in
  let%lwt _ = write_handshake oc sock in_nego Cstruct.empty "IN" in
  let%lwt _ = Lwt_io.printf "I > handshake: %s\n" @@ Cstruct.to_string in_nego in
  let%lwt (nego, msg) = read_handshake ic sock "IN" in
  let%lwt _ = Lwt_io.printf "I < handshake: %s\n" @@ Cstruct.to_string nego in
  assert_equal (Cstruct.equal nego re_nego) true;
  assert_equal (Cstruct.equal msg Cstruct.empty) true;
  let%lwt len = write_handshake oc sock Cstruct.empty Cstruct.empty "IN" in
  let%lwt _ = Lwt_io.printf "I > handshake (%d)\n" len in
  let%lwt _ = Lwt.pause () in
  let%lwt len = write_msg oc sock in_msg "IN" in
  let%lwt _ = Lwt_io.printf "I > %s (%d)\n" (Cstruct.to_string in_msg) len in
  let%lwt msg = read_msg ic sock "IN" in
  let%lwt _ = Lwt_io.printf "I < %s\n" (Cstruct.to_string msg) in
  assert_equal (Cstruct.equal msg re_msg) true;
  Lwt.return_unit

let responder ~s ?psk ~pre_pub_keys ic oc =
  let e = generate_private_key () in
  let sock =
    init
      ~is_initiator: false
      ~s: (Some s)
      ~rs: None
      ~e: (Some e)
      ~psk
      ~pre_pub_keys
  in

  let%lwt (nego, msg) = read_handshake ic sock "RE" in
  let%lwt _ = Lwt_io.printf "R < handshake: %s\n" @@ Cstruct.to_string nego in
  assert_equal (Cstruct.equal nego in_nego) true;
  assert_equal (Cstruct.equal msg Cstruct.empty) true;
  let%lwt _ = write_handshake oc sock re_nego Cstruct.empty "RE" in
  let%lwt _ = Lwt_io.printf "R > handshake: %s\n" @@ Cstruct.to_string re_nego in
  let%lwt (nego, msg) = read_handshake ic sock "RE" in
  assert_equal (Cstruct.equal nego Cstruct.empty) true;
  assert_equal (Cstruct.equal msg Cstruct.empty) true;
  let%lwt msg = read_msg ic sock "RE" in
  let%lwt _ = Lwt_io.printf "R < %s\n" @@ Cstruct.to_string msg in
  assert_equal (Cstruct.equal msg in_msg) true;
  let%lwt _ = write_msg oc sock re_msg "RE" in
  let%lwt _ = Lwt_io.printf "R > %s\n" @@ Cstruct.to_string re_msg in
  Lwt.return_unit

let main =
  let in_s = generate_private_key () in
  let re_s = generate_private_key () in
  let re_s_pub = Noise.Dh_25519.public_key re_s in
  let pre_pub_keys = [ re_s_pub ] in
  let (in_read, re_write) = Lwt_io.pipe () in
  let (re_read, in_write) = Lwt_io.pipe () in
  let%lwt () = Lwt_io.flush_all () in
  let in_t = initiator ~s:in_s ~rs:re_s_pub ~pre_pub_keys
               in_read in_write in
  let re_t = responder ~s:re_s ~pre_pub_keys
               re_read re_write in
  Lwt.on_failure in_t
    (fun exn ->
      assert_failure
      @@ Printf.sprintf "initiator failed: %s"
      @@ Printexc.to_string exn);
  Lwt.on_failure re_t
    (fun exn ->
      assert_failure
      @@ Printf.sprintf "responder failed: %s"
      @@ Printexc.to_string exn);
  Lwt.join [ in_t; re_t ]

let () = Lwt_main.run main
