// Código feito por Felipe Lima Miranda, RA: 25023932
import {db} from "../shared/firebase";

const usersCollection = db.collection("users");

export async function createUser(data: any) {
  await usersCollection.add(data);
}