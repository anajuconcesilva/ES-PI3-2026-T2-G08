import {initializeApp} from "firebase-admin/app";
initializeApp();
import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export * from "./auth";

export * from "./users";

export * from "./startups";

export * from "./wallet"

export * from "./transactions";

export * from "./trading";

export * from "./dashboard";