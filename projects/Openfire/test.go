// https://download.igniterealtime.org/openfire/docs/latest/documentation/client-minimal-working-example-mellium.html

package main

import (
	"context"
	"crypto/tls"
	"log"

	"mellium.im/sasl"
	"mellium.im/xmpp"
	"mellium.im/xmpp/dial"
	"mellium.im/xmpp/jid"
	"mellium.im/xmpp/stanza"
)

type logWriter struct {
	tag string
}

func (w logWriter) Write(p []byte) (int, error) {
	log.Printf("%s %s\n", w.tag, p)
	return len(p), nil
}

// MessageBody is a message stanza that contains a body. It is normally used for
// chat messages.
type MessageBody struct {
	stanza.Message
	Body string `xml:"body"`
}

// TODO: this is just an example, don't hard code passwords!
const (
	xmppPass = "secret"
	xmppUser = "jane@example.org"
)

func main() {
	j, err := jid.Parse(xmppUser)
	if err != nil {
		log.Fatalf("error parsing XMPP address: %v", err)
	}

	d := dial.Dialer{
		// TODO: we probably don't want to disable direct TLS connections and we
		// probably want to lookup the server using SRV records normally, but this
		// is an example so we're disabling security features.
		NoLookup: true,
		NoTLS:    true,
	}
	// TODO: normally we'd want to connect to the domainpart of the user
	// (example.org in this example), but let's override that and set it to
	// "localhost" since this is an example made to run locally.
	lo := jid.MustParse("localhost")
	conn, err := d.Dial(context.TODO(), "tcp", lo)
	if err != nil {
		log.Fatalf("error dialing TCP connection: %v", err)
	}

	s, err := xmpp.NewSession(context.TODO(), j.Domain(), j, conn, 0, xmpp.NewNegotiator(func(*xmpp.Session, *xmpp.StreamConfig) xmpp.StreamConfig {
		return xmpp.StreamConfig{
			Lang: "en",
			Features: []xmpp.StreamFeature{
				xmpp.BindResource(),
				xmpp.SASL("", xmppPass, sasl.Plain),
				xmpp.StartTLS(&tls.Config{
					// TODO: this is for example purposes only. We *really* don't want to
					// do this in prod. Use a nil TLS config for sane defaults.
					InsecureSkipVerify: true,
				}),
			},
			TeeIn:  logWriter{tag: "RECV"},
			TeeOut: logWriter{tag: "SENT"},
		}
	}))
	if err != nil {
		log.Fatalf("error connecting to server: %v", err)
	}
	defer func() {
		err := s.Close()
		if err != nil {
			log.Fatalf("error closing XMPP session: %v", err)
		}
	}()

	// Encode a message to ourself.
	err = s.Encode(context.TODO(), MessageBody{
		Message: stanza.Message{
			To:   s.LocalAddr(),
			Type: stanza.ChatMessage,
		},
		Body: "Hello world!",
	})
	if err != nil {
		log.Fatalf("error sending message to self: %v", err)
	}
}
