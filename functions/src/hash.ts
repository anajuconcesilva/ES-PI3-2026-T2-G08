// hash.ts
import bcrypt from "bcryptjs";

bcrypt.hash("123456", 10).then(console.log);