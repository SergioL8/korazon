const {onCall} = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
require("dotenv").config();
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY_TEST");
const stripeSigningSecret = defineSecret("STRIPE_SIGNING_SECRET_TEST");

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
      eventID,
      hostUID,
    } = req.body;

    const metadata = {
      eventID: eventID,
      ticketID: ticketID,
      attendeeUID: attendeeUID,
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
    console.log('In create payment intent, metadata passed: ', metadata)

    // Return clientSecret to app
    return res.status(200).send({
      clientSecret: paymentIntent.client_secret,
    });

  } catch (error) {
    console.error('❌ Stripe PaymentIntent creation failed:', error);
    return res.status(500).send({ error: error.message });
  }
});



// functions/index.js  (add near the bottom)

// Import helpers once at top of file (if not already):
// const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY_TEST);
// Store Signing Secret in Functions environment or Secret Manager

/**
 * Stripe Webhook – receives POSTs from Stripe,
 * verifies the signature, and gives us the event JSON.
 *
 * NOTE: do *not* add body-parsing middleware here;
 * Firebase provides rawBody automatically.
 */
exports.stripeWebhook = functions.https.onRequest(
  { secrets: [stripeSecretKey, stripeSigningSecret] },
  async (req, res) => {
    const stripe = require('stripe')(stripeSecretKey.value());
    const signingSecret = stripeSigningSecret.value();
  // 1. Only accept POST
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  let event; // initialize the verified Stripe event object
  const sig = req.headers['stripe-signature']; // get the stripe signature

  try {
    // 2.Convert athen untrusted HTTP POST into a verified, typed Stripe event 
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sig,
      signingSecret
    );
  } catch (err) {
    console.error('⚠️  Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // At this point `event` is trusted JSON from Stripe
  console.log(`✅ Received ${event.type} for ${event.id}`);

  switch(event.type) {
    // ────────── Payment succeeded ──────────
    case 'payment_intent.succeeded': {
      const paymentIntent = event.data.object; 

      // Check that metadata was attached when the PaymentIntent was created
      const { eventID, ticketID, attendeeUID } = paymentIntent.metadata || {};
      if (!eventID || !ticketID || !attendeeUID) {
        console.log('Metadata: ', paymentIntent.metadata)
        logger.error('❌ Missing metadata on payment_intent.succeeded');
        break;
      }

      // Docuemnts of event and user that will be be updated in the trasaction
      const eventRef = admin.firestore().collection('events').doc(eventID);
      const userRef  = admin.firestore().collection('users').doc(attendeeUID);

      // run transaction
      await admin.firestore().runTransaction(async (tx) => {
        
        // Get the event document and check it was loaded correctly
        const snap = await tx.get(eventRef);
        if (!snap.exists) throw new Error('Event missing during finalize.');

        // Get the document data and check that the tickets array exists
        const data = snap.data();
        if (!data || !Array.isArray(data.tickets)) {
          throw new Error('Tickets missing during finalize.');
        }

        const tickets = [...data.tickets]; // shallow copy
        const idx = tickets.findIndex(t => t.documentID === ticketID); // get the ticket to be purchased (passed in the metadata)
        if (idx === -1) throw new Error('Ticket not found during finalize.');

        // Shallow copy to not modify original data
        const ticket = { ...tickets[idx] };
        const pending = new Set(ticket.userWithTicketsOnHold || []);
        const holders = new Set(ticket.ticketHolders || []);

        // Remove the user from the userWithTicketOnHold array and add it to users with tickets
        pending.delete(attendeeUID);
        holders.add(attendeeUID);

        // Updat the ticket values
        ticket.userWithTicketsOnHold = Array.from(pending);
        ticket.ticketHolders         = Array.from(holders);
        tickets[idx] = ticket; // Upda the list of tickets

        // Make the firestore update to the event's document
        tx.update(eventRef, {
          tickets,
          eventTicketHolders: admin.firestore.FieldValue.arrayUnion(attendeeUID),
        });

        // Make the firestore update to the user's document
        tx.update(userRef, {
          tickets: admin.firestore.FieldValue.arrayUnion({
            eventID,
            ticketId: ticketID,
            purchasedAt: admin.firestore.Timestamp.now(),
          }),
        });
      });

      logger.info(`🎟️ Ticket ${ticketID} allocated to ${attendeeUID}`);
      break;
    }

    // ────────── Payment cancelled / failed ──────────
    case 'payment_intent.canceled':
    case 'payment_intent.payment_failed': {
      const paymentIntent = event.data.object;

      // Check that the necessary metadata arrived with the call
      const { eventID, ticketID, attendeeUID } = paymentIntent.metadata || {};
      if (!eventID || !ticketID || !attendeeUID) {
        logger.warn('⚠️ Missing metadata on failed/canceled intent');
        break;
      }

      // Get the event document reference to update
      const eventRef = admin.firestore().collection('events').doc(eventID);

      // Run transaction
      await admin.firestore().runTransaction(async (tx) => {
        
        // Get the event document, if it doesn't exists then no need to remove anything
        const snap = await tx.get(eventRef);
        if (!snap.exists) return; // nothing to clean

        // Check that the document contains data
        const data = snap.data();
        if (!data || !Array.isArray(data.tickets)) return;

        // Get the ticket, if the ticket doesn't exists, nothing to update
        const tickets = [...data.tickets];
        const idx = tickets.findIndex(t => t.documentID === ticketID);
        if (idx === -1) return;

        // Get the ticket and make a copy of it
        const ticket = { ...tickets[idx] };
        const pending = new Set(ticket.userWithTicketsOnHold || []);

        // Delet the ticket with the hold
        pending.delete(attendeeUID);

        // Copy the updated list back to the ticket
        ticket.userWithTicketsOnHold = Array.from(pending);

        // Update the tickets array
        tickets[idx] = ticket;

        // Update the document with the new list of tickets
        tx.update(eventRef, { tickets });
      });

      logger.info(`↩️ Hold released for ${attendeeUID} on ${ticketID}`);
      break;
    }
  }

  // Respond quickly; you’ll fill in logic later
  res.status(200).send('Received');
});