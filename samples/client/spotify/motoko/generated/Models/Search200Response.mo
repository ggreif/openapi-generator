
import { type PagingArtistObject; JSON = PagingArtistObject } "./PagingArtistObject";

import { type PagingPlaylistObject; JSON = PagingPlaylistObject } "./PagingPlaylistObject";

import { type PagingSimplifiedAlbumObject; JSON = PagingSimplifiedAlbumObject } "./PagingSimplifiedAlbumObject";

import { type PagingSimplifiedAudiobookObject; JSON = PagingSimplifiedAudiobookObject } "./PagingSimplifiedAudiobookObject";

import { type PagingSimplifiedEpisodeObject; JSON = PagingSimplifiedEpisodeObject } "./PagingSimplifiedEpisodeObject";

import { type PagingSimplifiedShowObject; JSON = PagingSimplifiedShowObject } "./PagingSimplifiedShowObject";

import { type PagingTrackObject; JSON = PagingTrackObject } "./PagingTrackObject";

// Search200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type Search200Response = {
        tracks : ?PagingTrackObject;
        artists : ?PagingArtistObject;
        albums : ?PagingSimplifiedAlbumObject;
        playlists : ?PagingPlaylistObject;
        shows : ?PagingSimplifiedShowObject;
        episodes : ?PagingSimplifiedEpisodeObject;
        audiobooks : ?PagingSimplifiedAudiobookObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer Search200Response type
        public type JSON = {
            tracks : ?PagingTrackObject;
            artists : ?PagingArtistObject;
            albums : ?PagingSimplifiedAlbumObject;
            playlists : ?PagingPlaylistObject;
            shows : ?PagingSimplifiedShowObject;
            episodes : ?PagingSimplifiedEpisodeObject;
            audiobooks : ?PagingSimplifiedAudiobookObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : Search200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?Search200Response = ?json;
    }
}
