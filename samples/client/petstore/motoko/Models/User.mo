
// User.mo
/// A User who is purchasing from the pet store

module {
    public type User = {
        id : ?Int;
        username : ?Text;
        firstName : ?Text;
        lastName : ?Text;
        email : ?Text;
        password : ?Text;
        phone : ?Text;
        /// User Status
        userStatus : ?Int;
    };
}
