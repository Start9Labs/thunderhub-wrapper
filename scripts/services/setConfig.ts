import {
  compat,
  types as T
} from "../deps.ts";
export const setConfig: T.ExpectedExports.setConfig = async (effects, input ) => {

  const depsLnd: T.DependsOn = {lnd: ['synced']}

  return await compat.setConfig(effects,input, {
    ...depsLnd,
  })
}
