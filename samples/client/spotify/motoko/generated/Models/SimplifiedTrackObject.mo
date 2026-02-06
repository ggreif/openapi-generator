
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type LinkedTrackObject; JSON = LinkedTrackObject } "./LinkedTrackObject";

import { type SimplifiedArtistObject; JSON = SimplifiedArtistObject } "./SimplifiedArtistObject";

import { type TrackRestrictionObject; JSON = TrackRestrictionObject } "./TrackRestrictionObject";

// SimplifiedTrackObject.mo

module {
    // User-facing type: what application code uses
    public type SimplifiedTrackObject = {
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
        /// External URLs for this track. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the track.
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        id : ?Text;
        /// Part of the response when [Track Relinking](/documentation/web-api/concepts/track-relinking/) is applied. If `true`, the track is playable in the given market. Otherwise `false`. 
        is_playable : ?Bool;
        /// Part of the response when [Track Relinking](/documentation/web-api/concepts/track-relinking/) is applied and is only part of the response if the track linking, in fact, exists. The requested track has been replaced with a different track. The track in the `linked_from` object contains information about the originally requested track.
        linked_from : ?LinkedTrackObject;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?TrackRestrictionObject;
        /// The name of the track.
        name : ?Text;
        /// A URL to a 30 second preview (MP3 format) of the track. 
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
        // Named "JSON" to avoid shadowing the outer SimplifiedTrackObject type
        public type JSON = {
            artists : ?[SimplifiedArtistObject];
            available_markets : ?[Text];
            disc_number : ?Int;
            duration_ms : ?Int;
            explicit : ?Bool;
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            is_playable : ?Bool;
            linked_from : ?LinkedTrackObject;
            restrictions : ?TrackRestrictionObject;
            name : ?Text;
            preview_url : ?Text;
            track_number : ?Int;
            type_ : ?Text;
            uri : ?Text;
            is_local : ?Bool;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SimplifiedTrackObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SimplifiedTrackObject = ?json;
    }
}
