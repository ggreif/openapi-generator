
import { type AlbumRestrictionObject; JSON = AlbumRestrictionObject } "./AlbumRestrictionObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

// AlbumBase.mo

module {
    // Motoko-facing type: what application code uses
    public type AlbumBase = {
        /// The type of the album. 
        album_type : Text;
        /// The number of tracks in the album.
        total_tracks : Int;
        /// The markets in which the album is available: [ISO 3166-1 alpha-2 country codes](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2). _**NOTE**: an album is considered available in a market when at least 1 of its tracks is available in that market._ 
        available_markets : [Text];
        /// Known external URLs for this album. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the album. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the album. 
        id : Text;
        /// The cover art for the album in various sizes, widest first. 
        images : [ImageObject];
        /// The name of the album. In case of an album takedown, the value may be an empty string. 
        name : Text;
        /// The date the album was first released. 
        release_date : Text;
        /// The precision with which `release_date` value is known. 
        release_date_precision : Text;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?AlbumRestrictionObject;
        /// The object type. 
        type_ : Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the album. 
        uri : Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumBase type
        public type JSON = {
            album_type : Text;
            total_tracks : Int;
            available_markets : [Text];
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            name : Text;
            release_date : Text;
            release_date_precision : Text;
            restrictions : ?AlbumRestrictionObject;
            type_ : Text;
            uri : Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumBase) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?AlbumBase = ?json;
    }
}
