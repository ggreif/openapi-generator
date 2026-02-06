
import { type CopyrightObject; JSON = CopyrightObject } "./CopyrightObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

// SimplifiedShowObject.mo

module {
    // Motoko-facing type: what application code uses
    public type SimplifiedShowObject = {
        /// A list of the countries in which the show can be played, identified by their [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) code. 
        available_markets : [Text];
        /// The copyright statements of the show. 
        copyrights : [CopyrightObject];
        /// A description of the show. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed. 
        description : Text;
        /// A description of the show. This field may contain HTML tags. 
        html_description : Text;
        /// Whether or not the show has explicit content (true = yes it does; false = no it does not OR unknown). 
        explicit : Bool;
        /// External URLs for this show. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the show. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the show. 
        id : Text;
        /// The cover art for the show in various sizes, widest first. 
        images : [ImageObject];
        /// True if all of the shows episodes are hosted outside of Spotify's CDN. This field might be `null` in some cases. 
        is_externally_hosted : Bool;
        /// A list of the languages used in the show, identified by their [ISO 639](https://en.wikipedia.org/wiki/ISO_639) code. 
        languages : [Text];
        /// The media type of the show. 
        media_type : Text;
        /// The name of the episode. 
        name : Text;
        /// The publisher of the show. 
        publisher : Text;
        /// The object type. 
        type_ : Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the show. 
        uri : Text;
        /// The total number of episodes in the show. 
        total_episodes : Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SimplifiedShowObject type
        public type JSON = {
            available_markets : [Text];
            copyrights : [CopyrightObject];
            description : Text;
            html_description : Text;
            explicit : Bool;
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            is_externally_hosted : Bool;
            languages : [Text];
            media_type : Text;
            name : Text;
            publisher : Text;
            type_ : Text;
            uri : Text;
            total_episodes : Int;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : SimplifiedShowObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?SimplifiedShowObject = ?json;
    }
}
