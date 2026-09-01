const customCoverIdPrefix = 'custom-cover:';

bool isCustomCoverId(String coverId) => coverId.startsWith(customCoverIdPrefix);

String customCoverId(String encryptedPath) =>
    '$customCoverIdPrefix$encryptedPath';

String? customCoverPath(String coverId) =>
    isCustomCoverId(coverId)
        ? coverId.substring(customCoverIdPrefix.length)
        : null;
