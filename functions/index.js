/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const axios = require("axios");
const QRCode = require('qrcode');
const admin = require('firebase-admin');

admin.initializeApp();

// exports.helloWorld = functions.https.onRequest((request, response) => {
//     response.send('Hello World');
// });
// exports.api = functions.https.onRequest( async (request, response) => {
//     switch (request.method) {
//         case 'GET':
//             const res = await axios.get('https://jsonplaceholder.typicode.com/users/1')
//             response.send(res.data.username);
//             break;
//         case 'POST':
//             const body = request.body;
//             response.send(body);
            
//             break;
//         case 'DELETE':
//             response.send('DELETE request received');
//             break;
//         default:
//             response.send('Default request received');
//     }
// });
// exports.userCreated = functions.auth.user().onCreate((user) => {
//     console.log('User Created:', user.email);
//     return Promise.resolve();
// });
// exports.userDeleted = functions.auth.user().onDelete((user) => {
//     console.log('User Deleted:', user.email);
//     return Promise.resolve();
// });
// exports.fruitsAdded = functions.firestore.document('fruits/{documentId}').onCreate((snapshot, context) => {
//     console.log('Fruit Added:', snapshot.data());
//     return Promise.resolve();
// });
// exports.fruitsDeleted = functions.firestore.document('fruits/{documentId}').onDelete((snapshot, context) => {
//     console.log('Fruit Deleted:', snapshot.data());
//     return Promise.resolve();
// });
// exports.fruitsUpdates= functions.firestore.document('fruits/{documentId}').onUpdate((snapshot, context) => {
//     console.log('Before:', snapshot.before.data());
//     console.log('After:', snapshot.after.data());
//     return Promise.resolve();
// });


exports.QRcodeGeneration = functions.auth.user().onCreate( async (user) => {
    
    // Get data from the user object
    const userID = user.uid;
    const userEmail = user.email;

    // Get the Firestore database
    const db = admin.firestore();

    try {

        // Generate the QR code
        const QRCodeURL = await QRCode.toDataURL(userID);

        // Store the QR code in the Firestore database
        // Store the QR code in the Firestore database
        await db.collection('users').doc(userID).set({
            qrCode: QRCodeURL,
        }, { merge: true });


    } catch (error) { // Catch any errors that occur
        console.error('Error generating or storing QR code:', error);
        throw new functions.https.HttpsError('internal', 'QR code generation failed');
   }
});