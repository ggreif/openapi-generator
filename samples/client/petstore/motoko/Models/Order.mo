
// Order.mo
/// An order for a pets from the pet store

module {
    public type Order = {
        id : ?Int;
        petId : ?Int;
        quantity : ?Int;
        shipDate : ?Text;
        /// Order Status
        status : ?Text;
        complete : ?Bool;
    };
}
