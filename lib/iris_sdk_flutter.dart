/// Face verification via the vendor Iris SDK (passportreader.app).
///
/// The SDK owns its own full-screen camera UI, so this package is a thin
/// bridge rather than a pipeline: hand [IrisFaceVerifier.verify] a reference
/// portrait and read the outcome back.
library;

export 'src/iris_face_verifier.dart';
export 'src/iris_verification_result.dart';
