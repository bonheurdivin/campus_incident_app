// Confirm the exact allowed ALU domains with your course before submitting.
const allowedDomains = ['alustudent.com', 'alueducation.com'];

String? validateAluEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  final email = v.trim().toLowerCase();
  if (!email.contains('@')) return 'Please enter a valid email';
  if (!allowedDomains.any((d) => email.endsWith('@$d'))) {
    return 'Only a verified ALU email can register/login';
  }
  return null;
}

String? validatePassword(String? v) =>
    (v == null || v.length < 6) ? 'At least 6 characters' : null;