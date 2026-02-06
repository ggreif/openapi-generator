
import { type AlbumBaseAlbumType; JSON = AlbumBaseAlbumType } "./AlbumBaseAlbumType";

import { type AlbumBaseReleaseDatePrecision; JSON = AlbumBaseReleaseDatePrecision } "./AlbumBaseReleaseDatePrecision";

import { type AlbumBaseType; JSON = AlbumBaseType } "./AlbumBaseType";

import { type AlbumRestrictionObject; JSON = AlbumRestrictionObject } "./AlbumRestrictionObject";

import { type ArtistDiscographyAlbumObjectAllOfAlbumGroup; JSON = ArtistDiscographyAlbumObjectAllOfAlbumGroup } "./ArtistDiscographyAlbumObjectAllOfAlbumGroup";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type SimplifiedArtistObject; JSON = SimplifiedArtistObject } "./SimplifiedArtistObject";

// ArtistDiscographyAlbumObject.mo

module {
    // User-facing type: what application code uses
    public type ArtistDiscographyAlbumObject = {
        album_type : AlbumBaseAlbumType;
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
        release_date_precision : AlbumBaseReleaseDatePrecision;
        /// Included in the response when a content restriction is applied. 
        restrictions : ?AlbumRestrictionObject;
        type_ : AlbumBaseType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the album. 
        uri : Text;
        /// The artists of the album. Each artist object includes a link in `href` to more detailed information about the artist. 
        artists : [SimplifiedArtistObject];
        album_group : ArtistDiscographyAlbumObjectAllOfAlbumGroup;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ArtistDiscographyAlbumObject type
        public type JSON = {
            album_type : AlbumBaseAlbumType.JSON;
            total_tracks : Int;
            available_markets : [Text];
            external_urls : ExternalUrlObject;
            href : Text;
            id : Text;
            images : [ImageObject];
            name : Text;
            release_date : Text;
            release_date_precision : AlbumBaseReleaseDatePrecision.JSON;
            restrictions : ?AlbumRestrictionObject.JSON;
            type_ : AlbumBaseType.JSON;
            uri : Text;
            artists : [SimplifiedArtistObject];
            album_group : ArtistDiscographyAlbumObjectAllOfAlbumGroup.JSON;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ArtistDiscographyAlbumObject) : JSON = { value with
            album_type = AlbumBaseAlbumType.toJSON(value.album_type);
            release_date_precision = AlbumBaseReleaseDatePrecision.toJSON(value.release_date_precision);
            restrictions = do ? { AlbumRestrictionObject.toJSON(value.restrictions!) };
            type_ = AlbumBaseType.toJSON(value.type_);
            album_group = ArtistDiscographyAlbumObjectAllOfAlbumGroup.toJSON(value.album_group);
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ArtistDiscographyAlbumObject {
            let ?album_type = AlbumBaseAlbumType.fromJSON(json.album_type) else return null;
            let ?release_date_precision = AlbumBaseReleaseDatePrecision.fromJSON(json.release_date_precision) else return null;
            let ?type_ = AlbumBaseType.fromJSON(json.type_) else return null;
            let ?album_group = ArtistDiscographyAlbumObjectAllOfAlbumGroup.fromJSON(json.album_group) else return null;
            ?{ json with
                album_type;
                release_date_precision;
                restrictions = do ? { AlbumRestrictionObject.fromJSON(json.restrictions!)! };
                type_;
                album_group;
            }
        };
    }
}
