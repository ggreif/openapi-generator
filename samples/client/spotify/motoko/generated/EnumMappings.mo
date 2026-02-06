// EnumMappings.mo - Global identifier mappings for JSON serialization
//
// This module contains all identifier mappings for the entire API.
// It provides bidirectional mappings for:
// - Enum variant names with special characters
// - Record field names with hyphens or reserved words
//
// These are used by serde's renameKeys option during JSON serialization.

module {
    // Field mappings for AlbumBase model
    public let AlbumBaseFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for AlbumObject model
    public let AlbumObjectFieldOptions = {
        encode = [
            ("type_", "type"),
            ("label_", "label")
        ];
        decode = [
            ("type", "type_"),
            ("label", "label_")
        ];
    };

    // Field mappings for ArtistDiscographyAlbumObject model
    public let ArtistDiscographyAlbumObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ArtistObject model
    public let ArtistObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for AudioFeaturesObject model
    public let AudioFeaturesObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for AudiobookBase model
    public let AudiobookBaseFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for AudiobookObject model
    public let AudiobookObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ChangePlaylistDetailsRequest model
    public let ChangePlaylistDetailsRequestFieldOptions = {
        encode = [
            ("public_", "public")
        ];
        decode = [
            ("public", "public_")
        ];
    };

    // Field mappings for ChapterBase model
    public let ChapterBaseFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ChapterObject model
    public let ChapterObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ContextObject model
    public let ContextObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for CopyrightObject model
    public let CopyrightObjectFieldOptions = {
        encode = [
            ("text_", "text"),
            ("type_", "type")
        ];
        decode = [
            ("text", "text_"),
            ("type", "type_")
        ];
    };

    // Field mappings for CreatePlaylistRequest model
    public let CreatePlaylistRequestFieldOptions = {
        encode = [
            ("public_", "public")
        ];
        decode = [
            ("public", "public_")
        ];
    };

    // Field mappings for DeviceObject model
    public let DeviceObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for EpisodeBase model
    public let EpisodeBaseFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for EpisodeObject model
    public let EpisodeObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for FollowPlaylistRequest model
    public let FollowPlaylistRequestFieldOptions = {
        encode = [
            ("public_", "public")
        ];
        decode = [
            ("public", "public_")
        ];
    };

    // Field mappings for GetUsersTopArtistsAndTracks200ResponseAllOfItemsInner model
    public let GetUsersTopArtistsAndTracks200ResponseAllOfItemsInnerFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for LinkedTrackObject model
    public let LinkedTrackObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for PlaylistObject model
    public let PlaylistObjectFieldOptions = {
        encode = [
            ("public_", "public"),
            ("type_", "type")
        ];
        decode = [
            ("public", "public_"),
            ("type", "type_")
        ];
    };

    // Field mappings for PlaylistOwnerObject model
    public let PlaylistOwnerObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for PlaylistTrackObjectTrack model
    public let PlaylistTrackObjectTrackFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for PlaylistUserObject model
    public let PlaylistUserObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for PrivateUserObject model
    public let PrivateUserObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for PublicUserObject model
    public let PublicUserObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for QueueObjectCurrentlyPlaying model
    public let QueueObjectCurrentlyPlayingFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for QueueObjectQueueInner model
    public let QueueObjectQueueInnerFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for RecommendationSeedObject model
    public let RecommendationSeedObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ShowBase model
    public let ShowBaseFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for ShowObject model
    public let ShowObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedAlbumObject model
    public let SimplifiedAlbumObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedArtistObject model
    public let SimplifiedArtistObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedAudiobookObject model
    public let SimplifiedAudiobookObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedChapterObject model
    public let SimplifiedChapterObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedEpisodeObject model
    public let SimplifiedEpisodeObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedPlaylistObject model
    public let SimplifiedPlaylistObjectFieldOptions = {
        encode = [
            ("public_", "public"),
            ("type_", "type")
        ];
        decode = [
            ("public", "public_"),
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedShowObject model
    public let SimplifiedShowObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for SimplifiedTrackObject model
    public let SimplifiedTrackObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

    // Field mappings for TrackObject model
    public let TrackObjectFieldOptions = {
        encode = [
            ("type_", "type")
        ];
        decode = [
            ("type", "type_")
        ];
    };

}
