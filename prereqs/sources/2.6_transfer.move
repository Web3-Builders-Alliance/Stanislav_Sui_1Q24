module prereqs::wrapper {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    // An object with `store` can be transferred in any module without a custom transfer implementation.
    struct Wrapper<T: store> has key, store {
        id: UID,
        contents: T
    }

    public fun contents<T: store>(c: &Wrapper<T>): &T {
        &c.contents
    }

    public fun create<T: store>(contents: T, ctx: &mut TxContext): Wrapper<T> {
        Wrapper {
            id: object::new(ctx),
            contents
        }
    }

    public fun destroy<T:store>(c: Wrapper<T>): T {
        let Wrapper {id, contents} = c;
        object::delete(id);
        contents
    }
}

module prereqs::user {
    use std::string::{Self, String};
    use sui::tx_context::TxContext;
    use sui::url::{Self, Url};

    use prereqs::wrapper::{Self, Wrapper};

    struct UserInfo has store {
        name: String,
        url: Url
    }

    public fun name(info: &UserInfo): &String {
        &info.name
    }

    public fun url(info: &UserInfo): &Url {
        &info.url
    }

    public fun create_user(name: vector<u8>, url: vector<u8>, ctx: &mut TxContext): Wrapper<UserInfo> {
        let container = wrapper::create(UserInfo {
            name: string::utf8(name),
            url: url::new_unsafe_from_bytes(url)
        }, ctx);
        container
    }
}