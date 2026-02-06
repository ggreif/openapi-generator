
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type PlaylistOwnerObject; JSON = PlaylistOwnerObject } "./PlaylistOwnerObject";

import { type PlaylistTracksRefObject; JSON = PlaylistTracksRefObject } "./PlaylistTracksRefObject";

// SimplifiedPlaylistObject.mo

module {
    // User-facing type: what application code uses
    public type SimplifiedPlaylistObject = {
        /// `true` if the owner allows other users to modify the playlist. 
        collaborative : ?Bool;
        /// The playlist description. _Only returned for modified, verified playlists, otherwise_ `null`. 
        description : ?Text;
        /// Known external URLs for this playlist. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the playlist. 
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the playlist. 
        id : ?Text;
        /// Images for the playlist. The array may be empty or contain up to three images. The images are returned by size in descending order. See [Working with Playlists](/documentation/web-api/concepts/playlists). _**Note**: If returned, the source URL for the image (`url`) is temporary and will expire in less than a day._ 
        images : ?[ImageObject];
        /// The name of the playlist. 
        name : ?Text;
        /// The user who owns the playlist 
        owner : ?PlaylistOwnerObject;
        /// The playlist's public/private status (if it is added to the user's profile): `true` the playlist is public, `false` the playlist is private, `null` the playlist status is not relevant. For more about public/private status, see [Working with Playlists](/documentation/web-api/concepts/playlists) 
        public_ : ?Bool;
        /// The version identifier for the current playlist. Can be supplied in other requests to target a specific playlist version 
        snapshot_id : ?Text;
        /// A collection containing a link ( `href` ) to the Web API endpoint where full details of the playlist's tracks can be retrieved, along with the `total` number of tracks in the playlist. Note, a track object may be `null`. This can happen if a track is no longer available. 
        tracks : ?PlaylistTracksRefObject;
        /// The object type: \"playlist\" 
        type_ : ?Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the playlist. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SimplifiedPlaylistObject type
        public type JSON = {
            collaborative : ?Bool;
            description : ?Text;
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            images : ?[ImageObject];
            name : ?Text;
            owner : ?PlaylistOwnerObject.JSON;
            public_ : ?Bool;
            snapshot_id : ?Text;
            tracks : ?PlaylistTracksRefObject;
            type_ : ?Text;
            uri : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SimplifiedPlaylistObject) : JSON = { value with
            owner = do ? { PlaylistOwnerObject.toJSON(value.owner!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SimplifiedPlaylistObject {
            ?{ json with
                owner = do ? { PlaylistOwnerObject.fromJSON(json.owner!)! };
            }
        };
    }
}
