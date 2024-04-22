/// This model class represents a set of Arguments that are used to configure an Effect in the Camera.
class CameraEffectArguments {
  /// The key for the argument.
  final String argumentKey;

  /// The value of the argument.
  final String? argumentValue;

  /// The values of the argument.
  final List<String>? argumentList;

  /// Default constructor
  const CameraEffectArguments({
    required this.argumentKey,
    this.argumentValue,
    this.argumentList,
  }) : assert(
          argumentValue != null || argumentList != null,
          "Please provide the data for argument value or argument list properties",
        );

  /// Method to map the data of a [CameraEffectArguments] object into a [Map] and use for channel method call.
  ///
  /// This method is used internally for the plugin only.
  Map<String, dynamic> toJson() {
    return {
      'argumentKey': argumentKey,
      'argumentValue': argumentValue,
      'argumentList': argumentList,
    };
  }
}
