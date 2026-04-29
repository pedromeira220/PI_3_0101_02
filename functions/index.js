const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {getNextLocation} = require("./src/getNextLocation");
const {saveProgress} = require("./src/saveProgress");

admin.initializeApp();

exports.getNextLocation = functions.https.onCall(async (request) => {
  return await getNextLocation(request.data, admin.firestore());
});

exports.saveProgress = functions.https.onCall(async (request) => {
  return await saveProgress(request.data, admin.firestore());
});
