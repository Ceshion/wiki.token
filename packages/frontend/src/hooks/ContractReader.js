import { useState, useEffect } from "react";
import usePoller from "./Poller";

const DEBUG = false;

export default function useContractReader(
  contracts,
  contractName,
  functionName,
  args,
  pollTime,
  formatter,
  onChange,
) {
  let adjustPollTime = 1777;
  if (pollTime) {
    adjustPollTime = pollTime;
  } else if (!pollTime && typeof args === "number") {
    // it's okay to pass poll time as last argument without args for the call
    adjustPollTime = args;
  }

  const [value, setValue] = useState();
  useEffect(() => {
    if (typeof onChange === "function") {
      setTimeout(onChange.bind(this, value), 1);
    }
  }, [value, onChange]);

  usePoller(
    async () => {
      if (contracts && contracts[contractName]) {
        try {
          let newValue;
          if (DEBUG) console.log("CALLING ", contractName, functionName, "with args", args);
          if (args && args.length > 0) {
            newValue = await contracts[contractName][functionName](...args);
            if (DEBUG)
              console.log(
                "contractName",
                contractName,
                "functionName",
                functionName,
                "args",
                args,
                "RESULT:",
                newValue,
              );
          } else {
            newValue = await contracts[contractName][functionName]();
          }
          if (formatter && typeof formatter === "function") {
            newValue = formatter(newValue);
          }
          if (newValue !== value) {
            console.log("change! ", functionName);
            console.log("old: ", value);
            console.log("new: ", newValue);
            setValue(newValue);
          }
        } catch (e) {
          console.log(e);
        }
      }
    },
    adjustPollTime,
    contracts && contracts[contractName],
  );

  return value;
}
