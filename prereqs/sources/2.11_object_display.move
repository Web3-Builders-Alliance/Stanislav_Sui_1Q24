module prereqs::dinosaurus {
    use std::string::{utf8, String};
    use sui::display;
    use sui::object::{Self, UID};
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{sender, TxContext};

    struct Dinosaur has key, store {
        id: UID,
        type: String,
        img_url: String
    }

    struct DINOSAURUS has drop {}

    fun init(otw: DINOSAURUS, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"type"),
            utf8(b"image_url"),
            utf8(b"description"),
        ];
        let values = vector[
            utf8(b"{type}"),
            utf8(b"ipfs://{img_url}"),
            utf8(b"Awesome collection of dinosaurus"),
        ];

        let publisher = package::claim(otw, ctx);

        let display = display::new_with_fields<Dinosaur>(&publisher, keys, values, ctx);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    public fun mint(type: String, img_url: String, ctx: &mut TxContext): Dinosaur {
        Dinosaur {
            id: object::new(ctx),
            type,
            img_url
        }
    }

}