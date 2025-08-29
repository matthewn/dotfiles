// eslint.config.js
export default [
    {
        languageOptions: {
            ecmaVersion: 2024,
            sourceType: 'module',
            globals: {
                // add any global variables you use
                console: 'readonly',
                process: 'readonly'
            }
        },
        rules: {
            'no-unused-vars': 'error',
            'no-console': 'off',
            'indent': ['error', 4],
            'quotes': ['error', 'single'],
            'semi': ['error', 'always']
        }
    }
];
