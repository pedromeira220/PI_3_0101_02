const functions = require("firebase-functions");

async function getNextLocation(data, db) {
  const {deviceId} = data;
  if (!deviceId) {
    throw new functions.https.HttpsError("invalid-argument", "deviceId is required");
  }

  const progressDoc = await db.collection("userProgress").doc(deviceId).get();
  const currentSequence = progressDoc.exists ? progressDoc.data().currentSequence : 0;

  const nextSequence = currentSequence + 1;
  const snapshot = await db.collection("locations")
      .where("sequence", "==", nextSequence)
      .limit(1)
      .get();

  if (snapshot.empty) {
    return {nextLocation: null, completed: true};
  }

  const doc = snapshot.docs[0];
  return {
    nextLocation: {id: doc.id, ...doc.data()},
    completed: false,
  };
}

module.exports = {getNextLocation};
