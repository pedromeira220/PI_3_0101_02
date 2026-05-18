import {setGlobalOptions} from "firebase-functions";
import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

setGlobalOptions({maxInstances: 10});

admin.initializeApp();
const db = admin.firestore();

export const getLocations = onCall(async () => {
  const snapshot = await db.collection("locations").get();
  return snapshot.docs.map((doc) => ({id: doc.id, ...doc.data()}));
});

export const getOrCreatePlayer = onCall(async (request) => {
  const {uid} = request.data as {uid: string};

  const ref = db.doc(`players/${uid}/progress/data`);
  const snap = await ref.get();
  if (snap.exists) return snap.data();

  const locSnap = await db
    .collection("locations")
    .where("sequence", "==", 1)
    .limit(1)
    .get();
  const firstId = locSnap.empty ? "1" : locSnap.docs[0].id;

  const initial = {visited: [], unlocked: [firstId]};
  await ref.set(initial);
  return initial;
});

export const saveProgress = onCall(async (request) => {
  const {uid, visited, unlocked} = request.data as {
    uid: string;
    visited: string[];
    unlocked: string[];
  };
  await db.doc(`players/${uid}/progress/data`).set({visited, unlocked});
  return {success: true};
});

export const loadProgress = onCall(async (request) => {
  const {uid} = request.data as {uid: string};
  const snap = await db.doc(`players/${uid}/progress/data`).get();
  if (!snap.exists) return {visited: [], unlocked: []};
  return snap.data() ?? {visited: [], unlocked: []};
});

export const getInteractions = onCall(async () => {
  const snapshot = await db.collection("interactions").get();
  return snapshot.docs.map((doc) => ({locationId: doc.id, ...doc.data()}));
});
