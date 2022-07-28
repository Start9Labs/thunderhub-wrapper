import { compat, types as T } from "../deps.ts";

export const migration: T.ExpectedExports.migration = compat.migrations
  .fromMapping(
    {
      "0.13.14": {
        up: compat.migrations.updateConfig(
          (config) => {
            return config;
          },
          true,
          { version: "0.13.14", type: "up" },
        ),
        down: compat.migrations.updateConfig(
          (config) => {
            return config;
          },
          true,
          { version: "0.13.14", type: "down" },
        ),
      },
    },
    "0.13.14",
  );
