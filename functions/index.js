const {onCall} = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
require("dotenv").config();
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY_TEST");

admin.initializeApp();
const sendGridVerifyEmailTemplateId = "d-3ee8b7adca1c445087e9200176f5bde2";
const sendGridResetPasswordTemplateId = "d-7505b8d3d4324f8893faa739eb9d2113";

exports.ResetPasswordEmail = onCall(async (req) => {
  try {
    // Retrieve API key from environment variables
    const sendGridKey = process.env.SENDGRID_API_KEY;
    if (!sendGridKey || !sendGridKey.startsWith("SG.")) {
      logger.error("❌ No valid SendGrid API key found.");
      throw new Error("No valid SendGrid API key found.");
    }

    sgMail.setApiKey(sendGridKey);

    // Extract recipient email from request data
    const {recipientEmail} = req.data;

    if (!recipientEmail) {
      logger.error("❌ Missing required email data.");
      throw new Error("Missing required email data.");
    }

    logger.info(`📩 Processing email request for: ${recipientEmail}`);

    // Step 1: Retrieve user's display name
    let displayName = recipientEmail;
    try {
      const userRecord = await admin.auth().getUserByEmail(recipientEmail);
      displayName = userRecord.displayName || recipientEmail;
      logger.info(`👤 User found: ${displayName}`);
    } catch (authError) {
      logger.warn(`⚠️ User not found in Firebase Auth: ${authError.message}`);
      // Continue execution even if user is not found
    }

    // Step 2: Generate a Firebase reset password link
    let resetPasswordLink;
    try {
      resetPasswordLink = await admin.auth().generatePasswordResetLink(recipientEmail);
      logger.info("🔗 Password reset link generated successfully: ${resetLinkError.message} ");
    } catch (resetLinkError) {
      logger.error(
          `❌ Failed to generate password reset link: ${resetLinkError.message}`,
      );
      throw new Error("Failed to generate password reset link.");
    }

    // Step 3: Prepare and send email via SendGrid
    const msg = {
      to: recipientEmail,
      from: "korazon@korazonapp.com",
      name: "Korazon",
      templateId: sendGridResetPasswordTemplateId,
      subject: "Reset Your Password - Korazon", // Dynamic subject
      dynamic_template_data: {
        subject: "Reset Password - Korazon",
        headerText: "Reset Your Password", // New header variable
        body1:
          "We've received a request to reset your password. " +
          "Click the button below to continue.",
        body2:
          "If you didn't request to change your password, " +
          "please ignore this email.",
        actionLink: resetPasswordLink, // Replace with actual reset link
        buttonText: "Reset Password", // New button text variable
      },
    };

    try {
      await sgMail.send(msg);
      logger.info("✅ Reset password email sent successfully!");
      return {
        success: true,
        message: "✅ Email sent successfully!",
      };
    } catch (sendGridError) {
      logger.error("❌ Failed to send email:", sendGridError.message);
      if (sendGridError.response) {
        logger.error("SendGrid Response Error:", sendGridError.response.body);
      }
      throw new Error("Failed to send email.");
    }
  } catch (error) {
    logger.error(`🔥 Fatal error in function: ${error.message}`);
    return {
      success: false,
      error: `❌ Error: ${error.message}`,
    };
  }
});

exports.VerificationEmail = onCall(async (req) => {
  try {
    // Retrieve API key from environment variables
    const sendGridKey = process.env.SENDGRID_API_KEY;
    if (!sendGridKey || !sendGridKey.startsWith("SG.")) {
      logger.error("❌ No valid SendGrid API key found.");
      throw new Error("No valid SendGrid API key found.");
    }

    sgMail.setApiKey(sendGridKey);

    // Extract recipient email from request data
    const { recipientEmail, verificationCode } = req.data;


    if (!recipientEmail) {
      logger.error("❌ Missing required email data.");
      throw new Error("Missing required email data.");
    }

    logger.info(`📩 Processing email request for: ${recipientEmail}`);

    // Step 1: Retrieve user's display name
    let displayName = recipientEmail;
    try {
      const userRecord = await admin.auth().getUserByEmail(recipientEmail);
      displayName = userRecord.displayName || recipientEmail;
      logger.info(`👤 User found: ${displayName}`);
    } catch (authError) {
      logger.warn(`⚠️ User not found in Firebase Auth: ${authError.message}`);
      // Continue execution even if user is not found
    }

    // Step 2: Generate a Firebase email verification link
    //let verifyEmailLink;
    const actionCodeSettings = {
      url: `https://korazonapp.com/verify?email=${encodeURIComponent(recipientEmail)}`,
      handleCodeInApp: true,
      // You can optionally add platform-specific settings:
      // iOS: { bundleId: 'com.yourapp.ios' },
      // android: { packageName: 'com.yourapp.android',
      // installApp: true, minimumVersion: '12' },
      // dynamicLinkDomain: 'yourcustom.page.link',
    };

    try {
      verifyEmailLink = await admin
          .auth()
          .generateEmailVerificationLink(recipientEmail, actionCodeSettings);
      logger.info("🔗 Email verification link generated successfully.");
    } catch (resetLinkError) {
      logger.error(
          `❌ ERROR WITH VERIFICATION LINK: ${resetLinkError.message}`,
      );
      throw new Error("Failed to generate email verification link.");
    }

    // Step 3: Prepare and send email via SendGrid
    const msg = {
      to: recipientEmail,
      from: "korazon@korazonapp.com",
      name: "Korazon",
      templateId: sendGridVerifyEmailTemplateId,
      subject: "Verify Your Email - Korazon", // Dynamic subject
      dynamic_template_data: {
        subject: "Verify Your Email - Korazon",
        headerText: "Verify Your Email",
        body1: `We've received a request to verify your email. Your code is: ${verificationCode}`,
        body2: "Your Korazon account is almost ready.",
        //buttonText: "Verify Email",
      }
    };

    try {
      await sgMail.send(msg);
      logger.info("✅ Verification email sent successfully!");
      return {
        success: true,
        message: "✅ Verification Email sent successfully!",
      };
    } catch (sendGridError) {
      logger.error("❌ Failed to send email:", sendGridError.message);
      if (sendGridError.response) {
        logger.error("SendGrid Response Error:", sendGridError.response.body);
      }
      throw new Error("Failed to send email.");
    }
  } catch (error) {
    logger.error(`🔥 Fatal error in function: ${error.message}`);
    return {
      success: false,
      error: `❌ Error: ${error.message}`,
    };
  }
});

exports.verifyUserEmailManuallyHttp = functions.https.onRequest(async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    const uid = decoded.uid;
    const email = decoded.email;

    await admin.auth().updateUser(uid, {
      emailVerified: true,
    });

    await admin.firestore().collection('users').doc(uid).set({
      verified: true,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    res.status(200).json({ success: true, message: `✅ Email for ${email} marked as verified.` });
  } catch (error) {
    console.error('❌ Error verifying user manually via HTTP:', error);
    res.status(500).json({ error: error.message });
  }
});


exports.createTicketPaymentIntent = functions.https.onRequest( {secrets: [stripeSecretKey],}, async (req, res) => {

  // Verify it's a POST request
  if (req.method !== 'POST') {
    return res.status(405).send({ error: 'Method not allowed' });
  }

  // Import the stripe SDK and pass the secret key to it to create a Stripe object
  const stripe = require("stripe")(stripeSecretKey.value());

  try {
    const {
      amount, // Total amount (user pays)
      korazonCut, // Korazon's cut
      stripeConnectedAccountId, // Frat's stripe account ID
      currency = 'usd',
      ticketID,
      attendeeUID,
      hostUID,
    } = req.body;

    const metadata = {
      attendeeUID: attendeeUID,
      ticketID: ticketID,
      hostID: hostUID
    };

    // Check user has a verified email
    const attendeeUser = await admin.auth().getUser(attendeeUID);
    if (!attendeeUser.emailVerified) {
      return res.status(403).send({ error: 'User must verify their email before purchasing a ticket.' });
    }

    // Check host as identityVerified
    const hostDoc = await admin.firestore().collection('users').doc(hostUID).get();
    if (!hostDoc.exists || !hostDoc.data().hostIdentityVerified) {
      return res.status(403).send({ error: 'Frat must complete identity verification before receiving payments.' });
    }

    if (
      typeof amount !== 'number' || amount <= 50 || // 50 cents
      typeof korazonCut !== 'number' || korazonCut < 0 ||
      typeof stripeConnectedAccountId !== 'string' || !stripeConnectedAccountId.startsWith('acct_')
    ) {
      return res.status(400).send({ error: 'Invalid or missing payment parameters.' });
    }

    // Create the PaymentIntent with transfer to connected account
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      payment_method_types: ['card', 'link'], // card includes apple pay and google pay if configured
      application_fee_amount: korazonCut,
      transfer_data: {
        destination: stripeConnectedAccountId,
      },
      metadata,
    });

    // Return clientSecret to app
    return res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });

  } catch (error) {
    console.error('❌ Stripe PaymentIntent creation failed:', error);
    return res.status(500).send({ error: error.message });
  }
});