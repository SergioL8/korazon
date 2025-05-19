const {onCall} = require("firebase-functions/v2/https");
// const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
require("dotenv").config(); // Add this at the top

admin.initializeApp();
const sendGridTemplateId = "d-3ee8b7adca1c445087e9200176f5bde2";

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
      resetPasswordLink = await admin.auth().generatePasswordResetLink(
      );
      logger.info("🔗 Password reset link generated successfully.");
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
      templateId: sendGridTemplateId,
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
    let verifyEmailLink;
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
      from: "no-reply@korazonapp.com",
      name: "Korazon",
      templateId: sendGridTemplateId,
      subject: "",//"Verify Your Email - Korazon", // Dynamic subject
      dynamic_template_data: {
        subject: "Verify Your Email - Korazon",
        headerText: "Verify Your Email", // New header variable
        body1:
          "We've received a request to verify your email. " +
          "Your code is: ${verificationCode}",
        body2: "Your Korazon account is almost ready.",
        //actionLink: verifyEmailLink, // The verification link generated above
        buttonText: "Verify Email", // New button text variable
      },
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

