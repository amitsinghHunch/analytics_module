/// This model class represents the textures that are used by an Effect in the Camera.
class CameraEffectTextures {
  /// The key of the texture.
  final String textureKey;

  /// The texture url.
  final String? textureUrl;

  /// Default constructor
  const CameraEffectTextures({
    required this.textureKey,
    required this.textureUrl,
  });

  /// Method to map the data of a [CameraEffectTextures] object into a [Map] and use for channel method call.
  ///
  /// This method is used internally for the plugin only.
  Map<String, dynamic> toJson() {
    return {
      'textureKey': textureKey,
      'textureUrl': textureUrl,
    };
  }
}
