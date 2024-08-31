import prettier from "eslint-plugin-prettier";
import security from "eslint-plugin-security";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default [
    ...compat.extends("eslint:recommended", "plugin:@typescript-eslint/recommended"),
    {
        plugins: {
            prettier,
            security,
            "@typescript-eslint": typescriptEslint,
        },

        languageOptions: {
            globals: {
                ...globals.jest,
                ...globals.node,
            },

            parser: tsParser,
            ecmaVersion: 2020,
            sourceType: "module",
        },

        rules: {
            "prettier/prettier": "error",
            semi: ["warn", "never"],

            "newline-per-chained-call": ["off", {
                ignoreChainWithDepth: 2,
            }],

            "global-require": "off",
            "arrow-parens": "off",
            "arrow-body-style": "off",
            "comma-dangle": "off",
            "func-names": "off",
            "no-use-before-define": "off",
            camelcase: "off",
            "no-plusplus": "off",
            "consistent-return": "off",
            "security/detect-object-injection": "off",
            "security/detect-non-literal-fs-filename": "off",

            "no-unused-vars": ["error", {
                vars: "all",
                args: "all",
                argsIgnorePattern: "^_",
                caughtErrors: "all",
                caughtErrorsIgnorePattern: "^_",
                destructuredArrayIgnorePattern: "^_",
                varsIgnorePattern: "^_",
                ignoreRestSiblings: true,
            }],

            "prefer-destructuring": ["off", {
                array: true,
                object: true,
            }, {
                enforceForRenamedProperties: false,
            }],

            "@typescript-eslint/no-unused-vars": ["error", {
                args: "all",
                argsIgnorePattern: "^_",
                caughtErrors: "all",
                caughtErrorsIgnorePattern: "^_",
                destructuredArrayIgnorePattern: "^_",
                varsIgnorePattern: "^_",
                ignoreRestSiblings: true,
            }],
        },
    },
    {
        files: ["**/*.ts", "**/*.tsx"],

        languageOptions: {
            parser: tsParser,
            ecmaVersion: 5,
            sourceType: "script",

            parserOptions: {
                project: "./tsconfig.json",
            },
        },

        rules: {
            "@typescript-eslint/ban-ts-comment": "off",
            "no-unused-vars": "off",
            semi: "off",
        },
    },
    {
        files: ["**/*.js", "**/*.jsx"],

        rules: {
            "@typescript-eslint/no-var-requires": "off",
            "@typescript-eslint/no-unused-vars": "off",
            "@typescript-eslint/explicit-module-boundary-types": "off",
        },
    },
];