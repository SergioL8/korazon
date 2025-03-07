const {onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");

exports.sendTestEmail = onCall(async (req, res) => {
  // Retrieve API key from environment variable (v2 method)
  const sendGridKey = process.env.SENDGRID_API_KEY;
  const sendGridTemplateId = "d-7505b8d3d4324f8893faa739eb9d2113";

  if (!sendGridKey || !sendGridKey.startsWith("SG.")) {
    logger.error("❌ No valid SendGrid API key found.");
    return res.status(500).send("No valid SendGrid API key found.");
  }

  sgMail.setApiKey(sendGridKey);

  const { recipientEmail, name, verificationLink } = request.data;

  if (!recipientEmail || !name || !verificationLink) {
    logger.error("❌ Missing required email data.");
    throw new Error("Missing required email data.");
  }

  try {
    // Create email message
    const msg = {
      to: recipientEmail,
      from: "Support@korazonapp.com", // Must be a verified sender in SendGrid
      templateId: sendGridTemplateId, // Correct SendGrid Template ID
      dynamic_template_data: {
        name: name, // Will replace {{name}} in the template
        reset_password_link: "https://korazonapp.com/verify?token=123", // Replaces {{verification_link}}
      },
    };

    // Send email
    await sgMail.send(msg);
    logger.info("✅ Email sent successfully!");
    res.status(200).send("✅ Email sent successfully!");
  } catch (error) {
    logger.error("❌ Error sending email:", error);

    // Check for detailed error response from SendGrid
    if (error.response) {
      logger.error("SendGrid Response Error:", error.response.body);
    }

    res.status(500).send(`❌ Error sending email: ${error.message}`);
  }
});
