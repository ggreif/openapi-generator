
import { type AudiobookBaseType; JSON = AudiobookBaseType } "./AudiobookBaseType";

import { type AuthorObject; JSON = AuthorObject } "./AuthorObject";

import { type CopyrightObject; JSON = CopyrightObject } "./CopyrightObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type NarratorObject; JSON = NarratorObject } "./NarratorObject";

// AudiobookObject.mo

module {
    // User-facing type: what application code uses
    public type AudiobookObject = {
        /// The author(s) for the audiobook. 
        authors : [AuthorObject];
        /// A list of the countries in which the audiobook can be played, identified by their [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) code. 
        available_markets : [Text];
        /// The copyright statements of the audiobook. 
        copyrights : [CopyrightObject];
        /// A description of the audiobook. HTML tags are stripped away from this field, use `html_description` field in case HTML tags are needed. 
        description : Text;
        /// A description of the audiobook. This field may contain HTML tags. 
        html_description : Text;
        /// The edition of the audiobook. 
        edition : ?Text;
        /// Whether or not the audiobook has explicit content (true = yes it does; false = no it does not OR unknown). 
        explicit : Bool;
        /// External URLs for this audiobook. 
        external_urls : ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the audiobook. 
        href : Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the audiobook. 
        id : Text;
        /// The cover art for the audiobook in various sizes, widest first. 
        images : [ImageObject];
        /// A list of the languages used in the audiobook, identified by their [ISO 639](https://en.wikipedia.org/wiki/ISO_639) code. 
        languages : [Text];
        /// The media type of the audiobook. 
        media_type : Text;
        /// The name of the audiobook. 
        name : Text;
        /// The narrator(s) for the audiobook. 
        narrators : [NarratorObject];
        /// The publisher of the audiobook. 
        publisher : Text;
        type_ : AudiobookBaseType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the audiobook. 
        uri : Text;
        /// The number of chapters in this audiobook. 
        total_chapters : Int;
        /// The chapters of the audiobook. 
        chapters : Any;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudiobookObject type
        public type JSON = {
            authors : [AuthorObject];
            available_markets : [Text];
            copyrights : [CopyrightObject];
            description : Text;
            html_description : Text;
            edition : ?Text;
            explicit : Bool;
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            languages : [Text];
            media_type : Text;
            name : Text;
            narrators : [NarratorObject];
            publisher : Text;
            type_ : AudiobookBaseType.JSON;
            uri : Text;
            total_chapters : Int;
            chapters : Any;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AudiobookObject) : JSON = { value with
            type_ = AudiobookBaseType.toJSON(value.type_);
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AudiobookObject {
            let ?type_ = AudiobookBaseType.fromJSON(json.type_) else return null;
            ?{ json with
                type_;
            }
        };
    }
}
