# auropay_flutter

This repository contains sample application for Flutter to demonstrates how to integrate AuroPay payments plugin in your application.

## Getting Started

# Prerequisite
- You should be onboarded on AuroPay merchant portal.
- You can get your sub domain id, accessKey, secretKey from AuroPay merchant portal.

# Demo Project Setup
- Clone the repository.

- Add dependency 'auropay_payments:' in pubspac.yamal file and run flutter pub get in terminal.

- If you find any errors then in terminal run flutter clean and flutter pub get again.

- Replace the placeholder values of subdomain id, accessKey and secretKey with your detail in AuroPayBuilder initializer.

# implementation

```dart
final builder = AuropayBuilder(
    subDomainId: keys.merchantId, // your merchant domain name
    accessKey: keys.accessKey, // your access key
    secretKey: keys.secretKey, // your secret key
    customerProfile: customerProfile)
        .setAutoContrast(true) // color theme setup for appbar
        .setCountry(Country.IN)
        .setShowReceipt(true)
        .askForCustomerDetail(false)
        .getDetailedResponse(false)
        .build();
```
# About AuroPay Payments SDK
AuroPay Payments flutter plugin allows you to accept in-app payments by providing you with the building blocks you need to create a checkout experience.