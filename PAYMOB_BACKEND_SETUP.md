# Paymob Payment Integration - Backend Configuration

## Overview

This document describes how the backend should be configured to support the deep linking payment flow.

## Deep Link URL Scheme

The app uses the custom URL scheme: `myapp://`

### Callback URLs:

- **Success**: `myapp://payment-success`
- **Failure**: `myapp://payment-failed`
- **Pending**: `myapp://payment-pending`

## Backend Implementation

### 1. Paymob Integration Request

When creating a payment request to Paymob, you MUST include the `redirect_url` parameter:

```json
{
  "auth_token": "YOUR_AUTH_TOKEN",
  "delivery_needed": "false",
  "amount_cents": 10000,
  "currency": "EGP",
  "items": [],
  "merchant_order_id": 12345,
  "redirect_url": "https://your-backend.com/payment/callback"
}
```

### 2. Backend Callback Handler

Your backend should handle Paymob's callback and redirect to the app:

```javascript
// Node.js/Express example
app.get('/payment/callback', async (req, res) => {
  const { transaction_id, success, pending } = req.query;
  
  // Verify transaction with Paymob
  const transaction = await verifyPaymobTransaction(transaction_id);
  
  if (success === 'true') {
    // Update user's wallet balance
    await updateWalletBalance(transaction.user_id, transaction.amount);
    
    // Redirect to app with success
    return res.redirect('myapp://payment-success?transaction_id=' + transaction_id);
  } else if (pending === 'true') {
    // Payment is pending
    return res.redirect('myapp://payment-pending?transaction_id=' + transaction_id);
  } else {
    // Payment failed
    return res.redirect('myapp://payment-failed?transaction_id=' + transaction_id);
  }
});
```

### 3. API Response Format

Your deposit endpoint should return:

```json
{
  "success": true,
  "data": {
    "url": "https://accept.paymob.com/api/acceptance/iframes/33333?payment_token=...",
    "transaction_id": "12345",
    "amount": 100.00,
    "currency": "EGP"
  }
}
```

### 4. URL Construction (if needed)

If Paymob doesn't provide a direct URL, construct it:

```javascript
const getPaymobIframeUrl = (iframeId, paymentToken) => {
  return `https://accept.paymob.com/api/acceptance/iframes/${iframeId}?payment_token=${paymentToken}`;
};
```

## Environment Variables

```bash
# .env file
PAYMOB_API_KEY=your_api_key
PAYMOB_IFRAME_ID=33333
PAYMOB_INTEGRATION_ID=12345
APP_REDIRECT_SCHEME=myapp
APP_SUCCESS_URL=myapp://payment-success
APP_FAILED_URL=myapp://payment-failed
```

## Testing Deep Links

### Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "myapp://payment-success"
```

### iOS:
```bash
xcrun simctl openurl booted "myapp://payment-success"
```

## Important Notes

1. **Always verify transactions** server-side before updating wallet balance
2. **Never trust** client-side success callbacks alone
3. **Implement idempotency** to prevent duplicate wallet updates
4. **Use HTTPS** for all redirect URLs in production
5. **Test thoroughly** on both Android and iOS before release

## Security Considerations

1. Validate the `hmac` parameter from Paymob callbacks
2. Check transaction amount matches the expected amount
3. Verify transaction hasn't been processed before
4. Use secure random tokens for merchant_order_id
5. Implement rate limiting on payment endpoints

## Flutter App Configuration

The app is already configured with:

### AndroidManifest.xml
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="myapp" android:host="payment-success"/>
</intent-filter>
```

### iOS Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

## Support

For issues or questions:
1. Check Paymob documentation: https://docs.paymob.com
2. Verify callback URLs are properly set
3. Test deep links manually using adb/xcrun commands
4. Check app logs for deep link handling
