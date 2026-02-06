
import { type ExternalIdObject; JSON = ExternalIdObject } "./ExternalIdObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type SimplifiedAlbumObject; JSON = SimplifiedAlbumObject } "./SimplifiedAlbumObject";

import { type SimplifiedArtistObject; JSON = SimplifiedArtistObject } "./SimplifiedArtistObject";

import { type TrackRestrictionObject; JSON = TrackRestrictionObject } "./TrackRestrictionObject";

// TrackObject.mo

module {
    // Motoko-facing type: what application code uses
    public type TrackObject = {
        /// The album on which the track appears. The album object includes a link in `href` to full information about the album. 
        album : ?SimplifiedAlbumObject;
        /// The artists who performed the track. Each artist object includes a link in `href` to more detailed information about the artist. 
        artists : ?[SimplifiedArtistObject];
        /// A list of the countries in which the track can be played, identified by their [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) code. 
        available_markets : ?[Text];
        /// The disc number (usually `1` unless the album consists of more than one disc). 
        disc_number : ?Int;
        /// The track length in milliseconds. 
        duration_ms : ?Int;
        /// Whether or not the track has explicit lyrics ( `true` = yes it does; `false` = no it does not OR unknown). 
        explicit : ?Bool;
        /// Known external IDs for the track. 
        external_ids : ?ExternalIdObject;
        /// Known external URLs for this track. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the track. 
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        id : ?Text;
        /// Part of the response when [Track Relinking](/documentation/web-api/concepts/track-relinking) is applied. If `true`, the track is playable in the given market. Otherwise `false`. 
        is_playable : ?Bool;
        /// Part of the response when [Track Relinking](/documentation/web-api/concepts/track-relinking) is applied, and the requested track has been replaced with different track. The track in the `linked_from` object contains information about the originally requested track. 
        linked_from : ?Any;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?TrackRestrictionObject;
        /// The name of the track. 
        name : ?Text;
        /// The popularity of the track. The value will be between 0 and 100, with 100 being the most popular.<br/>The popularity of a track is a value between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.<br/>Generally speaking, songs that are being played a lot now will have a higher popularity than songs that were played a lot in the past. Duplicate tracks (e.g. the same track from a single and an album) are rated independently. Artist and album popularity is derived mathematically from track popularity. _**Note**: the popularity value may lag actual popularity by a few days: the value is not updated in real time._ 
        popularity : ?Int;
        /// A link to a 30 second preview (MP3 format) of the track. Can be `null` 
        preview_url : ?Text;
        /// The number of the track. If an album has several discs, the track number is the number on the specified disc. 
        track_number : ?Int;
        /// The object type: \"track\". 
        type_ : ?Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        uri : ?Text;
        /// Whether or not the track is from a local file. 
        is_local : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer TrackObject type
        public type JSON = {
            album : ?SimplifiedAlbumObject;
            artists : ?[SimplifiedArtistObject];
            available_markets : ?[Text];
            disc_number : ?Int;
            duration_ms : ?Int;
            explicit : ?Bool;
            external_ids : ?ExternalIdObject;
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            is_playable : ?Bool;
            linked_from : ?Any;
            restrictions : ?TrackRestrictionObject;
            name : ?Text;
            popularity : ?Int;
            preview_url : ?Text;
            track_number : ?Int;
            type_ : ?Text;
            uri : ?Text;
            is_local : ?Bool;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : TrackObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?TrackObject = ?json;
    }
}
