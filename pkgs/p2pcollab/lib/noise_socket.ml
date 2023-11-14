module Parser = struct
  open Angstrom

  let len_data =
    BE.any_uint16 >>= fun len ->
    take_bigstring len

  let transport_msg = len_data

  let handshake_msg =
    len_data >>= fun nego ->
    len_data >>= fun msg ->
    return (nego, msg)
end


module Uint16 = Stdint.Uint16

type t =
  {
    mutable state: Noise.State.t;
    mutable is_initialized: bool;
    prologue: string;
    pre_pub_keys: Noise.Public_key.t list;
  }

let init
      ~name ~pattern ~dh ~cipher ~hash
      ~is_initiator ~s ~rs ~e ~psk ~pre_pub_keys =
  { state =
      Noise.State.make
        ~name ~pattern ~dh ~cipher ~hash
        ~is_initiator ~s ~rs ~e ~psk;
    prologue = "NoiseSocketInit1";
    pre_pub_keys;
    is_initialized = false;
  }

let set_int16 buf off n =
  Uint16.to_bytes_big_endian (Uint16.of_int n) buf off

let init_noise t nego =
  let pstr_len = String.length t.prologue in
  let nego_len = Cstruct.len nego in
  let nego_b = Cstruct.to_bytes nego in
  let prologue_len = pstr_len + 2 + nego_len in
  let prologue_b = Bytes.create prologue_len in
  Bytes.blit_string t.prologue 0 prologue_b 0 pstr_len;
  set_int16 prologue_b pstr_len nego_len;
  Bytes.blit nego_b 0 prologue_b (pstr_len + 2) nego_len;
  let prologue = Cstruct.of_bytes prologue_b in
  t.state <- Noise.Protocol.initialize
               t.state ~prologue ~public_keys: t.pre_pub_keys;
  t.is_initialized <- true

let pad_msg msg padded_len =
  let msg_len = Cstruct.len msg in
  let pmsg_len = 2 + padded_len in
  let pmsg_b = Bytes.create pmsg_len in
  Bytes.fill pmsg_b 0 padded_len '\000';
  set_int16 pmsg_b 0 msg_len;
  let pmsg = Cstruct.of_bytes pmsg_b in
  Cstruct.blit msg 0 pmsg 2 msg_len;
  pmsg

let write_handshake t nego msg padded_len =
  let pmsg = pad_msg msg padded_len in
  if t.is_initialized = false
  then init_noise t nego;
  match Noise.Protocol.write_message t.state pmsg with
  | Ok (state, pmsg') ->
     let nego_len = Cstruct.len nego in
     let nego_b = Cstruct.to_bytes nego in
     let pmsg_len' = Cstruct.len pmsg' in
     let hmsg_len = 2 + nego_len + 2 + pmsg_len' in
     let hmsg_b = Bytes.create hmsg_len in
     set_int16 hmsg_b 0 nego_len;
     Bytes.blit nego_b 0 hmsg_b 2 nego_len;
     set_int16 hmsg_b (2 + nego_len) pmsg_len';
     let hmsg = Cstruct.of_bytes hmsg_b in
     Cstruct.blit pmsg' 0 hmsg (2 + nego_len + 2) pmsg_len';
     t.state <- state;
     Ok (hmsg)
  | Error err -> Error err

let read_handshake t nego_a pmsg_a' =
  let nego = Cstruct.of_bigarray nego_a in
  let pmsg' = Cstruct.of_bigarray pmsg_a' in
  if t.is_initialized = false
  then init_noise t nego;
  match Noise.Protocol.read_message t.state pmsg' with
    Ok (state, pmsg) ->
     t.state <- state;
     let pmsg_a = Cstruct.to_bigarray pmsg in
     (match Angstrom.parse_bigstring Parser.transport_msg pmsg_a with
      | Ok msg -> Ok (nego, Cstruct.of_bigarray msg)
      | Error err -> Error (Printf.sprintf "read_handshake/angstrom: %s" err))
  | Error err -> Error (Printf.sprintf "read_handshake/noise: %s" err)

let parse_handshake t hmsg =
  let hmsg_a = Cstruct.to_bigarray hmsg in
  match Angstrom.parse_bigstring Parser.handshake_msg hmsg_a with
  | Ok (nego_a, pmsg_a') ->
     read_handshake t nego_a pmsg_a'
  | Error err ->
     Error (Printf.sprintf "parse_handshake/angstrom: %s" err)

let write_msg t msg padded_len =
  let pmsg = pad_msg msg padded_len in
  (* encrypt padded msg *)
  match Noise.Protocol.write_message t.state pmsg with
  | Ok (state, pmsg') ->
     (* create transport msg *)
     let pmsg_len' = Cstruct.len pmsg' in
     let tmsg_len = 2 + pmsg_len' in
     let tmsg_b = Bytes.create tmsg_len in
     set_int16 tmsg_b 0 pmsg_len';
     let tmsg = Cstruct.of_bytes tmsg_b in
     Cstruct.blit pmsg' 0 tmsg 2 pmsg_len';
     t.state <- state;
     Ok tmsg
  | Error err -> Error err

let read_msg t pmsg_a' =
  let pmsg' = Cstruct.of_bigarray pmsg_a' in
  match Noise.Protocol.read_message t.state pmsg' with
  | Ok (state, pmsg) ->
     t.state <- state;
     let pmsg_a = Cstruct.to_bigarray pmsg in
     (match Angstrom.parse_bigstring Parser.transport_msg pmsg_a with
      | Ok msg -> Ok (Cstruct.of_bigarray msg)
      | Error err -> Error (Printf.sprintf "read_msg/angstrom: %s" err))
  | Error err -> Error (Printf.sprintf "read_msg/noise: %s" err)

let parse_msg t tmsg =
  let tmsg_a = Cstruct.to_bigarray tmsg in
  match Angstrom.parse_bigstring Parser.transport_msg tmsg_a with
  | Ok pmsg_a' ->
     read_msg t pmsg_a'
  | Error err ->
     Error (Printf.sprintf "parse_msg/angstrom: %s" err)
