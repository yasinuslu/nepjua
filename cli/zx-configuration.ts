import { $, quote, useBash } from "zx";

useBash();
$.verbose = true;
$.shell = "bash";

export const zxConfiguration = {
  verbose: true,
  shell: "bash",
  quote,
};
