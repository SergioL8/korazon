const {onCall} = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
require("dotenv").config(); // Add this at the top

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
      return {
        success: false,
        message: "❌ User not found",
        userNotFound: true, 
      };    }

    // Step 2: Generate a Firebase reset password link
    let resetPasswordLink;
    try {
      resetPasswordLink = await admin.auth().generatePasswordResetLink(recipientEmail);
      logger.info("🔗 Password reset link generated successfully");
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
        userNotFound: false,
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
      userNotFound: false, // or null, if you want to signal "not relevant"
    };
  }
});

exports.VerificationEmail = onCall(async (req) => {
  try {
    // ✅ Load SendGrid API Key
    const sendGridKey = process.env.SENDGRID_API_KEY;
    if (!sendGridKey || !sendGridKey.startsWith("SG.")) {
      logger.error("❌ No valid SendGrid API key found.");
      throw new Error("No valid SendGrid API key found.");
    }
    sgMail.setApiKey(sendGridKey);

    // ✅ Extract data from request
if (!req.data || !req.data.recipientEmail || !req.data.code) {
  logger.error("❌ Missing required email data.");
  throw new Error("Missing required email data.");
}

const { recipientEmail, code, isEmailVerification } = req.data;


    logger.info(`📩 Processing email request for: ${recipientEmail}`);

    // ✅ Try to get user's display name
    let displayName = recipientEmail;
    try {
      const userRecord = await admin.auth().getUserByEmail(recipientEmail);
      displayName = userRecord.displayName || recipientEmail;
      logger.info(`👤 User found: ${displayName}`);
    } catch (authError) {
      logger.warn(`⚠️ User not found in Firebase Auth: ${authError.message}`);
      // Not critical — continue
    }

    // ✅ Generate verification link if this is an email verification email
    let verifyEmailLink = null;
    if (isEmailVerification) {
      const actionCodeSettings = {
        url: `https://korazonapp.com/verify?email=${encodeURIComponent(recipientEmail)}`,
        handleCodeInApp: true,
      };
      try {
        verifyEmailLink = await admin.auth().generateEmailVerificationLink(recipientEmail, actionCodeSettings);
        logger.info("🔗 Email verification link generated successfully.");
      } catch (resetLinkError) {
        logger.error(`❌ ERROR WITH VERIFICATION LINK: ${resetLinkError.message}`);
        throw new Error("Failed to generate email verification link.");
      }
    }

    // ✅ Prepare email
    let msg;
    if (isEmailVerification) {
      msg = {
        to: recipientEmail,
        from: "korazon@korazonapp.com",
        name: "Korazon",
        templateId: sendGridVerifyEmailTemplateId,
        subject: "Verify Your Email - Korazon",
        dynamic_template_data: {
          subject: "Verify Your Email - Korazon",
          body1: "We’ve received a request to verify your email. Your code is:",
          code: code,
          body2: "Your Korazon account is almost ready. Use the code above to complete setup.",
        },
      };
    } else {
      msg = {
        to: "korazon.dev@gmail.com",
        from: "korazon@korazonapp.com",
        name: "Korazon",
        templateId: sendGridVerifyEmailTemplateId,
        subject: "New Frat Code - Korazon",
        dynamic_template_data: {
          subject: "Here is the New Frat Verification Code - Korazon",
          body1: "Use this code to verify the next frat",
          code: code,
          body2: "",
        },
      };
    }

    // ✅ Send the email
    await sgMail.send(msg);
    logger.info("✅ Verification email sent successfully!");
    return {
      success: true,
      message: "✅ Verification Email sent successfully!",
    };

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


