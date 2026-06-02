import 'package:flutter/material.dart';

/// Simple, scalable localization helper.
///
/// - Add new languages by extending `_localizedValues`.
/// - Use keys instead of hard-coded strings in widgets.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('mr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General / common
      'app_title': 'Rozgar Adda',
      'app_logo_text': 'Rojgar',
      'sidebar_username': 'Rahul Sharma',
      'ok': 'OK',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'back': 'Back',
      'view_all': 'View All',

      // Splash
      'splash_tagline': 'Your Gateway to Opportunities',
      'splash_launching': 'Launching your future...',
      'splash_secure_verified': 'SECURE & VERIFIED JOBS',

      // Login
      'login_title': 'Rozgar Adda',
      'login_welcome_back': 'Welcome Back',
      'login_subtitle': 'Enter your credentials to access your job portal',
      'login_email_label': 'Email Address',
      'login_email_hint': 'name@company.com',
      'login_password_label': 'Password',
      'login_forgot': 'Forgot?',
      'login_button': 'Login',
      'login_no_account': 'Don\'t have an account? ',
      'login_register': 'Register',
      'login_error_title': 'Login Failed',
      'login_error_empty': 'Please enter username and password.',

      // Registration
      'registration_progress': 'Registration Progress',
      'registration_step': 'Step 1 of 3',
      'registration_personal_info': 'Personal Info',
      'registration_full_name': 'Full Name',
      'registration_full_name_hint': 'Enter your full name',
      'registration_phone_number': 'Phone Number',
      'registration_email': 'Email Address',
      'registration_email_hint': 'name@example.com',
      'registration_address_details': 'Address Details',
      'registration_state': 'State',
      'registration_select_state': 'Select State',
      'registration_district': 'District',
      'registration_area': 'Area / Locality',
      'registration_area_hint': 'Area',
      'registration_pincode': 'Pincode',
      'registration_pincode_hint': '000000',
      'registration_full_address': 'Full Address',
      'registration_full_address_hint': 'House no, Street name...',
      'registration_identity_verification': 'Identity Verification',
      'registration_account_credentials': 'Account Credentials',
      'registration_username': 'Username',
      'registration_username_hint': 'Choose a unique username',
      'registration_password': 'Password',
      'registration_terms_prefix': 'I agree to the ',
      'registration_terms_link': 'Terms & Conditions',
      'registration_create_account': 'Create Account',
      'registration_already_account': 'Already have an account? ',
      'registration_login': 'Log In',
      'registration_join_tagline': 'Join the Workforce',
      'registration_verify_otp': 'Verify OTP',
      'registration_send_otp': 'Send OTP',
      'registration_otp_hint': 'Enter 6-digit OTP sent to your phone',
      'registration_otp_resend': 'Resend OTP',
      'registration_otp_resend_in': 'Resend in',
      'registration_otp_resend_sec': 's',
      'registration_phone_verified': '✓ Verified',
      'registration_error_otp_phone': 'Please enter a valid 10-digit phone number.',
      'registration_error_otp_incomplete': 'Please enter the complete 6-digit OTP.',
      'registration_otp_sent_success': 'OTP sent to your number!',
      'registration_otp_verify_success': 'Phone verified successfully!',
      'registration_error_fields': 'Please fill all required fields.',
      'registration_error_state': 'Please select a state.',
      'registration_error_district': 'Please select a district.',
      'registration_error_terms': 'Please accept Terms and Privacy Policy to continue.',
      'registration_error_phone_verify': 'Please verify your phone number first.',

      'registration_upload_title': 'Upload Identity Proof',
      'registration_upload_hint': 'Aadhar Card, PAN, or Voter ID (JPG/PDF, max 2MB)',
      'registration_choose_file': 'Choose File',
      'registration_password_hint': 'Min 8 characters',
      'registration_terms_privacy': 'Privacy Policy',
      'registration_terms_and': ' and ',
      'registration_terms_suffix': ' of Rozgar Adda.',
      'select_state_appbar': 'Select State / राज्य चुनें',
      'select_state_step_label': 'STEP 2 OF 3',
      'select_state_progress': '66% Complete',
      'select_state_heading': 'Where are you looking for jobs?',
      'select_state_subheading':
          'Choose your state to see the best local opportunities tailored for you',
      'select_state_search_hint': 'Search state name...',

      // Language dialog
      'language_dialog_title': 'Select Language',
      'language_dialog_message':
          'Choose your preferred app language. You can change it anytime later.',
      'language_english': 'English',
      'language_hindi': 'Hindi',

      // Home / navigation
      'nav_home': 'HOME',
      'nav_explore': 'EXPLORE',
      'nav_saved': 'SAVED',
      'nav_profile': 'PROFILE',

      // Explore careers / job categories
      'explore_careers_title': 'Explore Careers',
      'explore_job_categories': 'Job Categories',
      'explore_job_categories_subtitle':
          'Find the perfect role across various industries',
      'explore_opportunities_pill': 'OPPORTUNITIES',
      'explore_custom_search': 'Custom Search',
      'explore_custom_search_sub': 'Find roles based on your skills',

      // Career hub / job list
      'careerhub_title': 'CareerHub',
      'careerhub_search_hint': 'Search for jobs, companies...',
      'careerhub_tab_all': 'All Jobs',
      'careerhub_tab_remote': 'Remote',
      'careerhub_tab_fulltime': 'Full-time',
      'careerhub_tab_salary': 'Salary',

      // Job detail
      'jobdetail_appbar_title': 'Job Opportunity',
      'jobdetail_annual_salary': 'ANNUAL SALARY',
      'jobdetail_experience': 'EXPERIENCE',
      'jobdetail_applicants': 'APPLICANTS',
      'jobdetail_role_description': 'Role Description',
      'jobdetail_requirements': 'Requirements',
      'jobdetail_location': 'Location',
      'jobdetail_apply_now': 'Apply Now',

      // Job application form
      'apply_header_title': 'Senior Product Designer',
      'apply_step_label': 'STEP 2 OF 4:\nEXPERIENCE',
      'apply_complete': 'Complete',
      'apply_personal_info': 'Personal Information',
      'apply_first_name': 'First Name',
      'apply_last_name': 'Last Name',
      'apply_email': 'Email Address',
      'apply_professional_details': 'Professional Details',
      'apply_current_position': 'Current Position',
      'apply_linkedin': 'LinkedIn Profile',
      'apply_resume_upload': 'Resume Upload',
      'apply_upload_cta': 'Click to upload or drag and drop',
      'apply_upload_hint': 'Max file size 10MB • PDF or DOCX',
      'apply_why_hire': 'Why should we hire you?',
      'apply_why_hire_hint':
          'Tell us briefly about your experience and why you are a great fit for this role.',
      'apply_agree':
          'I agree to share my application details with the employer.',
      'apply_submit': 'Submit Application',
      'apply_footer':
          'By submitting, you agree to our privacy policy and terms.',
      'dashboard_search_hint': 'Search for jobs, companies...',
      'dashboard_quick_links': 'Quick Links',
      'dashboard_new_job_badge': 'NEW JOB',
      'dashboard_recent_activity': 'Recent Activity',
      'dashboard_location': 'Jaipur, Rajasthan',
      'find_jobs': 'Find Jobs',
      'kyc_status': 'KYC Status',
      'sell_products': 'Sell Products',
      'marketplace': 'Marketplace',
      'earnings': 'Earnings',
      'support': 'Support',
      'news': 'News',
      'missing_persons': 'Missing Persons',
      'missing_persons_coming_soon': 'Missing Persons feature coming soon!',
      'skill_up': 'Skill Up',
      'home': 'Home',
      'products': 'Products',
      'settings': 'Settings',
      'logout': 'Logout',
      'worker_kyc_verified': 'Worker • KYC Verified',
      'menu': 'MENU',
      'registration_success_title': 'Registration Successful',
      'registration_success_message': 'You registered successfully with this email: ',

      // Profile screen
      'profile_my_profile': 'My Profile',
      'profile_id_label': 'ID',
      'profile_edit_profile': 'Edit Profile',
      'profile_kyc_status': 'KYC Status',
      'profile_my_products': 'My Products',
      'profile_my_applications': 'My Applications',
      'profile_change_password': 'Change Password',
      'profile_help_support': 'Help & Support',
      'logout_confirm_title': 'Logout',
      'logout_confirm_message': 'Are you sure you want to logout?',

      // Splash menu
      'splash_menu_home': 'Home Screen',
      'splash_menu_about': 'About Us',
      'splash_menu_missing': 'Missing',
      'splash_menu_news': 'News',
      'splash_menu_product': 'Product',
      'splash_menu_register': 'Candidate Register',
      'splash_menu_login': 'Candidate Login',

      // Login extras
      'login_terms_agree': 'I agree to Terms of Service and Privacy Policy.',
      'login_terms_error': 'Please accept Terms and Privacy Policy to continue.',
      'login_or_continue': 'OR CONTINUE WITH',
      'login_sign_in': 'Sign In',
      'login_error_generic': 'Something went wrong. Please try again.',

      // KYC screen
      'kyc_title': 'Edit KYC Details',
      'kyc_subtitle': 'Update your KYC information',
      'kyc_subtitle_id': 'Update your KYC information for candidate #',
      'kyc_status_pending': 'STATUS: PENDING',
      'kyc_section_personal': 'Personal Information',
      'kyc_section_address': 'Address Information',
      'kyc_section_documents': 'Documents Upload',
      'kyc_docs_hint': 'Upload clear, readable copies. Supported: JPG, PNG, PDF, DOC',
      'kyc_field_full_name': 'Full Name',
      'kyc_field_phone': 'Phone Number',
      'kyc_field_email': 'Email Address',
      'kyc_field_state': 'State',
      'kyc_field_district': 'District',
      'kyc_field_locality': 'Locality/Area',
      'kyc_field_pincode': 'Pincode',
      'kyc_field_address': 'Complete Address',
      'kyc_address_hint': 'Flat No, Building, Street...',
      'kyc_identity_title': 'Identity Proof',
      'kyc_identity_subtitle': 'Aadhar, PAN or Passport',
      'kyc_resume_title': 'Resume / CV',
      'kyc_resume_subtitle': 'PDF or Word format',
      'kyc_photo_title': 'Profile Photo',
      'kyc_photo_subtitle': 'Recent passport size photo',
      'kyc_update_button': 'Update KYC',
      'kyc_image_source_title': 'Select Image Source',
      'kyc_source_camera': 'Camera',
      'kyc_source_gallery': 'Gallery',
      'kyc_snack_photo_uploaded': 'Photo uploaded successfully!',
      'kyc_snack_doc_uploaded': 'Document uploaded successfully!',
      'kyc_snack_file_removed': 'File removed.',
      'kyc_snack_missing_docs': 'Please upload all required documents.',
      'kyc_snack_missing_fields': 'Please fill all required fields.',
      'kyc_snack_invalid_phone': 'Please enter a valid 10-digit phone number.',
      'kyc_snack_invalid_pin': 'Please enter a valid 6-digit pincode.',
      'kyc_snack_invalid_email': 'Please enter a valid email address.',
      'kyc_snack_no_candidate': 'Candidate ID not found. Please login again.',
      'kyc_snack_updated': 'KYC updated successfully',
      'kyc_snack_failed': 'Failed to update KYC. Please try again.',
      'kyc_snack_error': 'Something went wrong while updating KYC. Please check your connection.',
      'kyc_upload_label': 'UPLOAD',

      // News screen
      'news_title': 'Rozgar News',
      'news_trending_now': 'TRENDING NOW',
      'news_header_title': 'Career Insights for the\nModern Workforce',
      'news_read_more': 'Read More ',
      'news_mins_read': '5 MINS READ',
      'news_tab_all': 'All News',
      'news_tab_articles': 'Articles',
      'news_tab_videos': 'Videos',
      'news_error_loading': 'Failed to load news feed.',
      'news_empty_list': 'No news items available.',
    },
    'mr': {
      // General / common
      'app_title': 'रोजगार अड्डा',
      'app_logo_text': 'रोजगार',
      'sidebar_username': 'राहुल शर्मा',
      'ok': 'ठीक आहे',
      'cancel': 'रद्द करा',
      'continue': 'पुढे जा',
      'back': 'मागे',
      'view_all': 'सर्व पहा',

      // Splash
      'splash_tagline': 'संधींचे तुमचे प्रवेशद्वार',
      'splash_launching': 'तुमचे भविष्य सुरू होत आहे...',
      'splash_secure_verified': 'सुरक्षित आणि सत्यापित नोकऱ्या',

      // Login
      'login_title': 'रोजगार अड्डा',
      'login_welcome_back': 'पुन्हा आपले स्वागत आहे',
      'login_subtitle':
          'तुमच्या जॉब पोर्टलवर लॉग इन करण्यासाठी तुमची माहिती प्रविष्ट करा',
      'login_email_label': 'ईमेल पत्ता',
      'login_email_hint': 'name@company.com',
      'login_password_label': 'पासवर्ड',
      'login_forgot': 'पासवर्ड विसरलात?',
      'login_button': 'लॉग इन करा',
      'login_no_account': 'खाते नाही का? ',
      'login_register': 'नोंदणी करा',
      'login_error_title': 'लॉग इन अयशस्वी',
      'login_error_empty':
          'कृपया वापरकर्तानाव (username) आणि पासवर्ड प्रविष्ट करा.',

      // Registration
      'registration_progress': 'नोंदणी प्रगती',
      'registration_step': 'टप्पा १ पैकी ३',
      'registration_personal_info': 'वैयक्तिक माहिती',
      'registration_full_name': 'पूर्ण नाव',
      'registration_full_name_hint': 'तुमचे पूर्ण नाव प्रविष्ट करा',
      'registration_phone_number': 'मोबाईल नंबर',
      'registration_email': 'ईमेल पत्ता',
      'registration_email_hint': 'name@example.com',
      'registration_address_details': 'पत्ता तपशील',
      'registration_state': 'राज्य',
      'registration_select_state': 'राज्य निवडा',
      'registration_district': 'जिल्हा',
      'registration_area': 'क्षेत्र / परिसर',
      'registration_area_hint': 'क्षेत्र',
      'registration_pincode': 'पिनकोड',
      'registration_pincode_hint': '********',
      'registration_full_address': 'पूर्ण पत्ता',
      'registration_full_address_hint': 'घर क्रमांक, गल्लीचे नाव...',
      'registration_identity_verification': 'ओळख पडताळणी',
      'registration_account_credentials': 'खात्याची माहिती',
      'registration_username': 'वापरकर्तानाव (Username)',
      'registration_username_hint': 'एक युनिक वापरकर्तानाव निवडा',
      'registration_password': 'पासवर्ड',
      'registration_terms_prefix': 'मी नियम आणि अटींशी ',
      'registration_terms_link': 'सहमत आहे',
      'registration_create_account': 'खाते तयार करा',
      'registration_already_account': 'आधीच खाते आहे का? ',
      'registration_login': 'लॉग इन करा',
      'registration_join_tagline': 'कार्यबलात सामील व्हा',
      'registration_verify_otp': 'ओटीपी सत्यापित करा',
      'registration_send_otp': 'ओटीपी पाठवा',
      'registration_otp_hint': 'फोनवर पाठवलेला 6-अंकी ओटीपी प्रविष्ट करा',
      'registration_otp_resend': 'ओटीपी पुन्हा पाठवा',
      'registration_otp_resend_in': 'पुन्हा पाठवा',
      'registration_otp_resend_sec': 'से.',
      'registration_phone_verified': '✓ सत्यापित',
      'registration_error_otp_phone': 'कृपया वैध 10-अंकी फोन नंबर प्रविष्ट करा.',
      'registration_error_otp_incomplete': 'कृपया संपूर्ण 6-अंकी ओटीपी प्रविष्ट करा.',
      'registration_otp_sent_success': 'ओटीपी तुमच्या नंबरवर पाठवला!',
      'registration_otp_verify_success': 'फोन नंबर यशस्वीरीत्या सत्यापित झाला!',
      'registration_error_fields': 'कृपया सर्व आवश्यक फील्ड भरा.',
      'registration_error_state': 'कृपया एक राज्य निवडा.',
      'registration_error_district': 'कृपया एक जिल्हा निवडा.',
      'registration_error_terms': 'कृपया पुढे जाण्यासाठी नियम आणि गोपनीयता धोरण स्वीकारा.',
      'registration_error_phone_verify': 'कृपया प्रथम तुमचा फोन नंबर सत्यापित करा.',
      'registration_upload_title': 'ओळखपत्र अपलोड करा',
      'registration_upload_hint': 'आधार कार्ड, पॅन किंवा मतदार ओळखपत्र (JPG/PDF, कमाल 2MB)',
      'registration_choose_file': 'फाइल निवडा',
      'registration_password_hint': 'किमान ८ अक्षरे',
      'registration_terms_privacy': 'गोपनीयता धोरण',
      'registration_terms_and': ' आणि ',
      'registration_terms_suffix': ' शी सहमत आहे.',

      // Select State
      'select_state_appbar': 'राज्य निवडा / Select State',
      'select_state_step_label': 'टप्पा २ पैकी ३',
      'select_state_progress': '६६% पूर्ण',
      'select_state_heading': 'तुम्ही कुठे नोकरी शोधत आहात?',
      'select_state_subheading':
          'तुमच्यासाठी खास तयार केलेल्या सर्वोत्तम स्थानिक संधी पाहण्यासाठी तुमचे राज्य निवडा',
      'select_state_search_hint': 'राज्याचे नाव शोधा...',

      // Language dialog
      'language_dialog_title': 'भाषा निवडा',
      'language_dialog_message':
          'तुमची पसंतीची ॲप भाषा निवडा. तुम्ही ती नंतर कधीही बदलू शकता.',
      'language_english': 'इंग्रजी (English)',
      'language_hindi': 'हिंदी (Hindi)',

      // Home / navigation
      'nav_home': 'मुख्यपृष्ठ',
      'nav_explore': 'शोध घ्या',
      'nav_saved': 'जतन केलेले',
      'nav_profile': 'प्रोफाइल',

      // Explore careers / job categories
      'explore_careers_title': 'करिअरचे पर्याय शोधा',
      'explore_job_categories': 'नोकरीच्या श्रेणी',
      'explore_job_categories_subtitle':
          'विविध उद्योगांमध्ये तुमच्यासाठी योग्य भूमिका शोधा',
      'explore_opportunities_pill': 'संधी',
      'explore_custom_search': 'कस्टम सर्च',
      'explore_custom_search_sub': 'तुमच्या कौशल्यांवर आधारित नोकऱ्या शोधा',

      // Career hub / job list
      'careerhub_title': 'करिअरहब (CareerHub)',
      'careerhub_search_hint': 'नोकऱ्या, कंपन्या शोधा...',
      'careerhub_tab_all': 'सर्व नोकऱ्या',
      'careerhub_tab_remote': 'रिमोट (घरून काम)',
      'careerhub_tab_fulltime': 'पूर्ण वेळ',
      'careerhub_tab_salary': 'पगार',

      // Job detail
      'jobdetail_appbar_title': 'नोकरीची संधी',
      'jobdetail_annual_salary': 'वार्षिक पगार',
      'jobdetail_experience': 'अनुभव',
      'jobdetail_applicants': 'अर्जदार',
      'jobdetail_role_description': 'भूमिकेचे वर्णन (Role Description)',
      'jobdetail_requirements': 'आवश्यकता',
      'jobdetail_location': 'ठिकाण',
      'jobdetail_apply_now': 'आता अर्ज करा',

      // Job application form
      'apply_header_title': 'सीनिअर प्रॉडक्ट डिझायनर',
      'apply_step_label': 'टप्पा २ पैकी ४:\nअनुभव',
      'apply_complete': 'पूर्ण झाले',
      'apply_personal_info': 'वैयक्तिक माहिती',
      'apply_first_name': 'पहिले नाव',
      'apply_last_name': 'आडनाव',
      'apply_email': 'ईमेल पत्ता',
      'apply_professional_details': 'व्यावसायिक तपशील',
      'apply_current_position': 'सध्याचे पद',
      'apply_linkedin': 'लिंक्डइन प्रोफाइल (LinkedIn)',
      'apply_resume_upload': 'रेझ्युमे अपलोड (Resume Upload)',
      'apply_upload_cta':
          'अपलोड करण्यासाठी क्लिक करा किंवा फाइल येथे ड्रॅग करा',
      'apply_upload_hint': 'कमाल फाइल आकार १०MB • PDF किंवा DOCX',
      'apply_why_hire': 'आम्ही तुमची निवड का करावी?',
      'apply_why_hire_hint':
          'तुमच्या अनुभवाबद्दल आणि तुम्ही या भूमिकेसाठी योग्य का आहात याबद्दल थोडक्यात सांगा.',
      'apply_agree':
          'मी माझ्या अर्जाचा तपशील नियोक्त्यासोबत (employer) शेअर करण्यास सहमत आहे.',
      'apply_submit': 'अर्ज सबमिट करा',
      'apply_footer':
          'सबमिट करून, तुम्ही आमच्या गोपनीयता धोरण आणि अटींशी सहमत आहात.',
      'dashboard_search_hint': 'नोकऱ्या, कंपन्या शोधा...',
      'dashboard_quick_links': 'त्वरित दुवे',
      'dashboard_new_job_badge': 'नवीन नोकरी',
      'dashboard_recent_activity': 'अलीकडील क्रियाकलाप',
      'dashboard_location': 'जयपूर, राजस्थान',
      'find_jobs': 'नोकऱ्या शोधा',
      'kyc_status': 'केवायसी स्थिती',
      'sell_products': 'उत्पादने विका',
      'marketplace': 'मार्केटप्लेस',
      'earnings': 'कमाई',
      'support': 'मदत व सपोर्ट',
      'news': 'बातम्या',
      'missing_persons': 'बेपत्ता व्यक्ती',
      'missing_persons_coming_soon': 'बेपत्ता व्यक्ती वैशिष्ट्य लवकरच येत आहे!',
      'skill_up': 'कौशल्यांचा विकास',
      'home': 'मुख्यपृष्ठ',
      'products': 'उत्पादने',
      'settings': 'सेटिंग्ज',
      'logout': 'लॉगआउट',
      'worker_kyc_verified': 'कामगार • केवायसी सत्यापित',
      'menu': 'मेनू',
      'registration_success_title': 'नोंदणी यशस्वी',
      'registration_success_message': 'तुम्ही या ईमेलसह यशस्वीरीत्या नोंदणी केली आहे: ',

      // Profile screen
      'profile_my_profile': 'माझी प्रोफाइल',
      'profile_id_label': 'आयडी',
      'profile_edit_profile': 'प्रोफाइल संपादित करा',
      'profile_kyc_status': 'केवायसी स्थिती',
      'profile_my_products': 'माझी उत्पादने',
      'profile_my_applications': 'माझे अर्ज',
      'profile_change_password': 'पासवर्ड बदला',
      'profile_help_support': 'मदत आणि सपोर्ट',
      'logout_confirm_title': 'लॉगआउट',
      'logout_confirm_message': 'तुम्हाला खरोखर लॉगआउट करायचे आहे का?',

      // Splash menu
      'splash_menu_home': 'मुख्य स्क्रीन',
      'splash_menu_about': 'आमच्याबद्दल',
      'splash_menu_missing': 'बेपत्ता',
      'splash_menu_news': 'बातम्या',
      'splash_menu_product': 'उत्पादन',
      'splash_menu_register': 'उमेदवार नोंदणी',
      'splash_menu_login': 'उमेदवार लॉगिन',

      // Login extras
      'login_terms_agree': 'मी सेवा अटी आणि गोपनीयता धोरणाशी सहमत आहे.',
      'login_terms_error': 'कृपया पुढे जाण्यासाठी नियम आणि गोपनीयता धोरण स्वीकारा.',
      'login_or_continue': 'किंवा यासह सुरू ठेवा',
      'login_sign_in': 'साइन इन',
      'login_error_generic': 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.',

      // KYC screen
      'kyc_title': 'केवायसी तपशील संपादित करा',
      'kyc_subtitle': 'तुमची केवायसी माहिती अद्यतनित करा',
      'kyc_subtitle_id': 'उमेदवार क्रमांकाची केवायसी माहिती अद्यतनित करा #',
      'kyc_status_pending': 'स्थिती: प्रलंबित',
      'kyc_section_personal': 'वैयक्तिक माहिती',
      'kyc_section_address': 'पत्ता माहिती',
      'kyc_section_documents': 'कागदपत्रे अपलोड',
      'kyc_docs_hint': 'स्पष्ट, वाचनीय प्रती अपलोड करा. समर्थित: JPG, PNG, PDF, DOC',
      'kyc_field_full_name': 'पूर्ण नाव',
      'kyc_field_phone': 'मोबाईल नंबर',
      'kyc_field_email': 'ईमेल पत्ता',
      'kyc_field_state': 'राज्य',
      'kyc_field_district': 'जिल्हा',
      'kyc_field_locality': 'परिसर/क्षेत्र',
      'kyc_field_pincode': 'पिनकोड',
      'kyc_field_address': 'पूर्ण पत्ता',
      'kyc_address_hint': 'फ्लॅट क्र., इमारत, रस्ता...',
      'kyc_identity_title': 'ओळखपत्र',
      'kyc_identity_subtitle': 'आधार, पॅन किंवा पासपोर्ट',
      'kyc_resume_title': 'रेझ्युमे / CV',
      'kyc_resume_subtitle': 'PDF किंवा Word स्वरूप',
      'kyc_photo_title': 'प्रोफाइल फोटो',
      'kyc_photo_subtitle': 'अलीकडील पासपोर्ट आकाराचा फोटो',
      'kyc_update_button': 'केवायसी अद्यतनित करा',
      'kyc_image_source_title': 'प्रतिमा स्रोत निवडा',
      'kyc_source_camera': 'कॅमेरा',
      'kyc_source_gallery': 'गॅलरी',
      'kyc_snack_photo_uploaded': 'फोटो यशस्वीरित्या अपलोड झाला!',
      'kyc_snack_doc_uploaded': 'दस्तऐवज यशस्वीरित्या अपलोड झाला!',
      'kyc_snack_file_removed': 'फाइल काढली.',
      'kyc_snack_missing_docs': 'कृपया सर्व आवश्यक कागदपत्रे अपलोड करा.',
      'kyc_snack_missing_fields': 'कृपया सर्व आवश्यक फील्ड भरा.',
      'kyc_snack_invalid_phone': 'कृपया वैध 10-अंकी मोबाईल नंबर प्रविष्ट करा.',
      'kyc_snack_invalid_pin': 'कृपया वैध 6-अंकी पिनकोड प्रविष्ट करा.',
      'kyc_snack_invalid_email': 'कृपया वैध ईमेल पत्ता प्रविष्ट करा.',
      'kyc_snack_no_candidate': 'उमेदवार आयडी सापडला नाही. कृपया पुन्हा लॉगिन करा.',
      'kyc_snack_updated': 'केवायसी यशस्वीरित्या अद्यतनित केले',
      'kyc_snack_failed': 'केवायसी अद्यतन करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
      'kyc_snack_error': 'केवायसी अद्यतन करताना काहीतरी चूक झाली. कृपया आपले कनेक्शन तपासा.',
      'kyc_upload_label': 'अपलोड',

      // News screen
      'news_title': 'रोजगार बातम्या',
      'news_trending_now': 'आत्ता ट्रेंडिंग',
      'news_header_title': 'आधुनिक कार्यबलासाठी\nकरिअर अंतर्दृष्टी',
      'news_read_more': 'अधिक वाचा ',
      'news_mins_read': '५ मिनिटे वाचन',
      'news_tab_all': 'सर्व बातम्या',
      'news_tab_articles': 'लेख',
      'news_tab_videos': 'व्हिडिओ',
      'news_error_loading': 'बातम्या लोड करण्यात अयशस्वी.',
      'news_empty_list': 'कोणत्याही बातम्या उपलब्ध नाहीत.',
    },
    'hi': {
      // General / common
      'app_title': 'रोज़गार अड्डा',
      'app_logo_text': 'रोज़गार',
      'sidebar_username': 'राहुल शर्मा',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'continue': 'आगे बढ़ें',
      'back': 'वापस',
      'view_all': 'सभी देखें',

      // Splash
      'splash_tagline': 'आपके अवसरों का द्वार',
      'splash_launching': 'आपका भविष्य शुरू हो रहा है...',
      'splash_secure_verified': 'सुरक्षित और सत्यापित नौकरियां',

      // Login
      'login_title': 'रोज़गार अड्डा',
      'login_welcome_back': 'दोबारा स्वागत है',
      'login_subtitle': 'अपना जॉब पोर्टल एक्सेस करने के लिए विवरण दर्ज करें',
      'login_email_label': 'ईमेल पता',
      'login_email_hint': 'name@company.com',
      'login_password_label': 'पासवर्ड',
      'login_forgot': 'भूल गए?',
      'login_button': 'लॉगिन',
      'login_no_account': 'अब तक खाता नहीं है? ',
      'login_register': 'रजिस्टर करें',
      'login_error_title': 'लॉगिन विफल',
      'login_error_empty': 'कृपया उपयोगकर्ता नाम और पासवर्ड दर्ज करें।',

      // Registration
      'registration_progress': 'पंजीकरण प्रगति',
      'registration_step': 'स्टेप 1 / 3',
      'registration_personal_info': 'व्यक्तिगत जानकारी',
      'registration_full_name': 'पूरा नाम',
      'registration_full_name_hint': 'अपना पूरा नाम दर्ज करें',
      'registration_phone_number': 'मोबाइल नंबर',
      'registration_email': 'ईमेल पता',
      'registration_email_hint': 'name@example.com',
      'registration_address_details': 'पता विवरण',
      'registration_state': 'राज्य',
      'registration_select_state': 'राज्य चुनें',
      'registration_district': 'ज़िला',
      'registration_area': 'क्षेत्र / लोकैलिटी',
      'registration_area_hint': 'क्षेत्र',
      'registration_pincode': 'पिनकोड',
      'registration_pincode_hint': '000000',
      'registration_full_address': 'पूरा पता',
      'registration_full_address_hint': 'मकान नंबर, गली का नाम...',
      'registration_identity_verification': 'पहचान सत्यापन',
      'registration_account_credentials': 'अकाउंट विवरण',
      'registration_username': 'यूज़रनेम',
      'registration_username_hint': 'एक यूनिक यूज़रनेम चुनें',
      'registration_password': 'पासवर्ड',
      'registration_terms_prefix': 'मैं ',
      'registration_terms_link': 'नियम और शर्तें',
      'registration_create_account': 'अकाउंट बनाएं',
      'registration_already_account': 'पहले से अकाउंट है? ',
      'registration_login': 'लॉगिन',
      'registration_join_tagline': 'कार्यबल में शामिल हों',
      'registration_verify_otp': 'ओटीपी सत्यापित करें',
      'registration_send_otp': 'ओटीपी भेजें',
      'registration_otp_hint': 'फ़ोन पर भेजा गया 6-अंकीय ओटीपी दर्ज करें',
      'registration_otp_resend': 'ओटीपी दोबारा भेजें',
      'registration_otp_resend_in': 'दोबारा भेजें',
      'registration_otp_resend_sec': 'सेकंड',
      'registration_phone_verified': '✓ सत्यापित',
      'registration_error_otp_phone': 'कृपया वैध 10-अंकीय फ़ोन नंबर दर्ज करें।',
      'registration_error_otp_incomplete': 'कृपया पूरा 6-अंकीय ओटीपी दर्ज करें।',
      'registration_otp_sent_success': 'ओटीपी आपके नंबर पर भेज दिया गया!',
      'registration_otp_verify_success': 'फ़ोन नंबर सफलतापूर्वक सत्यापित हो गया!',
      'registration_error_fields': 'कृपया सभी आवश्यक फ़ील्ड भरें।',
      'registration_error_state': 'कृपया एक राज्य चुनें।',
      'registration_error_district': 'कृपया एक ज़िला चुनें।',
      'registration_error_terms': 'कृपया आगे बढ़ने के लिए नियम और गोपनीयता नीति स्वीकार करें।',
      'registration_error_phone_verify': 'कृपया पहले अपना फ़ोन नंबर सत्यापित करें।',
      'registration_upload_title': 'पहचान प्रमाण अपलोड करें',
      'registration_upload_hint': 'आधार कार्ड, पैन, या मतदाता पहचान पत्र (JPG/PDF, अधिकतम 2MB)',
      'registration_choose_file': 'फ़ाइल चुनें',
      'registration_password_hint': 'कम से कम 8 वर्ण',
      'registration_terms_privacy': 'गोपनीयता नीति',
      'registration_terms_and': ' और ',
      'registration_terms_suffix': ' से सहमत हूँ।',

      // Select State
      'select_state_appbar': 'राज्य चुनें',
      'select_state_step_label': 'स्टेप 2 / 3',
      'select_state_progress': '66% पूरा',
      'select_state_heading': 'आप कहां नौकरी ढूंढ रहे हैं?',
      'select_state_subheading':
          'अपने राज्य का चयन करें ताकि आपके लिए स्थानीय अवसर दिखाए जा सकें',
      'select_state_search_hint': 'राज्य का नाम खोजें...',

      // Language dialog
      'language_dialog_title': 'भाषा चुनें',
      'language_dialog_message':
          'अपनी पसंदीदा ऐप भाषा चुनें। आप इसे बाद में भी बदल सकते हैं।',
      'language_english': 'अंग्रेज़ी',
      'language_hindi': 'हिंदी',

      // Home / navigation
      'nav_home': 'होम',
      'nav_explore': 'एक्सप्लोर',
      'nav_saved': 'सेव्ड',
      'nav_profile': 'प्रोफ़ाइल',

      // Explore careers / job categories
      'explore_careers_title': 'करियर खोजें',
      'explore_job_categories': 'जॉब कैटेगरी',
      'explore_job_categories_subtitle':
          'विभिन्न उद्योगों में सही भूमिका खोजें',
      'explore_opportunities_pill': 'अवसर',
      'explore_custom_search': 'कस्टम सर्च',
      'explore_custom_search_sub': 'अपनी स्किल के अनुसार नौकरी खोजें',

      // Career hub / job list
      'careerhub_title': 'करियर हब',
      'careerhub_search_hint': 'नौकरियां, कंपनियां खोजें...',
      'careerhub_tab_all': 'सभी नौकरियां',
      'careerhub_tab_remote': 'रिमोट',
      'careerhub_tab_fulltime': 'फुल-टाइम',
      'careerhub_tab_salary': 'सैलरी',

      // Job detail
      'jobdetail_appbar_title': 'जॉब अवसर',
      'jobdetail_annual_salary': 'वार्षिक वेतन',
      'jobdetail_experience': 'अनुभव',
      'jobdetail_applicants': 'आवेदक',
      'jobdetail_role_description': 'भूमिका विवरण',
      'jobdetail_requirements': 'आवश्यकताएँ',
      'jobdetail_location': 'स्थान',
      'jobdetail_apply_now': 'अभी आवेदन करें',

      // Job application form
      'apply_header_title': 'सीनियर प्रोडक्ट डिज़ाइनर',
      'apply_step_label': 'स्टेप 2 / 4:\nअनुभव',
      'apply_complete': 'पूरा',
      'apply_personal_info': 'व्यक्तिगत जानकारी',
      'apply_first_name': 'पहला नाम',
      'apply_last_name': 'अंतिम नाम',
      'apply_email': 'ईमेल पता',
      'apply_professional_details': 'प्रोफेशनल विवरण',
      'apply_current_position': 'वर्तमान पद',
      'apply_linkedin': 'लिंक्डइन प्रोफाइल',
      'apply_resume_upload': 'रिज़्यूमे अपलोड',
      'apply_upload_cta': 'क्लिक कर अपलोड करें या ड्रैग और ड्रॉप करें',
      'apply_upload_hint': 'अधिकतम फ़ाइल साइज़ 10MB • केवल PDF या DOCX',
      'apply_why_hire': 'हमें आपको क्यों रखना चाहिए?',
      'apply_why_hire_hint':
          'संक्षेप में हमें अपने अनुभव और इस भूमिका के लिए अपनी उपयुक्तता के बारे में बताएं।',
      'apply_agree':
          'मैं अपनी एप्लिकेशन डिटेल्स नियोक्ता के साथ साझा करने के लिए सहमत हूँ।',
      'apply_submit': 'आवेदन सबमिट करें',
      'apply_footer':
          'सबमिट करके, आप हमारी प्राइवेसी नीति और नियमों से सहमत होते हैं.',
      'dashboard_search_hint': 'नौकरियां, कंपनियां खोजें...',
      'dashboard_quick_links': 'त्वरित लिंक्स',
      'dashboard_new_job_badge': 'नई नौकरी',
      'dashboard_recent_activity': 'हाल की गतिविधि',
      'dashboard_location': 'जयपुर, राजस्थान',
      'find_jobs': 'नौकरियां खोजें',
      'kyc_status': 'केवाईसी स्थिति',
      'sell_products': 'उत्पाद बेचें',
      'marketplace': 'मार्केटप्लेस',
      'earnings': 'कमाई',
      'support': 'सहायता',
      'news': 'समाचार',
      'missing_persons': 'लापता व्यक्ति',
      'missing_persons_coming_soon': 'लापता व्यक्ति सुविधा जल्द ही आ रही है!',
      'skill_up': 'कौशल बढ़ाएं',
      'home': 'होम',
      'products': 'उत्पाद',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'worker_kyc_verified': 'श्रमिक • केवाईसी सत्यापित',
      'menu': 'मेनू',
      'registration_success_title': 'पंजीकरण सफल',
      'registration_success_message': 'आपने इस ईमेल के साथ सफलतापूर्वक पंजीकरण किया है: ',

      // Profile screen
      'profile_my_profile': 'मेरी प्रोफ़ाइल',
      'profile_id_label': 'आईडी',
      'profile_edit_profile': 'प्रोफ़ाइल संपादित करें',
      'profile_kyc_status': 'केवाईसी स्थिति',
      'profile_my_products': 'मेरे उत्पाद',
      'profile_my_applications': 'मेरे आवेदन',
      'profile_change_password': 'पासवर्ड बदलें',
      'profile_help_support': 'सहायता और सपोर्ट',
      'logout_confirm_title': 'लॉगआउट',
      'logout_confirm_message': 'क्या आप वाकई लॉगआउट करना चाहते हैं?',

      // Splash menu
      'splash_menu_home': 'होम स्क्रीन',
      'splash_menu_about': 'हमारे बारे में',
      'splash_menu_missing': 'लापता',
      'splash_menu_news': 'समाचार',
      'splash_menu_product': 'उत्पाद',
      'splash_menu_register': 'उम्मीदवार पंजीकरण',
      'splash_menu_login': 'उम्मीदवार लॉगिन',

      // Login extras
      'login_terms_agree': 'मैं सेवा की शर्तें और गोपनीयता नीति से सहमत हूँ।',
      'login_terms_error': 'कृपया आगे बढ़ने के लिए नियम और गोपनीयता नीति स्वीकार करें।',
      'login_or_continue': 'या इसके साथ जारी रखें',
      'login_sign_in': 'साइन इन',
      'login_error_generic': 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',

      // KYC screen
      'kyc_title': 'KYC विवरण संपादित करें',
      'kyc_subtitle': 'अपनी KYC जानकारी अपडेट करें',
      'kyc_subtitle_id': 'उम्मीदवार की KYC जानकारी अपडेट करें #',
      'kyc_status_pending': 'स्थिति: लंबित',
      'kyc_section_personal': 'व्यक्तिगत जानकारी',
      'kyc_section_address': 'पता जानकारी',
      'kyc_section_documents': 'दस्तावेज़ अपलोड',
      'kyc_docs_hint': 'स्पष्ट, पठनीय प्रतियाँ अपलोड करें। समर्थित: JPG, PNG, PDF, DOC',
      'kyc_field_full_name': 'पूरा नाम',
      'kyc_field_phone': 'मोबाइल नंबर',
      'kyc_field_email': 'ईमेल पता',
      'kyc_field_state': 'राज्य',
      'kyc_field_district': 'ज़िला',
      'kyc_field_locality': 'लोकैलिटी/क्षेत्र',
      'kyc_field_pincode': 'पिनकोड',
      'kyc_field_address': 'पूरा पता',
      'kyc_address_hint': 'फ्लैट नं., इमारत, गली...',
      'kyc_identity_title': 'पहचान प्रमाण',
      'kyc_identity_subtitle': 'आधार, PAN या पासपोर्ट',
      'kyc_resume_title': 'रिज़्यूमे / CV',
      'kyc_resume_subtitle': 'PDF या Word प्रारूप',
      'kyc_photo_title': 'प्रोफ़ाइल फोटो',
      'kyc_photo_subtitle': 'हालिया पासपोर्ट साइज़ फोटो',
      'kyc_update_button': 'KYC अपडेट करें',
      'kyc_image_source_title': 'छवि स्रोत चुनें',
      'kyc_source_camera': 'कैमरा',
      'kyc_source_gallery': 'गैलरी',
      'kyc_snack_photo_uploaded': 'फोटो सफलतापूर्वक अपलोड हुआ!',
      'kyc_snack_doc_uploaded': 'दस्तावेज़ सफलतापूर्वक अपलोड हुआ!',
      'kyc_snack_file_removed': 'फ़ाइल हटाई गई।',
      'kyc_snack_missing_docs': 'कृपया सभी आवश्यक दस्तावेज़ अपलोड करें।',
      'kyc_snack_missing_fields': 'कृपया सभी आवश्यक फ़ील्ड भरें।',
      'kyc_snack_invalid_phone': 'कृपया वैध 10-अंकीय मोबाइल नंबर दर्ज करें।',
      'kyc_snack_invalid_pin': 'कृपया वैध 6-अंकीय पिनकोड दर्ज करें।',
      'kyc_snack_invalid_email': 'कृपया वैध ईमेल पता दर्ज करें।',
      'kyc_snack_no_candidate': 'उम्मीदवार आईडी नहीं मिली। कृपया पुनः लॉगिन करें।',
      'kyc_snack_updated': 'KYC सफलतापूर्वक अपडेट हुई',
      'kyc_snack_failed': 'KYC अपडेट करने में विफल। कृपया पुनः प्रयास करें।',
      'kyc_snack_error': 'KYC अपडेट करते समय कुछ गलत हो गया। कृपया अपना कनेक्शन जाँचें।',
      'kyc_upload_label': 'अपलोड',

      // News screen
      'news_title': 'रोज़गार समाचार',
      'news_trending_now': 'अभी ट्रेंडिंग',
      'news_header_title': 'आधुनिक कार्यबल के लिए\nकरियर अंतर्दृष्टि',
      'news_read_more': 'और पढ़ें ',
      'news_mins_read': '५ मिनट पढ़ना',
      'news_tab_all': 'सभी समाचार',
      'news_tab_articles': 'लेख',
      'news_tab_videos': 'वीडियो',
      'news_error_loading': 'समाचार लोड करने में विफल।',
      'news_empty_list': 'कोई समाचार उपलब्ध नहीं है।',
    },
  };

  String text(String key) {
    final langCode = locale.languageCode;
    final langMap = _localizedValues[langCode] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .map((e) => e.languageCode)
      .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
