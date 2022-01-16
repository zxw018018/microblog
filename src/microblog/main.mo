import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
    public type Message = {
        text: Text;
        time: Time.Time;
    };

    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared (Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async [Message];
    };

    var followed : List.List<Principal> = List.nil();

    public shared func follow(id: Principal) : async () {
        followed := List.push(id, followed)
    };

    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    };

    var messages : List.List<Message> = List.nil();

    public shared func post(text: Text) : async () {
        let mesg = {
            text = text;
            time = Time.now();
        };
        messages := List.push(mesg, messages)
    };

    public shared query func posts(since: Time.Time): async [Message] {
        var all : List.List<Message> = List.nil();
        for (i in Iter.fromList(messages)) {
            if (i.time > since) {
                all := List.push(i, all)
            }
        };
        
        List.toArray(all)
    };

    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all)
            }
        };

        List.toArray(all)
    };
};