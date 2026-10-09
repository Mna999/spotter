class ExceptionHandler {
  static String authExceptionHandler(String code) {
    return switch (code) {
      'invalid-email' =>
        "That email address isn't valid. Check it and try again.",
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Wrong email or password.',
      'user-disabled' => 'This account has been disabled.',
      'email-already-in-use' =>
        'An account with this email already exists. Try signing in instead.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'operation-not-allowed' =>
        "This sign-in method isn't available right now.",
      'account-exists-with-different-credential' =>
        'An account already exists with this email using a different '
            'sign-in method. Sign in with your password instead.',
      'requires-recent-login' =>
        'For security, please sign in again and then retry.',
      'user-token-expired' ||
      'invalid-user-token' => 'Your session has expired. Please sign in again.',
      'too-many-requests' =>
        'Too many attempts. Please wait a few minutes and try again.',
      'network-request-failed' =>
        'No internet connection. Check your connection and try again.',
      _ => serverExceptionHandler(code),
    };
  }

  static String serverExceptionHandler(String code) {
    return switch (code) {
      'no-current-user' =>
        "You're not signed in. Please sign in and try again.",
      'google-sign-in-canceled' => 'Google sign-in was cancelled.',
      'google-missing-id-token' => 'Google sign-in failed. Please try again.',
      'google-interrupted' =>
        'Google sign-in was interrupted. Please try again.',
      'google-clientConfigurationError' ||
      'google-providerConfigurationError' =>
        "Google sign-in isn't set up correctly on this device.",
      _ when code.startsWith('google-') =>
        'Google sign-in failed. Please try again.',
      'permission-denied' => "You don't have permission to do that.",
      'unauthenticated' => 'Please sign in to continue.',
      'unavailable' || 'deadline-exceeded' =>
        'The service is temporarily unavailable. Try again in a moment.',
      'resource-exhausted' =>
        'The service is busy right now. Please try again later.',
      'not-found' => "We couldn't find that data.",
      'already-exists' => 'That already exists.',
      'failed-precondition' ||
      'aborted' => "That action couldn't be completed. Please try again.",
      'cancelled' => 'The request was cancelled. Please try again.',
      'invalid-argument' ||
      'out-of-range' => "Some of the information entered isn't valid.",
      'internal' ||
      'data-loss' ||
      'unknown' ||
      'unimplemented' => 'Something went wrong on our side. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
