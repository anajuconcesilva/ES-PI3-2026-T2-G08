import {db} from "../shared/firebase";

const usersCollection = db.collection("users");

export async function createUser(data: any) {
  await usersCollection.add(data);
}