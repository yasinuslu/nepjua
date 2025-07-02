import { $ as originalDollar, useBash } from "zx";

useBash();

export const $ = originalDollar;
