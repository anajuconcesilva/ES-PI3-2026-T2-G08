import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export * from "./auth";

export * from "./users";

export * from "./startups";