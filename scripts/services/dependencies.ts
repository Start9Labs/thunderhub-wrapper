import { matches, types as T } from "../deps.ts";

const { shape, arrayOf, string, boolean } = matches;

const matchLndConfig = shape({

});

function times<T>(fn: (i: number) => T, amount: number): T[] {
  const answer = new Array(amount);
  for (let i = 0; i < amount; i++) {
    answer[i] = fn(i);
  }
  return answer;
}

function randomItemString(input: string) {
  return input[Math.floor(Math.random() * input.length)];
}

const serviceName = "thunderhub";
const fullChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
type Check = {
  currentError(config: T.Config): string | void;
  fix(config: T.Config): T.Config;
};

export const dependencies: T.ExpectedExports.dependencies = {
    lnd: {
        async check(effects, configInput) {
            effects.info("check lnd");
            const config = matchLndConfig.unsafeCast(configInput);
            return { result: null };
        },
        async autoConfigure(effects, configInput) {
            effects.info("autoconfigure lnd");
            const config = matchLndConfig.unsafeCast(configInput);
            return { result: config };
        },
    },
};
