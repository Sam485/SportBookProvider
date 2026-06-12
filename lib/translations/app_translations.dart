import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/language_provider.dart';
import 'package:provider/provider.dart';

/// Centralized translation management for the SportMate app.
/// Supports English ('en') and Khmer ('km') languages.
class AppTranslations {
  // ============================================================================
  // Translation Data
  // ============================================================================

  static const Map<String, Map<String, String>> _translations = {
    // ------------------------------------------------------------------------
    // English Translations
    // ------------------------------------------------------------------------
    'en': {
      // ---------------------- Navigation ----------------------------
      'home': 'Home',
      'explore': 'Explore',
      'bookings': 'Bookings',
      'settings': 'Settings',
      'profile': 'Profile',

      // ---------------------- Settings Screen ----------------------------
      'settings_title': 'Settings',
      'account': 'Account',
      'preferences': 'Preferences',
      'language': 'Language',
      'appearance': 'Appearance',
      'notifications': 'Notifications',
      'sign_out': 'Sign Out',
      'sign_out_confirmation': 'Are you sure you want to sign out?',
      'sign_out_cancel': 'Cancel',
      'sign_out_confirm': 'Sign Out',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'email_address': 'Email Address',
      'save_changes': 'Save Changes',
      'fill_all_fields': 'Please fill all fields',
      'enter_valid_email': 'Please enter a valid email',
      'history_bookings': 'History Bookings',
      'no_booking_history': 'No booking history',
      'past_bookings_appear_here': 'Your past bookings will appear here',
      'completed': 'Completed',
      'security': 'Security',
      'view_past_sessions': 'View past sessions',
      'last_changed': 'Last changed 3 months ago',
      'total_bookings': 'Bookings',
      'upcoming': 'Upcoming',
      'booking_reminders': 'Booking reminders & alerts',
      'select_language': 'Select Language',
      'english': 'English (US)',
      'khmer': 'Khmer',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_default': 'System Default',
      'dark': 'Dark',
      'light': 'Light',
      'system': 'System',

      // ---------------------- Password & Security ----------------------------
      'password_security': 'Password & Security',
      'security_tips': 'Security Tips',
      'strong_password_tip':
          'Use a strong password with letters, numbers, and symbols',
      'change_password_section': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'change_password': 'Change Password',
      'two_factor_auth': 'Two-Factor Authentication',
      'two_factor_desc': 'Add an extra layer of security',
      'two_factor_coming_soon': '2FA coming soon',
      'enter_current_password': 'Please enter current password',
      'enter_new_password': 'Please enter new password',
      'password_min_length': 'Password must be at least 6 characters',
      'passwords_do_not_match': 'Passwords do not match',
      'password_changed_success': 'Password changed successfully!',

      // ---------------------- Authentication ----------------------------
      'login': 'Login',
      'sign_up': 'Sign Up',
      'phone_or_username': 'Phone or Username',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember Me',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      'verify_phone': 'Verify Your Phone',
      'enter_otp': 'Enter the 6-digit code sent to your phone',
      'resend_code': 'Didn\'t receive the code?',
      'resend': 'Resend',
      'verify': 'Verify',
      'welcome_back': 'Welcome back! Please Sign in to continue',
      'valid_phone_required': 'Please enter a valid phone number',
      'password_hint': 'Enter your password',
      'password_required': 'Password is required',
      'create_account_desc': 'Create your account to get started',
      'phone': 'Phone',
      'confirm_password_required': 'Please confirm your password',
      'confirm_password_hint': 'Confirm your password',
      'password_mismatch': "Password doesn't match",
      'reset_password_desc': 'Reset your password',
      'reset_password': 'Reset Password',
      'remembered_password': 'Remembered your password?',
      'resend_in': 'Resend in {seconds}s',
      'back_to': 'Back to ',

      // ---------------------- Create Profile Screen ----------------------------
      'choose_photo': 'Choose Photo',
      'choose_from_library': 'Choose from Library',
      'take_a_photo': 'Take a Photo',
      'remove_photo': 'Remove Photo',
      'create_profile_title': 'Create Your Profile',
      'create_profile_desc':
          'Set up your profile so other players\ncan find and connect with you.',
      'username': 'Username',
      'username_required': 'Username is required',
      'username_min_length': 'Username must be at least 3 characters',
      'username_no_spaces': 'Username cannot contain spaces',
      'username_hint': 'e.g. john_doe',
      'email': 'Email',
      'optional': 'Optional',
      'email_hint': 'your@email.com',
      'valid_email_required': 'Please enter a valid email address',
      'create_profile': 'Create Profile',
      'skip_for_now': 'Skip for now',

      // ---------------------- Landing Screen ----------------------------
      'banner_title_1': 'Book Your\nGame Today!',
      'banner_title_2': 'Find Courts\nInstantly',
      'banner_title_3': 'Meet & Play\nWith Others',
      'banner_title_4': 'Track Every\nPerformance',
      'banner_desc_1':
          'Find courts, book slots, and connect with players near you — all in one place.',
      'banner_desc_2':
          'Discover available basketball courts, check real-time slot availability and reserve in seconds.',
      'banner_desc_3':
          'Join local games, challenge nearby players, and grow your sports community.',
      'banner_desc_4':
          'Log your sessions, monitor progress, and push your personal best every time you play.',
    },

    // ------------------------------------------------------------------------
    // Khmer Translations
    // ------------------------------------------------------------------------
    'km': {
      // ---------------------- Landing Screen ----------------------------
      'banner_title_1': 'កក់កីឡា\nរបស់អ្នកថ្ងៃនេះ!',
      'banner_title_2': 'ស្វែងរកទីលាន\nភ្លាមៗ',
      'banner_title_3': 'ជួប និងលេង\nជាមួយអ្នកដទៃ',
      'banner_title_4': 'តាមដាន\nការអនុវត្តន៍',
      'banner_desc_1':
          'ស្វែងរកទីលាន កក់ពេលវេលា និងភ្ជាប់ជាមួយអ្នកលេងក្បែរអ្នក — ទាំងអស់នៅកន្លែងតែមួយ។',
      'banner_desc_2':
          'ស្វែងរកទីលានបាល់បោះដែលមាន ពិនិត្យមើលភាពអាចរកបានតាមពេលវេលាជាក់ស្តែង និងកក់ក្នុងរយៈពេលប៉ុន្មានវិនាទី។',
      'banner_desc_3':
          'ចូលរួមការប្រកួតក្នុងតំបន់ ប្រកួតប្រជែងជាមួយអ្នកលេងក្បែរអ្នក និងពង្រីកសហគមន៍កីឡារបស់អ្នក។',
      'banner_desc_4':
          'កត់ត្រាវគ្គរបស់អ្នក តាមដានវឌ្ឍនភាព និងបង្កើនសមត្ថភាពផ្ទាល់ខ្លួនរាល់ពេលដែលអ្នកលេង។',

      // ---------------------- Navigation ----------------------------
      'home': 'ទំព័រដើម',
      'explore': 'ស្វែងរក',
      'bookings': 'ការកក់',
      'settings': 'ការកំណត់',
      'profile': 'ប្រវត្តិរូប',

      // ---------------------- Settings Screen ----------------------------
      'settings_title': 'ការកំណត់',
      'account': 'គណនី',
      'preferences': 'ចំណូលចិត្ត',
      'language': 'ភាសា',
      'appearance': 'រូបរាង',
      'notifications': 'ការជូនដំណឹង',
      'sign_out': 'ចាកចេញ',
      'sign_out_confirmation': 'តើអ្នកពិតជាចង់ចាកចេញមែនទេ?',
      'sign_out_cancel': 'បោះបង់',
      'sign_out_confirm': 'ចាកចេញ',
      'edit_profile': 'កែប្រវត្តិរូប',
      'full_name': 'ឈ្មោះពេញ',
      'email_address': 'អាសយដ្ឋានអ៊ីមែល',
      'save_changes': 'រក្សាទុកការផ្លាស់ប្តូរ',
      'fill_all_fields': 'សូមបំពេញគ្រប់វាល',
      'enter_valid_email': 'សូមបញ្ចូលអ៊ីមែលដែលមានសុពលភាព',
      'history_bookings': 'ប្រវត្តិការកក់',
      'no_booking_history': 'គ្មានប្រវត្តិការកក់',
      'past_bookings_appear_here': 'ការកក់មុនរបស់អ្នកនឹងបង្ហាញនៅទីនេះ',
      'completed': 'បានបញ្ចប់',
      'security': 'សុវត្ថិភាព',
      'view_past_sessions': 'មើលវគ្គមុនៗ',
      'last_changed': 'បានផ្លាស់ប្តូរចុងក្រោយកាលពី ៣ ខែមុន',
      'total_bookings': 'ការកក់',
      'upcoming': 'នាពេលខាងមុខ',
      'booking_reminders': 'ការរំលឹក និងដំណឹងជូនដំណឹង',
      'select_language': 'ជ្រើសរើសភាសា',
      'english': 'អង់គ្លេស',
      'khmer': 'ខ្មែរ',
      'dark_mode': 'របៀបងងឹត',
      'light_mode': 'របៀបភ្លឺ',
      'system_default': 'តាមប្រព័ន្ធ',
      'dark': 'ងងឹត',
      'light': 'ភ្លឺ',
      'system': 'ប្រព័ន្ធ',

      // ---------------------- Password & Security ----------------------------
      'password_security': 'ពាក្យសម្ងាត់ និងសុវត្ថិភាព',
      'security_tips': 'គន្លឹះសុវត្ថិភាព',
      'strong_password_tip': 'ប្រើពាក្យសម្ងាត់រឹងមាំដែលមានអក្សរ លេខ និងសញ្ញា',
      'change_password_section': 'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
      'current_password': 'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
      'new_password': 'ពាក្យសម្ងាត់ថ្មី',
      'confirm_new_password': 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
      'change_password': 'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
      'two_factor_auth': 'ការផ្ទៀងផ្ទាត់ពីរជាន់',
      'two_factor_desc': 'បន្ថែមស្រទាប់សុវត្ថិភាពបន្ថែម',
      'two_factor_coming_soon': '2FA នឹងមកដល់ឆាប់ៗនេះ',
      'enter_current_password': 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្ន',
      'enter_new_password': 'សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី',
      'password_min_length': 'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងហោចណាស់ ៦ តួអក្សរ',
      'passwords_do_not_match': 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ',
      'password_changed_success': 'បានផ្លាស់ប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',

      // ---------------------- Create Profile Screen ----------------------------
      'choose_photo': 'ជ្រើសរើសរូបថត',
      'choose_from_library': 'ជ្រើសរើសពីបណ្ណាល័យ',
      'take_a_photo': 'ថតរូប',
      'remove_photo': 'លុបរូបថត',
      'create_profile_title': 'បង្កើតប្រវត្តិរូបរបស់អ្នក',
      'create_profile_desc':
          'កំណត់ប្រវត្តិរូបរបស់អ្នកដើម្បីឱ្យអ្នកលេងផ្សេងទៀត\nអាចស្វែងរក និងភ្ជាប់ជាមួយអ្នកបាន',
      'username': 'ឈ្មោះអ្នកប្រើ',
      'username_required': 'តម្រូវឱ្យបញ្ចូលឈ្មោះអ្នកប្រើ',
      'username_min_length': 'ឈ្មោះអ្នកប្រើត្រូវមានយ៉ាងហោចណាស់ ៣ តួអក្សរ',
      'username_no_spaces': 'ឈ្មោះអ្នកប្រើមិនអាចមានដកឃ្លាបានទេ',
      'username_hint': 'ឧទាហរណ៍ john_doe',
      'email': 'អ៊ីមែល',
      'optional': 'ស្រេចចិត្ត',
      'email_hint': 'your@email.com',
      'valid_email_required': 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលដែលមានសុពលភាព',
      'create_profile': 'បង្កើតប្រវត្តិរូប',
      'skip_for_now': 'រំលងសម្រាប់ពេលនេះ',
    },
  };

  // ============================================================================
  // Public Methods
  // ============================================================================

  /// Translates a given key to the specified locale.
  /// If the translation is not found, falls back to English or returns the key itself.
  static String translate(String key, {String? locale}) {
    final languageCode = locale ?? 'en';
    final translation = _translations[languageCode]?[key];

    if (translation == null) {
      // Log missing translations for debugging
      debugPrint(
        'Missing translation for key: $key in language: $languageCode',
      );
      return _translations['en']?[key] ?? key;
    }

    return translation;
  }
}

// ============================================================================
// String Extension for Convenient Translation
// ============================================================================

/// Extension on String to easily translate text using BuildContext.
///
/// Usage: 'hello'.tr(context)
extension StringTranslation on String {
  String tr(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return AppTranslations.translate(
      this,
      locale: languageProvider.currentLanguage,
    );
  }
}
