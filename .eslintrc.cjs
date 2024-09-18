/* eslint-disable no-undef */
/* eslint-disable unicorn/prefer-module */
const typescriptProject = ["./tsconfig.json"];

module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: typescriptProject,
  },
  settings: {
    "import/core-modules": ["bun:test"],
    "import/resolver": {
      typescript: {
        project: typescriptProject,
      },
      node: {
        project: typescriptProject,
      },
    },
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:unicorn/recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "plugin:prettier/recommended",
    "plugin:tailwindcss/recommended",
  ],
  rules: {
    "import/order": [
      "error",
      {
        "newlines-between": "always",
        distinctGroup: false,
        pathGroups: [
          {
            pattern: "@/**",
            group: "internal",
            position: "before",
          },
        ],
        groups: [
          "builtin",
          "external",
          "internal",
          "index",
          "type",
          "object",
          "parent",
          "sibling",
        ],
      },
    ],
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/consistent-type-imports": [
      "error",
      {
        prefer: "type-imports",
        disallowTypeAnnotations: false,
      },
    ],
    // allow unused vars prefixed with `_`
    "@typescript-eslint/no-unused-vars": [
      "error",
      { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
    ],
    "unicorn/no-null": "off",
    "unicorn/filename-case": [
      "error",
      {
        case: "kebabCase",
        ignore: [],
      },
    ],
    "unicorn/prevent-abbreviations": "off",
    "unicorn/no-array-callback-reference": "off",
    "unicorn/no-await-expression-member": "off",
    "unicorn/prefer-node-protocol": "off",
    "unicorn/consistent-function-scoping": [
      "error",
      { checkArrowFunctions: false },
    ],
    "unicorn/throw-new-error": "off",
    "unicorn/prefer-structured-clone": "off",
    "unicorn/prefer-string-raw": "off",

    // array-callback-return is recommended
    // See https://github.com/sindresorhus/eslint-plugin-unicorn/blob/v48.0.1/docs/rules/no-useless-undefined.md
    "unicorn/no-useless-undefined": ["error", { checkArguments: false }],
    "array-callback-return": [
      "error",
      {
        allowImplicit: true,
      },
    ],
    "unicorn/no-array-reduce": ["error", { allowSimpleOperations: true }],
    "import/no-relative-packages": "error",
  },
};
