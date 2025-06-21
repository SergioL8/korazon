const {onCall} = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const sgMail = require("@sendgrid/mail");
const admin = require("firebase-admin");
require("dotenv").config();
const axios = require('axios');
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');
const secretClient = new SecretManagerServiceClient();
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



exports.freeTicketTransaction = functions.https.onRequest(async (req, res) => {
  // --- (A) Authenticate the user manually via ID token: ---
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing Authorization header." });
  }
  let decoded;
  try {
    const idToken = authHeader.split("Bearer ")[1];
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    return res.status(401).json({ error: "Invalid or expired ID token." });
  }
  const attendeeUID = decoded.uid;

  // --- (B) Parse and validate eventID/ticketID from the request body: ---
  const { eventID, ticketID } = req.body || {};
  if (typeof eventID !== "string" || typeof ticketID !== "string") {
    return res.status(400).json({ error: "eventID and ticketID must be provided." });
  }

  // --- (C) Run the exact same transaction you had in Dart, now in JS: ---
  const db = admin.firestore();
  const eventRef = db.collection("events").doc(eventID);
  const userRef = db.collection("users").doc(attendeeUID);

  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(eventRef);
      if (!snap.exists) throw new Error("Event missing during finalize.");

      const data = snap.data();
      if (!data || !Array.isArray(data.tickets)) {
        throw new Error("Tickets missing during finalize.");
      }
      const tickets = [...data.tickets];
      const idx = tickets.findIndex((t) => t.documentID === ticketID);
      if (idx === -1) throw new Error("Ticket not found during finalize.");

      // Copy and update the specific ticket
      const ticket = { ...tickets[idx] };
      const pending = Array.isArray(ticket.userWithTicketsOnHold)
        ? [...ticket.userWithTicketsOnHold]
        : [];
      const holders = Array.isArray(ticket.ticketHolders)
        ? [...ticket.ticketHolders]
        : [];

      // Remove from pending and add to holders
      const pIndex = pending.indexOf(attendeeUID);
      if (pIndex !== -1) pending.splice(pIndex, 1);
      if (!holders.includes(attendeeUID)) holders.push(attendeeUID);

      ticket.userWithTicketsOnHold = pending;
      ticket.ticketHolders = holders;
      tickets[idx] = ticket;

      // Update event doc
      tx.update(eventRef, {
        tickets: tickets,
        eventTicketHolders: admin.firestore.FieldValue.arrayUnion(attendeeUID),
      });

      // Update user doc
      tx.update(userRef, {
        tickets: admin.firestore.FieldValue.arrayUnion({
          eventId: eventID,
          ticketId: ticketID,
          purchasedAt: admin.firestore.Timestamp.now(),
        }),
      });
    });

    // --- (D) If it succeeds, send back a 200 response: ---
    return res.status(200).json({ success: true });
  } catch (err) {
    // Any thrown error inside the transaction ends up here:
    console.error("Free ticket transaction failed:", err);
    return res.status(400).json({ error: err.message });
  }
});




// Static Map Image endpoint: returns a PNG of a marker at the given lat/lng
exports.getStaticMapImage = onRequest(async (req, res) => {
  try {
    // Get arguments and check that lat and lon were provided
    const { lat, lng, zoom = '15', width = '300', height = '200' } = req.query;
    if (!lat || !lng) {
      return res.status(400).send('Missing lat or lng parameter');
    }

    // Retrieve API key from Secret Manager
    const [version] = await secretClient.accessSecretVersion({ name: `projects/korazon-dc77a/secrets/google-maps-staticmap-api-key/versions/latest`, });
    const apiKey = version.payload.data.toString('utf8');

    // Build the Static Maps URL
    const mapUrl = [
      'https://maps.googleapis.com/maps/api/staticmap',
      `?center=${lat},${lng}`,
      `&zoom=${zoom}`,
      `&size=${width}x${height}`,
      `&markers=color:0xFF177C%7C${lat},${lng}`,
      `&key=${apiKey}`,

      // hide everything
      '&style=feature:all|element:labels|visibility:off',
      '&style=feature:all|element:labels.icon|visibility:off',
      '&style=feature:poi|visibility:off',
      '&style=feature:transit|visibility:off',
      '&style=feature:water|visibility:off',
      '&style=feature:administrative|visibility:off',
      '&style=feature:landscape|visibility:off',
      
      // ensure map geometry still visible
      '&style=feature:all|element:geometry|visibility:on',

      // show only road names
      '&style=feature:road|element:labels.text.fill|visibility:on',
      '&style=feature:road|element:labels.text.stroke|visibility:on',

      // Dark-mode styling:
      '&style=feature:all|element:geometry|color:0x121212',
      '&style=feature:water|element:geometry|color:0x0f0f0f',
      '&style=feature:landscape|element:geometry|color:0x181818',
      '&style=feature:road.highway|element:geometry|color:0x3a3a3a',
      '&style=feature:road.arterial|element:geometry|color:0x343434',
      '&style=feature:road.local|element:geometry|color:0x2e2e2e',
      '&style=feature:road|element:labels.text.fill|color:0xffffff',
      '&style=feature:road|element:labels.text.stroke|color:0x121212',
      '&style=feature:all|element:labels.icon|visibility:off',
      '&style=feature:poi|visibility:off',
      '&style=feature:transit|visibility:off',
      '&style=feature:administrative|visibility:off',

    ].join('');

    // Fetch the image bytes
    const response = await axios.get(mapUrl, { responseType: 'arraybuffer' });

    console.log('Response: ', response);

    // Set caching headers
    res.set('Content-Type', 'image/png');
    res.set('Cache-Control', 'public, max-age=3600, s-maxage=86400');

    // Send the image
    res.status(200).send(response.data);
  } catch (error) {
    console.error('Error fetching static map image:', error);
    res.status(500).send('Internal Server Error');
  }
});