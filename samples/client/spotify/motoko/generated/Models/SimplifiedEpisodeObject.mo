
import { type EpisodeBaseReleaseDatePrecision; JSON = EpisodeBaseReleaseDatePrecision } "./EpisodeBaseReleaseDatePrecision";

import { type EpisodeBaseType; JSON = EpisodeBaseType } "./EpisodeBaseType";

import { type EpisodeRestrictionObject; JSON = EpisodeRestrictionObject } "./EpisodeRestrictionObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type ResumePointObject; JSON = ResumePointObject } "./ResumePointObject";

// SimplifiedEpisodeObject.mo

module {
    // User-facing type: what application code uses
    public type SimplifiedEpisodeObject = {
        /// A URL to a 30 second preview (MP3 format) of the episode. `null` if not available. 
        audio_preview_url : Text;
        /// A description of the episode. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed. 
        description : Text;
        /// A description of the episode. This field may contain HTML tags. 
        html_description : Text;
        /// The episode length in milliseconds. 
        duration_ms : Int;
        /// Whether or not the episode has explicit content (true = yes it does; false = no it does not OR unknown). 
        explicit : Bool;
        /// External URLs for this episode. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the episode. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the episode. 
        id : Text;
        /// The cover art for the episode in various sizes, widest first. 
        images : [ImageObject];
        /// True if the episode is hosted outside of Spotify's CDN. 
        is_externally_hosted : Bool;
        /// True if the episode is playable in the given market. Otherwise false. 
        is_playable : Bool;
        /// The language used in the episode, identified by a [ISO 639](https://en.wikipedia.org/wiki/ISO_639) code. This field is deprecated and might be removed in the future. Please use the `languages` field instead. 
        language : ?Text;
        /// A list of the languages used in the episode, identified by their [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639) code. 
        languages : [Text];
        /// The name of the episode. 
        name : Text;
        /// The date the episode was first released, for example `\"1981-12-15\"`. Depending on the precision, it might be shown as `\"1981\"` or `\"1981-12\"`. 
        release_date : Text;
        release_date_precision : EpisodeBaseReleaseDatePrecision;
        /// The user's most recent position in the episode. Set if the supplied access token is a user token and has the scope 'user-read-playback-position'. 
        resume_point : ?ResumePointObject;
        type_ : EpisodeBaseType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the episode. 
        uri : Text;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?EpisodeRestrictionObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SimplifiedEpisodeObject type
        public type JSON = {
            audio_preview_url : Text;
            description : Text;
            html_description : Text;
            duration_ms : Int;
            explicit : Bool;
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            is_externally_hosted : Bool;
            is_playable : Bool;
            language : ?Text;
            languages : [Text];
            name : Text;
            release_date : Text;
            release_date_precision : EpisodeBaseReleaseDatePrecision.JSON;
            resume_point : ?ResumePointObject;
            type_ : EpisodeBaseType.JSON;
            uri : Text;
            restrictions : ?EpisodeRestrictionObject;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SimplifiedEpisodeObject) : JSON = { value with
            release_date_precision = EpisodeBaseReleaseDatePrecision.toJSON(value.release_date_precision);
            type_ = EpisodeBaseType.toJSON(value.type_);
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SimplifiedEpisodeObject {
            let ?release_date_precision = EpisodeBaseReleaseDatePrecision.fromJSON(json.release_date_precision) else return null;
            let ?type_ = EpisodeBaseType.fromJSON(json.type_) else return null;
            ?{ json with
                release_date_precision;
                type_;
            }
        };
    }
}
