open Bigarray

type t

val init :
     name: string
  -> pattern: Noise.Pattern.t
  -> dh: Noise.Dh.t
  -> cipher: Noise.Cipher.t
  -> hash: Noise.Hash.t
  -> is_initiator: bool
  -> s: Noise.Private_key.t option
  -> rs: Noise.Public_key.t option
  -> e: Noise.Private_key.t option
  -> psk: Cstruct.t option
  -> pre_pub_keys: Noise.Public_key.t list
  -> t
(** initialize Noise Socket

    see also [Noise.Socket.make] & [Noise.Protocol.initialize] *)

val write_handshake :
     t
  -> Cstruct.t
  -> Cstruct.t
  -> int
  -> (Cstruct.t, string) result

(** [write_handshake t negotiation_data msg_body padded_len]

    render handshake message in wire format

    returns [handshake_message result] *)

val read_handshake :
     t
  -> (char, int8_unsigned_elt, c_layout) Array1.t
  -> (char, int8_unsigned_elt, c_layout) Array1.t
  -> (Cstruct.t * Cstruct.t, string) result

(** [read_handshake t negotiation_data padded_msg]

    read & decrypt handshake message from its two wire-format components
    without length header, [negotiation_data] and [padded_msg]

    returns [(negotiation_data * message_body) result] *)

val parse_handshake :
     t
  -> Cstruct.t
  -> (Cstruct.t * Cstruct.t, string) result

(** [parse_handshake t handshake_msg]

    parse wire format handshake message

    returns [(negotiation_data * message_body) result] *)

val write_msg :
     t
  -> Cstruct.t
  -> int
  -> (Cstruct.t, string) result

(** [write_msg t msg padded_len]

    render transport message in wire format

    returns [transport_message result] *)

val read_msg :
     t
  -> (char, int8_unsigned_elt, c_layout) Array1.t
  -> (Cstruct.t, string) result

(** [read_msg t padded_msg]

    read & decrypt transport message from a wire format
    [padded_msg] buffer without length header

    returns [message_body result] *)

val parse_msg :
     t
  -> Cstruct.t
  -> (Cstruct.t, string) result

(** [parse_msg t transport_msg]

    parse wire format transport message

    returns [message_body result] *)

module Parser : sig
  open Angstrom

  val transport_msg :
    bigstring t

  (** [transport_msg]

      transport message parser

      returns [noise_message] *)

  val handshake_msg :
    (bigstring * bigstring) t

(** [handshake_msg]

    handshake message parser

    returns [(negotiation_data * noise_message)] *)
end
