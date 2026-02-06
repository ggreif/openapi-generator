
import { type EpisodeObject; JSON = EpisodeObject } "./EpisodeObject";

import { type EpisodeRestrictionObject; JSON = EpisodeRestrictionObject } "./EpisodeRestrictionObject";

import { type ExternalIdObject; JSON = ExternalIdObject } "./ExternalIdObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type ResumePointObject; JSON = ResumePointObject } "./ResumePointObject";

import { type SimplifiedAlbumObject; JSON = SimplifiedAlbumObject } "./SimplifiedAlbumObject";

import { type SimplifiedArtistObject; JSON = SimplifiedArtistObject } "./SimplifiedArtistObject";

import { type SimplifiedShowObject; JSON = SimplifiedShowObject } "./SimplifiedShowObject";

import { type TrackObject; JSON = TrackObject } "./TrackObject";

// PlaylistTrackObjectTrack.mo
/// Information about the track or episode.

module {
    // Motoko-facing type: what application code uses
    public type PlaylistTrackObjectTrack = {
        /// The album on which the track appears. The album object includes a link in `href` to full information about the album. 
        album : ?SimplifiedAlbumObject;
        /// The artists who performed the track. Each artist object includes a link in `href` to more detailed information about the artist. 
        artists : ?[SimplifiedArtistObject];
        /// A list of the countries in which the track can be played, identified by their [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) code. 
        available_markets : ?[Text];
        /// The disc number (usually `1` unless the album consists of more than one disc). 
        disc_number : ?Int;
        /// The episode length in milliseconds. 
        duration_ms : Int;
        /// Whether or not the episode has explicit content (true = yes it does; false = no it does not OR unknown). 
        explicit : Bool;
        /// Known external IDs for the track. 
        external_ids : ?ExternalIdObject;
        /// External URLs for this episode. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the episode. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the episode. 
        id : Text;
        /// True if the episode is playable in the given market. Otherwise false. 
        is_playable : Bool;
        /// Part of the response when [Track Relinking](/documentation/web-api/concepts/track-relinking) is applied, and the requested track has been replaced with different track. The track in the `linked_from` object contains information about the originally requested track. 
        linked_from : ?Any;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?EpisodeRestrictionObject;
        /// The name of the episode. 
        name : Text;
        /// The popularity of the track. The value will be between 0 and 100, with 100 being the most popular.<br/>The popularity of a track is a value between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are.<br/>Generally speaking, songs that are being played a lot now will have a higher popularity than songs that were played a lot in the past. Duplicate tracks (e.g. the same track from a single and an album) are rated independently. Artist and album popularity is derived mathematically from track popularity. _**Note**: the popularity value may lag actual popularity by a few days: the value is not updated in real time._ 
        popularity : ?Int;
        /// A link to a 30 second preview (MP3 format) of the track. Can be `null` 
        preview_url : ?Text;
        /// The number of the track. If an album has several discs, the track number is the number on the specified disc. 
        track_number : ?Int;
        /// The object type: \"track\". 
        type_ : Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the episode. 
        uri : Text;
        /// Whether or not the track is from a local file. 
        is_local : ?Bool;
        /// A URL to a 30 second preview (MP3 format) of the episode. `null` if not available. 
        audio_preview_url : Text;
        /// A description of the episode. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed. 
        description : Text;
        /// A description of the episode. This field may contain HTML tags. 
        html_description : Text;
        /// The cover art for the episode in various sizes, widest first. 
        images : [ImageObject];
        /// True if the episode is hosted outside of Spotify's CDN. 
        is_externally_hosted : Bool;
        /// The language used in the episode, identified by a [ISO 639](https://en.wikipedia.org/wiki/ISO_639) code. This field is deprecated and might be removed in the future. Please use the `languages` field instead. 
        language : ?Text;
        /// A list of the languages used in the episode, identified by their [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639) code. 
        languages : [Text];
        /// The date the episode was first released, for example `\"1981-12-15\"`. Depending on the precision, it might be shown as `\"1981\"` or `\"1981-12\"`. 
        release_date : Text;
        /// The precision with which `release_date` value is known. 
        release_date_precision : Text;
        /// The user's most recent position in the episode. Set if the supplied access token is a user token and has the scope 'user-read-playback-position'. 
        resume_point : ?ResumePointObject;
        /// The show on which the episode belongs. 
        show : SimplifiedShowObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlaylistTrackObjectTrack type
        public type JSON = {
            album : ?SimplifiedAlbumObject;
            artists : ?[SimplifiedArtistObject];
            available_markets : ?[Text];
            disc_number : ?Int;
            duration_ms : Int;
            explicit : Bool;
            external_ids : ?ExternalIdObject;
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            is_playable : Bool;
            linked_from : ?Any;
            restrictions : ?EpisodeRestrictionObject;
            name : Text;
            popularity : ?Int;
            preview_url : ?Text;
            track_number : ?Int;
            type_ : Text;
            uri : Text;
            is_local : ?Bool;
            audio_preview_url : Text;
            description : Text;
            html_description : Text;
            images : [ImageObject];
            is_externally_hosted : Bool;
            language : ?Text;
            languages : [Text];
            release_date : Text;
            release_date_precision : Text;
            resume_point : ?ResumePointObject;
            show : SimplifiedShowObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistTrackObjectTrack) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?PlaylistTrackObjectTrack = ?json;
    }
}
