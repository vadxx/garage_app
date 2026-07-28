// Copyright (c) 2026 vadxx
// SPDX-License-Identifier: MIT

const String githubUrl = 'https://github.com/vadxx';
const String googlePlayUrl =
    'https://play.google.com/store/apps/details?id=com.vadxx.garage_app';

const String contactUsEmail = 'realvadxx@gmail.com';
const String contactUsSubject = 'Garage App Support';
String get contactUsUri =>
    'mailto:$contactUsEmail?subject=${Uri.encodeComponent(contactUsSubject)}';

const String iapDonate5 = 'donate_5';
const String iapDonate10 = 'donate_10';
const String iapDonate15 = 'donate_15';
const String iapDonate3monthly = 'donate_3_monthly';

/// All donation product IDs registered in the Play Console.
const Set<String> donationProductIds = {
  iapDonate5,
  iapDonate10,
  iapDonate15,
  iapDonate3monthly,
};
