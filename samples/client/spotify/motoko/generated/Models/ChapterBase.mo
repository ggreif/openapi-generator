
import { type ChapterRestrictionObject; JSON = ChapterRestrictionObject } "./ChapterRestrictionObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type ResumePointObject; JSON = ResumePointObject } "./ResumePointObject";

// ChapterBase.mo

module {
    // Motoko-facing type: what application code uses
    public type ChapterBase = {
        /// A URL to a 30 second preview (MP3 format) of the chapter. `null` if not available. 
        audio_preview_url : Text;
        /// A list of the countries in which the chapter can be played, identified by their [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) code. 
        available_markets : ?[Text];
        /// The number of the chapter 
        chapter_number : Int;
        /// A description of the chapter. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed. 
        description : Text;
        /// A description of the chapter. This field may contain HTML tags. 
        html_description : Text;
        /// The chapter length in milliseconds. 
        duration_ms : Int;
        /// Whether or not the chapter has explicit content (true = yes it does; false = no it does not OR unknown). 
        explicit : Bool;
        /// External URLs for this chapter. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the chapter. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the chapter. 
        id : Text;
        /// The cover art for the chapter in various sizes, widest first. 
        images : [ImageObject];
        /// True if the chapter is playable in the given market. Otherwise false. 
        is_playable : Bool;
        /// A list of the languages used in the chapter, identified by their [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639) code. 
        languages : [Text];
        /// The name of the chapter. 
        name : Text;
        /// The date the chapter was first released, for example `\"1981-12-15\"`. Depending on the precision, it might be shown as `\"1981\"` or `\"1981-12\"`. 
        release_date : Text;
        /// The precision with which `release_date` value is known. 
        release_date_precision : Text;
        /// The user's most recent position in the chapter. Set if the supplied access token is a user token and has the scope 'user-read-playback-position'. 
        resume_point : ?ResumePointObject;
        /// The object type. 
        type_ : Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the chapter. 
        uri : Text;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?ChapterRestrictionObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ChapterBase type
        public type JSON = {
            audio_preview_url : Text;
            available_markets : ?[Text];
            chapter_number : Int;
            description : Text;
            html_description : Text;
            duration_ms : Int;
            explicit : Bool;
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            is_playable : Bool;
            languages : [Text];
            name : Text;
            release_date : Text;
            release_date_precision : Text;
            resume_point : ?ResumePointObject;
            type_ : Text;
            uri : Text;
            restrictions : ?ChapterRestrictionObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ChapterBase) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ChapterBase = ?json;
    }
}
