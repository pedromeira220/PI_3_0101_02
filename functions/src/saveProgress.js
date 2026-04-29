const functions = require("firebase-functions");

async function saveProgress(data, db) {
  const {deviceId, currentSequence} = data;
  if (!deviceId || currentSequence === undefined) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "deviceId and currentSequence are required",
    );
  }

  await db.collection("userProgress").doc(deviceId).set({
    currentSequence,
    updatedAt: new Date(),
  });

  const nextSequence = currentSequence + 1;
  const snapshot = await db.collection("locations")
      .where("sequence", "==", nextSequence)
      .limit(1)
      .get();

  if (snapshot.empty) {
    return {success: true, nextLocation: null, completed: true};
  }

  const doc = snapshot.docs[0];
  return {
    success: true,
    nextLocation: {id: doc.id, ...doc.data()},
    completed: false,
  };
}

module.exports = {saveProgress};
