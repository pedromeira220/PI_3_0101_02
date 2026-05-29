import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

interface DialogOptionData {
  text: string;
  nextStep: number;
}

interface DialogStepData {
  speaker?: string;
  characterImage?: string;
  text: string;
  options?: DialogOptionData[];
}

interface InteractionData {
  locationId: string;
  dialogs: DialogStepData[];
  musicPath?: string | null;
  unlockHint?: string | null;
}

const keyPath = path.resolve(__dirname, "../../serviceAccountKey.json");

if (fs.existsSync(keyPath)) {
  admin.initializeApp({credential: admin.credential.cert(keyPath)});
} else {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: "teste-pedro-16cfe",
  });
}

const db = admin.firestore();

// eslint-disable-next-line require-jsdoc
async function seed(): Promise<void> {
  const dataPath = path.resolve(__dirname, "../../seed/interactions.json");
  const interactions = JSON.parse(
    fs.readFileSync(dataPath, "utf8")
  ) as InteractionData[];

  const batch = db.batch();
  for (const item of interactions) {
    const ref = db.collection("interactions").doc(item.locationId);
    batch.set(ref, item);
  }
  await batch.commit();
  console.log(`✓ ${interactions.length} interações salvas no Firestore.`);
}

seed().catch((err: unknown) => {
  console.error("Erro ao executar seed:", err);
  process.exit(1);
});
