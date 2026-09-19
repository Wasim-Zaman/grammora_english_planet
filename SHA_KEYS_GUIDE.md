# Why Your Google Sign-In Breaks When You Publish to Google Play (And How to Fix It)

### The definitive guide to understanding Android SHA fingerprints, the Google Play App Signing trap, and making Google Sign-In work across Debug, Staging, and Production.

---

![Banner](https://images.unsplash.com/photo-1607252650355-f7fd0460ccdb?auto=format&fit=crop&w=1200&q=80)
*Photo by Unsplash*

Picture this: You’ve just finished building your Flutter app. You tested **Sign in with Google** on your local emulator, and it worked flawlessly. You tested it on your physical device via USB, and it logged in in less than a second. 

Proud of your milestone, you bundle the app, upload it to the **Google Play Console** for Closed Testing, and invite your testers. 

They download the app from Google Play, tap **Sign in with Google**, and… **nothing happens**. Or worse, the app throws:

```text
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

No clear error message. Just a mysterious **Error Code 10**.

You open your Firebase Console, look at your settings, and mutter to yourself: *"Wait... my SHA-1 is already there! Why isn’t this working?!"*

If you’ve experienced this frustration, you are not alone. It is one of the most common pitfalls in Android and Flutter development. 

In this article, we’ll demystify:
1. **What SHA keys actually are** (and why Google needs them).
2. **The "Play Store Trap"** that breaks your authentication.
3. **The 3 different keys** you must manage.
4. **The step-by-step fix** to get it working in under 5 minutes.

---

## 1. What Exactly is a SHA Key?

When you build an Android application, you sign it with a cryptographic certificate contained in a **Keystore file** (like `key.jks` or `debug.keystore`).

A **SHA key** (commonly **SHA-1** and **SHA-256**) is simply a **cryptographic fingerprint** of your keystore’s public certificate. 

Think of it like this:
* Your **Package Name** (`com.yourcompany.app`) is your app’s **Name**.
* Your **SHA-1 Fingerprint** is your app’s **Unforgeable Biometric Passport**.

Anyone in the world can create an app named `com.yourcompany.app`. But **nobody** can forge your digital signature without having your private keystore file and its passwords.

---

## 2. Why Does Google Sign-In Demand a SHA Key?

Unlike web applications that authenticate using client secrets stored securely on a backend server, mobile apps run on public, untrusted devices. 

If Google allowed mobile apps to use a static secret key, an attacker could simply decompile your APK, extract your secret, and impersonate your app.

Instead, Google uses the **Android OAuth 2.0 Security Model**:

```
[User Taps "Google Sign-In"]
             │
             ▼
[Google Play Services on Phone]
  Checks calling app:
  • Package Name: com.sairatec.gep
  • Signing Certificate Hash: 91:92:68:16:F7...
             │
             ▼
[Google Auth Servers]
  Does this Package + SHA-1 combination match an authorized client?
  ├── YES ──► Issues ID Token & logs user in! 🎉
  └── NO  ──► REJECTED! Returns ApiException: 10 🛑
```

If the SHA-1 of the app running on the phone does not match what’s registered in your Firebase or Google Cloud project, Google immediately shuts down the request.

---

## 3. The 3 Keys of Android Development

Most developers assume there is only *one* keystore. In reality, your app lives across three distinct worlds:

| Key Name | Where It Lives | Purpose |
| :--- | :--- | :--- |
| **Debug Key** | Your machine (`~/.android/debug.keystore`) | Used when you run `flutter run` locally. |
| **Upload Key** | Your project repo (`gep.jks`) | Used to sign your `.aab` (App Bundle) before uploading to Play Store. |
| **Play App Signing Key** | Google's Secure Cloud | The *real* key that signs the APK your users download from Google Play. |

And that brings us to the core problem.

---

## 4. The "Play Store Trap": Why It Worked Locally but Failed in Production

When you upload your `.aab` to Google Play Console:

1. You sign it with your local **Upload Key**.
2. Google Play receives your bundle.
3. **Google Play strips your signature off the app!**
4. Google Play **re-signs the app using the Google Play App Signing Key** before distributing it to your users (even in Internal and Closed Testing!).

```
┌────────────────────────────────────────────────────────┐
│ 1. Your Computer                                      │
│    Builds .aab signed with YOUR local Upload Key       │
└──────────────────────────┬─────────────────────────────┘
                           │ Upload to Play Console
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Google Play Console                                │
│    • Strips your Upload Key                            │
│    • Re-signs with GOOGLE'S Play App Signing Key       │
└──────────────────────────┬─────────────────────────────┘
                           │ Download from Play Store
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Tester / User Device                                │
│    Runs APK signed with GOOGLE'S Play App Signing Key! │
└────────────────────────────────────────────────────────┘
```

### The "Aha!" Moment:
The SHA-1 you initially added to Firebase was your **Upload Key**. 

When you downloaded the app from Google Play, it was running with **Google’s App Signing Key**. 

Because Google’s key was not in Firebase, Google Play Services blocked the authentication.

---

## 5. How to Fix It (Step-by-Step)

To make Google Sign-In work seamlessly everywhere, you must register **both** your local keys and your Google Play key.

### Step 1: Get the Google Play App Signing Key

1. Go to the **[Google Play Console](https://play.google.com/console)** and select your app.
2. In the left menu, navigate to **Protected with Play** *(or **App integrity** in older console layouts)*.
3. Find **Play Store protection** and click the expand arrow (`∨`).
4. Click **Manage Play app signing** (or **App signing**).
5. Look for the **App signing key** section:
   * Copy the **SHA-1 certificate fingerprint** under the **Classical key** column.
   * Copy the **SHA-256 certificate fingerprint**.

> 💡 **Tip:** If you see a row titled **"Previous app signing keys"**, click the three dots (`⋮`) and grab that SHA-1 as well just in case!

---

### Step 2: Get Your Local Keystore Fingerprints

Open your terminal in your project's `android/` directory and run:

```bash
# For your production upload keystore:
keytool -list -v -keystore app/gep.jks -alias gep

# For your local debug keystore (for development):
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

*(Alternatively, you can simply run `./gradlew signingReport` inside your `android` folder).*

---

### Step 3: Add All Fingerprints to Firebase

1. Open your **[Firebase Console](https://console.firebase.google.com/)**.
2. Click the ⚙️ **Gear icon** &rarr; **Project settings**.
3. Under the **General** tab, scroll down to **Your apps** and select your Android app.
4. Click **Add fingerprint**.
5. Add all three pairs:
   - ✅ **Google Play App Signing SHA-1 & SHA-256** *(Fixes Google Play / Closed Testing)*
   - ✅ **Local Upload Keystore SHA-1 & SHA-256** *(For builds installed directly via APK)*
   - ✅ **Local Debug Keystore SHA-1 & SHA-256** *(For local `flutter run` debugging)*

---

### Step 4: The 10-Minute Rule ⏱️

Here is a detail that trips up many developers:

> **Do NOT expect it to work instantly.**

When you save a SHA fingerprint in Firebase, Google's backend has to sync your new OAuth 2.0 Client ID across all its global authentication servers. 

**Wait 5 to 10 minutes** before testing. You do **not** need to re-upload or rebuild your app bundle—this is an entirely server-side permission update!

---

## 6. Quick Troubleshooting Checklist

If you've followed all the steps above and Google Sign-In is still giving you a headache, verify these four things:

- [ ] **Support Email**: Open Firebase Console &rarr; Project settings &rarr; General. Ensure **Support email** is selected. If this is empty, Google Sign-In fails silently.
- [ ] **Google Provider Enabled**: Go to Firebase &rarr; Authentication &rarr; Sign-in method, and ensure **Google** is enabled.
- [ ] **Clear App Storage**: On your test device, go to *Settings &rarr; Apps &rarr; Your App &rarr; Storage &rarr; Clear Data* to clear any cached failed auth tokens.
- [ ] **Update `google-services.json`**: While SHA-1 changes are handled server-side, it is always best practice to re-download the latest `google-services.json` and drop it into `android/app/`.

---

## Summary

Whenever Google Sign-In breaks between your computer and the Play Store, remember:

> **Different environment = Different signing key = Different SHA-1.**

Register your **Debug Key**, your **Upload Key**, and your **Google Play App Signing Key** in Firebase, and your authentication will work without a hitch across every stage of your app's journey.

---

*Did this article save you hours of debugging? Give it a few claps 👏 and share it with fellow developers!*
